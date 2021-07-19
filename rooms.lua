Room = Object:extend()
function Room:init(roomDef)
   local ch = editor.roomParser(roomDef)

   self.main = Group()

   self.grid = Grid(4, 4, 16, 16)

   ch(function (x, y, c)
         if (c == 'S') then
            self.grid:get(x, y, true)
         end
   end)


end

function Room:update(dt)
   self.main:update(dt)
end


function Room:draw()
   self.grid:draw_solid()   
   self.main:draw()
end

Rooms = Object:extend()
function Rooms:init()

   self.main = Group()

   local roomDef = levels[1]
   local ch = editor.roomParser(roomDef)

   self.room = Room(roomDef)

   self.player = Player{group = self.main,
                        room = self.room,
                        x = 0,
                        y = 0}

   ch(function(x,y,c)
         if (c == '@') then
            self.player.x = (x - 1) * 4
            self.player.y = (y - 1) * 4
          end
   end)

end

function Rooms:update(dt)

   self.main:update(dt)

   if Input:btn('c') > 0 then
      self:reset()
   end
end

function Rooms:draw()

   -- local color = {
   --    r = 1,
   --    g = 0,
   --    b = 1,
   --    a = 1
   -- }

   -- local line_width = 1
   
   --graphics.rectangle(8, 2, 2, 2, 0, 0, color, line_width)

   --graphics.polygon({2, 2, 2, 4, 4, 4, 4, 2 }, color, line_width)

   self.room:draw()
   self.main:draw()

end
