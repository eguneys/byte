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

function HasCardWithPos:draw_card_pos()
  self.card:draw(self.pos.x, self.pos.y)
end


CardStack = Object:extend()
CardStack:implement(HasPos)
function CardStack:init(x, y, margin)

  self:init_pos(Vector(x, y))

  self.margin = margin or 8
  self.targets = {}
  self.bases = {}
  self.cards = { }

  self.it = 1
  self.t = Trigger()


  self.to_adds = {}
end

function CardStack:is_idle()
  return self.it == 1
end

function CardStack:remove()
  return table.remove(self.cards)
end

function CardStack:is_idle()
  return #self.to_adds == 0 and self.it == 1
end

function CardStack:remove()
  return table.remove(self.cards)
end

function CardStack:add(cardpos)
  table.insert(self.to_adds, cardpos)
end

function CardStack:top_target_pos()
  return self.targets[#self.targets]
end

function CardStack:_do_add(cardpos)
  table.insert(self.cards, StillCard(cardpos.card, cardpos.pos))

  self.it = 0
  self.bases = {}
  self.targets = {}
  for i, card in ipairs(self.cards) do
    table.insert(self.bases, Vector(card.pos.x, card.pos.y))
    table.insert(self.targets, Vector(self.pos.x, self.pos.y + (i - 1) * self.margin))
  end

  table.insert(self.targets, Vector(self.pos.x, self.pos.y + #self.cards * self.margin))
  
  self.t:tween(0.3, self, { it = 1 }, math.sine_in_out, function()
    self.it = 1
  end, 'settle')

end

function CardStack:update(dt)

  self.t:update(dt)

  for i = #self.to_adds, 1, -1 do
    local cardpos = self.to_adds[i]
    if cardpos:is_idle() then
      self:_do_add(cardpos)
      table.remove(self.to_adds, i)
    end
  end


  for i, card in ipairs(self.cards) do
    card.pos = vlerp(self.it, self.bases[i], self.targets[i])
  end

  for i, to_add in ipairs(self.to_adds) do
    to_add:update(dt)
  end
end


function CardStack:draw()
  for i, card in ipairs(self.cards) do
    card:draw()
  end

  for i, to_add in ipairs(self.to_adds) do
    to_add:draw()
  end
end


Foundation = Object:extend()
Foundation:implement(HasPos)
function Foundation:init(x, y)
  self:init_pos(Vector(x, y))
  self.downturned = CardStack(x, y)
  self.upturned = nil
end

function Foundation:add_hidden(cardpos)
  self.downturned:add(cardpos)
end

function Foundation:add_upturned(ss_cardpos)
  self.to_upturned = ss_cardpos
end

function Foundation:reveal_soon(card)
  self.to_reveal = card
end

function Foundation:update(dt)
  self.downturned:update(dt)


  if self.to_reveal ~= nil and #self.downturned.cards > 0 and self.downturned:is_idle() then
    if self.upturned == nil then
     local reveal_at_pos = self.downturned:remove().pos

     self.upturned = CardStack(reveal_at_pos.x, reveal_at_pos.y)

     self.upturned:add(RevealCard(self.to_reveal, reveal_at_pos))
     self.to_reveal = nil
    end
  end


  if self.to_upturned ~= nil and self.downturned:is_idle() then
    if self.upturned == nil then
      local target_pos = self.downturned:top_target_pos()
      if target_pos == nil then
        target_pos = self.pos
      end
      self.upturned = CardStack(target_pos.x, target_pos.y)
    end
    for _, cardpos in ipairs(self.to_upturned) do
      self.upturned:add(cardpos)
    end
    self.to_upturned = nil
  end






  self.downturned:update(dt)
  if self.upturned then
    self.upturned:update(dt)
  end
  
end


function Foundation:draw()
  self.downturned:draw()
  if self.upturned then
    self.upturned:draw()
  end
end

StillCard = Object:extend()
StillCard:implement(HasCardWithPos)
function StillCard:init(card, pos)
  self:init_card_pos(card, pos)
end

function StillCard:is_idle()
  return true
end

function StillCard:draw()
  self:draw_card_pos()
end


RevealCard = Object:extend()
RevealCard:implement(HasCardWithPos)
function RevealCard:init(card, pos)
  self:init_card_pos(card, pos)
  self.idle = false

  self.anim = anim8.newAnimation(g34('4-8', 1), 0.4/5, function()
    self.idle = true
    self.anim:pauseAtEnd()
  end)
end

function RevealCard:is_idle()
  return self.idle
end

function RevealCard:update(dt)
  self.anim:update(dt)
end

function RevealCard:draw()
  self.anim:draw(sprites, math.round(self.pos.x), math.round(self.pos.y))
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

function ShuffleCard:is_idle()
  return true
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

function ShuffleCard:draw()
  self:draw_card_pos()
end



function vlerp(f, vsrc, vdst)
  return Vector(
  math.lerp(f, vsrc.x, vdst.x),
  math.lerp(f, vsrc.y, vdst.y))
end



ShuffleUpAndSolitaire = Object:extend()
function ShuffleUpAndSolitaire:init()
  self.solitaire = Solitaire()

  self.sc = {}

  self.t = Trigger()

  for i = 1,7 do
    local max_delay = 0

    for j = 1, i do
      local delay = random:float(0.4, 0.6 + (1-i/7) * 0.4)
      if delay > max_delay then
        max_delay = delay
      end
      table.insert(self.sc, ShuffleCard(BackCard()))

      self.t:after(delay, function ()
        local cardpos = table.remove(self.sc)
        self.solitaire.foundations[i]:add_hidden(cardpos)
      end)
    end 
    self.t:after(max_delay + 0.2, function ()
      self.solitaire.foundations[i]:reveal_soon(UpCard(4, 12))
    end)
  end

  -- 28 24
  for i = 1, 24 do

    table.insert(self.sc, ShuffleCard(BackCard()))

    self.t:after(random:float(0.4, 0.6 + (1-i/24)*0.5), function()
      local cardpos = table.remove(self.sc)

      self.solitaire.stock:add(cardpos)
    end)
  end

  self.t:after(2, function()
    self.solitaire:deal_stock3 {
      UpCard(1, 1),
      UpCard(2, 2),
      UpCard(3, 3)
    } 
  end)

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


LoadSolitaire = Object:extend()
function LoadSolitaire:init()


  self.fs = {
    { 0, 1, 1, 1, 2, 1, 3 },
    { 0 },
    { 0, 1, 4 },
    { 2, 2, 1, 3, 4 },
    { 2, 3, 2, 4, 4 },
    { 2, 3, 2, 4, 4, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3 },
    { 5, 3, 2  }
  }

  self.solitaire = Solitaire()

  for fi, fs in ipairs(self.fs) do
    local foun = self.solitaire.foundations[fi]
    local hidden = fs[1]

    for k=1,hidden do
      foun:add_hidden(StillCard(BackCard(),
      foun.downturned.pos
      ))
    end

    local ss_upturned = {}
    for i=2,#fs, 2 do
      local suit, rank = fs[i], fs[i+1]
      table.insert(ss_upturned, StillCard(UpCard(suit, rank), foun.downturned.pos))
    end

    foun:add_upturned(ss_upturned)
  end


end

function LoadSolitaire:update(dt)
  self.solitaire:update(dt)
end


function LoadSolitaire:draw()
  self.solitaire:draw()
end



Solitaire = Object:extend()
function Solitaire:init()

  self.bg = anim8.newAnimation(gbg(1, 1), 1)


  self.foundations = {
    Foundation(33 * 0 + 50, 11, 0),
    Foundation(33 * 1 + 50, 11, 1),
    Foundation(33 * 2 + 50, 11, 2),
    Foundation(33 * 3 + 50, 11, 3),
    Foundation(33 * 4 + 50, 11, 4),
    Foundation(33 * 5 + 50, 11, 5),
    Foundation(33 * 6 + 50, 11, 6),
  }

  self.stock = CardStack(8, 8, 0.1)
  self.waste = CardStack(8, 40 + 8 + 8)

end

function Solitaire:deal_stock3(cards)


  for i=1,3 do
    local cardpos = self.stock:remove()


    self.waste:add(RevealCard(cards[i], cardpos.pos))

  end

end

function Solitaire:update(dt)

  for i, f in ipairs(self.foundations) do
    f:update(dt)
  end

  self.stock:update(dt)
  self.waste:update(dt)
end

function Solitaire:draw()

  self.bg:draw(sprites2, 0, 0)
  for i, f in ipairs(self.foundations) do
    f:draw()
  end

  self.stock:draw()
  self.waste:draw()

end

UpCard = Object:extend()
UpCard:implement(Card)
function UpCard:init(suit, rank)
  self.anim = anim8.newAnimation(g34(1, 1), 1)
  self.a_shadow = anim8.newAnimation(g34(3, 1), 1)

  self.a_suit1 = anim8.newAnimation(g66('1-4', 1), 1)
  self.a_rank1 = anim8.newAnimation(g86('1-13', 1), 1)
  self.a_suit2 = anim8.newAnimation(g66('1-4', 2), 1)
  self.a_rank2 = anim8.newAnimation(g86('1-13', 2), 1)

  self.a_suit = suit%2==1 and self.a_suit2 or self.a_suit1
  self.a_rank = suit%2==1 and self.a_rank2 or self.a_rank1
  self.a_suit:gotoFrame(suit)
  self.a_rank:gotoFrame(rank)
end

function UpCard:draw(x, y)
  x = math.round(x)
  y = math.round(y)

  self.a_shadow:draw(sprites, x + 1, y + 1)
  self.anim:draw(sprites, x, y)
  self.a_suit:draw(sprites, x+22, y+2)
  self.a_rank:draw(sprites, x+2, y+2)

end


BackCard = Object:extend()
BackCard:implement(Card)
function BackCard:init()
  self.anim = anim8.newAnimation(g34(2, 1), 1)
  self.a_shadow = anim8.newAnimation(g34(3, 1), 1)
end

function BackCard:draw(x, y)
  x = math.round(x)
  y = math.round(y)
  self.a_shadow:draw(sprites, x + 1, y + 1)
  self.anim:draw(sprites, x, y)
end


Showcase = Object:extend()
function Showcase:init()
  self.r = RevealCard(UpCard(1, 1), Vector(50, 50))
end

function Showcase:update(dt)
  self.r:update(dt)
end

function Showcase:draw()
  self.r:draw()
end

MouseDraw = Object:extend()
MouseDraw:implement(HasPos)
function MouseDraw:init()
  local x, y = Mouse.x, Mouse.y
  self:init_pos(Vector(x, y))
  self.anim = anim8.newAnimation(g12('1-2', 1), 1)
  self.anim:gotoFrame(2)

end


function MouseDraw:update(dt)
  self.pos:set(Mouse.x, Mouse.y)
  if Mouse.cur ~= nil then
    self.anim:gotoFrame(1)
  else
    self.anim:gotoFrame(2)
  end
end

function MouseDraw:draw()

  local x, y = math.round(self.pos.x), math.round(self.pos.y)
  self.anim:draw(sprites, x, y)
end

Play = Object:extend()

dbg = ''

function Play:init()

  print('[Init] Play')



  self.md = MouseDraw()
  self.solitaire = LoadSolitaire()
end

function Play:update(dt)


  if Input:btn('left') > 0 then
    --self.solitaire = ShuffleUpAndSolitaire()
    self.solitaire = LoadSolitaire()
  end


  self.md:update(dt)
  self.solitaire:update(dt)
end

function Play:draw()


  self.solitaire:draw()
  self.md:draw()


  if dbg then
    love.graphics.setColor(1,0,0,1)
    love.graphics.print(dbg, 0, 0)
  end
end
