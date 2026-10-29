import datetime
import subprocess
from kitty.boss import get_boss
from kitty.fast_data_types import Screen, get_options, add_timer
from kitty.tab_bar import (
    DrawData,
    ExtraData,
    Formatter,
    TabBarData,
    as_rgb,
    draw_attributed_string,
    draw_tab_with_powerline,
)
from kitty.utils import color_as_int

opts = get_options()

CLOCK_FG = as_rgb(color_as_int(opts.active_tab_foreground))
CLOCK_BG = as_rgb(color_as_int(opts.active_tab_background))

def get_battery_info():
    try:
        result = subprocess.run(["pmset", "-g", "batt"], capture_output=True, text=True)
        output = result.stdout

        battery_level = None
        charging_status = None
        time_to_full = None

        for line in output.splitlines():
            if "InternalBattery" in line:
                parts = line.split("\t")[1].split("; ")
                battery_level = int(parts[0].replace("%", ""))
                charging_status = parts[1].strip()
                if len(parts) > 2:
                    time_to_full = parts[2].strip()

        return {
            "battery_level": battery_level,
            "charging_status": charging_status,
            "time_to_full": time_to_full
        }
    except Exception as e:
        print(f"Error getting battery info: {e}")
    return None

def _draw_right_status(screen: Screen, is_last: bool, draw_data: DrawData) -> int:
    if not is_last:
        return screen.cursor.x

    draw_attributed_string(Formatter.reset, screen)
    battery_info = get_battery_info()
    percent = battery_info['battery_level']
    cells = [
        (CLOCK_FG, CLOCK_BG, str(percent) + "% "),
        (CLOCK_FG, CLOCK_BG, datetime.datetime.now().strftime("%H:%M ")),
    ]

    right_status_length = 0
    for _, _, cell in cells:
        right_status_length += len(cell)

    draw_spaces = screen.columns - screen.cursor.x - right_status_length
    if draw_spaces > 0:
        screen.draw(" " * draw_spaces)

    for fg, bg, cell in cells:
        screen.draw(cell)

    screen.cursor.x = max(screen.cursor.x, screen.columns - right_status_length)
    return screen.cursor.x

def _redraw_tab_bar(_) -> None:
    tm = get_boss().active_tab_manager
    if tm is not None:
        tm.mark_tab_bar_dirty()

timer_id = None

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
    end = draw_tab_with_powerline(
        draw_data, screen, tab, before, max_title_length, index, is_last, extra_data
    )
    global timer_id
    if timer_id is None:
        timer_id = add_timer(_redraw_tab_bar, 2.0, True)
    end = _draw_right_status(screen, is_last, draw_data)
    return end
