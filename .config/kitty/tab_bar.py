# ~/.config/kitty/tab_bar.py

import subprocess
import time
from datetime import datetime

from kitty.fast_data_types import Screen, add_timer, get_boss
from kitty.tab_bar import DrawData, ExtraData, TabBarData, as_rgb
from kitty.utils import color_as_int

ACCENT = as_rgb(0x4AA3DF)      # 活动标签序号（蓝）
ACTIVE_FG = as_rgb(0xECF0F1)   # 活动标签标题
DIM_FG = as_rgb(0x767676)      # 非活动标签 / 右侧状态
ALERT_FG = as_rgb(0xF1C40F)    # 有响铃/活动提示（黄）
GAP = "  "                    # 标签之间的间距
SHOW_GIT = True
SHOW_TIME = True
TIME_FORMAT = "%H:%M"
REFRESH_SECONDS = 5.0

_timer_id = None
_git_cache = {"cwd": None, "branch": "", "ts": 0.0}


def _redraw(_):
    tm = get_boss().active_tab_manager
    if tm is not None:
        tm.mark_tab_bar_dirty()


def _git_branch() -> str:
    window = get_boss().active_window
    cwd = window.cwd_of_child if window else None
    if not cwd:
        return ""
    now = time.time()
    if _git_cache["cwd"] == cwd and now - _git_cache["ts"] < 3:
        return _git_cache["branch"]
    branch = ""
    try:
        out = subprocess.run(
            ["git", "-C", cwd, "rev-parse", "--abbrev-ref", "HEAD"],
            capture_output=True, text=True, timeout=0.3,
        )
        if out.returncode == 0:
            branch = out.stdout.strip()
    except Exception:
        pass
    _git_cache.update(cwd=cwd, branch=branch, ts=now)
    return branch


def _draw_right(screen: Screen, is_last: bool) -> None:
    if not is_last:
        return
    parts = []
    if SHOW_GIT:
        b = _git_branch()
        if b:
            parts.append(b)
    if SHOW_TIME:
        parts.append(datetime.now().strftime(TIME_FORMAT))
    if not parts:
        return
    text = "  ·  ".join(parts) + "  "
    spaces = screen.columns - screen.cursor.x - len(text)
    if spaces <= 0:
        return
    screen.cursor.bold = False
    screen.cursor.fg = DIM_FG
    screen.draw(" " * spaces + text)
    screen.cursor.fg = 0


def draw_tab(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    global _timer_id
    if _timer_id is None:
        _timer_id = add_timer(_redraw, REFRESH_SECONDS, True)

    bar_bg = as_rgb(color_as_int(draw_data.default_bg))
    screen.cursor.bg = bar_bg

    if index == 1:
        screen.draw("  ")

    alert = tab.needs_attention or tab.has_activity_since_last_focus
    num_fg = ACCENT if tab.is_active else (ALERT_FG if alert else DIM_FG)
    title_fg = ACTIVE_FG if tab.is_active else DIM_FG

    room = max_title_length - len(str(index)) - 1
    title = tab.title
    if room > 1 and len(title) > room:
        title = title[: room - 1] + "…"

    screen.cursor.bold = tab.is_active
    screen.cursor.fg = num_fg
    screen.draw(str(index))
    screen.cursor.fg = title_fg
    screen.draw(f" {title}")

    screen.cursor.bold = False
    screen.cursor.fg = 0
    if not is_last:
        screen.draw(GAP)

    _draw_right(screen, is_last)
    return screen.cursor.x
