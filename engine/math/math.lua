function math.rotate_point(x, y, r, ox, oy)
   return x*math.cos(r) - y*math.sin(r) + ox - ox*math.cos(r) + oy*math.sin(r), x*math.sin(r) + y*math.cos(r) + oy - oy*math.cos(r) - ox*math.sin(r)
end

function math.lerp(value, src, dst)
   return src*(1 - value) + dst*value
end

function math.linear(t)
   return t
end

function math.quad_in(t)
   return t*t
end
