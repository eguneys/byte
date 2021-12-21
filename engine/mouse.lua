XMouse = Object:extend()
function XMouse:init()
  local x, y = love.mouse.getPosition()
  self.x, self.y = x / sx, y / sy

  self._btn = {}
end

function XMouse:update(dt)
  for input,t in pairs(self._btn) do
    if (t ~= 0) then
      self._btn[input] = t + 1
    end
  end
end

function XMouse:setxy(x, y)
  self.x, self.y = x / sx, y / sy
  self.y = self.y - 2
end

function XMouse:move(x, y, dx, dy)
  self:setxy(x, y)
end

function XMouse:btn_press(x, y, button)
  self._btn[button] = 1 
  self:setxy(x, y)
end

function XMouse:btn_release(x, y, button)
  self._btn[button] = -2 
end

function XMouse:btn(button)
  return self._btn[button or 1] or 0
end

Mouse = XMouse()

function love.mousepressed(x, y, button)
  Mouse:btn_press(x, y, button)
end

function love.mousereleased(x, y, button)
  Mouse:btn_release(x, y, button)
end

function love.mousemoved(x, y, dx, dy)
  Mouse:move(x, y, dx, dy)
end
