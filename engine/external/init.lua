local path = ...
if not path:find('init') then
   mlib = require(path .. '.mlib')
   --ripple = require(path .. '.ripple')
end
