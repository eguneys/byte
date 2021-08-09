graphics = {}

-- All operations after this is called will be affected by the transform.
function graphics.push(x, y, r, sx, sy)
  love.graphics.push()
  love.graphics.translate(x or 0, y or 0)
  love.graphics.scale(sx or 1, sy or sx or 1)
  love.graphics.rotate(r or 0)
  love.graphics.translate(-x or 0, -y or 0)
end

function graphics.pop()
   love.graphics.pop()
end

function graphics.translate(x, y)
  love.graphics.translate(x or 0, y or 0)
end


function graphics.rotate(r)
  love.graphics.rotate(r or 0)
end


function graphics.scale(sx, sy)
  love.graphics.scale(sx or 1, sy or sx or 1)
end

-- Prints text to the screen, alternative to using a Text object.
function graphics.print(text, font, x, y, r, sx, sy, ox, oy, color)
  local _r, g, b, a = love.graphics.getColor()
  if color then love.graphics.setColor(color.r, color.g, color.b, color.a) end
  love.graphics.print(text, font.font, x, y, r or 0, sx or 1, sy or 1, ox or 0, oy or 0)
  if color then love.graphics.setColor(_r, g, b, a) end
end


-- Sets the currently active color, the passed in argument should be a Color object.
function graphics.set_color(color)
  love.graphics.setColor(color.r, color.g, color.b, color.a)
end

function graphics.shape(shape, color, line_width, ...)
   local r, g, b, a = love.graphics.getColor()
   if not color and not line_width then love.graphics[shape]("line", ...)
   elseif color and not line_width then
      love.graphics.setColor(color.r, color.g, color.b, color.a)
      love.graphics[shape]("fill", ...)
   else
      if color then 
         love.graphics.setColor(color.r, color.g, color.b, color.a)
      end
      love.graphics.setLineWidth(line_width)
      love.graphics[shape]("line", ...)
      love.graphics.setLineWidth(1)
   end
   love.graphics.setColor(r, g, b, a)
end

function graphics.rectangle(x, y, w, h, rx, ry, color, line_width)
   graphics.shape('rectangle', color, line_width, x, y, w, h, rx, ry)
end

function graphics.polygon(vertices, color, line_width)
   graphics.shape('polygon', color, line_width, vertices)
end

function graphics.circle(x, y, r, color, line_width)
   graphics.shape('circle', color, line_width, x, y, r)
end


function graphics.line(x1, y1, x2, y2, color, line_width)
   local r, g, b, a = love.graphics.getColor()
   if color then 
      love.graphics.setColor(color.r, color.g, color.b, color.a)
   end
   if line_width then
      love.graphics.setLineWidth(line_width)
   end
   love.graphics.line(x1, y1, x2, y2)
   love.graphics.setColor(r, g, b, a)
   love.graphics.setLineWidth(1)
end

