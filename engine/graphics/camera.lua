Camera = Object:extend()
function Camera:init(x, y, w, h)
   
   self.x, self.y = x, y
   self.w, self.h = w, h

   self.r, self.sx, self.sy = 0, 1, 1

   self.lerp = Vector(1, 1)
   self.last_target = Vector(0, 0)

end

function Camera:follow(target)
   self.target = target
end

function Camera:update(dt)
   
   if not self.target then return end


   local scroll_x, scroll_y = 0, 0

   local target_x, target_y = self:get_local_coords(self.target.x, self.target.y)

   scroll_x = target_x
   scroll_y = target_y

   if not self.last_target.x and not self.last_target.y then
      self.last_target.x, self.last_target.y = self.target.x, self.target.y
   end

   scroll_x = scroll_x + self.target.x - self.last_target.x
   scroll_y = scroll_y + self.target.y - self.last_target.y

   self.last_target.x, self.last_target.y = self.target.x, self.target.y
   self.x = math.lerp(self.lerp.x, self.x, self.x + scroll_x)
   self.y = math.lerp(self.lerp.y, self.y, self.y + scroll_y)

   print(self.x, scroll_x)

end

function Camera:get_local_coords(x, y)
   local c, s = math.cos(self.r), math.sin(self.r)
   x, y = x - self.x, y - self.y
   x, y = c * x - s * y, s * x + c * y
   return x*self.sx, y * self.sy
end


function Camera:attach(scroll_x, scroll_y)
   self.bx, self.by = self.x, self.y
   self.x = self.bx*(scroll_x or 1)
   self.y = self.by*(scroll_y or scroll_x or 1)
   love.graphics.push()

   love.graphics.translate(self.w / 2, self.h / 2)
   love.graphics.scale(self.sx, self.sy)
   love.graphics.rotate(self.r)

   love.graphics.translate(-self.w / 2, -self.h / 2)

   love.graphics.translate(-self.x*(scroll_x or 1),
                              -self.y*(scroll_y or scroll_x or 1))

end

function Camera:detach()
   love.graphics.pop()
   self.x, self.y = self.bx, self.by
end
