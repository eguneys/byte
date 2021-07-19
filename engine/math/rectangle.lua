Rectangle = Object:extend()
Rectangle:implement(Polygon)
function Rectangle:init(x, y, w, h, r)
   r = r or 0
   self.x, self.y, self.w, self.h, self.r = x, y, w, h, r
   local x1, y1 = x, y
   local x2, y2 = x + w, y
   local x3, y3 = x + w, y + h
   local x4, y4 = x, y + h
   self.vertices = { x1, y1, x2, y2, x3, y3, x4, y4 }
   self:get_size()
   self:get_bounds()
   self:get_centroid()
end
