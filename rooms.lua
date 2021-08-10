Room = Object:extend()
Room:implement(GameObject)
function Room:init(rooms, rect, def, name)

   self.name = name
   self.rooms = rooms

   self.rect = Rectangle(rect.x * 32,
                         rect.y * 32,
                         rect.w * 32,
                         rect.h * 32)

   self.ch = editor.roomParser(def)

   self.main = Group()

   self.grid = Grid(4, 4, 80, 80)

   self.ch(function (x, y, c)
         if c == 'D' then
            Door{
               room=self,
               group=self.main,
               x = x,
               y = y
            }
         end
         if c == 'L' then
            Sentient{
               room=self,
               group=self.main,
               x = x,
               y = y
            }
         end
         if c == 'S' then
            self.grid:get(x,
                          y, true)
         end
         if c == 'R' then
            self.grid:get(x, y, true)
         end
   end)
end




function Room:collide_objects(body)
   for _, object in ipairs(self.main.objects) do
      if object.body then
         if object.body:is_colliding_with_polygon(body) then
            return object
         end
      end
   end
   return nil
end

function Room:update(dt)
   self.main:update(dt)
end

function Room:collide_solid(x, y, w, h, ox, oy)
   ox = ox or 0
   oy = oy or 0
   return self.grid:collide_solid(
         -self.rect.x + x + ox,
         -self.rect.y + y + oy,
      w, h)
end

function Room:collide_bounds(x,y)
   return not self.rect:colliding_with_point_inside(x, y)
end

function Room:draw()
   self.grid:draw_solid(self.rect.x, self.rect.y)
   self.main:draw()
end

Rooms = Object:extend()
Rooms:implement(GameObject)
function Rooms:init(args)

   self:init_game_object(args)

   self.main = Group(Camera(0, 0, 64, 64))

   self:load_rooms()
   self.background = background

   self:reset()
end

function Rooms:reset()
   self.in_transition = 0
   self._t = 0
   self.warm_up_called = false
   self:set_player(self.rooms[1])
end

function Rooms:load_last_checkpoint()
   self:reset()
end

function Rooms:player_die()
   self.player:remove_game_object()

   if self.after_die then
      self.after_die(
         Vector(self.main.camera:get_local_coords(self.player.body.cx, self.player.body.cy))
      )
   end
end

function Rooms:set_player(room)
   self.player = Player{group = self.main,
                        rooms = self,
                        room = room}

   self.main.camera.lerp.x = 0.5
   self.main.camera.lerp.y = 0.5
   self.main.camera:follow(self.player.camera_target)

   self.main.camera:set_bounds(self.player.room.rect.x,
                               self.player.room.rect.y,
                               self.player.room.rect.w,
                               self.player.room.rect.h)
end

function Rooms:load_rooms()
   self.rooms = {}

   local levelDef = editor.levelParser(rooms, levels[1])
   for name,roomRect in pairs(levelDef) do
      local roomDef = rooms[name]
      local room = Room(self, roomRect, roomDef, name)
      table.push(self.rooms, room)
      self.main:add(room)
   end

   self.room_to_transition = nil
end

function Rooms:check_room_transition(to)
   if to then
      self.room_to_transition = to
   end
end

function Rooms:update(dt)

   self._t = self._t + dt

   if self._t > ticks.second then
      if not self.warm_up_called and self.after_warmup then
         self.after_warmup(
            Vector(self.main.camera:get_local_coords(self.player.body.cx, self.player.body.cy))
         )
         self.warm_up_called = true
      end
   end

   if self.room_to_transition then
      self.main.camera:set_bounds(self.room_to_transition.rect.x,
                                  self.room_to_transition.rect.y,
                                  self.room_to_transition.rect.w,
                                  self.room_to_transition.rect.h)
      self.room_to_transition = nil
      self.in_transition = ticks.sixth
   end

   if self.in_transition > 0 then
      self.in_transition = self.in_transition - dt
   else
      self.main:update(dt)
   end
   self.main.camera:update(dt)
end

function Rooms:draw()

   self.main.camera:attach(0.25)
   self.background:draw(-32 + 32 * 0.25, -32 + 32 * 0.25)
   self.main.camera:detach()

   --self.main.camera:draw()
   self.main:draw()

end
