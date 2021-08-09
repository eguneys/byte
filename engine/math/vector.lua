local EPSILON = 0.0001
local EPSILON_SQUARED = EPSILON*EPSILON
Vector = Object:extend()
function Vector:init(x, y)
   self.x = x or 0
   self.y = y or x or 0
end

function Vector:set(x, y)
   if not y then
      self.x = x.x
      self.y = x.y
   else
      self.x = x
      self.y = y
   end
   return self
end


function Vector:add(x, y)
   if not y then
      self.x = self.x + x.x
      self.y = self.y + x.y
   else
      self.x = self.x + x
      self.y = self.y + y
   end
   return self
end

function Vector:sub(x, y)
   if not y then
      self.x = self.x - x.x
      self.y = self.y - x.y
   else
      self.x = self.x - x
      self.y = self.y - y
   end
   return self
end

function Vector:direction(v2)
   return v2:sub(self):normalize()
end

function Vector:scale(k)
   self.x = self.x*k
   self.y = self.y*k
   return self
end

function Vector:distance_squared(v)
   local dx = v.x - self.x
   local dy = v.y - self.y
   return dx * dx + dy * dy
end

function Vector:distance(v)
   return math.sqrt(self:distance_squared(v))
end

function Vector:is_zero()
   return math.abs(self.x) < EPSILON and math.abs(self.y) < EPSILON
end

function Vector:is_equal(v2)
   return math.abs(self.x - v2.x) < EPSILON and math.abs(self.y - v2.y) < EPSILON
end

function Vector:is_backwards(v2)
   return math.abs(self.x + v2.x) < EPSILON and math.abs(self.y + v2.y) < EPSILON
end

function Vector:length()
   return math.sqrt(self.x*self.x+self.y*self.y)
end

function Vector:normalize()
   if self:is_zero() then return self end
   return self:scale(1/self:length())
end

function Vector:dot(v)
   return self.x*v.x + self.y*v.y
end

function Vector:is_perpendicular(v)
   return math.abs(self:dot(v)) < EPSILON_SQUARED
end

function Vector.__tostring(self)
   return tonumber(self.x) .. ',' .. tonumber(self.y)
end

VLeft = Vector(-1,0)
VRight = Vector(1,0)
VUp = Vector(0,-1)
VDown=Vector(0,1)
