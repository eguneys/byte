-- A chain class. If loop is true then this is the same as a polygon, otherwise its a collection of connected lines (an open polygon).
-- Implements every function that Polygon does.
Chain = Object:extend()
Chain:implement(Polygon)
function Chain:init(x,y,x2,y2)
   self.vertices = { x, y, x2, y2 }
   self:get_size()
   self:get_bounds()
   self:get_centroid()
end

function Chain:extend(x, y)
   local x3, y3, x2, y2 = self.vertices[#self.vertices-3],
   self.vertices[#self.vertices-2],
   self.vertices[#self.vertices-1],
   self.vertices[#self.vertices]

   local p_dir, c_dir = 
      Vector(x3, y3):direction(Vector(x2,y2)),
   Vector(x2,y2):direction(Vector(x, y))

   if p_dir:is_zero() then
      self.vertices[#self.vertices] = nil
      self.vertices[#self.vertices] = nil
   end

   if not c_dir:is_zero() then
      if c_dir:is_equal(p_dir) or c_dir:is_backwards(p_dir) then
         self.vertices[#self.vertices-1] = x
         self.vertices[#self.vertices] = y
      else
         table.push(self.vertices, x)
         table.push(self.vertices, y)
      end
   end
   
end


-- Draws the chain of lines with the given color and width.
function Chain:draw()
   love.graphics.line(self.vertices)
end


-- If loop is true, returns true if the point is inside the polygon.
-- If loop is false, returns true if the point lies on any of the chain's lines.
-- colliding = chain:is_colliding_with_point(x, y)
function Chain:is_colliding_with_point(x, y)
  if self.loop then
    return mlib.polygon.checkPoint(x, y, self.vertices)
  else
    for i = 1, #self.vertices-2, 2 do
      if mlib.segment.checkPoint(x, y, self.vertices[i], self.vertices[i+1], self.vertices[i+2], self.vertices[i+3]) then
        return true
      end
    end
  end
end


-- If loop is true, returns true if the line is colliding with the polygon.
-- If loop is false, returns true if the line is colliding with any of the chain's lines.
-- colliding = chain:is_colliding_with_line(line)
function Chain:is_colliding_with_line(line)
  if self.loop then
    return mlib.polygon.isSegmentInside(line.x1, line.y1, line.x2, line.y2, self.vertices)
  else
    for i = 1, #self.vertices-2, 2 do
      if mlib.segment.getIntersection(self.vertices[i], self.vertices[i+1], self.vertices[i+2], self.vertices[i+3], line.x1, line.y1, line.x2, line.y2) then
        return true
      end
    end
  end
end


-- If loop is true, returns true if the polygon is colliding with the polygon.
-- If loop is false, returns true if the polygon is colliding with any of the chain's lines.
-- colliding = chain:is_colliding_with_polygon(polygon)
function Chain:is_colliding_with_polygon(polygon)
  if self.loop then
    return mlib.polygon.isPolygonInside(self.vertices, polygon.vertices) or mlib.polygon.isPolygonInside(polygon.vertices, self.vertices)
  else
    for i = 1, #self.vertices-2, 2 do
      if mlib.polygon.getSegmentIntersection(self.vertices[i], self.vertices[i+1], self.vertices[i+2], self.vertices[i+3], polygon.vertices) then
        return true
      end
    end
  end
end
