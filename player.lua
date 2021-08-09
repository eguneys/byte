Player = Object:extend()
Player:implement(GameObject)
Player:implement(Physics)
function Player:init(args)
   self:init_game_object(args)
   
   self:set_as_rectangle(2, 2, 3, 6)

   self.rooms = args.rooms
   self.room = args.room

   local x, y

   self.room.ch(function(x,y,c)
         if (c == '@') then
            self.x = self.room.rect.x + (x - 1) * 4
            self.y = self.room.rect.y + (y - 1) * 4 - 5
         end
   end)

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

   self.dash = self.velocity:add(Dash{prop=function(vx, vy)
                                         self.dx = vx
                                         self.dy = vy
                                end,
                                      begin_hook = function(direction)
                                         Slash {
                                            group = self.rooms.main,
                                            x = self.body.cx,
                                            y = self.body.cy,
                                            direction=direction
                                         }
                                end})

   self.t = Trigger()

   self:get_facing()
   self:get_grounded()
   self:get_camera_target()
   self:get_pickup_target()
   self:get_jumping()

   self.a_idle = anim8.newAnimation(g8(1, 1), ticks.second)
   self.a_fall = anim8.newAnimation(g8(2, 1), ticks.second)
   self.a_run = anim8.newAnimation(g8('7-10', 1), ticks.third/4)
   self.a_jump = anim8.newAnimation(g8('3-6', 1), (ticks.third + ticks.lengths)/4, 'pauseAtEnd')

   self.a_dash = anim8.newAnimation(g8('11-13', 1), ticks.sixth/3)

   self.a_current = self.a_idle

end

function Player:get_jumping()
   self.ing_jump_lift = false
   if self.jump:is_accel() then
      self.ing_jump_lift = true
   end

   self.was_dash = self.ing_dash or false
   self.ing_dash = true
   if self.dash:is_rest() then
      self.ing_dash = false
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

   self.grounded = self.room:collide_solid(self.body.x,
                                           self.body.y+1,
                                           self.body.w,
                                           self.body.h)

   if self.grounded then
      self.dampen_x = 1
   else
      self.dampen_x = math.lerp(0.01, self.dampen_x, 0.3)
   end

end

function Player:get_pickup_target()
   if not self.pickup_target then
      self.pickup_target = Vector(0, 0)
   end

   self.pickup_target.x = self.body.cx
   self.pickup_target.y = self.body.cy
end

function Player:get_camera_target()
   if not self.camera_target then
      self.camera_target = Vector(0, 0)
   end

   self.camera_target.x = self.body.cx
   self.camera_target.y = self.body.cy
end

function Player:collide_base(body)
   return self.room:collide_solid(
      body.x,
      body.y,
      body.w,
      body.h)

end

function Player:check_room_transition()
   local to
   for _, room in pairs(self.rooms.rooms) do
      if room ~= self.room then
         if room.rect:is_colliding_with_polygon(self.body) then
            to = room
            break
         end
      end
   end
   if to then
      self.room = to
      self.rooms:check_room_transition(to)
      return true
   end
   return false
end

function Player:update(dt)

   self:update_game_object(dt)

   local d_left, d_right = self.body.x - self.room.rect.x,
   self.body.x2 - self.room.rect.x2
   if d_left <= 0 then
      if self:check_room_transition() then
         self.x = self.x + d_left - 4
      else
         self.x = self.x - d_left
      end
   end
   if d_right >= 0 then
      if self:check_room_transition() then
         self.x = self.x + d_right + 4
      else
         self.x = self.x - d_right - 1
      end
   end
   self:get_body()


   self:get_camera_target()
   self:get_pickup_target()
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

   if self.grounded and not self.ing_dash then
      self.dash:replenish()
   end

   if self.ing_dash then

      if not self.was_dash then
         self.rooms.main.camera:shake(8, ticks.sixth, 16)
      end

      local enemy = self.room:collide_objects(self.body)

      if enemy ~= nil then
         enemy:damage(Vector(self.dash.direction.x,
                             self.dash.direction.y))
      end


      for i=1,2 do
         if random:sign() == 1 then
            DashTrail{
               group=self.rooms.main,
               x=self.body.cx + random:int(-4,4),
               y=self.body.cy + random:int(-4,4),
               direction=self.dash.direction
            }
         end
      end
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

   if Input:btn('c') ~= 0 then
      self.dash:request(self.facing)
   end

   self.velocity:update(dt)

   if self.ing_dash then
      if self.a_current ~= self.a_dash then
         self.a_current = self.a_dash
         self.a_current:gotoFrame(1)
      end
   elseif self.ing_jump_lift then
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

Rock = Object:extend()
Rock:implement(GameObject)
Rock:implement(Physics)
function Rock:init(args)
   self:init_game_object(args)
   self:set_as_rectangle(2, 2, 4, 4)


   self.rooms = args.rooms
   self.player = args.player
   self.i_t = 0

   self.throw = Throw{prop= function(vx, vy)
                         self.dx=vx*self.throw_dir
                         self.dy=vy
                     end}

   self.a_idle = anim8.newAnimation(g8(1, 2), ticks.second)
   self.a_throw = anim8.newAnimation(g8('2-4', 2), ticks.lengths/3)
   self.a_crush = anim8.newAnimation(g8('5-7', 2), ticks.sixth/3, 'pauseAtEnd')

   self.a_current = self.a_idle

   self.ing_throw = false

   self._t = Trigger()
end

function Rock:collide_base(body)
   return self.room:collide_solid(
      body.x,
      body.y,
      body.w,
      body.h) or
      self.room:collide_bounds(body.x, body.y)
end

function Rock:just_collided()
   self.ing_crash = self.ing_throw
   self.ing_throw = false
   self._t:after(ticks.sixth, function()
                    self.dead = true
   end)
end

function Rock:request_throw()
   self.throw_dir = self.player.facing + math.sign(self.player.dx) * 0.5
   self.ing_throw = true
   self.room = self.player.room
   self.throw:request()
   self.player = nil
end

function Rock:update(dt)

   self._t:update(dt)
   self.i_t = self.i_t + dt

   if self.player then
      local px, py = 
         self.player.pickup_target.x + (self.player.facing == -1 and -self.player.body.w or 1),
      self.player.pickup_target.y - self.body.h / 2

      px = px - self.shape.x
      py = py - self.shape.y

      self.x = math.lerp(1, self.x, px)
      self.y = math.lerp(1, self.y, py + 
                            (0.5 + 0.4 * math.sign(self.player.dy * -1)) * 
                            math.sin(self.i_t * 2*math.pi/
                                        (ticks.second + 
                                            ticks.half * math.sign(self.player.dy))))
   end

   self:update_game_object(dt)

   if self.ing_throw then
      self.throw:update(dt)
   elseif self.ing_crash then
      self.dx = 0
      self.dy = 0
   end

   if self.ing_crash then
      if self.a_current ~= self.a_crush then
         self.a_current = self.a_crush
      end
   elseif self.ing_throw then
      if self.a_current ~= self.a_throw then
         self.a_current = self.a_throw
         self.a_current:gotoFrame(1)
      end
   end

   self.a_current:update(dt)
end

function Rock:draw()
   local x, y = math.floor(self.x), math.floor(self.y)
   self.a_current:draw(sprites, x, y)
end
