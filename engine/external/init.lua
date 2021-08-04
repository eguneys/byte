local path = ...
if not path:find('init') then
   mlib = require(path .. '.mlib')
   anim8 = require(path .. '.anim8')
   --ripple = require(path .. '.ripple')
end
