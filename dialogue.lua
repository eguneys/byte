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

   graphics.rectangle(0, 0, 64, self.i_cutscene * 32, 0, 0, colors.dark)
   graphics.rectangle(0, 32+(1-self.i_cutscene)*32, 64, 32, 0, 0, colors.dark)

   graphics.rectangle(self.i_bg_x * 64, 5, self.i_bg*64, 5, 0, 0, colors.light)
   if self.text ~= nil then
      self.text:draw(0, 5)
   end

   if self.b_off then
      graphics.rectangle(0, 0, 64, 64, 0, 0, colors.dark)
   end
end
