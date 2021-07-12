function table.push(t, v)
   table.insert(t, v)
   return t
end

function table.reverse2(t)
   local res = {}
   for i=1,#t,2 do
      res[#t-i] = t[i]
      res[#t-i+1] = t[i+1]
   end
   return res
end

-- t = {1, 2, 3, 4}
-- table.tostring(t) -> '{[1] = 1, [2] = 2, [3] = 3, [4] = 4}'
function table.tostring(t)
  if type(t) == "table" then
    local str = "{"
    for k, v in pairs(t) do
       if type(k) ~= "number" then 
          k = '"' .. k .. '"'
          str = str .. "[" .. k .. "] = "
       end
       str = str .. table.tostring(v) .. ", "
    end
    if str ~= "{" then return str:sub(1, -3) .. "}"
    else return str .. "}" end
  elseif type(t) == "string" then
    return '"' .. tostring(t) .. '"'
  else return tostring(t) end
end
