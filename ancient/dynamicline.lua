DynamicLine = Object:extend()
DynamicLine:implement(Line)
function DynamicLine:init(x1, y1)
   self.x,self.y,self.x2,self.y2 = x1, y1, x1, y1
   self.vertices = { x1, y1, x2, y2 }
   self:get_size()
   self:get_bounds()
end

function DynamicLine:extend(x2, y2)
   self.x2, self.y2 = x2, y2
   self.vertices[3] = self.x2
   self.vertices[4] = self.y2
   self:get_size()
   self:get_bounds()
end
