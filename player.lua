Player = Object:extend()
Player:implement(GameObject)
Player:implement(Physics)
function Player:init(args)
   self:init_game_object(args)
   self:set_as_rectangle(0, 0, 3, 3)

   self.velocity = Group()

   self.walk_left = self.velocity:add(Walk(self, -1))
   self.walk_right = self.velocity:add(Walk(self, 1))

end


function Player:update(dt)
   self:update_game_object(dt)

   if Input:btn('left') > 0 then
      self.walk_left:request()
   else
      self.walk_left:cut()
   end
   if Input:btn('right') > 0 then
      self.walk_right:request()
   else
      self.walk_right:cut()
   end

   self.velocity:update(dt)
   
end


function Player:draw()
   self:draw_game_object()
end
