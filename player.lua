Player = Object:extend()
Player:implement(GameObject)
Player:implement(Physics)
function Player:init(args)
   self:init_game_object(args)
   
   self:set_as_rectangle(0, 0, 4, 4)

   self.rooms = args.rooms

   self.velocity = Group()

   self.dampen_x = 1

   self.walk_left = self.velocity:add(
      Walk{prop =function (v)
              self.dx=v*-1*self.dampen_x
   end })
   self.walk_right = self.velocity:add(
      Walk{prop=function(v) 
              self.dx=v*self.dampen_x
   end})

   self.jump = self.velocity:add(Jump{prop=function(v) self.dy = v end})

   self.t = Trigger()

   self:get_grounded()
   self:get_camera_target()

end

function Player:get_grounded()

   self.was_grounded = self.grounded or false

   self.grounded = self.rooms.room:collide_solid(self.body.x,
                                           self.body.y+1,
                                           self.body.w,
                                           self.body.h)

   if self.grounded then
      self.dampen_x = 1
   else
      self.dampen_x = math.lerp(0.01, self.dampen_x, 0.3)
   end

end

function Player:get_camera_target()
   if not self.camera_target then
      self.camera_target = Vector(0, 0)
   end

   self.camera_target.x = self.body.cx
   self.camera_target.y = self.body.cy
end

function Player:collide_base(body)
   return self.rooms.room:collide_solid(
      body.x,
      body.y,
      body.w,
      body.h)

end

function Player:update(dt)

   self:update_game_object(dt)

   local d_left, d_right = self.body.cx - self.rooms.room.rect.x,
   self.body.cx - self.rooms.room.rect.x2

   if d_left < 0 then
      self.rooms:check_room_transition()
      self.x = self.x - d_left
   end
   if d_right > 0 then
      self.rooms:check_room_transition()
      self.x = self.x - d_right
   end
   self:get_body()


   self:get_camera_target()
   self:get_grounded()

   if self.dampen_x <= 0.51 then
      self.dampen_x = math.lerp(0.1, self.dampen_x, 0.4)
   elseif self.dampen_x <= 0.81 then
      self.dampen_x = math.lerp(0.05, self.dampen_x, 0.5)
   elseif self.dampen_x < 1 then
      self.dampen_x = math.lerp(0.1, self.dampen_x, 0.8)
   end

   print(self.dampen_x)

   self.grace_time_on = self.grounded

   if self.was_grounded and not self.grounded then
      self.t:during(ticks.lengths, 
                    function()
                       self.grace_time_on = true
      end, nil, 'grace')
   end

   self.t:update(dt)
   
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

   if Input:btn('x') ~= 0 then
      if self.grace_time_on then
         self.jump:request()
      end
   else
      self.jump:cut()
   end

   self.velocity:update(dt)
end

function Player:draw()
   self:draw_game_object({ r=1, g=1, b=0, a=1 }, 1)
end
