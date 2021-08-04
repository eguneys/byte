Sentient=Object:extend()
Sentient:implement(GameObject)
Sentient:implement(Physics)
function Sentient:init(args)
   self:init_game_object(args)
   
   self:set_as_rectangle(2, 2, 6, 3)

   self.room = args.room
   self.rooms = self.room.rooms

   self.x = self.room.rect.x + (self.x - 1) * 4 - self.shape.x - self.shape.w / 2
   self.y = self.room.rect.y + (self.y - 1) * 4 - self.shape.y - self.shape.h / 2

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

end

function Sentient:get_facing()
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

function Sentient:get_grounded()

   self.was_grounded = self.grounded or false

   self.grounded = self.room:collide_solid(self.body.x,
                                           self.body.y+1,
                                           self.body.w,
                                           self.body.h)
end

function Sentient:collide_base(body)
   return self.room:collide_solid(
      body.x,
      body.y,
      body.w,
      body.h)

end

function Sentient:update(dt)
   self:update_game_object(dt)

   self:get_grounded()
   self:get_facing()

   self.t:update(dt)

   self.velocity:update(dt)

   
end

function Sentient:draw()
   self:draw_game_object()
end
