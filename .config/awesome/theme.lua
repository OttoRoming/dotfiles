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

  -- Extra gruvbox surfaces used by the Mango colours.
  bg1 = "#3c3836",
  bg2 = "#504945",
  bg3 = "#665c54",
  bg4 = "#7c6f64",
  fg0 = "#fbf1c7",
  fg2 = "#d5c4a1",
  fg3 = "#bdae93",
  fg4 = "#a89984",
  orange = "#d65d0e",
  bright_orange = "#fe8019",
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

theme.font = "sans-serif 12"
theme.bar_height = 38
theme.window_gap = 5

-- Mango's client border colours (gruvbox dark).
theme.focus = colors.primary
theme.border_normal = colors.bg2
theme.urgent = colors.bright_red

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

  -- Gaps between tiled clients and the screen edges. Keep them when a tag
  -- has only one client.
  useless_gap = theme.window_gap,
  gap_single_client = true,

  -- Taglist: square buttons with a primary background when selected,
  -- matching the Waybar workspace style.
  taglist_font = theme.font,
  taglist_fg_focus = colors.foreground,
  taglist_bg_focus = colors.primary,
  taglist_fg_urgent = colors.background,
  taglist_bg_urgent = theme.urgent,
  taglist_fg_occupied = colors.foreground,
  taglist_bg_occupied = colors.background,
  taglist_fg_empty = colors.foreground,
  taglist_bg_empty = colors.background,
  taglist_shape = gears.shape.rectangle,
  taglist_shape_border_width = 0,
  taglist_shape_border_color = colors.primary,
  taglist_spacing = 0,

  -- Wibar: full-width, square and without an outline.
  wibar_bg = colors.background,
  wibar_fg = colors.foreground,
  wibar_height = theme.bar_height,
  wibar_border_width = 0,
  wibar_shape = gears.shape.rectangle,
  wibar_ontop = true,

  -- Tooltips and notifications. Gruvbox colours, no rounded corners.
  tooltip_bg = colors.background,
  tooltip_fg = colors.foreground,
  tooltip_border_width = 2,
  tooltip_border_color = colors.primary,
  tooltip_font = theme.font,
  tooltip_opacity = 1,
  tooltip_shape = gears.shape.rectangle,

  notification_bg = colors.background,
  notification_fg = colors.foreground,
  notification_border_width = 2,
  notification_border_color = colors.primary,
  notification_font = theme.font,
  notification_shape = gears.shape.rectangle,

  -- Systray.
  bg_systray = colors.background,
  systray_icon_spacing = 8,
})

return theme
