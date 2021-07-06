Stage = Object:extend()

function Stage:new()
   self.area = Area(self)

   self.area:addGameObject(Player, 32, 32)
end

function Stage:update()
   
end

function Stage:draw()
   camera:attach(0, 0, gw, gh)
   love.graphics.circle('line', 32, 32, 32)
   self.area:draw()
   camera:detach()
end
