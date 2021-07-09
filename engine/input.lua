XInput = Object:extend()
function XInput:init()
   self._btn = {}
end

function XInput:update()
   for input,t in pairs(self._btn) do
      if (t ~= 0) then
         self._btn[input] = t + 1
      end
   end
end

function XInput:press(key)
   if (not self._btn[key] or self._btn[key] <= 0) then
      self._btn[key] = 1
   end
end

function XInput:release(key)
   if (self._btn[key]) then
      self._btn[key] = -10
   end
end

function XInput:btn(key)
   return self._btn[key] or 0
end

Input=XInput()

function love.keypressed(key)
   Input:press(key)
end

function love.keyreleased(key)
   Input:release(key)
end
