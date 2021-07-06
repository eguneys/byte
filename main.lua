Object = require 'vendor/classic/classic'
Input = require('vendor/boipushy/Input')
Timer = require('vendor/hump/timer')
Camera = require('vendor/stalker/Camera')
M = require('vendor/Moses/moses')

require('objects/Area')
require('objects/Stage')
require('objects/GameObject')
require('objects/Player')

function love.load()
   resize(10)

   love.graphics.setDefaultFilter('nearest')
   love.graphics.setLineStyle('rough')

   main_canvas = love.graphics.newCanvas(gw, gh)

   image = love.graphics.newImage('sprites8.png')

   input = Input()
   timer = Timer()
   camera = Camera(32, 32, 64, 64)

   input:bind('x', function() camera:shake(8, 1, 60) end)

   current_room = nil

   addRoom(Stage)
end

function love.update(dt)
   timer:update(dt)
   camera:update(dt)

   if current_room then current_room:update(dt) end
end

function love.draw()

   love.graphics.setCanvas(main_canvas)
   love.graphics.clear()

   if current_room then current_room:draw() end

   love.graphics.setCanvas()

   love.graphics.setColor(255, 255, 255, 255)
   love.graphics.setBlendMode('alpha', 'premultiplied')
   love.graphics.draw(main_canvas, 0, 0, 0, sx, sy)
   love.graphics.setBlendMode('alpha')
end

function addRoom(room_type)
   current_room = room_type()
end

function resize(s)
   love.window.setMode(s*gw, s*gh)
   sx, sy = s, s
end
