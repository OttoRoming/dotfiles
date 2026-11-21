-- Shared palette and visual settings for the AwesomeWM config.
--
-- The colours come from ~/.cache/theme/colors.lua, which process.py generates
-- from theme.json. The fallback keeps Awesome usable before that file exists.

local gears = require("gears")
local beautiful = require("beautiful")

local home = os.getenv("HOME") or ""
local theme = {}

local fallback = {
  foreground = "#ebdbb2",
  background = "#282828",
  primary = "#cc241d",

  black = "#282828",
  red = "#cc241d",
  green = "#98971a",
  yellow = "#d79921",
  blue = "#458588",
  magenta = "#b16286",
  cyan = "#689d6a",
  white = "#a89984",

  bright_black = "#928374",
  bright_red = "#fb4934",
  bright_green = "#b8bb26",
  bright_yellow = "#fabd2f",
  bright_blue = "#83a598",
  bright_magenta = "#d3869b",
  bright_cyan = "#8ec07c",
  bright_white = "#ebdbb2",
}

local ok, colors = pcall(dofile, home .. "/.cache/theme/colors.lua")
if not ok or type(colors) ~= "table" then
  colors = fallback
else
  for key, value in pairs(fallback) do
    if colors[key] == nil then
      colors[key] = value
    end
  end
end

theme.colors = colors

theme.font = "Hack Nerd Font 12"
theme.bar_height = 38
theme.bar_gap = 10

-- Mango's client border colours.
theme.focus = "#F22C57"
theme.border_normal = "#2C3746"
theme.urgent = "#ef5e5e"

theme.wallpaper = home .. "/Pictures/wallpapers/jonathan-curry.jpg"

local function file_readable(path)
  local file = io.open(path, "r")
  if file then
    file:close()
    return true
  end
  return false
end

theme.wallpaper_exists = file_readable(theme.wallpaper)

local function rounded_3(cr, width, height)
  gears.shape.rounded_rect(cr, width, height, 3)
end

beautiful.init({
  font = theme.font,

  bg_normal = colors.background,
  fg_normal = colors.foreground,
  bg_focus = colors.primary,
  fg_focus = colors.foreground,
  bg_urgent = theme.urgent,
  fg_urgent = colors.background,
  bg_minimize = colors.bright_black,
  fg_minimize = colors.background,

  -- Client borders. Mango uses 2px and no rounded corners.
  border_width = 2,
  border_normal = theme.border_normal,
  border_focus = theme.focus,
  border_marked = colors.bright_yellow,
  border_mark_minimized = colors.bright_black,
  border_color_normal = theme.border_normal,
  border_color_focus = theme.focus,
  border_color_marked = colors.bright_yellow,

  -- Taglist: transparent buttons with a rounded primary background when
  -- selected, matching the Waybar workspace style.
  taglist_font = theme.font,
  taglist_fg_focus = colors.foreground,
  taglist_bg_focus = colors.primary,
  taglist_fg_urgent = colors.background,
  taglist_bg_urgent = theme.urgent,
  taglist_fg_occupied = colors.foreground,
  taglist_bg_occupied = colors.background,
  taglist_fg_empty = colors.foreground,
  taglist_bg_empty = colors.background,
  taglist_shape = rounded_3,
  taglist_shape_border_width = 0,
  taglist_shape_border_color = colors.primary,
  taglist_spacing = 0,

  -- Wibar. The bar itself is transparent and the visible part is wrapped in
  -- a margin in bar.lua, so the 10px Waybar gap also works on Awesome 4.3.
  wibar_bg = "#00000000",
  wibar_fg = colors.foreground,
  wibar_height = theme.bar_height + theme.bar_gap,
  wibar_ontop = true,

  -- Tooltips and notifications.
  tooltip_bg = colors.background,
  tooltip_fg = colors.foreground,
  tooltip_border_width = 2,
  tooltip_border_color = colors.primary,
  tooltip_font = theme.font,
  tooltip_opacity = 1,

  notification_bg = colors.background,
  notification_fg = colors.foreground,
  notification_border_width = 2,
  notification_border_color = colors.primary,
  notification_font = theme.font,

  -- Systray.
  bg_systray = colors.background,
  systray_icon_spacing = 8,
})

return theme
