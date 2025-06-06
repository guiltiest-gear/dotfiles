-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- Load vicious
local vicious = require("vicious")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
  naughty.notify({
    preset = naughty.config.presets.critical,
    title = "Oops, there were errors during startup!",
    text = awesome.startup_errors,
  })
end

-- Handle runtime errors after startup
do
  local in_error = false
  awesome.connect_signal("debug::error", function(err)
    -- Make sure we don't go into an endless error loop
    if in_error then
      return
    end
    in_error = true

    naughty.notify({
      preset = naughty.config.presets.critical,
      title = "Oops, an error happened!",
      text = tostring(err),
    })
    in_error = false
  end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_themes_dir() .. "xresources/theme.lua")

-- Set the gap
beautiful.useless_gap = 3

-- Make the taglist use noto fonts instead
beautiful.taglist_font = "Noto Sans CJK Black 8"

-- Use hack nerd mono for the default font
beautiful.font = "Hack Nerd Font Mono Regular 8"

-- This is used later as the default terminal and editor to run.
terminal = "kitty -1"

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"
alt = "Mod1"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
  -- awful.layout.suit.floating,
  awful.layout.suit.spiral.dwindle,
  awful.layout.suit.spiral,
  awful.layout.suit.tile,
  awful.layout.suit.tile.left,
  awful.layout.suit.tile.bottom,
  awful.layout.suit.tile.top,
  awful.layout.suit.fair,
  awful.layout.suit.fair.horizontal,
  -- awful.layout.suit.max,
  -- awful.layout.suit.max.fullscreen,
  awful.layout.suit.magnifier,
  awful.layout.suit.corner.nw,
  -- awful.layout.suit.corner.ne,
  -- awful.layout.suit.corner.sw,
  -- awful.layout.suit.corner.se,
}

datewidget = wibox.widget.textclock("%B %d %G, %r", 1)
month_calendar = awful.widget.calendar_popup.month({
  start_sunday = true,
  position = "tr",
  long_weekdays = true,
})
month_calendar:attach(datewidget)

memwidget = wibox.widget.textbox()
vicious.cache(vicious.widgets.mem)
vicious.register(memwidget, vicious.widgets.mem, "Mem: $1% | Swp: $5%", 10)

cpuwidget = wibox.widget.textbox()
vicious.cache(vicious.widgets.cpu)
vicious.register(cpuwidget, vicious.widgets.cpu, "CPU: $1%", 10)

fswidget = wibox.widget.textbox()
vicious.cache(vicious.widgets.fs)
vicious.register(fswidget, vicious.widgets.fs, "/ ${/ used_p}%")

wifiwidget = wibox.widget.textbox()
vicious.cache(vicious.widgets.wifi)
vicious.register(
  wifiwidget,
  vicious.widgets.wifiiw,
  "${ssid} ${rate}Mb/s",
  1,
  "wlo1"
)

volumewidget = wibox.widget.textbox()
vicious.cache(vicious.widgets.volume)
vicious.register(
  volumewidget,
  vicious.widgets.volume,
  "VOL: $1%",
  1,
  { "Master", "-D", "pulse" }
)

batwidget = wibox.widget.textbox()
vicious.cache(vicious.widgets.bat)
vicious.register(batwidget, vicious.widgets.bat, "BAT: $2%", 60, "BAT1")

spacer = wibox.widget.textbox("|")

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
  awful.button({}, 1, function(t)
    t:view_only()
  end),
  awful.button({ modkey }, 1, function(t)
    if client.focus then
      client.focus:move_to_tag(t)
    end
  end),
  awful.button({}, 3, awful.tag.viewtoggle),
  awful.button({ modkey }, 3, function(t)
    if client.focus then
      client.focus:toggle_tag(t)
    end
  end),
  awful.button({}, 4, function(t)
    awful.tag.viewnext(t.screen)
  end),
  awful.button({}, 5, function(t)
    awful.tag.viewprev(t.screen)
  end)
)

local tasklist_buttons = gears.table.join(
  awful.button({}, 1, function(c)
    if c == client.focus then
      c.minimized = true
    else
      c:emit_signal("request::activate", "tasklist", { raise = true })
    end
  end),
  awful.button({}, 3, function()
    awful.menu.client_list({ theme = { width = 250 } })
  end),
  awful.button({}, 4, function()
    awful.client.focus.byidx(1)
  end),
  awful.button({}, 5, function()
    awful.client.focus.byidx(-1)
  end)
)

local function set_wallpaper(s)
  gears.wallpaper.maximized(
    gears.filesystem.get_configuration_dir() .. "wallpaper.png",
    s,
    true
  )
end

-- Re-set the wallpaper when a screen's geometry changes
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
  -- Set the wallpaper
  set_wallpaper(s)

  -- Each screen has its own tag table.
  awful.tag(
    -- { "1", "2", "3", "4", "5", "6", "7", "8", "9" },
    { "一", "二", "三", "四", "五", "六", "七", "八", "九" },
    s,
    awful.layout.layouts[1]
  )

  -- Create a promptbox for each screen
  s.mypromptbox = awful.widget.prompt()
  -- Create an imagebox widget which will contain an icon indicating which layout we're using.
  -- We need one layoutbox per screen.
  s.mylayoutbox = awful.widget.layoutbox(s)
  s.mylayoutbox:buttons(gears.table.join(
    awful.button({}, 1, function()
      awful.layout.inc(1)
    end),
    awful.button({}, 3, function()
      awful.layout.inc(-1)
    end),
    awful.button({}, 4, function()
      awful.layout.inc(1)
    end),
    awful.button({}, 5, function()
      awful.layout.inc(-1)
    end)
  ))
  -- Create a taglist widget
  s.mytaglist = awful.widget.taglist({
    screen = s,
    filter = awful.widget.taglist.filter.all,
    buttons = taglist_buttons,
  })

  -- Create a tasklist widget
  s.mytasklist = awful.widget.tasklist({
    screen = s,
    filter = awful.widget.tasklist.filter.currenttags,
    buttons = tasklist_buttons,
  })

  -- Create the wibox
  s.mywibox = awful.wibar({ position = "top", screen = s })

  -- Add widgets to the wibox
  s.mywibox:setup({
    layout = wibox.layout.align.horizontal,
    { -- Left widgets
      layout = wibox.layout.fixed.horizontal,
      s.mytaglist,
      s.mypromptbox,
    },
    s.mytasklist, -- Middle widget
    { -- Right widgets
      layout = wibox.layout.fixed.horizontal,
      spacing = 5,
      wibox.widget.systray(),
      wifiwidget,
      spacer,
      volumewidget,
      spacer,
      fswidget,
      spacer,
      cpuwidget,
      spacer,
      memwidget,
      spacer,
      batwidget,
      spacer,
      datewidget,
      s.mylayoutbox,
    },
  })
end)
-- }}}

-- {{{ Mouse bindings
--[[ root.buttons(gears.table.join(
  awful.button({}, 3, function()
    mymainmenu:toggle()
  end),
  awful.button({}, 4, awful.tag.viewnext),
  awful.button({}, 5, awful.tag.viewprev)
)) ]]
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
  awful.key(
    { modkey },
    "s",
    hotkeys_popup.show_help,
    { description = "show help", group = "awesome" }
  ),
  awful.key(
    { modkey },
    "[",
    awful.tag.viewprev,
    { description = "view previous", group = "tag" }
  ),
  awful.key(
    { modkey },
    "]",
    awful.tag.viewnext,
    { description = "view next", group = "tag" }
  ),
  awful.key(
    { modkey },
    "Escape",
    awful.tag.history.restore,
    { description = "go back", group = "tag" }
  ),

  awful.key({ modkey, "Control" }, "j", function()
    awful.screen.focus_relative(1)
  end, { description = "Focus to the next screen", group = "screen" }),
  awful.key({ modkey, "Control" }, "k", function()
    awful.screen.focus_relative(-1)
  end, { description = "Focus to the previous screen", group = "screen" }),

  --[[ awful.key({ modkey, "Shift" }, "j", function()
		awful.client.swap.byidx(1)
	end, { description = "swap with next client by index", group = "client" }),
	awful.key({ modkey, "Shift" }, "k", function()
		awful.client.swap.byidx(-1)
	end, { description = "swap with previous client by index", group = "client" }),
	awful.key({ modkey, "Control" }, "j", function()
		awful.screen.focus_relative(1)
	end, { description = "focus the next screen", group = "screen" }),
	awful.key({ modkey, "Control" }, "k", function()
		awful.screen.focus_relative(-1)
	end, { description = "focus the previous screen", group = "screen" }), ]]
  awful.key(
    { modkey },
    "u",
    awful.client.urgent.jumpto,
    { description = "jump to urgent client", group = "client" }
  ),
  awful.key({ modkey }, "Tab", function()
    awful.client.focus.history.previous()
    if client.focus then
      client.focus:raise()
    end
  end, { description = "go back", group = "client" }),

  -- Standard program
  awful.key({ modkey }, "Return", function()
    awful.spawn(terminal)
  end, { description = "open a terminal", group = "launcher" }),
  awful.key(
    { modkey, "Control" },
    "r",
    awesome.restart,
    { description = "reload awesome", group = "awesome" }
  ),
  awful.key(
    { modkey, "Shift" },
    "q",
    awesome.quit,
    { description = "quit awesome", group = "awesome" }
  ),

  awful.key({ modkey }, "space", function()
    awful.layout.inc(1)
  end, { description = "select next", group = "layout" }),
  awful.key({ modkey, "Shift" }, "space", function()
    awful.layout.inc(-1)
  end, { description = "select previous", group = "layout" }),

  awful.key({ modkey, "Control" }, "n", function()
    local c = awful.client.restore()
    -- Focus restored client
    if c then
      c:emit_signal("request::activate", "key.unminimize", { raise = true })
    end
  end, { description = "restore minimized", group = "client" }),

  -- Prompt
  awful.key({ modkey }, "r", function()
    awful.spawn({ "j4-dmenu-desktop", "--dmenu=/usr/local/bin/dmenu" })
  end, { description = "run prompt", group = "launcher" }),

  -- dmenu_run prompt
  awful.key({ modkey, alt }, "r", function()
    awful.spawn("dmenu_run")
  end, { description = "Run dmenu_run", group = "launcher" }),

  awful.key({ modkey }, "x", function()
    awful.prompt.run({
      prompt = "Run Lua code: ",
      textbox = awful.screen.focused().mypromptbox.widget,
      exe_callback = awful.util.eval,
      history_path = awful.util.get_cache_dir() .. "/history_eval",
    })
  end, { description = "lua execute prompt", group = "awesome" }),
  -- Menubar
  --[[ awful.key({ modkey }, "p", function()
		menubar.show()
	end, { description = "show the menubar", group = "launcher" }) ]]

  -- Application keys
  awful.key({ modkey }, "b", function()
    awful.spawn("firefox")
  end, { description = "Open Firefox", group = "launcher" }),
  awful.key({ modkey }, "m", function()
    awful.spawn("thunderbird")
  end, { description = "Open Thunderbird", group = "launcher" }),
  awful.key({ modkey }, "f", function()
    awful.spawn("thunar")
  end, { description = "Open thunar", group = "launcher" }),
  awful.key({ modkey }, "p", function()
    awful.spawn("powermenu")
  end, { description = "Open the power menu", group = "launcher" }),
  awful.key({ modkey, "Shift" }, "c", function()
    awful.spawn("clipmenu")
  end, { description = "Open clipmenu", group = "launcher" }),
  awful.key({ modkey, "Shift" }, "n", function()
    awful.spawn("networkmanager_dmenu")
  end, { description = "Open networkmanager dmenu", group = "launcher" }),
  awful.key({ modkey }, ".", function()
    awful.spawn("emote")
  end, { description = "Open emote", group = "launcher" }),
  awful.key({}, "Print", function()
    awful.spawn("flameshot gui")
  end, { description = "Take screenshot", group = "launcher" }),
  awful.key({ modkey, alt }, "m", function()
    awful.spawn(terminal .. " ncmpcpp")
  end, { description = "Open ncmpcpp", group = "launcher" }),

  awful.key({}, "XF86AudioMute", function()
    awful.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle")
  end, { description = "Toggle mute", group = "audio" }),
  awful.key({}, "XF86AudioRaiseVolume", function()
    awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%")
  end, { description = "Raise volume", group = "audio" }),
  awful.key({}, "XF86AudioLowerVolume", function()
    awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%")
  end, { description = "Lower volume", group = "audio" }),

  awful.key({}, "XF86MonBrightnessUp", function()
    awful.spawn("brightnessctl -q s +5%")
  end, { description = "Increase brightness", group = "brightness" }),
  awful.key({}, "XF86MonBrightnessDown", function()
    awful.spawn("brightnessctl -q s 5%-")
  end, { description = "Decrease brightness", group = "brightness" })
)

clientkeys = gears.table.join(
  --[[ awful.key({ modkey }, "f", function(c)
		c.fullscreen = not c.fullscreen
		c:raise()
	end, { description = "toggle fullscreen", group = "client" }), ]]
  awful.key({ modkey }, "w", function(c)
    c:kill()
  end, { description = "close", group = "client" }),
  awful.key(
    { modkey, "Shift" },
    "f",
    awful.client.floating.toggle,
    { description = "toggle floating", group = "client" }
  ),
  awful.key({ modkey, "Control" }, "Return", function(c)
    c:swap(awful.client.getmaster())
  end, { description = "move to master", group = "client" }),
  awful.key({ modkey }, "o", function(c)
    c:move_to_screen()
  end, { description = "move to screen", group = "client" }),
  awful.key({ modkey }, "t", function(c)
    c.ontop = not c.ontop
  end, { description = "toggle keep on top", group = "client" }),
  awful.key({ modkey }, "n", function(c)
    -- The client currently has the input focus, so it cannot be
    -- minimized, since minimized clients can't have the focus.
    c.minimized = true
  end, { description = "minimize", group = "client" }),
  --[[ awful.key({ modkey, "Shift" }, "m", function(c)
		c.maximized = not c.maximized
		c:raise()
	end, { description = "(un)maximize", group = "client" }), ]]
  awful.key({ modkey, "Control" }, "m", function(c)
    c.maximized_vertical = not c.maximized_vertical
    c:raise()
  end, { description = "(un)maximize vertically", group = "client" }),
  awful.key({ modkey, "Shift" }, "m", function(c)
    c.maximized_horizontal = not c.maximized_horizontal
    c:raise()
  end, { description = "(un)maximize horizontally", group = "client" }),

  -- Vim keybinds to navigate focus
  awful.key({ modkey }, "h", function(c)
    awful.client.focus.bydirection("left", c, false)
  end, { description = "focus left", group = "client" }),
  awful.key({ modkey }, "j", function(c)
    awful.client.focus.bydirection("down", c, false)
  end, { description = "focus down", group = "client" }),
  awful.key({ modkey }, "k", function(c)
    awful.client.focus.bydirection("up", c, false)
  end, { description = "focus up", group = "client" }),
  awful.key({ modkey }, "l", function(c)
    awful.client.focus.bydirection("right", c, false)
  end),

  -- Layout manipulation
  awful.key({ modkey, alt }, "h", function(c)
    awful.client.swap.bydirection("left", c, false)
  end, { description = "Swap client to the left", group = "client" }),
  awful.key({ modkey, alt }, "j", function(c)
    awful.client.swap.bydirection("down", c, false)
  end, { description = "Swap client down", group = "client" }),
  awful.key({ modkey, alt }, "k", function(c)
    awful.client.swap.bydirection("up", c, false)
  end, { description = "Swap client up", group = "client" }),
  awful.key({ modkey, alt }, "l", function(c)
    awful.client.swap.bydirection("right", c, false)
  end, { description = "Swap client to the right", group = "client" }),

  awful.key({ modkey, "Shift" }, "j", function(c)
    c:move_to_screen(c.screen.index + 1)
  end, { description = "Move to right screen", group = "client" }),
  awful.key({ modkey, "Shift" }, "k", function(c)
    c:move_to_screen(c.screen.index - 1)
  end, { description = "Move to left screen", group = "client" })
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
  globalkeys = gears.table.join(
    globalkeys,
    -- View tag only.
    awful.key({ modkey }, "#" .. i + 9, function()
      local screen = awful.screen.focused()
      local tag = screen.tags[i]
      if tag then
        tag:view_only()
      end
    end, { description = "view tag #" .. i, group = "tag" }),
    -- Toggle tag display.
    awful.key({ modkey, "Control" }, "#" .. i + 9, function()
      local screen = awful.screen.focused()
      local tag = screen.tags[i]
      if tag then
        awful.tag.viewtoggle(tag)
      end
    end, { description = "toggle tag #" .. i, group = "tag" }),
    -- Move client to tag.
    awful.key({ modkey, "Shift" }, "#" .. i + 9, function()
      if client.focus then
        local tag = client.focus.screen.tags[i]
        if tag then
          client.focus:move_to_tag(tag)
        end
      end
    end, { description = "move focused client to tag #" .. i, group = "tag" }),
    -- Toggle tag on focused client.
    awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9, function()
      if client.focus then
        local tag = client.focus.screen.tags[i]
        if tag then
          client.focus:toggle_tag(tag)
        end
      end
    end, {
      description = "toggle focused client on tag #" .. i,
      group = "tag",
    })
  )
end

clientbuttons = gears.table.join(
  awful.button({}, 1, function(c)
    c:emit_signal("request::activate", "mouse_click", { raise = true })
  end),
  awful.button({ modkey }, 1, function(c)
    c:emit_signal("request::activate", "mouse_click", { raise = true })
    awful.mouse.client.move(c)
  end),
  awful.button({ modkey }, 3, function(c)
    c:emit_signal("request::activate", "mouse_click", { raise = true })
    awful.mouse.client.resize(c)
  end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
  -- All clients will match this rule.
  {
    rule = {},
    properties = {
      border_width = beautiful.border_width,
      border_color = beautiful.border_normal,
      focus = awful.client.focus.filter,
      raise = true,
      keys = clientkeys,
      maximized_vertical = false,
      maximized_horizontal = false,
      buttons = clientbuttons,
      screen = awful.screen.preferred,
      placement = awful.placement.no_overlap + awful.placement.no_offscreen,
    },
  },

  -- Fix various windows not tiling
  {
    rule_any = {
      class = {
        "firefox",
        "thunderbird",
        "libreoffice",
        "PrismLauncher",
      },
      name = {
        "Discord",
        "Thunar",
        "Steam",
        "HandBrake Queue",
        "HandBrake",
      },
    },
    properties = {
      maximized = false,
      floating = false,
    },
  },

  -- Fix utility type windows attempting to tile and act as their own window
  {
    rule = { type = "utility" },
    properties = {
      floating = true,
      focusable = false,
      border_width = 0,
    },
  },

  -- Always maximize mpv
  {
    rule = { class = "mpv" },
    properties = {
      size_hints_honor = false,
      fullscreen = true,
    },
  },

  -- Floating clients.
  {
    rule_any = {
      instance = {
        "DTA", -- Firefox addon DownThemAll.
        "copyq", -- Includes session name in class.
        "pinentry",
      },
      class = {
        "Arandr",
        "Blueman-manager",
        "Gpick",
        "Kruler",
        "MessageWin", -- kalarm.
        "Sxiv",
        "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
        "Wpa_gui",
        "veromix",
        "xtightvncviewer",
      },

      -- Note that the name property shown in xprop might be set slightly after creation of the client
      -- and the name shown there might not match defined rules here.
      name = {
        "Event Tester", -- xev.
        "Picture-in-Picture",
      },
      role = {
        "AlarmWindow", -- Thunderbird's calendar.
        "ConfigManager", -- Thunderbird's about:config.
        "pop-up", -- e.g. Google Chrome's (detached) Developer Tools.
      },
      type = { "dialog" },
    },
    properties = { floating = true },
  },

  -- Set Firefox to always map on the tag named "2" on screen 1.
  -- { rule = { class = "Firefox" },
  --   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
  -- Set the windows at the slave,
  -- i.e. put it at the end of others instead of setting it master.
  -- if not awesome.startup then awful.client.setslave(c) end

  if
    awesome.startup
    and not c.size_hints.user_position
    and not c.size_hints.program_position
  then
    -- Prevent clients from being unreachable after screen count changes.
    awful.placement.no_offscreen(c)
  end
end)

-- Disable the stupid titlebar
client.connect_signal("request::titlebars", function(c)
  awful.titlebar.hide(c)
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
  c:emit_signal("request::activate", "mouse_enter", { raise = false })
end)

client.connect_signal("focus", function(c)
  c.border_color = beautiful.border_focus
end)
client.connect_signal("unfocus", function(c)
  c.border_color = beautiful.border_normal
end)
-- }}}

-- Run garbage collector regularly to prevent memory leaks
gears.timer({
  timeout = 30,
  autostart = true,
  callback = function()
    collectgarbage()
  end,
})

-- Autostart applications in the background
awful.spawn.with_shell(gears.filesystem.get_configuration_dir() .. "autorun.sh")
