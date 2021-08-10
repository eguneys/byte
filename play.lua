Play = Object:extend()

dbg = ''

function Play:init()

   self.dialogue = Dialogue()
   self.rooms = Rooms{
      after_warmup =function(player_pos)
         -- self.dialogue:print('[black]I am [red]hungry')
         self.dialogue:spawn(
            player_pos,
            ticks.sixth, function()
               self.dialogue:on()
               self.show_rooms = true
         end)
      end,
      after_die= function(player_pos)
         self.dialogue:player_die(
            player_pos,
            ticks.sixth, function()
               self.rooms:load_last_checkpoint()
               
         end)
   end}


   self.show_rooms = false
   self.dialogue:off()

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
