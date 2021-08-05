Image = Object:extend()
function Image:init(asset_name)
   self.image = love.graphics.newImage('assets/' .. asset_name .. '.png')
   self.w = self.image:getWidth()
   self.h = self.image:getHeight()
end

function Image:draw(x, y)
   love.graphics.draw(self.image, x, y)
end
