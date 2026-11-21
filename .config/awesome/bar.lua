-- Status bar for the AwesomeWM config.
--
-- This is a native wibar replacement for the Waybar modules in
-- ~/.config/waybar/config.jsonc: tags, focused title, volume, backlight,
-- battery, temperature, memory, clock and the systray.

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local theme = require("theme")

local colors = theme.colors
local bar = {}

local icons = {
  volume = { "󰕿", "󰖀", "󰕾" },
  muted = "󰖁",
  backlight = {
    "", "", "", "", "", "", "", "",
    "", "", "", "", "", "", "",
  },
  battery = { "󰁻", "󰁼", "󰁾", "󰂀", "󰂂", "󰁹" },
  charging = "󰂄",
  temperature = { "", "", "" },
  memory = "",
  clock = "󱑎",
}

local function shell(script)
  return { "sh", "-c", script }
end

local function margin(widget, left, right, top, bottom)
  return wibox.container.margin(
    widget,
    left or 0,
    right or 0,
    top or 0,
    bottom or 0
  )
end

local function add_tooltip(widget, text)
  awful.tooltip({
    objects = { widget },
    timer_function = text,
    mode = "mouse",
  })
end

local function truncate(text, max)
  if not text or text == "" then
    return ""
  end
  if not utf8 or not utf8.len then
    return text
  end

  local length = utf8.len(text)
  if length and length > max then
    local offset = utf8.offset(text, max + 1)
    if offset then
      return text:sub(1, offset - 1) .. "…"
    end
  end
  return text
end

-- One title textbox per wibar. A client signal updates all of them.
local title_widgets = setmetatable({}, { __mode = "v" })

local function current_title()
  local c = client.focus
  if not c then
    return ""
  end

  local name = c.name
  if not name or name == "" then
    name = c.class or c.instance or ""
  end

  return gears.string.xml_escape(truncate(name, 80))
end

local function update_titles()
  local text = current_title()
  for _, widget in pairs(title_widgets) do
    widget:set_markup(text)
  end
end

client.connect_signal("focus", update_titles)
client.connect_signal("unfocus", update_titles)
client.connect_signal("property::name", update_titles)
client.connect_signal("property::class", update_titles)
client.connect_signal("manage", update_titles)
client.connect_signal("unmanage", update_titles)

local function make_title()
  local widget = wibox.widget.textbox()
  widget:set_halign("center")
  widget:set_markup(current_title())

  title_widgets[#title_widgets + 1] = widget
  return widget
end

-- Volume ---------------------------------------------------------------

local volume_state = { muted = false, volume = 0, desc = "" }

local volume_script = [=[
mute=$(pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | awk '{print $2}')
vol=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | grep -oE '[0-9]+%' | head -n1 | tr -d '%')
desc=$(pactl list sinks 2>/dev/null | sed -n 's/^[[:space:]]*Description: //p' | head -n1)
printf '%s|%s|%s\n' "${mute:-no}" "${vol:-0}" "$desc"
]=]

local function make_volume()
  local widget = awful.widget.watch(shell(volume_script), 2, function(w, stdout)
    local mute, volume, desc = stdout:match("([^|]*)|([^|]*)|(.*)")
    if not mute then
      w:set_text("")
      return
    end

    local percent = tonumber(volume) or 0
    volume_state.muted = mute == "yes"
    volume_state.volume = percent
    volume_state.desc = desc or ""

    if volume_state.muted then
      w:set_markup(icons.muted .. " muted")
      return
    end

    local icon = icons.volume[1]
    if percent >= 67 then
      icon = icons.volume[3]
    elseif percent >= 34 then
      icon = icons.volume[2]
    end

    w:set_markup(icon .. " " .. percent .. "%")
  end)

  widget:buttons(gears.table.join(
    awful.button({}, 1, function()
      awful.spawn({ "pactl", "set-sink-mute", "@DEFAULT_SINK@", "toggle" })
    end),
    awful.button({}, 2, function()
      awful.spawn("pavucontrol")
    end),
    awful.button({}, 4, function()
      awful.spawn({ "pactl", "set-sink-volume", "@DEFAULT_SINK@", "+5%" })
    end),
    awful.button({}, 5, function()
      awful.spawn({ "pactl", "set-sink-volume", "@DEFAULT_SINK@", "-5%" })
    end)
  ))

  add_tooltip(widget, function()
    local status
    if volume_state.muted then
      status = "Muted"
    else
      status = volume_state.volume .. "%"
    end
    if volume_state.desc ~= "" then
      status = status .. " | " .. volume_state.desc
    end
    return status
  end)

  return widget
end

-- Backlight ------------------------------------------------------------

local backlight_state = { percent = 0 }

local backlight_script = [[
out=$(brightnessctl -d intel_backlight -m 2>/dev/null) || out=$(brightnessctl -m 2>/dev/null)
printf '%s\n' "$out"
]]

local function set_backlight(step)
  awful.spawn.with_shell(
    "if brightnessctl -d intel_backlight info >/dev/null 2>&1; then "
      .. "brightnessctl -d intel_backlight set " .. step
      .. "; else brightnessctl set " .. step .. "; fi"
  )
end

local function make_backlight()
  local widget = awful.widget.watch(shell(backlight_script), 5, function(w, stdout)
    local value = stdout:match(",(%d+)%%")
    if not value then
      w:set_text("")
      return
    end

    local percent = tonumber(value)
    backlight_state.percent = percent

    local index = math.floor(percent / 100 * (#icons.backlight - 1)) + 1
    index = math.max(1, math.min(#icons.backlight, index))

    w:set_markup(icons.backlight[index] .. " " .. percent .. "%")
  end)

  widget:buttons(gears.table.join(
    awful.button({}, 4, function() set_backlight("+5%") end),
    awful.button({}, 5, function() set_backlight("-5%") end)
  ))

  add_tooltip(widget, function()
    return "Brightness " .. backlight_state.percent .. "%"
  end)

  return widget
end

-- Battery --------------------------------------------------------------

local battery_state = { capacity = 0, status = "" }

local battery_script = [[
for battery in /sys/class/power_supply/BAT*; do
  [ -r "$battery/capacity" ] || continue
  printf '%s %s\n' "$(cat "$battery/capacity")" "$(cat "$battery/status" 2>/dev/null)"
  break
done
]]

local function make_battery()
  local widget = awful.widget.watch(shell(battery_script), 30, function(w, stdout)
    local capacity, status = stdout:match("(%d+)%s+(.-)%s*$")
    if not capacity then
      w:set_text("")
      return
    end

    local percent = tonumber(capacity)
    battery_state.capacity = percent
    battery_state.status = status or ""

    local icon
    if status == "Full" then
      icon = icons.battery[#icons.battery]
    elseif status == "Charging" then
      icon = icons.charging
    else
      local index = math.ceil(percent / 100 * #icons.battery)
      index = math.max(1, math.min(#icons.battery, index))
      icon = icons.battery[index]
    end

    local text = icon .. " " .. percent .. "%"
    local color
    if percent <= 15 then
      color = colors.bright_red
    elseif percent <= 30 then
      color = colors.bright_yellow
    end

    if color then
      text = "<span color='" .. color .. "'>" .. text .. "</span>"
    end
    w:set_markup(text)
  end)

  add_tooltip(widget, function()
    if battery_state.status == "" then
      return battery_state.capacity .. "%"
    end
    return battery_state.status .. " | " .. battery_state.capacity .. "%"
  end)

  return widget
end

-- Temperature ----------------------------------------------------------

local temperature_state = { celsius = 0 }

local temperature_script = [[
for zone in /sys/class/thermal/thermal_zone*; do
  [ -r "$zone/temp" ] || continue
  value=$(cat "$zone/temp")
  [ "$value" -gt 0 ] && printf '%s\n' "$value"
done | sort -n | tail -n1
]]

local function make_temperature()
  local widget = awful.widget.watch(shell(temperature_script), 10, function(w, stdout)
    local raw = tonumber(stdout:match("%d+"))
    if not raw then
      w:set_text("")
      return
    end

    local celsius = raw > 1000 and math.floor(raw / 1000 + 0.5) or raw
    temperature_state.celsius = celsius

    local icon = icons.temperature[1]
    if celsius >= 75 then
      icon = icons.temperature[3]
    elseif celsius >= 55 then
      icon = icons.temperature[2]
    end

    local text = icon .. " " .. celsius .. "°C"
    if celsius >= 85 then
      text = "<span color='" .. colors.bright_red .. "'>" .. text .. "</span>"
    end
    w:set_markup(text)
  end)

  add_tooltip(widget, function()
    return "CPU temperature " .. temperature_state.celsius .. "°C"
  end)

  return widget
end

-- Memory ---------------------------------------------------------------

local memory_state = { percent = 0 }

local memory_script = [[
awk '/^MemTotal:/{total=$2} /^MemAvailable:/{available=$2}
     END{if (total > 0) printf "%d", (total - available) * 100 / total}' /proc/meminfo
]]

local function make_memory()
  local widget = awful.widget.watch(shell(memory_script), 30, function(w, stdout)
    local percent = tonumber(stdout)
    if not percent then
      w:set_text("")
      return
    end

    memory_state.percent = percent
    w:set_markup(icons.memory .. " " .. percent .. "%")
  end)

  add_tooltip(widget, function()
    return "RAM used " .. memory_state.percent .. "%"
  end)

  return widget
end

-- Clock ----------------------------------------------------------------

local function make_clock()
  local widget = wibox.widget.textclock(icons.clock .. " %H:%M", 60)
  widget:set_font(theme.font)

  local calendar = awful.widget.calendar_popup.year({
    position = "tr",
    font = theme.font,
    spacing = 8,
    week_numbers = true,
    start_sunday = false,
    bg = colors.background,
    style_year = {
      bg_color = colors.background,
      fg_color = colors.foreground,
      padding = 6,
    },
    style_yearheader = {
      bg_color = colors.background,
      fg_color = colors.bright_yellow,
      padding = 6,
    },
    style_header = {
      bg_color = colors.background,
      fg_color = colors.bright_yellow,
      padding = 4,
    },
    style_weekday = { fg_color = colors.bright_blue },
    style_weeknumber = { fg_color = colors.bright_green },
    style_normal = { fg_color = colors.foreground },
    style_focus = {
      fg_color = colors.background,
      bg_color = colors.primary,
    },
  })
  calendar:attach(widget, "tr")

  return widget
end

-- Systray --------------------------------------------------------------

local function make_tray()
  local tray = wibox.widget.systray()
  tray:set_base_size(21)
  tray:set_horizontal(true)
  return margin(tray, 8, 0, 0, 0)
end

-- Taglist --------------------------------------------------------------

local function toggle_tag(t)
  if t.selected and #t.screen.selected_tags == 1 then
    return
  end
  awful.tag.viewtoggle(t)
end

local taglist_buttons = gears.table.join(
  awful.button({}, 1, function(t) t:view_only() end),
  awful.button({}, 2, toggle_tag),
  awful.button({}, 4, function(t) awful.tag.viewnext(t.screen) end),
  awful.button({}, 5, function(t) awful.tag.viewprev(t.screen) end)
)

local tag_template = {
  {
    {
      {
        id = "text_role",
        widget = wibox.widget.textbox,
      },
      left = 8,
      right = 8,
      top = 1,
      bottom = 0,
      widget = wibox.container.margin,
    },
    id = "background_role",
    widget = wibox.container.background,
  },
  top = 5,
  bottom = 5,
  left = 2,
  right = 2,
  widget = wibox.container.margin,
}

-- Bar ------------------------------------------------------------------

function bar.create(s)
  local taglist = awful.widget.taglist({
    screen = s,
    filter = awful.widget.taglist.filter.all,
    buttons = taglist_buttons,
    widget_template = tag_template,
  })

  local left = wibox.widget({
    margin(taglist, 6, 8, 0, 0),
    layout = wibox.layout.fixed.horizontal,
  })

  local right = wibox.layout.fixed.horizontal()
  right:add(make_volume())
  right:add(margin(make_backlight(), 24, 0, 0, 0))
  right:add(margin(make_battery(), 24, 0, 0, 0))
  right:add(margin(make_temperature(), 24, 0, 0, 0))
  right:add(margin(make_memory(), 24, 0, 0, 0))
  right:add(margin(make_clock(), 24, 24, 0, 0))

  -- The systray widget can only exist once and only draws on the primary
  -- screen, so add it to that wibar only.
  if s == screen.primary then
    right:add(make_tray())
  end

  local content = wibox.widget({
    {
      left,
      make_title(),
      right,
      layout = wibox.layout.align.horizontal,
    },
    bg = colors.background,
    fg = colors.foreground,
    shape = gears.shape.rectangle,
    shape_border_width = 2,
    shape_border_color = colors.primary,
    widget = wibox.container.background,
  })

  -- Waybar uses margin: 10 10 0 10. Awesome 4.3's awful.wibar has no margins,
  -- so the gap is created inside a slightly taller transparent wibar.
  local outer = wibox.widget({
    content,
    top = theme.bar_gap,
    left = theme.bar_gap,
    right = theme.bar_gap,
    bottom = 0,
    widget = wibox.container.margin,
  })

  return awful.wibar({
    position = "top",
    screen = s,
    height = theme.bar_height + theme.bar_gap,
    font = theme.font,
    bg = "#00000000",
    fg = colors.foreground,
    ontop = true,
    widget = outer,
  })
end

return bar
