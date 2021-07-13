Tween=Object:extend()
function Tween:init(delay,
                    target,
                    prop,
                    method,
                    after)

   self.delay = delay
   self.target = target
   self.prop = prop
   self.method = method
   self.after = after   
end

function Tween:restart()
end

function Tween:cancel()
end

function Tween:update(dt)
end

