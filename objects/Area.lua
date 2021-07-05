Area = Object:extend()

function Area:new(room)
   self.room = room
   self.objects = {}
end

function Area:update(dt)
   for i = #self.objects,1,-1 do 
      local object = self.objects[i]
      object:update(dt)
      if not object.alive then
         table.remove(self.objects, i)
      end
   end
end

function Area:draw()
   for _, object in ipairs(self.objects) do object:draw() end
end

function Area:addObject(object_type, x, y, opts)
   local opts = opts or {}
   local object = _G[object_type](self, x or 0, y or 0, opts)
   table.insert(self.objects, object)
   return object
end

function Area:getGameObjects(filter)
   local res = {}
   for object in pairs(self.objects) do
      if filter(object) then
         table.insert(res, object)
      end
   end
   return res
end
