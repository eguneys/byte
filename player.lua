Player = Object:extend()
Player:implement(GameObject)
Player:implement(Physics)
function Player:init(args)
   self:init_game_object(args)
   
   self:set_as_rectangle(2, 2, 3, 6)

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

   self:get_facing()
   self:get_grounded()
   self:get_camera_target()
   self:get_jumping()

   self.a_idle = anim8.newAnimation(g8(1, 1), ticks.second)
   self.a_fall = anim8.newAnimation(g8(2, 1), ticks.second)
   self.a_run = anim8.newAnimation(g8('7-10', 1), ticks.third/4)
   self.a_jump = anim8.newAnimation(g8('3-6', 1), (ticks.third + ticks.lengths)/4, 'pauseAtEnd')

   self.a_current = self.a_idle

end

function Player:get_jumping()
   self.ing_jump_lift = fale
   if self.jump:is_accel() then
      self.ing_jump_lift = true
   end
end

function Player:get_facing()
   if self.facing == nil then
      self.facing = 1
   end
   self.walking = false
   if self.walk_left:is_pace() then
      self.walking = true
      self.facing = -1
   elseif self.walk_right:is_pace() then
      self.walking = true
      self.facing = 1
   end
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

function Player:check_room_transition()
   local to
   for _, room in pairs(self.rooms.rooms) do
      if room ~= self.rooms.room then
         if room.rect:is_colliding_with_polygon(self.body) then
            to = room
            break
         end
      end
   end
   if to then
      self.rooms:check_room_transition(to)
   end
end

function Player:update(dt)

   self:update_game_object(dt)

   local d_left, d_right = self.body.cx - self.rooms.room.rect.x,
   self.body.cx - self.rooms.room.rect.x2

   if d_left < 0 then
      self:check_room_transition()
      self.x = self.x - d_left
   end
   if d_right > 0 then
      self:check_room_transition()
      self.x = self.x - d_right
   end
   self:get_body()


   self:get_camera_target()
   self:get_grounded()
   self:get_facing()
   self:get_jumping()

   if self.dampen_x <= 0.51 then
      self.dampen_x = math.lerp(0.1, self.dampen_x, 0.4)
   elseif self.dampen_x <= 0.81 then
      self.dampen_x = math.lerp(0.05, self.dampen_x, 0.5)
   elseif self.dampen_x < 1 then
      self.dampen_x = math.lerp(0.1, self.dampen_x, 0.8)
   end

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

   if self.ing_jump_lift then
      if self.a_current ~= self.a_jump then
         self.a_current = self.a_jump
         self.a_current:gotoFrame(1)
         self.a_current:resume()
      end
   elseif self.grounded == false then
      if self.a_current ~= self.a_fall then
         self.a_current = self.a_fall
         self.a_current:gotoFrame(1)
      end
   elseif self.walking then
      if self.a_current ~= self.a_run then
         self.a_current = self.a_run
         self.a_current:gotoFrame(1)
      end
   else
      if self.a_current ~= self.a_idle then
         self.a_current = self.a_idle
         self.a_current:gotoFrame(1)
      end
   end

   self.a_current:update(dt)
   self.a_current:flipH(self.facing==-1)
end

function Player:draw()
   local x, y = math.floor(self.x), math.floor(self.y)
   self.a_current:draw(sprites, x, y)
end
