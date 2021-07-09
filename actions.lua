Walk = Object:extend()
function Walk:init(parent, dir)
   self.parent, self.dir = parent, dir

   local VIn60 = 1

   self.machine = Machine{
      accel=MachineState{
         next_key='pace',
         delay=ticks.sixth,
         method=math.quad_in,
         hooks= {
            update=function(i)
               self.parent.dx=VIn60*i*dir
            end
         }
      },
      deccel=MachineState{
         next_key='rest',
         delay=ticks.sixth,
         method=math.quad_in,
         hooks= {
            update=function(i)
               self.parent.dx=VIn60*(1-i)*dir
            end
         }         
      },
      pace=MachineState{
         delay=0,
         hooks= {
            begin=function(i)
               self.parent.dx=VIn60*dir
            end
         }
      },
      rest=MachineState{
         delay=0,
         hooks= {
            begin=function(i)
               self.parent.dx=0
            end            
         }
      }
   }
   self.machine:set_current_key('rest')
end

function Walk:request()
   if self.machine.current_key == 'rest' then
      self.machine:transition('accel')
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
