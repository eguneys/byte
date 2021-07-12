Polygon = Object:extend()
function Polygon:init(vertices)
   self.vertices = vertices
   self:get_size()
   self:get_bounds()
   self:get_centroid()
end

-- local path_to_polygon = function (path)
--    local vs = {}
--    for i = 1, path:size() do
--       local p = path:get(i)
--       table.insert(vs, tonumber(p.x))
--       table.insert(vs, tonumber(p.y))
--    end
--    return vs
-- end

-- local polygon_to_path = function (vs)
--    local path = clipper.Path()
--    for i = 1, #vs, do path:add(vs[i], vs[i+1]) end
--    return path
-- end

function Polygon:draw(color, line_width)
   graphics.polygon(self.vertices, color, line_width)
end

function Polygon:get_size()
   local min_x, min_y, max_x, max_y = self:get_minmaxxy()
   self.w, self.h = math.abs(max_x - min_x), math.abs(max_y - min_y)
   return self.w, self.h
end

function Polygon:get_bounds()
   local min_x, min_y, max_x, max_y = self:get_minmaxxy()
   self.x,self.y,self.x2,self.y2 = min_x, min_y, max_x, max_y
   return self.x, self.y, self.x2, self.y2
end

function Polygon:get_centroid()
  local sum_x, sum_y = 0, 0
  for i = 1, #self.vertices, 2 do
    sum_x = sum_x + self.vertices[i]
    sum_y = sum_y + self.vertices[i+1]
  end
  self.cx, self.cy = sum_x/(#self.vertices/2), sum_y/(#self.vertices/2)
  return self.cx, self.cy
end


function Polygon:get_minmaxxy()
   local min_x, min_y, max_x, max_y = 100000, 100000, -100000, -100000
   for i = 1, #self.vertices, 2 do
      if self.vertices[i] < min_x then min_x = self.vertices[i] end
      if self.vertices[i] > max_x then max_x = self.vertices[i] end
      if self.vertices[i+1] < min_y then min_y = self.vertices[i+1] end
      if self.vertices[i+1] > max_y then max_y = self.vertices[i+1] end
   end
   return min_x, min_y, max_x, max_y
end

function Polygon:move_to(x, y)
   self:translate(x - self.x, y - self.y)
end

function Polygon:translate(x, y)
   for i = 1, #self.vertices, 2 do
      self.vertices[i] = self.vertices[i] + x
      self.vertices[i+1] = self.vertices[i+1] + y
   end
   self:get_bounds()
   self:get_centroid()
end

function Polygon:scale(sx, sy, ox, oy)
   for i = 1, #self.vertices, 2 do
      self.vertices[i], self.vertices[i+1] = math.scale_point(self.vertices[i], self.vertices[i+1], sx or 1, sy or sx or 1, ox or self.cx or 0, oy or self.cy or 0)
   end
   self:get_bounds()
   self:get_centroid()
end

function Polygon:colliding_with_point_inside(x, y)
   return mlib.polygon.checkPoint(x, y, self.vertices)
end
