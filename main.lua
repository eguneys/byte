Object = require 'vendor/classic/classic'
Input = require('vendor/boipushy/Input')
Timer = require('vendor/hump/timer')

local Circle = require 'objects/circle'

function love.load()
   image = love.graphics.newImage('sprites8.png')

   acircle = Circle(400, 300, 50)

   input = Input()
   input:bind('mouse1', 'test')

   timer = Timer()

   timer:after(2, function() print(love.math.random()) end)

   timer:tween(6, acircle, { radius = 96 }, 'in-out-cubic')
end

function love.update(dt)
   if input:pressed('test') then print('pressed') end
   if input:released('test') then print('released') end
   if input:down('test') then print('down') end

   timer:update(dt)
end

function love.draw()
   acircle:draw()
   love.graphics.print("Hello World", 400, 300)
   love.graphics.draw(image, 0, 0)
end
