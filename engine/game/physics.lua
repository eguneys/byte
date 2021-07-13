Physics = Object:extend()
function Physics:set_as_rectangle(ox, oy, w, h)
   if not self.group then error("The GameObject must have a group") end

   self.dx, self.dy = 0, 0
   self.rem_x, self.rem_y = 0, 0

   self.shape = Rectangle(ox, oy, w, h)
   self:get_body()
   return self;
end

function Physics:reshape(w, h)
   self.shape = Rectangle(self.shape.x,
                          self.shape.y,
                          w,
                          h)
   self:get_body()
end

function Physics:collide_x (body)
   return false
end

function Physics:collide_y (body)
   return false
end

function Physics:get_body()
   if not self.body or self.body.w ~= self.shape.w then
      self.body = Rectangle(self.shape.x,
                            self.shape.y,
                            self.shape.w,
                            self.shape.h)
   end
   

   self.body:move_to(self.x,
                     self.y)

   return self.body
end

function Physics:update_physics()
   self.rem_x = self.rem_x + self.dx
   local step = math.sign(self.dx)
   local amount = math.floor(math.abs(self.rem_x))
   if amount > 0 then
      self:move_x(amount, step)
   end
   self.rem_x = self.rem_x - amount * step

   self.rem_y = self.rem_y + self.dy
   local step = math.sign(self.dy)
   local amount = math.floor(math.abs(self.rem_y))
   if amount > 0 then
      self:move_y(amount, step)
   end
   self.rem_y = self.rem_y - amount * step

   self:get_body()
end

function Physics:move_x(amount, step)
   for i=1,amount do
      self.x = self.x + step
      if self:collide_x(self:get_body()) then
         self.x = self.x - step
         self.dx = 0
         break
      end
   end
end

function Physics:move_y(amount, step)
   for i=1,amount do
      self.y = self.y + step
      if self:collide_y(self:get_body()) then
         self.y = self.y - step
         self.dy = 0
         break
      end
   end
end

function Physics:draw_physics(color, line_width)
   self.body:draw(color, line_width)
end
