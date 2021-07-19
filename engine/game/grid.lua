Grid = Object:extend()
function Grid:init(celw, celh, w, h)
   self.data = {}

   self.celw = celw
   self.celh = celh

   self.w = w
   self.h = h
end

function Grid:get(celx, cely, v)
   if v == nil then
      return self.data[self:_key(celx, cely)]
   else
      self.data[self:_key(celx, cely)] = v
      return v
   end
end

function Grid:_key(celx, cely)
   return cely * self.w + celx
end

function Grid:draw_solid()
   for i=1,self.w do
      for j =1,self.h do
         if self:get(i, j) then
            graphics.rectangle((i-1)*self.celw, (j-1)*self.celh, self.celw, self.celh, 0, 0, {
                                  r=1,
                                  g=0,
                                  b=0,
                                  a=1
                                                                                             }, 1)
         end
      end
   end
end

function Grid:collide_solid(x, y, w, h)
   for i=x,x+w do
      for j=y,y+h do
         if self:get(math.ceil(i/self.celw),
                     math.ceil(j/self.celh)) then
            return true
         end            
      end
   end
   return false
end
