function push_if_nondup2(t, x, y)
   local x2,y2=t[#t-1],
   t[#t]

   if x == x2 and y == y2 or x == t[1] and y == t[2] then
   else
      table.push(t, x)
      table.push(t, y)
   end
end

RegularPolygon = Object:extend()
RegularPolygon:implement(Polygon)
function RegularPolygon:init(vertices)
   self.vertices = vertices
   self:get_size()
   self:get_bounds()
   self:get_centroid()
end

function RegularPolygon:split(vertices)
   local x1, y1, x2, y2 = vertices[1],
   vertices[2],
   vertices[#vertices -1],
   vertices[#vertices]

   local _a, _b = self:split_index(x1, y1),
   self:split_index(x2, y2)

   local a, b = math.min(_a, _b),
   math.max(_a, _b)

   if a ~= _a then
      vertices = table.reverse2(vertices)
   end

   local va, vb = {}, {}

   if a == -1 or b == -1 then
      return nil, nil
   end

   for i=1,a,2 do
      table.push(va, self.vertices[i])
      table.push(va, self.vertices[i+1])
   end

   for i=1,#vertices,2 do
      push_if_nondup2(va, 
                      vertices[i],
                      vertices[i+1])
   end
   for i = b+2,#self.vertices,2 do
      push_if_nondup2(va, 
                      self.vertices[i],
                      self.vertices[i+1])
   end

   for i=1,#vertices,2 do
      table.push(vb, vertices[i])
      table.push(vb, vertices[i+1])
   end

   for i=b,a+2,-2 do
      push_if_nondup2(vb, self.vertices[i],
                      self.vertices[i+1])
   end

   return va, vb
end

function RegularPolygon:split_index(x, y)

   for i = 1, #self.vertices, 2 do
      local x1,y1,x2,y2 = self.vertices[i],
      self.vertices[i+1],
      self.vertices[i+2] or self.vertices[1],
      self.vertices[i+3] or self.vertices[2]

      local a, b, c = Vector(x1,y1),
      Vector(x, y),
      Vector(x2, y2)

      if a:distance(b) + b:distance(c) == a:distance(c) then
         return i
      end
   end
   return -1
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
   return false
end
