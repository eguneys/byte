Play = Object:extend()

dbg = ''

function Play:init()

  self.tiles = Tiles()
end

function Play:update(dt)
  self.tiles:update(dt)
end

function Play:draw()

  self.tiles:draw()


   if dbg then
      love.graphics.setColor(1,0,0,1)
      love.graphics.print(dbg, 0, 0)
   end
end
