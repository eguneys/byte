Card = Object:extend()
function Card:init()
end


CardStack = Object:extend()
function CardStack:init()
  self.cards = { }

  self.margin = 8 
end

function CardStack:add(card)
  table.insert(self.cards, card)
end

function CardStack:draw(x, y)

  for i, card in ipairs(self.cards) do
    card:draw(x, y + i * self.margin)
  end
end


Foundation = Object:extend()
function Foundation:init(x, y)
  self.x, self.y = x, y
  self.hiddens = CardStack()
end

function Foundation:add_hidden(card)
  self.hiddens:add(card)
end

function Foundation:draw()
  self.hiddens:draw(self.x, self.y)
end


ShuffleCard = Object:extend()
function ShuffleCard:init(card)
  self.pos = Vector(0, 0)
  self.ipos = Vector(0, 0)
  self.target = Vector(0, 0)
  self.it = 0
  self.delay = 0.1
  self.card = card
end

function ShuffleCard:update(dt)

  self.it = self.it + dt

  local t = math.sine_in_out(self.it / self.delay)

  if t > 0.99 then
    self.ipos = self.target
    self.target = Vector(random:int(-10,  300),
    random:int(-10, 160))
    self.it = 0
    self.delay = self.ipos:distance(self.target) / (200 + random:int(100))
  else 
    self.pos = vlerp(t, self.ipos, self.target)
  end
end


function vlerp(f, vsrc, vdst)
  return Vector(
  math.lerp(f, vsrc.x, vdst.x),
  math.lerp(f, vsrc.y, vdst.y))
end


function ShuffleCard:draw()
  self.card:draw(self.pos.x, self.pos.y)
end


Solitaire = Object:extend()
function Solitaire:init()
  self.foundations = {
    Foundation(32 * 0 + 42, 0, 0),
    Foundation(32 * 1 + 42, 0, 1),
    Foundation(32 * 2 + 42, 0, 2),
    Foundation(32 * 3 + 42, 0, 3),
    Foundation(32 * 4 + 42, 0, 4),
    Foundation(32 * 5 + 42, 0, 5),
    Foundation(32 * 6 + 42, 0, 6),
  }


  self.sc = {}
  -- table.insert(self.sc, ShuffleCard(BackCard()))

  for i = 1,7 do
    for j = 1, i do
      table.insert(self.sc, ShuffleCard(BackCard()))
    end
  end

end

function Solitaire:update(dt)
  for _, sc in ipairs(self.sc) do
    sc:update(dt)
  end

end

function Solitaire:draw()

  for i, f in ipairs(self.foundations) do
    f:draw()
  end


  for _, sc in ipairs(self.sc) do
    sc:draw()
  end
end

BackCard = Object:extend()
BackCard:implement(Card)
function BackCard:init()
  
  self.anim = anim8.newAnimation(g34(2, 1), 1)
end

function BackCard:draw(x, y)
  self.anim:draw(sprites, math.round(x), math.round(y))
end


Play = Object:extend()

dbg = ''

function Play:init()

  self.solitaire = Solitaire()
end

function Play:update(dt)
  self.solitaire:update(dt)
end

function Play:draw()


  self.solitaire:draw()


   if dbg then
      love.graphics.setColor(1,0,0,1)
      love.graphics.print(dbg, 0, 0)
   end
end
