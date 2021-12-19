XMouse = Object:extend()
function XMouse:init()
  local x, y = love.mouse.getPosition()
  self.x, self.y = x / sx, y / sy
end


function XMouse:move(x, y, dx, dy)
  self.x, self.y = x / sx, y / sy
end

function XMouse:btn(x, y, button)
  if button == 1 then
    self.cur = { x, y }
  end
end

function XMouse:btn_release(x, y, button)
  if button == 1 then
    self.cur = nil
  end
end

Mouse = XMouse()

function love.mousepressed(x, y, button)
  Mouse:btn(x, y, button)
end

function love.mousereleased(x, y, button)
  Mouse:btn_release(x, y, button)
end

function love.mousemoved(x, y, dx, dy)
  Mouse:move(x, y, dx, dy)
end
