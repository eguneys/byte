Group = Object:extend()
function Group:init()
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
   for _, object in pairs(self.objects) do
      object:draw()
   end
end

function Group:add(object)
   object.group = self
   table.insert(self.objects, object)
   return object
end
