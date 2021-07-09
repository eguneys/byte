graphics = {}


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

function graphics.polygon(vertices, color, line_width)
   graphics.shape('polygon', color, line_width, vertices)
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
