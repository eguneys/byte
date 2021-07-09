Physics = Object:extend()
function Physics:set_as_rectangle(ox, oy, w, h)
   if not self.group then error("The GameObject must have a group") end

   self.dx, self.dy = 0, 0
   self.rem_x, self.rem_y = 0, 0

   self.shape = Rectangle(ox, oy, w, h)
   self:get_body()
   return self;
end

function Physics:get_body()
   if not self.body then
      self.body = Rectangle(self.shape.x,
                            self.shape.y,
                            self.shape.w,
                            self.shape.h)
   end
   self.body:move_to(self.x,
                     self.y)
end

function Physics:update_physics()
   self:move_x()
   self:move_y()
   self:get_body()
end

function Physics:move_x()
   self.x = self.x + self.dx
end

function Physics:move_y()
   
end

function Physics:draw_physics(color, line_width)
   self.body:draw(color, line_width)
end
