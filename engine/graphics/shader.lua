Shader = Object:extend()
function Shader:init(v_name, f_name)
  self.shader = love.graphics.newShader("assets/" .. (v_name or "default.vert"), "assets/" .. f_name)
end

function Shader:set()
  current_shader = self
  love.graphics.setShader(self.shader)
end

function Shader:unset()
  current_shader = nil
  love.graphics.setShader()
end

function Shader:send(value, data)
  self.shader:send(value, data)
end
