Player = Object:extend()
Player:implement(GameObject)
Player:implement(Physics)
function Player:init(args)
   self:init_game_object(args)

   self:set_as_rectangle(0, 0, 3, 3)
end


function Player:update(dt)
   self:update_game_object(dt)

   
end


function Player:draw()
   self:draw_game_object()
end
