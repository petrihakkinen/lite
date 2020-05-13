local style = require "core.style"
local common = require "core.common"

local context_menu = {}


local function get_item_height()
  return style.font:get_height() + style.padding.y
end


function context_menu.show(x, y, items, handlers)
  local menu = { x = x, y = y, width = 0, items = items, handlers = handlers }
  for _, item in ipairs(items) do
    menu.width = math.max(menu.width, style.font:get_width(item))
  end
  menu.width = menu.width + 40
  menu.height = #items * get_item_height()
  context_menu.menu = menu
end


function context_menu.cancel()
  context_menu.menu = nil
end


function context_menu.draw()
  local menu = context_menu.menu
  if menu == nil then return end

  renderer.draw_rect(menu.x, menu.y, menu.width, menu.height, style.background)

  local x = menu.x
  local y = menu.y
  local w = menu.width
  local h = get_item_height()

  for i, item in ipairs(menu.items) do
    local color = style.text

    -- hovered item background
    if i == menu.hovered_item then
      renderer.draw_rect(x, y, w, h, style.line_highlight)
      color = style.accent
    end

    common.draw_text(style.font, color, item, "center", x + w / 2, y, 0, h)
    y = y + h
  end
end


function context_menu.is_overlapping_with_point(x, y)
  local menu = context_menu.menu
  return menu and x >= menu.x and y >= menu.y and x <= menu.x + menu.width and y <= menu.y + menu.height
end


function context_menu.on_mouse_pressed(button, x, y, clicks)
  local menu = context_menu.menu
  assert(menu and menu.hovered_item)
  context_menu.cancel()
  local handler = menu.handlers[menu.items[menu.hovered_item]]
  if handler then
    handler()
  end
end


function context_menu.on_mouse_moved(x, y, dx, dy)
  local menu = context_menu.menu
  if menu then
    local h = get_item_height()
    menu.hovered_item = common.clamp(math.floor((y - menu.y) / h) + 1, 1, #menu.items)
  end
end


return context_menu
