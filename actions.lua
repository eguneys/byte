Walk = Object:extend()
function Walk:init(prop)
   self.prop = prop

   local VIn60 = 0.5

   self.machine = Machine{
      pace=MachineState{
         delay=0,
         hooks= {
            update=function(i)
               self.prop(VIn60)
            end
         }
      },
      rest=MachineState{
         delay=0,
         hooks= {
            begin=function(i)
               self.prop(0)
            end            
         }
      }
   }
   self.machine:set_current_key('rest')
end

function Walk:request()
   if self.machine.current_key == 'rest' then
      self.machine:transition('pace')
   end
end

function Walk:cut()
   if self.machine.current_key == 'pace' then
          self.machine:transition('rest')
   end
end

function Walk:update(dt)
   self.machine:update(dt)
end
