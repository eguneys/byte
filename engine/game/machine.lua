Machine=Object:extend()
function Machine:init(states)
   self.states = states
   
   for key,state in pairs(self.states) do
      state:set_key(key)
   end
end

function Machine:set_current_key(key)
   if key then
      self.current_key = key
      self:withCurrent(function (state)
            state:enter()
      end)
   end
end

function Machine:update(dt)
   self:withCurrent(function(current)
         current:update(dt)
         local transition_next = current.transition_next
         if transition_next then
            current:exit()
            self:set_current_key(transition_next)
         end
   end)
end

function Machine:transition(key)
   self:withCurrent(function (current)
         current:cut()
         self:set_current_key(key)
   end)
end

function Machine:withCurrent(fn)
   if self.current_key and self.states[self.current_key] then
      fn(self.states[self.current_key])
   else
      error("No Current State Key " .. key)
   end
end

MachineState=Object:extend()
function MachineState:init(args)
   self.next_key = args.next_key
   self.delay = args.delay or ticks.second
   self.method = args.method or math.linear
   self.hooks = args.hooks or {}
   self.t = Trigger()
   self.target = {i=0}
end

function MachineState:set_key(key)
   self.key = key
end

function MachineState:update(dt)
   self.t:update(dt)
   if self.hooks.update then
      self.hooks.update(self.target.i)
   end
end

function MachineState:cut()
   self:exit()
end

function MachineState:enter()
   if self.hooks.begin then
      self.hooks.begin()
   end
   if self.delay > 0 then
      self.target = {i=0}
      self.t:tween(self.delay, self.target, {i=1}, self.method, function ()
                      if self.hooks.after then
                         self.hooks.after()
                      end
                      if self.next_key then
                         self.transition_next = self.next_key
                      end
      end, 'single_tag')
   end
end

function MachineState:exit()
   self.transition_next = nil
   self.t:cancel('single_tag')
   if self.hooks.exit then
      self.hooks.exit()
   end
end
