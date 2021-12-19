Card = Object:extend()
function Card:init()
end

HasCard = Object:extend()
function HasCard:init_card(card)
  self.card = card
end

HasPos = Object:extend()
function HasPos:init_pos(pos)
  self.pos = pos
end

HasCardWithPos = Object:extend()
HasCardWithPos:implement(HasCard)
HasCardWithPos:implement(HasPos)
function HasCardWithPos:init_card_pos(card, pos)
  self:init_card(card)
  self:init_pos(pos)
end

function HasCardWithPos:draw()
  self.card:draw(self.pos.x, self.pos.y)
end

CardStack = Object:extend()
CardStack:implement(HasPos)
function CardStack:init(x, y)

  self:init_pos(Vector(x, y))

  self.targets = {}
  self.bases = {}
  self.cards = { }

  self.margin = 8 

  self.it = 1
  self.t = Trigger()
end

function CardStack:is_idle()
  return self.it == 1
end

function CardStack:remove()
  return table.remove(self.cards)
end

function CardStack:add(cardpos)
  table.insert(self.cards, StillCard(cardpos.card, cardpos.pos))


  self.it = 0
  self.bases = {}
  self.targets = {}
  for i, card in ipairs(self.cards) do
    table.insert(self.bases, Vector(card.pos.x, card.pos.y))
    table.insert(self.targets, Vector(self.pos.x, self.pos.y + i * self.margin))
  end
  
  self.t:tween(0.3, self, { it = 1 }, math.sin_in_out, function()
    self.it = 1
  end, 'settle')

end

function CardStack:update(dt)

  self.t:update(dt)
  for i, card in ipairs(self.cards) do
    card.pos = vlerp(self.it, self.bases[i], self.targets[i])
  end
end


function CardStack:draw()
  for i, card in ipairs(self.cards) do
    card:draw()
  end
end


Foundation = Object:extend()
function Foundation:init(x, y)
  self.downturned = CardStack(x, y)
  self.upturned = nil
end

function Foundation:add_hidden(cardpos)
  self.downturned:add(cardpos)
end


function Foundation:reveal_soon(card)
  self.to_reveal = card
end

function Foundation:update(dt)
  self.downturned:update(dt)

  if self.to_reveal ~= nil and self.downturned:is_idle() then
    if self.upturned == nil then
      local reveal_at_pos = self.downturned:remove().pos

      self.upturned = CardStack(reveal_at_pos.x, reveal_at_pos.y)

      self.upturned:add(self.to_reveal)
      self.to_reveal = nil
    end
  end
end


function Foundation:draw()
  self.downturned:draw()
end

StillCard = Object:extend()
StillCard:implement(HasCardWithPos)
function StillCard:init(card, pos)
  self:init_card_pos(card, pos)
end

ShuffleCard = Object:extend()
ShuffleCard:implement(HasCardWithPos)
function ShuffleCard:init(card)
  self:init_card_pos(card, Vector(0, 0))
  self.ipos = Vector(180, 180)
  self.target = Vector(self.ipos.x, self.ipos.y)
  self.it = 0
  self.delay = 0.1
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

ShuffleUpAndSolitaire = Object:extend()
function ShuffleUpAndSolitaire:init()
  self.solitaire = Solitaire()

  self.sc = {}

  self.t = Trigger()

  for i = 1,7 do
    for j = 1, i do
      table.insert(self.sc, ShuffleCard(BackCard()))

      self.t:after(random:float(0.4, 0.6 + (1-i/7) * 0.4), function ()
        local cardpos = table.remove(self.sc)
        self.solitaire.foundations[i]:add_hidden(cardpos)
      end)
    end 
    self.solitaire.foundations[i]:reveal_soon(UpCard())
  end
end


function ShuffleUpAndSolitaire:update(dt)

  self.t:update(dt)
  self.solitaire:update(dt)

  for _, sc in ipairs(self.sc) do
    sc:update(dt)
  end
end


function ShuffleUpAndSolitaire:draw()

  self.solitaire:draw()


  for _, sc in ipairs(self.sc) do
    sc:draw()
  end

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

end

function Solitaire:update(dt)

  for i, f in ipairs(self.foundations) do
    f:update(dt)
  end
end

function Solitaire:draw()

  for i, f in ipairs(self.foundations) do
    f:draw()
  end

end

UpCard = Object:extend()
UpCard:implement(Card)
function UpCard:init()
end

function UpCard:draw(x, y)
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

  self.solitaire = ShuffleUpAndSolitaire()
end

function Play:update(dt)


  if Input:btn('left') > 0 then
    self.solitaire = ShuffleUpAndSolitaire()
  end


  self.solitaire:update(dt)
end

function Play:draw()


  self.solitaire:draw()


   if dbg then
      love.graphics.setColor(1,0,0,1)
      love.graphics.print(dbg, 0, 0)
   end
end
