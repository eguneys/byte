Play = Object:extend()

dbg = ''

function Play:init()
   self.main = Group()

   self.rider = Rider{ group = self.main }

   self.player = Player{group = self.main,
                        collide_x = function (body)
                           return not self.rider:is_colliding_with_point(body.cx, body.cy)
                        end,
                        collide_y = function (body)
                           return not self.rider:is_colliding_with_point(body.cx, body.cy)
                        end,
                        x = 1,
                        y = 9}
end

function Play:update(dt)
   self.main:update(dt)
end

function Play:draw()
   self.main:draw()

   if dbg then
      love.graphics.setColor(1,0,0,1)
      love.graphics.print(dbg, 0, 0)
   end
end
