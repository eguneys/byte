Camera = Object:extend()
function Camera:init(x, y, w, h)
   
   self.x, self.y = x, y
   self.w, self.h = w, h

   self.r, self.sx, self.sy = 0, 1, 1

   self.lerp = Vector(1, 1)
   self.last_target = Vector(0, 0)

   self.scroll = Vector(0, 0)

   self:set_deadzone()
   self:set_bounds(0, 0, 0, 0)


   self.shake_amount = Vector(0, 0)
   self.last_shake_amount = Vector(0, 0)
   self.shakes = { x = {}, y = {} }
end

function Camera:shake(intensity, duration, frequency)
   table.insert(self.shakes.x, Shake(intensity, duration or 0, frequency or 60))
   table.insert(self.shakes.y, Shake(intensity, duration or 0, frequency or 60))
end

function Camera:follow(target)
   self.target = target
end

function Camera:set_deadzone()

   local w, h = self.w / 8, self.h / 8
   local x, y = (self.w - w) / 2, 
   (self.h - h) / 2

   
   self.deadzone = { x = x, y = y, w = w, h = h }
end

function Camera:set_bounds(x, y, w, h)
   if self.bounds == nil then
      self.bounds = Rectangle(x, y, w, h)
   end
   self.target_bounds = Rectangle(x, y, w, h)
end

function Camera:update(dt)
   self.shake_amount:set(0, 0)
   for _, z in ipairs({"x", "y"}) do
      for i = #self.shakes[z], 1, -1 do
         self.shakes[z][i]:update(dt)
         self.shake_amount[z] = self.shake_amount[z] + self.shakes[z][i]:get_amplitude()
         if not self.shakes[z][i].shaking then
            table.remove(self.shakes[z], i)
         end
      end
   end

   self.bounds:reshape(math.lerp(self.lerp.x, self.bounds.x, self.target_bounds.x),
                       math.lerp(self.lerp.y, self.bounds.y, self.target_bounds.y),
                       math.lerp(self.lerp.x, self.bounds.w, self.target_bounds.w),
                       math.lerp(self.lerp.y, self.bounds.h, self.target_bounds.h))
   
   if not self.target then return end

   local dx1, dy1, dx2, dy2 = self.deadzone.x, 
   self.deadzone.y,
   self.deadzone.x + self.deadzone.w,
   self.deadzone.y + self.deadzone.h


   local scroll_x, scroll_y = 0, 0

   local target_x, target_y = self:get_local_coords(self.target.x, self.target.y)
   local x, y = self:get_local_coords(self.x, self.y)

   --if target_x < x + (dx1 + dx2 - x) then
   if target_x < 64 then
      local d = target_x - dx1
      if d < 0 then scroll_x = d end
   end
   --if target_x > x - (dx1 + dx2 - x) then
   if target_x > 0 then
      local d = target_x - dx2
      if d > 0 then scroll_x = d end
   end
   if target_y < y + (dy1 + dy2 - y) then
      local d = target_y - dy1
      if d < 0 then scroll_y = d end
   end
   if target_y > y - (dy1 + dy2 - y) then
      local d = target_y - dy2
      if d > 0 then scroll_y = d end
   end

   if not self.last_target.x and not self.last_target.y then
      self.last_target.x, self.last_target.y = self.target.x, self.target.y
   end

   scroll_x = scroll_x + self.target.x - self.last_target.x
   scroll_y = scroll_y + self.target.y - self.last_target.y

   self.last_target.x, self.last_target.y = self.target.x, self.target.y

   self.x = math.lerp(self.lerp.x, self.x, self.x + scroll_x)
   self.y = math.lerp(self.lerp.y, self.y, self.y + scroll_y)

   if self.bounds then
      self.x = math.min(math.max(self.x, self.bounds.x + self.w/2), self.bounds.x2 - self.w/2)
      self.y = math.min(math.max(self.y, self.bounds.y + self.h/2), self.bounds.y2 - self.h/2)
   end

   self.x, self.y = self.x - self.last_shake_amount.x, self.y - self.last_shake_amount.y
   self.x, self.y = self.x + self.shake_amount.x, self.y + self.shake_amount.y
   self.last_shake_amount:set(self.shake_amount)
end

function Camera:get_local_coords(x, y)
   local c, s = math.cos(self.r), math.sin(self.r)
   x, y = x - self.x, y - self.y
   x, y = c * x - s * y, s * x + c * y
   return x*self.sx+self.w/2, y * self.sy+self.h/2
end


function Camera:attach(scroll_x, scroll_y)
   self.bx, self.by = self.x, self.y
   -- self.x = self.x*(scroll_x or 1)
   -- self.y = self.y*(scroll_y or scroll_x or 1)
   love.graphics.push()

   love.graphics.translate(self.w / 2, self.h / 2)
   love.graphics.scale(self.sx, self.sy)
   love.graphics.rotate(self.r)

   -- love.graphics.translate(-self.w / 2, -self.h / 2)
   
   love.graphics.translate(math.floor(-self.x*(scroll_x or 1)),
                           math.floor(-self.y*(scroll_y or scroll_x or 1)))

end

function Camera:detach()
   love.graphics.pop()
   self.x, self.y = self.bx, self.by
end


function Camera:draw()
   if self.deadzone then
      graphics.rectangle(self.deadzone.x,
                         self.deadzone.y,
                         self.deadzone.w,
                         self.deadzone.h, 0, 0, nil, 1)
   end
end


Shake = Object:extend()
function Shake:init(amplitude, duration, frequency)
   self.amplitude = amplitude or 0
   self.duration = duration or 0
   self.frequency = frequency or 60

   self.samples = {}
   for i = 1, duration * frequency do self.samples[i] = 2 * love.math.random()-1 end
   self.ti = love.timer.getTime()
   self.t = 0
   self.shaking = true
end

function Shake:update(dt)
   self.t = love.timer.getTime() - self.ti
   if self.t > self.duration then
      self.shaking = false
   end
end

function Shake:get_noise(s)
   return self.samples[s] or 0
end

function Shake:get_decay(t)
   if t > self.duration then return end
   return (self.duration - t) / self.duration
end

function Shake:get_amplitude(t)
   if not t then
      if not self.shaking then return 0 end
      t = self.t
   end
   local s = t * self.frequency
   local s0 = math.floor(s)
   local s1 = s0 + 1
   local k = self:get_decay(t)
   return self.amplitude*(self:get_noise(s0) + (s-s0)*(self:get_noise(s1)-self:get_noise(s0)))*k
end
