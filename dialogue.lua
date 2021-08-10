Dialogue=Object:extend()
function Dialogue:init()

   self.text = nil

   self.text_tags = {
      dark = TextTag{draw = function(c, i, text) graphics.set_color(colors.dark) end},
      red = TextTag{draw = function(c, i, text) graphics.set_color(colors.red) end}
   }

   self._t = Trigger()
   self.i_bg = 0
   self.i_bg_x = 0

   self.i_cutscene = 0

   self.b_off = false

   self.spawn_pos = Vector(32, 32)
end

function Dialogue:off()
   self.b_off = true
end

function Dialogue:on()
   self.b_off = false
end

function Dialogue:cutscene(delay, after)
   self._t:tween(ticks.third * 3, self, { i_cutscene = 1 }, math.quart_in_out, after)
   self._t:after(delay, function()
                    self._t:tween(ticks.half,
                                  self, { i_cutscene = 0 }, math.quart_in_out)
   end)
end

function Dialogue:player_die(die_pos, delay, after)
   local f_open = function()
      self._t:tween(ticks.third,
                    self, { i_cutscene = 1 }, math.quart_in, after)
   end

   local f_close = function()
      self._t:after(delay, function()
                       self._t:tween(ticks.half,
                                     self, 
                                     { i_cutscene = 1-(6/64) },
                                     math.quart_out, function()
                                        self._t:after(ticks.third*2, f_open)
                       end)
      end)
   end

   self.spawn_pos = die_pos
   f_close()

end

function Dialogue:spawn(spawn_pos, delay, after)
   self.spawn_pos = spawn_pos
   self._t:tween(ticks.third * 3, self, { i_cutscene = 1 }, math.quart_in_out, after)

   local f_open = function()
      self._t:tween(ticks.third,
                    self, { i_cutscene = 0 }, math.quart_out)
   end

   self._t:after(ticks.third * 3 + delay, function()
                    self._t:tween(ticks.half,
                                  self, 
                                  { i_cutscene = 1-6/64 },
                                  math.quart_in, function()
                                     self._t:after(ticks.third*3, f_open)
                    end)
   end)
end

function Dialogue:print(text)
   self.i_bg_x = 0
   self.text = Text({{text=text, font=font}}, self.text_tags)
   self._t:tween(ticks.half, self, { i_bg = 1 }, math.quart_in_out)

   self._t:after(ticks.second * 3, function()
                    self.text = nil
                    self._t:tween(ticks.half, self, { i_bg = 0, i_bg_x = 1 }, math.quart_in_out)
   end)
end


function Dialogue:update(dt)
   self._t:update(dt)
end

function Dialogue:draw()

   if self.i_cutscene > 0.0001 then
      local sx, sy = self.spawn_pos.x, self.spawn_pos.y
      local sx2, sy2 = sx + 12, sy + 12

      graphics.rectangle(0, 0, sx - (1-self.i_cutscene) * 64, 64, 0, 0, colors.dark)
      graphics.rectangle(sx + (1-self.i_cutscene)*64, 0, 64, 64, 0, 0, colors.dark)

      graphics.rectangle(0, 0, 64, sy - (1-self.i_cutscene) * 64, 0, 0, colors.dark)
      graphics.rectangle(0, sy + (1-self.i_cutscene)*64, 64, 64, 0, 0, colors.dark)
   end

   graphics.rectangle(self.i_bg_x * 64, 5, self.i_bg*64, 5, 0, 0, colors.light)
   if self.text ~= nil then
      self.text:draw(0, 5)
   end

   if self.b_off then
      graphics.rectangle(0, 0, 64, 64, 0, 0, colors.dark)
   end
end
