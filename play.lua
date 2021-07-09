Play = Object:extend()

dbg = ''

function Play:init()
   self.main = Group()

   self.player = Player{group = self.main, 
                        x = gw/2,
                        y = gh/2}
end

function Play:update(dt)
   self.main:update(dt)
end

function Play:draw()
   self.main:draw()

   if dbg then
      love.graphics.print(dbg, 0, 0)
   end
end
