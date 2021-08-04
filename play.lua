Play = Object:extend()

dbg = ''

function Play:init()

   self.dialogue = Dialogue()
   self.rooms = Rooms()

   self.show_rooms = false


   self.show_rooms = true
   -- self.dialogue:off()
   -- self.dialogue:cutscene(ticks.second*3, function()
   --                           self.dialogue:on()
   --                           self.show_rooms = true
   -- end)
   -- self.dialogue:print('[black]I am [red]hungry')
   
end

function Play:update(dt)
   self.dialogue:update(dt)
   self.rooms:update(dt)
end

function Play:draw()

   if self.show_rooms then
      self.rooms:draw()
   end
   self.dialogue:draw()

   if dbg then
      love.graphics.setColor(1,0,0,1)
      love.graphics.print(dbg, 0, 0)
   end
end
