-- OSD 时钟显示
-- 定期显示当前时间，支持自定义格式和间隔

local mp = require "mp"
local msg = require "mp.msg"
local utils = require "mp.utils"
local options = require "mp.options"

-- 默认配置
local cfg = {
    interval = "15m",    -- 显示间隔
    format = "%H:%M",    -- 时间格式
    duration = 2.5,      -- OSD 显示时长
    key = "h",           -- 手动触发快捷键
    name = "show-clock", -- 命令名
}

-- 读取用户配置 ~/.config/mpv/script-opts/osd-clock.conf
options.read_options(cfg, "osd-clock")

-- 将人类可读时间转换为秒 (如 "1h30m" → 5400)
local function parse_time(str)
    local num = tonumber(str)
    if num then
        return num
    end
    
    local total = 0
    for value, unit in str:gmatch("(%d+)([hms])") do
        local mult = ({ h = 3600, m = 60, s = 1 })[unit] or 1
        total = total + tonumber(value) * mult
    end
    return total > 0 and total or 900  -- 默认15分钟
end

-- 计算对齐到下一个间隔的延迟
local function calc_delay(interval)
    local now = os.time()
    return interval * math.ceil(now / interval) - now
end

-- 显示时钟
local function show_clock()
    mp.osd_message(os.date(cfg.format), cfg.duration)
end

-- 主逻辑
local interval_sec = parse_time(cfg.interval)

if interval_sec <= 0 then
    msg.warn("间隔无效，OSD时钟已禁用")
    return
end

msg.info(string.format("OSD时钟已启动: 间隔=%ds, 格式=%s", interval_sec, cfg.format))

-- 创建定时器但不启动
local timer = mp.add_periodic_timer(interval_sec, show_clock)
timer:stop()

-- 对齐到整点启动
local delay = calc_delay(interval_sec)
mp.add_timeout(delay, function()
    timer:resume()
    show_clock()
end)

msg.verbose(string.format("首次显示将在 %d 秒后", delay))

-- 绑定手动触发键
if cfg.key and cfg.key ~= "" then
    mp.add_key_binding(cfg.key, cfg.name, show_clock)
    msg.verbose(string.format("已绑定 '%s' 键到 %s", cfg.key, cfg.name))
end
