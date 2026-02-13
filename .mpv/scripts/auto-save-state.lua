-- 智能保存播放位置
-- 当视频接近开头/结尾时，不保存位置（避免重新打开时从头/尾开始）
-- 播放列表模式下总是保存位置

local mp = require 'mp'
local msg = require 'mp.msg'
local opts = require 'mp.options'

-- 配置选项
local o = {
    thresh_end = 180,    -- 距离结尾多少秒内不保存
    thresh_start = 60,   -- 距离开头多少秒内不保存
}
opts.read_options(o)

-- 检查是否为播放列表模式
local function is_playlist_mode()
    local count = mp.get_property_number("playlist-count", 1)
    return count > 1
end

-- 检查当前播放时间是否不在开头/结尾附近
local function should_save_position()
    -- 播放列表模式下总是保存
    if is_playlist_mode() then
        return true
    end
    
    local remaining = mp.get_property_number("time-remaining", 0)
    local pos = mp.get_property_number("time-pos", 0)
    local duration = mp.get_property_number("duration", 0)
    
    -- 无法获取时间信息时，保守起见保存位置
    if duration <= 0 then
        return true
    end
    
    -- 不在开头附近且不在结尾附近
    return pos > o.thresh_start and remaining > o.thresh_end
end

-- 绑定快捷键：智能退出
mp.add_forced_key_binding("Q", "quit-watch-later-conditional", function()
    local save = should_save_position()
    mp.set_property_bool("options/save-position-on-quit", save)
    
    if save then
        msg.info("保存播放位置并退出")
    else
        msg.info("不保存播放位置（接近开头/结尾）")
    end
    
    mp.command("quit")
end)

-- 同时绑定小写 q 为普通退出（不保存）
mp.add_forced_key_binding("q", "quit-no-save", function()
    mp.set_property_bool("options/save-position-on-quit", false)
    mp.command("quit")
end)
