Object = require 'vendor/classic/classic'
Input = require('vendor/boipushy/Input')
Timer = require('vendor/hump/timer')
M = require('vendor/Moses/moses')

-- local Circle = require 'objects/circle'

function love.load()
   image = love.graphics.newImage('sprites8.png')

   input = Input()
   input:bind('mouse1', 'test')

   timer = Timer()


   current_room = nil
end

function love.update(dt)
   timer:update(dt)

   if current_room then current_room:update(dt) end
end

function love.draw()

   if current_room then current_room:draw() end
end

