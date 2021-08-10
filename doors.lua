Door = Object:extend()
Door:implement(GameObject)
Door:implement(Physics)
function Door:init(args)
   self:init_game_object(args)

   self:set_as_rectangle(1, 0, 6, 16)

   self.unlock_solids = Vector(self.x, self.y)

   self:set_lock(self)

   self.x = self.room.rect.x + (self.x - 1) * 4 - self.shape.x
   self.y = self.room.rect.y + (self.y - 1) * 4 - self.shape.x

   self.a_idle = anim8.newAnimation(g82(1, 3), ticks.second)
end

function Door:set_lock(value)
   for i=1,4 do
      self.room.grid:get(self.unlock_solids.x, self.unlock_solids.y + i, value)
   end
end


function Door:update(dt)
   self:update_game_object(dt)
   self.a_idle:update(dt)
end

function Door:draw()
   local x, y = math.floor(self.x), math.floor(self.y)
   self.a_idle:draw(sprites, x, y)
   self:draw_game_object()
end
