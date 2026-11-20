--[[
	Variables file for end4-pC configuration
	This file is managed by the install script - do not edit manually unless you know what you're doing
]]

-- Quickshell configuration name
hl.env("qsConfig", "end4-pC")

-- Hyprland general settings
hl.config({
	-- Monitor settings
	monitor = {
		-- Auto-detect monitors
		preferred = "auto",
		-- Fallback for when no monitor is detected
		fallback = "1920x1080@60",
	},

	-- Input settings
	input = {
		kb_layout = "us",
		kb_variant = "",
		kb_options = "grp:alt_shift_toggle",
		kb_model = "",
		follow_mouse = 1,
		touchpad = {
			natural_scroll = false,
			tap_to_click = true,
			drag_lock = false,
			disable_while_typing = true,
		},
	},

	-- General behavior
	general = {
		gaps_in = 5,
		gaps_out = 10,
		border_size = 2,
		col_active_border = "rgba(898989ee)",
		col_inactive_border = "rgba(313131ee)",
		resize_on_border = true,
		allow_tearing = false,
		layout = "dwindle",
		no_focus_fallback = true,
		focus_on_activate = true,
	},

	-- Decoration
	decoration = {
		rounding = 12,
		blur = {
			enabled = true,
			size = 8,
			passes = 3,
			new_optimizations = true,
		},
		drop_shadow = true,
		shadow_range = 15,
		shadow_render_power = 3,
		shadow_offset = { 0, 3 },
	},

	-- Animations
	animations = {
		enabled = true,
		bezier = "easeOutExpo",
		speed = 1.0,
	},

	-- Gestures
	gestures = {
		enabled = true,
		workspace_swipe = true,
		fingers = 3,
	},

	-- Input
	input = {
		sensitivity = 0.5,
		accel_profile = "flat",
	},

	-- Misc
	misc = {
		vfr = true,
		cursor_inactive_timeout = 0,
		allow_session_lock_restore = true,
	},
})

-- Keybindings are in keybinds.lua
-- Window rules are in windowrules.lua
-- Monitors are in monitors.lua
-- Autostart is in autostart.lua

-- Environment variables
hl.env("XCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "bibata-modern-ice")
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("_JAVA_AWT_WM_NONREPARENTING", "1")

-- NVIDIA specific
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("VDPAU_DRIVER", "nvidia")
hl.env("NVD_BACKEND", "direct")
hl.env("__GL_GSYNC_ALLOWED", "1")
hl.env("__GL_VRR_ALLOWED", "1")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")

-- GBM/GBM_BACKEND for NVIDIA
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")