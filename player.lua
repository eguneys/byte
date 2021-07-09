Player = Object:extend()
Player:implement(GameObject)
Player:implement(Physics)
function Player:init(args)
   self:init_game_object(args)

   self:set_as_rectangle(0, 0, 2, 2)

   self.velocity = Group()

   self.walk_left = self.velocity:add(Walk(function (v) self.dx=v*-1 end))
   self.walk_right = self.velocity:add(Walk(function(v) self.dx=v end))
   self.walk_up = self.velocity:add(Walk(function(v) self.dy=v*-1 end))
   self.walk_down = self.velocity:add(Walk(function(v) self.dy=v end))

end


function Player:update(dt)
   self:update_game_object(dt)

   --dbg=self.body.cx..'|'..self.body.cy

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

   if Input:btn('up') > 0 then
      self.walk_up:request()
   else
      self.walk_up:cut()
   end
   if Input:btn('down') > 0 then
      self.walk_down:request()
   else
      self.walk_down:cut()
   end

   self.velocity:update(dt)

end


function Player:draw()
   self:draw_game_object({ r=1,g=1,b=0,a=1 }, 1)
end
