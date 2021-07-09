Rectangle = Object:extend()
Rectangle:implement(Polygon)
function Rectangle:init(x, y, w, h, r)
   r = r or 0
   self.x, self.y, self.w, self.h, self.r = x, y, w, h, r
   local x1, y1 = math.rotate_point(x - w/2, y - h/2, r, x, y)
   local x2, y2 = math.rotate_point(x + w/2, y - h/2, r, x, y)
   local x3, y3 = math.rotate_point(x + w/2, y + h/2, r, x, y)
   local x4, y4 = math.rotate_point(x - w/2, y + h/2, r, x, y)
   self.vertices = { x1, y1, x2, y2, x3, y3, x4, y4 }
   self:get_size()
   self:get_bounds()
   self:get_centroid()
end
