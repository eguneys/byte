Player = Object:extend()
Player:implement(GameObject)
Player:implement(Physics)
function Player:init(args)
   self:init_game_object(args)

   self.volride = args.volride

   self:set_as_rectangle(0, 0, 2, 2)

   self.velocity = Group()

   self.walk_left = self.velocity:add(Walk{prop =function (v) self.dx=v*-1 end })
   self.walk_right = self.velocity:add(Walk{prop=function(v) self.dx=v end})
   self.walk_up = self.velocity:add(Walk{prop=function(v) self.dy=v*-1 end})
   self.walk_down = self.velocity:add(Walk{prop=function(v) self.dy=v end})

   self.allow_dash = false
   self:get_grounded_lazy()
end

function Player:get_grounded_lazy()
   self.grounded = self.volride:is_colliding_with_point(self.body.cx, self.body.cy)
end

function Player:collide_base(body)
   if self.allow_dash then
      return not self.volride:is_colliding_with_point_inside(self.body.cx, self.body.cy)
   elseif not self.grounded then
      return false
   else 
      return not self.volride:is_colliding_with_point(body.cx, body.cy)
   end
end

function Player:collide_x(body)
   return self:collide_base(body)
end

function Player:collide_y(body)
   return self:collide_base(body)
end


function Player:update(dt)

   local p_cx, p_cy = self.body.cx, self.body.cy

   self:update_game_object(dt)

   local c_cx, c_cy = self.body.cx, self.body.cy

   -- dbg=self.body.cx..'|'..self.body.cy
   -- print(self:grounded()and'yes'or'no')

   self.grounded_before = self.grounded
   self:get_grounded_lazy()


   if self.grounded and not self.grounded_before then
      self.volride:extend(c_cx, c_cy)
      self.volride:stop()
   end

   if self.grounded_before and not self.grounded then
      self.volride:start(p_cx,p_cy,c_cx,c_cy)
   elseif self.volride:is_dash() then
      self.volride:extend(c_cx, c_cy)
   end

   if Input:btn('left') > 0 then
      self.walk_up:cut()
      self.walk_down:cut()
      self.walk_left:request()
   else
      self.walk_left:cut()
   end
   if Input:btn('right') > 0 then
      self.walk_up:cut()
      self.walk_down:cut()
      self.walk_right:request()
   else
      self.walk_right:cut()
   end

   if Input:btn('up') > 0 then
      self.walk_left:cut()
      self.walk_right:cut()
      self.walk_up:request()
   else
      self.walk_up:cut()
   end
   if Input:btn('down') > 0 then
      self.walk_left:cut()
      self.walk_right:cut()
      self.walk_down:request()
   else
      self.walk_down:cut()
   end

   if Input:btn('x') > 0 then
      self.allow_dash = true
   else
      self.allow_dash = false
   end

   self.velocity:update(dt)

end


function Player:draw()
   self:draw_game_object({ r=1,g=1,b=0,a=1 }, 1)
end
