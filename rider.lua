
Rider = Object:extend()
Rider:implement(GameObject)
function Rider:init(args)
   self:init_game_object(args)


   self.body = RegularPolygon {
      2,9,
      2,63,
      63,63,
      63,9
   }

   print('3 9 '..(self.body:is_colliding_with_point(3,9)and"yes"or"no"))
end

function Rider:update(dt)

end

function Rider:draw()
   self.body:draw()
end

function Rider:is_colliding_with_point(x, y)
   return self.body:is_colliding_with_point(x, y)
end
