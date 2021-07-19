editor = {}

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
