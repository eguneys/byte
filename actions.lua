Throw = Object:extend()
function Throw:init(args)
   self.prop = args.prop

   local JumpDuration = ticks.third
   local MaxJumpHeight = 4 * 3
   local JumpV = MaxJumpHeight / JumpDuration

   local FallV = MaxJumpHeight / ticks.second

   local MaxThrowWidth = 4 * 4 + 2 * 4
   local ThrowV = MaxThrowWidth / JumpDuration

   self.machine = Machine{
      accel=MachineState{
         delay=JumpDuration,
         method=math.quad_in_out,
         hooks= {
            update=function(i)
               if i < 0.5 then
                  self.prop(ThrowV * i * 2, -JumpV*i*2)
               else
                  self.prop(ThrowV * i * 2, -JumpV*(1-i)*2)
               end
            end
         },
         next_key='hang'
      },
      hang=MachineState{
         delay=ticks.lengths,
         hooks= {
            update=function(i)
               self.prop(ThrowV, 0)
            end
         },
         next_key='rest'
      },
      rest=MachineState{
         delay=0,
         hooks= {
            update=function(i)
               self.prop(0, JumpV)
            end            
         }
      }
   }

   self.machine:set_current_key('rest')
end

function Throw:is_throw()
   return self.machine.current_key ~= 'rest'
end

function Throw:request()
   if self.machine.current_key == 'rest' then
      self.machine:transition('accel')
   end
end

function Throw:update(dt)
   self.machine:update(dt)
end


Jump = Object:extend()
function Jump:init(args)

   self.prop = args.prop

   local JumpDuration = ticks.third
   local MaxJumpHeight = 4 * 5 + 2 * 5
   local JumpV = MaxJumpHeight / JumpDuration

   local FallV = MaxJumpHeight / ticks.second

   self.machine = Machine{
      accel=MachineState{
         delay=JumpDuration,
         method=math.quad_out,
         hooks= {
            update=function(i)
               if i < 0.5 then
                  self.prop(-JumpV*i*2)
               else
                  self.prop(-JumpV*(1-i)*2)
               end
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
            update=function(i)
               self.prop(FallV)
            end            
         }
      }
   }
   self.machine:set_current_key('rest')
end

function Jump:is_accel()
   return self.machine.current_key == 'accel' or self.machine.current_key == 'hang'
end

function Jump:request()
   if self.machine.current_key == 'rest' then
      self.machine:transition('accel')
   end
end

function Jump:cut()
   if self.machine.current_key == 'accel' then
      self.machine:transition('rest')
   end
end

function Jump:update(dt)
   self.machine:update(dt)
end

Walk = Object:extend()
function Walk:init(args)
   self.prop = args.prop

   local V = 50 / ticks.second

   self.machine = Machine{
      pace=MachineState{
         delay=0,
         hooks= {
            update=function(i)
               self.prop(V)
            end
         },
         next_key='cool'
      },
      cool=MachineState{
         delay=ticks.second,
         hooks={
            begin=function()
               self.prop(0)
            end
         },
         next_key='rest'
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

function Walk:is_pace()
   return self.machine.current_key == 'pace'
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
