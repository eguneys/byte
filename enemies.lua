Tank = Object:extend()
Tank:implement(GameObject)
Tank:implement(Physics)
function Tank:init(args)
   self:init_game_object(args)

   self.volride = args.volride

   self:set_as_rectangle(0, 0, 2, 2)
end

function Tank:update(dt)
   self:update_game_object(dt)

   self.volride:set_target(self.body.cx, self.body.cy)
end

function Tank:draw()
   self:draw_game_object({ r = 1, g=0, b=0, a=1 }, 1)
end
