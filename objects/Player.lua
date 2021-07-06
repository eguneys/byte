Player = GameObject:extend()

function Player:new(area, x, y, opts)
   Player.super.new(self, area, x, y, opts)
end

function Player:update()
end

function Player:draw()
   love.graphics.circle('line', self.x, self.y, 10)
end
