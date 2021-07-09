Line = Object:extend()
Line:implement(Polygon)
function Line:init(x1, y1, x2, y2)
   self.x,self.y,self.x2,self.y2 = x1, y1, x2, y2
   self.vertices = { x1, y1, x2, y2 }
   self:get_size()
   self:get_bounds()
end

function Line:draw(color, line_width)
   graphics.line(self.x, self.y, self.x2, self.y2, color, line_width)
end
