
Tiles = Object:extend()


function Tiles:init()
  self.main = Group()
end

function Tiles:update(dt)
  self.main:update(dt)
end


function Tiles:draw()

  graphics.rectangle(0, 0, 80, 160, 8, 8, colors.dark)

  self.main:draw()

end
