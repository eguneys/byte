Play = Object:extend()

dbg = ''

function Play:init()

   self.rooms = Rooms()
end

function Play:update(dt)
   self.rooms:update(dt)
end

function Play:draw()

   self.rooms:draw()

   if dbg then
      love.graphics.setColor(1,0,0,1)
      love.graphics.print(dbg, 0, 0)
   end
end
