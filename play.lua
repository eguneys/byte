Play = Object:extend()

dbg = ''

function Play:init()
   self.main = Group()

   self:reset()

end

function Play:reset()

   self.main = Group()

   self.volride = Volride { group = self.main }

   self.player = Player{group = self.main,
                        volride=self.volride,
                        x = 1,
                        y = 8}
end

function Play:update(dt)

   if Input:btn('c') > 0 then
      self:reset()
   end

   self.main:update(dt)
end

function Play:draw()
   self.main:draw()

   if dbg then
      love.graphics.setColor(1,0,0,1)
      love.graphics.print(dbg, 0, 0)
   end
end
