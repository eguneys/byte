require 'engine'
require 'levels'
require 'rooms'
require 'play'
require 'actions'
require 'player'

local play
local main_canvas

function love.load()
   resize(10)

   love.graphics.setDefaultFilter('nearest')
   love.graphics.setLineStyle('rough')

   main_canvas = love.graphics.newCanvas(gw, gh)

   image = love.graphics.newImage('sprites8.png')

   font = love.graphics.newFont('PICO-8.ttf', 5)
   font:setFilter('nearest', 'nearest');
   love.graphics.setFont(font)

   trigger = Trigger()
   random = Random()
   play = Play()
end

function love.update(dt)
   Input:update(dt)
   play:update(dt)
   trigger:update(dt)
end

function love.draw()

   love.graphics.setCanvas(main_canvas)
   love.graphics.clear()

   -- DRAW --
   play:draw()
   ----

   love.graphics.setCanvas()

   love.graphics.setColor(255, 255, 255, 255)
   love.graphics.setBlendMode('alpha', 'premultiplied')
   love.graphics.draw(main_canvas, 0, 0, 0, sx, sy)
   love.graphics.setBlendMode('alpha')
end

function resize(s)
   love.window.setMode(s*gw, s*gh)
   sx, sy = s, s
end
