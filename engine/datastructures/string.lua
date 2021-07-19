function string:split(s)
   local res = {}
   for str in self:gmatch("[^" .. s .. "]+") do
      table.insert(res, str)
   end
   return res
end
