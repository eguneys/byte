Sentient=Object:extend()
Sentient:implement(GameObject)
Sentient:implement(Physics)
function Sentient:init(args)
   self:init_game_object(args)
   
   self:set_as_rectangle(3, 3, 10, 10)

   self.room = args.room
   self.rooms = self.room.rooms

   self.x = self.room.rect.x + (self.x - 1) * 4 - self.shape.x - self.shape.w / 2
   self.y = self.room.rect.y + (self.y - 1) * 4 - self.shape.y - self.shape.h / 2


   self.a_idle = anim8.newAnimation(g16('1-3', 3), ticks.second)
   self.a_shoot = anim8.newAnimation(g8('1-3', 4), ticks.second)

   self.a_idle:flipH(self.direction.x==-1):pause()
   self.a_shoot:flipH(self.direction.x == -1)

   self.a_current = self.a_idle

   self._spring = { x = Spring(1),
                    y = Spring(1) }

   self._t = 0

   self.damage_direction = Vector(0, 0)
   
   self.health = 3

   self.t_immune = 0
end

function Sentient:damage(direction)
   if self.t_immune > 0 then return end

   self.health = self.health - 1
   self._spring.x:pull(direction.x*8, 100, 2)
   self._spring.y:pull(direction.y*8, 100, 2)

   self.t_immune = ticks.second

   SmokeGroup {
      group=self.rooms.main,
      x=self.x,
      y=self.y
   }
end

function Sentient:update(dt)
   self:update_game_object(dt)

   if self.t_immune > 0 then
      self.t_immune = self.t_immune - dt
   end

   self._spring.x:update(dt)
   self._spring.y:update(dt)
   self._t = self._t + dt

   if self.health < 1 then
      self.dead = true
   else
      self.a_idle:gotoFrame(4 - self.health)
   end

   if self.spring.x == 1 then
      self.x = math.lerp(0.2, self.x, self.x + (0.2 + self.direction.y) * math.sin(self._t * 2 * math.pi * 2))
      self.y = math.lerp(0.2, self.y, self.y + (0.1 + self.direction.x) * math.sin(self._t * 2 * math.pi * 4))
   end

   self.a_current:update(dt)
end

function Sentient:draw()
   local x, y = math.floor(self.x + self._spring.x.x),
   math.floor(self.y + self._spring.y.x)

   self.a_current:draw(sprites, x, y)
end
