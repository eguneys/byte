Tank = Object:extend()
Tank:implement(GameObject)
Tank:implement(Physics)
function Tank:init(args)
   self:init_game_object(args)

   self.volride = args.volride

   self:set_as_rectangle(0, 0, 20, 20)

   self.velocity = Group()

   self.walk_up = self.velocity:add(Walk{
                                         speed=0.5,
                                         prop=function (v) self.dy=v*-1 end
   })
   self.walk_down = self.velocity:add(Walk{
                                             speed=0.5,
                                             prop=function(v) self.dy=v end
   })
   self.walk_left = self.velocity:add(Walk{
                                         speed=0.5,
                                         prop=function (v) self.dx=v*-1 end
   })
   self.walk_right = self.velocity:add(Walk{
                                             speed=0.5,
                                             prop=function(v) self.dx=v end
   })


   self.direction = {x=1,y=0}

   self.t_walk = Trigger()

   self.collide_nb = 0

   trigger:every(2, function()
                    self.collide_nb = self.collide_nb - 1

                    if self.collide_nb > 10 then
                       self.collide_nb = 0
                       self:reshape(self.body.w / 2,
                                    self.body.h / 2)
                    end
   end)

   self:scheduleWalk()
end

function Tank:scheduleWalk()
   self.t_walk:after(random:int(1, 3), function()
                        self.direction.x = random:sign(50)
                        self.direction.y = random:sign(50)

                        if random:bool() then
                           if random:bool() then
                              self.direction.x = 0 
                           else
                              self.direction.y = 0
                           end
                        end
                        self:scheduleWalk()
   end)
end

function Tank:collide_base(body)
   local res = not self.volride.ground:is_polygon_inside(self.body)

   if not res and self.volride.body then
      res = self.volride.body:is_colliding_with_polygon(self.body)
   end

   if (res) then
      self.direction.x = self.direction.x * -1
      self.direction.y = self.direction.y * -1

      self.collide_nb = self.collide_nb + 1
   end
   return res
end

function Tank:collide_x(body)
   return self:collide_base(body)
end

function Tank:collide_y(body)
   return self:collide_base(body)
end

function Tank:update(dt)
   self:update_game_object(dt)

   self.volride:set_target(self.body.cx, self.body.cy)

   self.t_walk:update(dt)

   dbg=self.collide_nb

   if self.direction.x < 0 then
      self.walk_right:cut()
      self.walk_left:request()
   elseif self.direction.x > 0 then
      self.walk_left:cut()
      self.walk_right:request()
   else 
      self.walk_left:cut()
      self.walk_right:cut()
   end
   if self.direction.y < 0 then
      self.walk_up:cut()
      self.walk_down:request()
   elseif self.direction.y > 0 then
      self.walk_down:cut()
      self.walk_up:request()
   else 
      self.walk_down:cut()
      self.walk_up:cut()
   end

   self.velocity:update(dt)
end

function Tank:draw()
   self:draw_game_object({ r = 1, g=0, b=0, a=1 }, 1)
end
