RegularPolygon = Object:extend()
RegularPolygon:implement(Polygon)
function RegularPolygon:init(vertices)
   self.vertices = vertices
   self:get_size()
   self:get_bounds()
   self:get_centroid()
end

function RegularPolygon:is_colliding_with_point(x, y)
   for i = 1, #self.vertices, 2 do
      local x1,y1,x2,y2 = self.vertices[i],
      self.vertices[i+1],
      self.vertices[i+2] or self.vertices[1],
      self.vertices[i+3] or self.vertices[2]
      if x1 == x2 and x1 == x then
         if math.min(y1,y2) <= y and
         y <= math.max(y1, y2) then
               return true
         end
      elseif y1 == y2 and y1 == y then
         if math.min(x1,x2) <= x and
            x <= math.max(x1, x2) then
               return true
         end
      end
   end
   dbg=x..y
   return false
end
