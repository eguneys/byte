editor = {}

function editor.levelParser(rooms, levelS)
   local res = {}

   local lines = levelS:split('\n')
   for j=1,#lines do
      local line = lines[j]
      for i=1,#line do
         local c = line:sub(i,i)

         if rooms[c] ~= nil then
            if res[c] == nil then
               res[c] = {}
            end
            table.push(res[c], {x=i-1,y=j-1})
         end
      end
   end
   for k,coords in pairs(res) do
      local min_x, 
      max_x,
      min_y,
      max_y = coords[1].x, coords[1].x, coords[1].y, coords[1].y

      for i=2,#coords do
         min_x = math.min(coords[i].x, min_x)
         max_x = math.max(coords[i].x, max_x)
         min_y = math.min(coords[i].y, min_y)
         max_y = math.max(coords[i].y, max_y)
      end

      res[k] = Rectangle(min_x, min_y, max_x -min_x + 1, max_y - min_y + 1)
   end
   return res
end

function editor.roomParser(roomS)
   return function(fn)
      local lines = roomS:split('\n')

      for j=1,#lines do
         local line = lines[j]
         for i=1,#line do
            local c = line:sub(i,i)
            fn(i,j,c)
         end
      end
   end
end
