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
