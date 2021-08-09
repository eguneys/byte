Dash = Object:extend()
function Dash:init(args)
   self.begin_hook = args.begin_hook
   self.prop = args.prop

   self.direction = Vector(1, 0)

   self.d_dash = 1

   local DashDuration = ticks.sixth
   local DashHeight = 4 * 5 + 8 * 5
   local DashV = DashHeight / DashDuration

   self.machine = Machine{
      input=MachineState{
         delay=ticks.sixth,
         hooks={
            update=function()
               if Input:btn('up') > 0 then
                  self.direction.y = -1
               elseif Input:btn('down') > 0 then
                  self.direction.y = 1
               else
                  self.direction.y = 0
               end

               if Input:btn('left') > 0 then
                  self.direction.x = -1
               elseif Input:btn('right') > 0 then
                  self.direction.x = 1
               else
                  if self.direction.y ~= 0 then
                     self.direction.x = 0
                  end
               end
               self.prop(0, 0)
            end
         },
         next_key='accel'
      },
      accel=MachineState{
         delay=ticks.sixth,
         hooks={
            begin = function()
               self.d_dash = self.d_dash - 1
               if self.direction.x ~= 0 and self.direction.y ~= 0 then
                  self.damping = 0.75
               else
                  self.damping = 1
               end
               if self.direction.x == 0 and self.direction.y == 0 then
                  self.direction.x = 1
               end

               self.begin_hook(self.direction)
            end,
            update= function(i)
               if i < 0.5 then
                  self.prop(self.damping * self.direction.x * DashV * i * 2,
                               self.damping * self.direction.y * DashV *i*2)
               else
                  self.prop(self.damping * self.direction.x * DashV * (1-i) * 2,
                            self.damping * self.direction.y * DashV *(1-i)*2)
               end
            end,
            exit= function()
               self.prop(0, 0)
               self.direction.x = 0
            end
         },
         next_key='rest'
      },
      rest=MachineState{
         delay=0,
         hooks={
         }
      }
   }

   self.machine:set_current_key('rest')
end

function Dash:is_rest()
   return self.machine.current_key == 'rest'
end

function Dash:replenish()
   self.d_dash = 1
end

function Dash:request(facing)
   if self.d_dash < 1 then
      return
   end
   if self.machine.current_key == 'rest' then
      if facing ~= nil then
         self.direction.x = facing
      end
      self.machine:transition('input')
   end
end

function Dash:update(dt)
   self.machine:update(dt)
end

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
