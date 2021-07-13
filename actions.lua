Jump = Object:extend()
function Jump:init(args)

   self.prop = args.prop

   self.machine = Machine{
      accel=MachineState{
         delay=ticks.third,
         method=math.quad_in,
         hooks= {
            update=function(i)
               self.prop(-i)
            end
         },
         next_key='hang'
      },
      hang=MachineState{
         delay=ticks.lengths,
         hooks= {
            update=function(i)
               self.prop(0)
            end
         },
         next_key='rest'
      },
      rest=MachineState{
         delay=0,
         hooks= {
            begin=function(i)
               self.prop(0.5)
            end            
         }
      }
   }
   self.machine:set_current_key('rest')
end

function Jump:request()
   if self.machine.current_key == 'rest' then
      self.machine:transition('accel')
   end
end
function Jump:update(dt)
   self.machine:update(dt)
end

Walk = Object:extend()
function Walk:init(args)
   self.prop = args.prop

   local VIn60 = args.speed or 0.5

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

function Walk:is_rest()
   return self.machine.current_key == 'rest'
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
