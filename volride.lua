Volride = Object:extend()
Volride:implement(GameObject)
function Volride:init(args)
   self:init_game_object(args)

   self.ground = RegularPolygon {
      2,9,
      2,63,
      63,63,
      63,9
   }

   self.target = { x = 0, y = 0 }

   self.body = nil
end

function Volride:is_colliding_with_point(x, y)
   return self.ground:is_colliding_with_point(x, y)
end

function Volride:is_colliding_with_point_inside(x, y)
   return self.ground:colliding_with_point_inside(x, y)
end


function Volride:is_dash()
   return self.body ~= nil
end

function Volride:start(x, y, x2,y2)
   self.body = Chain(x,y,x2,y2)
end

function Volride:stop()
   local va, vb = self.ground:split(self.body.vertices)

   if Polygon(va):colliding_with_point_inside(self.target.x, self.target.y) then
      self.ground = RegularPolygon(va)
      --print(table.tostring(va))
   else
      self.ground = RegularPolygon(vb)
   end



   self.body = nil
end

function Volride:extend(x, y)
   return self.body:extend(x, y)
end

function Volride:set_target(x, y)
   self.target = { x=x, y=y }
end

function Volride:update(dt)
   if self.body then
      --print(table.tostring(self.body.vertices))
   end
end

function Volride:draw()

   self.ground:draw()

   if self.body then
      self.body:draw()
   end
end
