Player = Object:extend()
Player:implement(GameObject)
Player:implement(Physics)
function Player:init(args)
   self:init_game_object(args)
   
   self:set_as_rectangle(0, 0, 4, 4)

   self.room = args.room

   self.velocity = Group()
   
   self.walk_left = self.velocity:add(Walk{prop =function (v) self.dx=v*-1 end })
   self.walk_right = self.velocity:add(Walk{prop=function(v) self.dx=v end})

   self.jump = self.velocity:add(Jump{prop=function(v) self.dy = v end})

   self.t = Trigger()

   self:get_grounded()

end

function Player:get_grounded()

   self.was_grounded = self.grounded or false

   self.grounded = self.room.grid:collide_solid(self.body.x,
                                                self.body.y+1,
                                                self.body.w,
                                                self.body.h)

end

function Player:set_room(room)
   self.room = room
end

function Player:collide_base(body)
   return self.room.grid:collide_solid(body.x,
                                       body.y,
                                       body.w,
                                       body.h)

end

function Player:update(dt)

   self:update_game_object(dt)

   self:get_grounded()

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
