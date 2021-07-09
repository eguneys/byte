GameObject = Object:extend()
function GameObject:init_game_object(args)
   for k, v in pairs(args or {}) do self[k] = v end

   if self.group then self.group:add(self) end

   self.x, self.y = self.x or 0, self.y or 0
   self.spring = Spring(1)

   return self
end

function GameObject:update_game_object(dt)
   self.spring:update(dt)
   if self.body then self:update_physics(dt) end
end

function GameObject:draw_game_object(color, line_width)
   if self.body then self:draw_physics(color, line_width) end
end
