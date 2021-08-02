Room = Object:extend()
Room:implement(GameObject)
function Room:init(rect, def)

   self.rect = Rectangle(rect.x * 32,
                         rect.y * 32,
                         rect.w * 32,
                         rect.h * 32)

   self.ch = editor.roomParser(def)

   self.main = Group()

   self.grid = Grid(4, 4, 40, 40)

   self.ch(function (x, y, c)
         if (c == 'S') then
            self.grid:get(x,
                          y, true)
         end
   end)

end

function Room:update(dt)
   self.main:update(dt)
end

function Room:collide_solid(x, y, w, h)
   return self.grid:collide_solid(
         -self.rect.x + x,
         -self.rect.y + y,
      w, h)
end

function Room:draw()
   self.grid:draw_solid(self.rect.x, self.rect.y)
   self.main:draw()
end

Rooms = Object:extend()
function Rooms:init()

   self.main = Group(Camera(0, 0, 64, 64))

   self:load_rooms()

   self.player = Player{group = self.main,
                        rooms = self,
                        x = 0,
                        y = 0}

   self.main.camera.lerp.x = 0.5
   self.main.camera.lerp.y = 0.5
   self.main.camera:follow(self.player.camera_target)

   self.room.ch(function(x,y,c)
         if (c == '@') then
            self.player.x = self.room.rect.x + (x - 1) * 4
            self.player.y = self.room.rect.y + (y - 1) * 4
          end
   end)

   self.in_transition = 0

end

function Rooms:load_rooms()
   self.rooms = {}

   local levelDef = editor.levelParser(rooms, levels[1])
   for name,roomRect in pairs(levelDef) do
      local roomDef = rooms[name]
      local room = Room(roomRect, roomDef)
      table.push(self.rooms, room)
      self.main:add(room)
   end

   self.room = self.rooms[1]
   self.main.camera:set_bounds(self.room.rect.x,
                               self.room.rect.y,
                               self.room.rect.w,
                               self.room.rect.h)

   self.room_to_transition = nil
end

function Rooms:check_room_transition()
   local to
   for _, room in pairs(self.rooms) do
      if room ~= self.room then
         if room.rect:is_colliding_with_polygon(self.player.body) then
            to = room
            break
         end
      end
   end
   if to then
      self.room_to_transition = to
   end
end

function Rooms:update(dt)

   if self.in_transition > 0 then
      self.in_transition = self.in_transition - dt
   else
      self.main:update(dt)
   end
   self.main.camera:update(dt)

   if self.room_to_transition then
      self.room = self.room_to_transition
      self.room_to_transition = nil
      self.in_transition = ticks.sixth
      self.main.camera:set_bounds(self.room.rect.x,
                                  self.room.rect.y,
                                  self.room.rect.w,
                                  self.room.rect.h)
   end
end

function Rooms:draw()

   self.main.camera:draw()
   self.main:draw()

end
