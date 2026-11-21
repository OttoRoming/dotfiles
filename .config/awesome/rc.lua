-- AwesomeWM configuration.
--
-- X11 counterpart to the Mango/Waybar setup in this dotfiles repository:
--   * Mango keybindings and window behaviour
--   * Waybar's top bar, rewritten as a native wibar
--   * alacritty as the terminal

pcall(require, "luarocks.loader")

local awful = require("awful")
require("awful.autofocus")
local beautiful = require("beautiful")
local gears = require("gears")
local naughty = require("naughty")
local wibox = require("wibox")

local theme = require("theme")
local bar = require("bar")

local colors = theme.colors

-- Error handling -------------------------------------------------------

if awesome.startup_errors then
  naughty.notify({
    preset = naughty.config.presets.critical,
    title = "Oops, there were errors during startup!",
    text = awesome.startup_errors,
  })
end

do
  local in_error = false
  awesome.connect_signal("debug::error", function(err)
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

-- Variables ------------------------------------------------------------

local modkey = "Mod4"
local terminal = "alacritty"
local browser = "firefox"

local layout_tile = awful.layout.suit.tile
local layout_monocle = awful.layout.suit.max.fullscreen
local layout_fair = awful.layout.suit.fair
local layout_dwindle = awful.layout.suit.spiral.dwindle
local layout_floating = awful.layout.suit.floating

local layouts = {
  layout_tile,
  layout_monocle,
  layout_fair,
  layout_dwindle,
  layout_floating,
}

awful.layout.layouts = layouts

local tag_names = { "1", "2", "3", "4", "5", "6", "7", "8", "9" }

local home = os.getenv("HOME") or ""

-- Wallpaper ------------------------------------------------------------

local function set_wallpaper(s)
  if theme.wallpaper_exists then
    gears.wallpaper.maximized(theme.wallpaper, s, false)
  else
    gears.wallpaper.set(colors.background)
  end
end

screen.connect_signal("property::geometry", set_wallpaper)

-- Screens, tags and bars -----------------------------------------------

awful.screen.connect_for_each_screen(function(s)
  set_wallpaper(s)

  awful.tag(tag_names, s, layout_tile)

  for _, t in ipairs(s.tags) do
    t.master_width_factor = 0.55
  end

  s.mywibar = bar.create(s)
end)

-- Mouse bindings -------------------------------------------------------

local clientbuttons = gears.table.join(
  awful.button({}, 1, function(c)
    c:emit_signal("request::activate", "mouse_click", { raise = true })
  end),
  awful.button({ modkey }, 1, function(c)
    c:emit_signal("request::activate", "mouse_move", { raise = true })
    awful.mouse.client.move(c)
  end),
  awful.button({ modkey }, 3, function(c)
    c:emit_signal("request::activate", "mouse_resize", { raise = true })
    awful.mouse.client.resize(c)
  end)
)

-- Tag helpers ----------------------------------------------------------

local function view_all_tags()
  local s = awful.screen.focused()
  awful.tag.viewmore(s.tags, s)
end

-- Global keys ----------------------------------------------------------

local globalkeys = gears.table.join(
  -- Applications
  awful.key({ modkey }, "t", function()
    awful.spawn(terminal)
  end, { description = "open alacritty", group = "launcher" }),

  awful.key({ modkey }, "b", function()
    awful.spawn(browser)
  end, { description = "open browser", group = "launcher" }),

  awful.key({ "Mod1" }, "space", function()
    awful.spawn.with_shell("BEMENU_BACKEND=x11 " .. home .. "/.local/bin/menu-run")
  end, { description = "run launcher", group = "launcher" }),

  awful.key({ modkey, "Shift" }, "q", function()
    awful.spawn.with_shell("BEMENU_BACKEND=x11 " .. home .. "/.local/bin/menu-power")
  end, { description = "power menu", group = "awesome" }),

  awful.key({ modkey, "Shift" }, "l", function()
    awful.spawn.with_shell(home .. "/.local/bin/lock")
  end, { description = "lock screen", group = "awesome" }),

  awful.key({ modkey, "Control" }, "a", function()
    awful.spawn.with_shell("BEMENU_BACKEND=x11 " .. home .. "/.local/bin/menu-audio")
  end, { description = "audio menu", group = "launcher" }),

  awful.key({ modkey, "Control" }, "b", function()
    awful.spawn.with_shell("BEMENU_BACKEND=x11 " .. home .. "/.local/bin/menu-bluetooth")
  end, { description = "bluetooth menu", group = "launcher" }),

  awful.key({ modkey, "Control" }, "c", function()
    awful.spawn.with_shell([[
      if command -v clipmenu >/dev/null 2>&1; then
        CM_LAUNCHER=bemenu BEMENU_BACKEND=x11 clipmenu
      elif command -v xclip >/dev/null 2>&1; then
        xclip -o -selection clipboard |
          BEMENU_BACKEND=x11 bemenu -p clipboard |
          xclip -selection clipboard
      fi
    ]])
  end, { description = "clipboard menu", group = "launcher" }),

  -- Layouts
  awful.key({ modkey }, "v", function()
    awful.layout.set(layout_tile)
  end, { description = "tile layout", group = "layout" }),

  awful.key({ modkey }, "m", function()
    awful.layout.set(layout_monocle)
  end, { description = "monocle layout", group = "layout" }),

  awful.key({ modkey }, "g", function()
    awful.layout.set(layout_fair)
  end, { description = "fair layout", group = "layout" }),

  awful.key({ modkey }, "d", function()
    awful.layout.set(layout_dwindle)
  end, { description = "dwindle layout", group = "layout" }),

  awful.key({ modkey }, "f", function()
    local c = client.focus
    if c then
      c.floating = not c.floating
    end
  end, { description = "toggle floating", group = "layout" }),

  -- Focus
  awful.key({ modkey }, "j", function()
    awful.client.focus.byidx(1)
  end, { description = "focus next client", group = "client" }),

  awful.key({ modkey }, "k", function()
    awful.client.focus.byidx(-1)
  end, { description = "focus previous client", group = "client" }),

  awful.key({ modkey }, "h", function()
    awful.tag.incmwfact(-0.05)
  end, { description = "decrease master width", group = "layout" }),

  awful.key({ modkey }, "l", function()
    awful.tag.incmwfact(0.05)
  end, { description = "increase master width", group = "layout" }),

  awful.key({ modkey }, "Return", function()
    local c = client.focus
    if c then
      local master = awful.client.getmaster()
      if master and master ~= c then
        c:swap(master)
        c:emit_signal("request::activate", "key.zoom", { raise = true })
      end
    end
  end, { description = "zoom to master", group = "client" }),

  awful.key({ modkey, "Shift" }, "c", function()
    local c = client.focus
    if c then
      c:kill()
    end
  end, { description = "close client", group = "client" }),

  awful.key({ modkey, "Shift" }, "r", awesome.restart,
    { description = "restart awesome", group = "awesome" }),

  -- Screens. Mango uses code:60 (period) for focusmon/tagmon right.
  awful.key({ modkey }, "period", function()
    awful.screen.focus_relative(1)
  end, { description = "focus next screen", group = "screen" }),

  awful.key({ modkey }, "comma", function()
    awful.screen.focus_relative(-1)
  end, { description = "focus previous screen", group = "screen" }),

  awful.key({ modkey, "Shift" }, "period", function()
    local c = client.focus
    if c then
      c:move_to_screen()
    end
  end, { description = "move client to next screen", group = "screen" }),

  awful.key({ modkey, "Shift" }, "comma", function()
    local c = client.focus
    if c then
      c:move_to_screen(c.screen.index - 1)
    end
  end, { description = "move client to previous screen", group = "screen" }),

  -- Swap clients
  awful.key({ modkey, "Shift" }, "Up", function()
    awful.client.swap.bydirection("up")
  end, { description = "swap with client above", group = "client" }),

  awful.key({ modkey, "Shift" }, "Down", function()
    awful.client.swap.bydirection("down")
  end, { description = "swap with client below", group = "client" }),

  awful.key({ modkey, "Shift" }, "Left", function()
    awful.client.swap.bydirection("left")
  end, { description = "swap with client to the left", group = "client" }),

  awful.key({ modkey, "Shift" }, "Right", function()
    awful.client.swap.bydirection("right")
  end, { description = "swap with client to the right", group = "client" }),

  -- Tags
  awful.key({ modkey }, "0", view_all_tags,
    { description = "view all tags", group = "tag" }),

  awful.key({ modkey, "Shift" }, "0", function()
    local c = client.focus
    if c then
      c:tags(c.screen.tags)
    end
  end, { description = "put client on all tags", group = "tag" }),

  -- Brightness
  awful.key({}, "XF86MonBrightnessUp", function()
    awful.spawn({ "brightnessctl", "s", "+2%" })
  end, { description = "increase brightness", group = "media" }),

  awful.key({ "Shift" }, "XF86MonBrightnessUp", function()
    awful.spawn({ "brightnessctl", "s", "100%" })
  end, { description = "maximum brightness", group = "media" }),

  awful.key({}, "XF86MonBrightnessDown", function()
    awful.spawn({ "brightnessctl", "s", "2%-" })
  end, { description = "decrease brightness", group = "media" }),

  awful.key({ "Shift" }, "XF86MonBrightnessDown", function()
    awful.spawn({ "brightnessctl", "s", "0" })
  end, { description = "minimum brightness", group = "media" }),

  -- Volume
  awful.key({}, "XF86AudioRaiseVolume", function()
    awful.spawn({ "wpctl", "set-volume", "@DEFAULT_SINK@", "5%+" })
  end, { description = "increase volume", group = "media" }),

  awful.key({}, "XF86AudioLowerVolume", function()
    awful.spawn({ "wpctl", "set-volume", "@DEFAULT_SINK@", "5%-" })
  end, { description = "decrease volume", group = "media" }),

  awful.key({}, "XF86AudioMute", function()
    awful.spawn({ "wpctl", "set-mute", "@DEFAULT_SINK@", "toggle" })
  end, { description = "toggle mute", group = "media" }),

  awful.key({}, "XF86AudioMicMute", function()
    awful.spawn({ "wpctl", "set-mute", "@DEFAULT_SOURCE@", "toggle" })
  end, { description = "toggle microphone mute", group = "media" }),

  -- Media keys
  awful.key({}, "XF86AudioNext", function()
    awful.spawn({ "playerctl", "next" })
  end, { description = "next track", group = "media" }),

  awful.key({}, "XF86AudioPrev", function()
    awful.spawn({ "playerctl", "previous" })
  end, { description = "previous track", group = "media" }),

  awful.key({}, "XF86AudioPlay", function()
    awful.spawn({ "playerctl", "play-pause" })
  end, { description = "play/pause", group = "media" }),

  -- Screenshot. Mango uses grim/slurp; X11 uses maim/xclip.
  awful.key({}, "Print", function()
    awful.spawn.with_shell([[
      if command -v maim >/dev/null 2>&1; then
        maim -s | xclip -selection clipboard -t image/png
      elif command -v scrot >/dev/null 2>&1; then
        scrot -s - | xclip -selection clipboard -t image/png
      fi
    ]])
  end, { description = "screenshot selection", group = "media" })
)

-- Tags 1-9: switch to tag on Super+N, move client on Super+Shift+N.
for i = 1, 9 do
  globalkeys = gears.table.join(
    globalkeys,
    awful.key({ modkey }, "#" .. (i + 9), function()
      local t = awful.screen.focused().tags[i]
      if t then
        awful.tag.viewonly(t)
      end
    end, { description = "view tag " .. i, group = "tag" }),

    awful.key({ modkey, "Shift" }, "#" .. (i + 9), function()
      local c = client.focus
      if c then
        local t = c.screen.tags[i]
        if t then
          c:move_to_tag(t)
        end
      end
    end, { description = "move client to tag " .. i, group = "tag" })
  )
end

root.keys(globalkeys)

-- Rules ----------------------------------------------------------------

awful.rules.rules = {
  {
    rule = {},
    properties = {
      border_width = beautiful.border_width,
      border_color = beautiful.border_normal,
      focus = awful.client.focus.filter,
      raise = true,
      buttons = clientbuttons,
      screen = awful.screen.preferred,
      placement = awful.placement.no_overlap + awful.placement.no_offscreen,
      size_hints_honor = false,
    },
  },
  {
    rule_any = {
      instance = { "DTA", "copyq", "pinentry" },
      class = {
        "Arandr",
        "Blueman-manager",
        "Gpick",
        "Kruler",
        "MessageWin",
        "Sxiv",
        "Tor Browser",
        "Wpa_gui",
        "veromix",
        "xtightvncviewer",
      },
      name = { "Event Tester" },
      role = { "AlarmWindow", "ConfigManager", "pop-up" },
    },
    properties = { floating = true },
  },
  {
    rule_any = { type = { "dialog" } },
    properties = { floating = true },
  },
}

-- Client signals -------------------------------------------------------

client.connect_signal("manage", function(c)
  c.opacity = c.active and 1 or 0.95

  -- Mango's new_is_master = 1: place new tiled windows in the master slot.
  if not awesome.startup
    and not c.floating
    and c.type == "normal"
    and awful.layout.get(c.screen) ~= layout_floating
  then
    gears.timer.delayed_call(function()
      if c.valid and not c.floating then
        -- client:to_primary_section() is newer than Awesome 4.3, so swap
        -- with the current master instead.
        local master = awful.client.getmaster(c.screen)
        if master and master ~= c then
          c:swap(master)
        end
      end
    end)
  end
end)

client.connect_signal("focus", function(c)
  c.border_color = beautiful.border_focus
  c.opacity = 1
end)

client.connect_signal("unfocus", function(c)
  c.border_color = beautiful.border_normal
  c.opacity = 0.95
end)

for _, c in ipairs(client.get()) do
  c.border_color = c.active and beautiful.border_focus or beautiful.border_normal
  c.opacity = c.active and 1 or 0.95
end

-- Autostart ------------------------------------------------------------

local function run_once(process, command)
  awful.spawn.with_shell(
    "command -v " .. process .. " >/dev/null 2>&1 && "
      .. "(pgrep -x " .. process .. " >/dev/null 2>&1 || " .. command .. ")"
  )
end

-- XKB settings from Mango.
awful.spawn.with_shell(
  "command -v setxkbmap >/dev/null 2>&1 && "
    .. "setxkbmap -layout us,se -variant colemak,nodeadkeys "
    .. "-option grp:win_space_toggle"
)

awful.spawn.with_shell(
  "command -v xset >/dev/null 2>&1 && xset r rate 300 30"
)

-- Disable pointer acceleration. xset covers the legacy X pointer driver;
-- libinput (the usual Xorg driver now) ignores it, so switch every device
-- to the flat profile with speed 0.
awful.spawn.with_shell([[
  command -v xset >/dev/null 2>&1 && xset m 0 0

  command -v xinput >/dev/null 2>&1 || exit 0
  xinput list --id-only 2>/dev/null | while read -r id; do
    # Newer libinput exposes adaptive/flat/custom, older only adaptive/flat.
    xinput set-prop "$id" "libinput Accel Profile Enabled" 0 1 0 2>/dev/null ||
      xinput set-prop "$id" "libinput Accel Profile Enabled" 0 1 2>/dev/null
    xinput set-prop "$id" "libinput Accel Speed" 0 2>/dev/null
    xinput set-prop "$id" "Device Accel Constant Deceleration" 1 2>/dev/null
  done
]])

awful.spawn.with_shell(
  "command -v numlockx >/dev/null 2>&1 && numlockx on"
)

awful.spawn.with_shell(
  "command -v gsettings >/dev/null 2>&1 && "
    .. "gsettings set org.gnome.desktop.interface color-scheme prefer-dark"
)

-- Optional X11 helpers: the reference X11 compositor, notifications and
-- clipboard history. xcompmgr is what makes client opacity work.
run_once("xcompmgr", "xcompmgr")
run_once("dunst", "dunst")
run_once("clipmenud", "clipmenud")

awful.spawn.with_shell([[
  for agent in \
    /usr/libexec/polkit-mate-authentication-agent-1 \
    /usr/lib/polkit-mate/polkit-mate-authentication-agent-1 \
    /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1; do
    if [ -x "$agent" ]; then
      pgrep -f "$agent" >/dev/null 2>&1 || "$agent" &
      break
    fi
  done
]])
