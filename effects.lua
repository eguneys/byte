SmokeGroup = Object:extend()
SmokeGroup:implement(GameObject)
function SmokeGroup:init(args)
   self:init_game_object(args)

   self.main = Group()

   for i=1,self.n do
      local delay = random:float(ticks.third * self.n/5, ticks.one)
      trigger:after(delay, function()
                       Smoke {
                          group=self.main,
                          x=self.x + random:float(-4, 4),
                          y=self.y+ random:float(-4, 4),
                          r=((ticks.third-delay)/ticks.third) * 8 + random:float(-4, 4)
                       }
      end)
   end

   trigger:after(ticks.second*3, function()
                    self.dead = true
   end)
end

function SmokeGroup:update(dt)
   self:update_game_object(dt)

   self.main:update(dt)
end

function SmokeGroup:draw()
   self.main:draw()
end


Smoke = Object:extend()
Smoke:implement(GameObject)
function Smoke:init(args)
   self:init_game_object(args)

   self.color = colors.light

   self._t = random:float(ticks.second * 2, ticks.lengths)

   self.angle = math.pi * random:float(0, 2)
   self.line = Vector(0, 0)

   self.line2 = Vector(0, 0)

end

function Smoke:update(dt)
   self:update_game_object(dt)

   self._t = self._t - dt

   self.r = math.lerp(random:float(0.1, 0.2), self.r, 0)

   self.x = math.lerp(random:float(0.1, 0.3), self.x, self.x+self.r*2*random:sign())
   self.y = math.lerp(random:float(0.1, 0.3), self.y, self.y-self.r)

   self.line.x = math.cos(self.angle) * self.r
   self.line.y = math.sin(self.angle) * self.r

   self.line2.x = math.lerp(0.5, self.line2.x, self.line2.x + math.cos(self.angle) * self.r)
   self.line2.y = math.lerp(0.5, self.line2.y, self.line2.y + math.sin(self.angle) * self.r)

   if self._t < 0 then
      self.dead = true
   elseif self._t < ticks.lengths then
   elseif self._t < (ticks.second * 2 - ticks.half) then
      self.color = colors.red
   elseif self._t < (ticks.second * 2 - ticks.third) then
      self.color = colors.red
   elseif self._t < (ticks.second * 2 - ticks.sixth) then
      self.color = colors.dark_red
   end

end

function Smoke:draw()
   graphics.circle(self.x, self.y,
                   self.r,
                   self.color)

   graphics.line(self.line2.x + self.x - self.line.x,
                 self.line2.y + self.y - self.line.x,
                 self.line2.x + self.x + self.line.x,
                 self.line2.y + self.y + self.line.y,
                 colors.violet, random:int(1, 8))
end


Slash = Object:extend()
Slash:implement(GameObject)
function Slash:init(args)
   self:init_game_object(args)

   self.a_horiz = anim8.newAnimation(g32('1-4', 4), ticks.third/4, 'pauseAtEnd')
   self.a_diag = anim8.newAnimation(g32('1-4', 3), ticks.third/4, 'pauseAtEnd')

   self.ox, self.oy, self.angle = 0, 0, 0
   if self.direction.x == -1 then
      if self.direction.y == -1 then
         self.ox=0
         self.oy=32
         self.angle = -math.pi*0.5
         self.a_current = self.a_diag
      elseif self.direction.y == 0 then
         self.angle = -math.pi
         self.oy = 16
         self.a_current = self.a_horiz
      elseif self.direction.y == 1 then
         self.oy = 32
         self.angle = -math.pi*1
         self.a_current = self.a_diag
      end
   elseif self.direction.x == 0 then
      self.oy = 16
      self.a_current = self.a_horiz
      if self.direction.y == -1 then
         self.angle = math.pi*1.5
      elseif self.direction.y == 1 then
         self.angle = math.pi*0.5
      end
   elseif self.direction.x == 1 then
      if self.direction.y == -1 then
         self.oy = 32
         self.angle = 0
         self.a_current = self.a_diag
      elseif self.direction.y == 0 then
         self.oy = 16
         --self.angle = math.pi*0.25
         self.a_current = self.a_horiz
      elseif self.direction.y == 1 then
         self.oy = 32
         self.angle = math.pi*0.5
         self.a_current = self.a_diag
      end
   end

   self.t:after(ticks.third, function()
                   self:remove_game_object()
   end)
end

function Slash:update(dt)
   self.x = math.lerp(0.5, self.x, self.x + self.direction.x)
   self.y = math.lerp(0.5, self.y, self.y + self.direction.y)
   self:update_game_object(dt)
   self.a_current:update(dt)
end

function Slash:draw()
   local x, y = math.floor(self.x), math.floor(self.y)
   self.a_current:draw(sprites, x, y, self.angle, 1, 1, self.ox, self.oy)
end


DashTrail = Object:extend()
DashTrail:implement(GameObject)
function DashTrail:init(args)
   self:init_game_object(args)

   self.lx = 0 --self.direction.x * 8
   self.ly = 0 --self.direction.y * 8
   self.die_thres = random:float(0, ticks.sixth * 2)
   -- self.x = self.x - self.lx
   -- self.y = self.y - self.ly

   self.color = colors.red
end

function DashTrail:update(dt)

   self.die_thres = self.die_thres - dt

   if self.die_thres > ticks.sixth then
      self.lx = math.lerp(0.4, self.lx, self.direction.x * 8)
      self.ly = math.lerp(0.4, self.ly, self.direction.y * 8)
   elseif self.die_thres < ticks.sixth then
      self.lx = math.lerp(0.3, self.lx, 0.1)
      self.ly = math.lerp(0.3, self.ly, 0.1)
      self.color = colors.dark_red
   end

   if self.die_thres < 0 then
      self:remove_game_object()
   end
end

function DashTrail:draw()
   graphics.line(self.x, self.y, self.x - self.lx, self.y - self.ly, self.color, 1)
end
