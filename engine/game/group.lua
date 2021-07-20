Group = Object:extend()
function Group:init(camera)
   self.camera = camera
   self.objects = {}
   return self
end

function Group:update(dt)
   for _,object in pairs(self.objects) do
      object:update(dt)
   end

   for i = #self.objects, 1, -1 do
      if self.objects[i].dead then
         table.remove(self.objects, i)
      end
   end
end

function Group:draw()
   if self.camera then self.camera:attach(scroll_x, scroll_y) end

   for _, object in pairs(self.objects) do
      object:draw()
   end

   if self.camera then self.camera:detach() end
end

function Group:add(object)
   object.group = self
   table.insert(self.objects, object)
   return object
end
