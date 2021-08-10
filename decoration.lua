Crate=Object:extend()
Crate:implement(GameObject)
Crate:implement(Physics)
function Crate:init(args)
   self:init_game_object(args)

   self:set_as_rectangle(0, 0, 8, 8)

   self.a_idle = anim8.newAnimation(g8(8, 2), ticks.second)
   
end

function Crate:update(dt)
   self:update_game_object(args)
end

function Crate:draw()
   self.draw_game_object()
end
