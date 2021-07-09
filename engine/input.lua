local keys = { 'left', 
               'right',
               'up',
               'down',
               'x',
               'c' }

function input_update()
   for input,t in pairs(Input.btn) do
      if (t ~= 0) then
         Input.btn[input] = t + 1
      end
   end
end

Input = {
   btn={},
   update=input_update
}


function love.keypressed(key)
   if (not Input.btn[key] or Input.btn[key] <= 0) then
      Input.btn[key] = 1
   end
end

function love.keyreleased(key)
   if (Input.btn[key]) then
      Input.btn[key] = -10
   end
end
