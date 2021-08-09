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

   self.a_sleep = anim8.newAnimation(g16('1-4', 2), ticks.half/4, 'pauseAtEnd')
   self.a_wake = anim8.newAnimation(g16('4-1', 2), ticks.half/4, 'pauseAtEnd')

   self:reset()
end

function Sentient:reset()
   self.t_sleep = -ticks.half
   self.a_current = self.a_wake
   self.a_current:gotoFrame(1)
   self.a_current:resume()
   self._spring = { x = Spring(1),
                    y = Spring(1) }
   self.rotate = 0
   self._t = 0
   self.damage_direction = Vector(0, 0)
   self.health = 3
   self.t_immune = 0
end

function Sentient:damage(direction)
   if self.t_sleep > 0 or self.t_immune > 0 then return false end
   self.health = self.health - 1
   self._spring.x:pull(direction.x*8, 100, 2)
   self._spring.y:pull(direction.y*8, 100, 2)

   self.t_immune = ticks.second

   SmokeGroup {
      group=self.rooms.main,
      x=self.x,
      y=self.y,
      n=5
   }

   return true
end

function Sentient:update(dt)
   self:update_game_object(dt)

   if self.t_immune > 0 then
      self.t_immune = self.t_immune - dt
      if self.t_immune < 0 then
         self.t_immune = 0
      end
   end

   if self.t_sleep > 0 then
      self.t_sleep = self.t_sleep - dt
      if self.t_sleep < 0 then
         self:reset()
      end
   end

   if self.t_sleep < 0 then
      self.t_sleep = self.t_sleep + dt
      if self.t_sleep > 0 then
         self.t_sleep = 0
      end
   end

   self._spring.x:update(dt)
   self._spring.y:update(dt)
   self._t = self._t + dt

   self.rotate = math.sin(-((self._spring.x.x + self._spring.y.x) / 4) * ticks.half +
                             self._t / ticks.half) * math.pi * 2
   self.rotate = math.round(self.rotate / (math.pi * 0.5)) * math.pi * 0.5

   if self.t_sleep == 0 and self.health < 1 then
      SmokeGroup {
         group=self.rooms.main,
         x=self.x,
         y=self.y,
         n=11
      }
      self.t_sleep = ticks.second * 10
      self.a_current = self.a_sleep
      self.a_current:gotoFrame(1)
      self.a_current:resume()
   end
   
   if self.spring.x == 1 then
      self.x = math.lerp(0.2, self.x, self.x + 0.2 * math.sin(self._t * 2 * math.pi * 2))
      self.y = math.lerp(0.2, self.y, self.y + 0.1 * math.sin(self._t * 2 * math.pi * 4))
   end

   self.a_current:update(dt)
end

function Sentient:draw()

   local x, y = math.floor(self.x + self._spring.x.x),
   math.floor(self.y + self._spring.y.x)

   local rl = self.rotate / math.pi * 2
   if self.t_sleep > 0 and self.t_sleep < ticks.second * 10 - ticks.half then
      x, y = math.floor(self.x), math.floor(self.y)
      graphics.line(8 + x + rl, 8 + y + rl,
                    8 + x - rl, 8 + y - rl, colors.black)
      graphics.line(8 + x - rl, 8 + y + rl,
                    8 + x + rl, 8 + y - rl, colors.black)
   else
      if self.t_sleep > 0 or self.t_immune % ticks.sixth < (ticks.sixth / 2) then
         self.a_current:draw(sprites, x + 8, y + 8, self.rotate, 1, 1, 8, 8)
      end
   end
end
