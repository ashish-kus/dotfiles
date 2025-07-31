-- camera.lua
-- Save this file to: ~/.config/mpv/scripts/camera.lua

-- Set where screenshots will be saved
local screenshot_path = os.getenv("HOME") .. "/Pictures/camera/"
os.execute("mkdir -p " .. screenshot_path)

-- 🔊 Function to play a camera shutter sound
local function play_click()
	-- You can replace this with another sound path if needed
	os.execute("paplay /usr/share/sounds/freedesktop/stereo/camera-shutter.oga &")
end

-- 📸 Take screenshot with timestamp
mp.add_key_binding("s", "take_screenshot", function()
	local time = os.date("%Y-%m-%d_%H-%M-%S")
	local filename = screenshot_path .. "snapshot_" .. time .. ".png"
	mp.commandv("screenshot-to-file", filename)
	play_click()
	mp.osd_message("📸 Saved: " .. filename)
end)

-- ❌ Quit mpv
mp.add_key_binding("q", "quit_mpv", function()
	mp.command("quit")
end)

-- ☀️ Brightness increase
mp.add_key_binding("UP", "brightness_up", function()
	mp.command("add brightness 5")
	mp.osd_message("Brightness +5")
end)

-- 🌙 Brightness decrease
mp.add_key_binding("DOWN", "brightness_down", function()
	mp.command("add brightness -5")
	mp.osd_message(" Brightness -5")
end)

-- 🖼️ Show help when script loads
mp.osd_message(" Press 's' to capture, ↑/↓ to adjust brightness, 'q' to quit", 5)
