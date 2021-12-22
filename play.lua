Card = Object:extend()
function Card:init()
end

HasCard = Object:extend()
function HasCard:init_card(card)
  self.card = card
end

HasPos = Object:extend()
function HasPos:init_pos(pos)
  self.pos = Vector(pos.x, pos.y)
end

HasCardWithPos = Object:extend()
HasCardWithPos:implement(HasCard)
HasCardWithPos:implement(HasPos)
function HasCardWithPos:init_card_pos(card, pos)
  self:init_card(card)
  self:init_pos(pos)
  self.local_pos = Vector(pos.x, pos.y)
  self.stack_pos = Vector(0, 0)
  self.t = Trigger()
end

function HasCardWithPos:smooth_move_local(x, y)

  self.t:tween(0.3, self.local_pos, { x=x, y=y }, math.sine_in_out, function()
    self.local_pos:set(x, y)
  end, 'local_tween')
end

function HasCardWithPos:smooth_move_stack(x, y, a)
  self.t:tween(a, self.stack_pos, { x=x, y=y }, math.sine_in_out, function()
    self.stack_pos:set(x, y)
  end, 'stack_tween')
end


function HasCardWithPos:has_tween()
  return self.t.triggers['local_tween'] ~= nil or 
  self.t.triggers['stack_tween'] ~= nil
end


function HasCardWithPos:add_to_stack(x, y, target_local_y)
  self.stack_pos:set(x, y)
  self.local_pos:sub(x, y)
  self:smooth_move_local(0, target_local_y)
end


function HasCardWithPos:update_card_pos(dt)
  self.t:update(dt)
  self.pos:set(self.local_pos.x + self.stack_pos.x,
  self.local_pos.y + self.stack_pos.y)
end

function HasCardWithPos:draw_card_pos(pass)
  if pass == 2 and not self:has_tween() then return end
  self.card:draw(self.pos.x, self.pos.y)
end

function HasCardWithPos:draw(pass)
  return self:draw_card_pos(pass)
end

function HasCardWithPos:hit(w, h, x, y)
  return self.pos.x < x and self.pos.x + w > x and
  self.pos.y < y and self.pos.y + h > y
end

function HasCardWithPos:decay(x, y)
  return Vector(self.pos.x - x, self.pos.y - y)
end




CardStack = Object:extend()
CardStack:implement(HasPos)
function CardStack:init(x, y, margin)

  self:init_pos(Vector(x, y))

  self.margin = margin or 8
  self.cards = { }
end

function CardStack:remove()
  return table.remove(self.cards)
end

function CardStack:smooth_move(x, y)
  self.pos:set(x, y)
  for i, card in ipairs(self.cards) do
    card:smooth_move_stack(x, y, (i/15) * 0.2)
  end
end

function CardStack:top_target_pos()
  return Vector(self.pos.x, self.pos.y + #self.cards * self.margin)
end


function CardStack:hit_target_index(x, y)
  for i, card in ipairs(self.cards) do
    local height = i == #self.cards and 40 or 8
    if card:hit(30, height, x, y) then
      return i, card:decay(x, y)
    end
  end
end

function CardStack:hit_target_front(x, y)
  if #self.cards == 0 then return false end
  local card = self.cards[#self.cards]
  return card:hit(30, 40, x, y)
end

function CardStack:paste(stack)
  for _, card in ipairs(stack.cards) do
    self:add(card)
  end
end

function CardStack:cut(index)
  -- TODO
  local pos = self.cards[index].pos
  local res = CardStack(pos.x, pos.y)
  local tmp = {}
  for i=#self.cards, index, -1 do
    local card = table.remove(self.cards, i)
    table.insert(tmp, card)
  end
  for i=#tmp, 1, -1 do
    res:add(tmp[i])
  end
  return res
end

-- card 100 0
-- stack 50
-- card 50 50
function CardStack:add(cardpos)
  local card = StillCard(cardpos.card, cardpos.pos)
  card:add_to_stack(self.pos.x, self.pos.y, #self.cards * self.margin)
  table.insert(self.cards, card)
end

function CardStack:update(dt)
  for i, card in ipairs(self.cards) do
    card:update_card_pos(dt)
  end
end


function CardStack:draw(pass)
  for i, card in ipairs(self.cards) do
    card:draw(pass)
  end
end


Foundation = Object:extend()
Foundation:implement(HasPos)
function Foundation:init(logic, x, y, index)
  self:init_pos(Vector(x, y))
  self.logic = logic
  self.downturned = CardStack(x, y)
  self.upturned = nil
  self.index = index
  self.dest_data = self.index * 100
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

function Foundation:drag_cancel(stack)
  self.upturned:paste(stack) 
end

function Foundation:drag_drop(stack)
  for _, card in ipairs(stack.cards) do 
    self.upturned:add(card)
  end
end

function Foundation:orig_data(hit_index)
  return self.dest_data + hit_index
end

function Foundation:drag_cut_stack(x, y)
  local hit_index, hit_decay = self.upturned:hit_target_index(x, y)


  if hit_index ~= nil then
    return DragInfoSolitaire(self.logic, self.upturned:cut(hit_index), hit_decay, self, self:orig_data(hit_index))
  end
end

function Foundation:drag_drop_stack(x, y, stack)

  if self.upturned:hit_target_front(x, y) then
    return true
  end
end

function Foundation:update(dt)

  self.downturned:update(dt)


  if self.to_reveal ~= nil and #self.downturned.cards > 0 then
    if self.upturned == nil then
     local reveal_at_pos = self.downturned:remove().pos

     self.upturned = CardStack(reveal_at_pos.x, reveal_at_pos.y)

     self.upturned:add(RevealCard(self.to_reveal, reveal_at_pos))
     self.to_reveal = nil
    end
  end


  if self.to_upturned ~= nil then
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


function Foundation:draw(pass)
  self.downturned:draw(pass)
  if self.upturned then
    self.upturned:draw(pass)
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

function StillCard:update(dt)
  self:update_card_pos(dt)
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
  self:update_card_pos(dt)
  self.anim:update(dt)
end

function RevealCard:draw(pass)
  self.anim:draw(sprites, math.round(self.pos.x), math.round(self.pos.y))
end


function RevealCard:draw_back()
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

function vlerp(f, vsrc, vdst)
  return Vector(
  math.lerp(f, vsrc.x, vdst.x),
  math.lerp(f, vsrc.y, vdst.y))
end

function vlerp_dt(f, dt, vsrc, vdst)
  return Vector(
  math.lerp_dt(f, dt, vsrc.x, vdst.x),
  math.lerp_dt(f, dt, vsrc.y, vdst.y))
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
function LoadSolitaire:init(logic, data)

  self.solitaire = Solitaire(logic)
  self.md = MouseDraw(self.solitaire)

  for fi, fs in ipairs(data) do
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
  self.md:update(dt)
end


function LoadSolitaire:draw()
  self.solitaire:draw()
  self.md:draw()
end



Solitaire = Object:extend()
function Solitaire:init(logic)

  self.bg = anim8.newAnimation(gbg(1, 1), 1)

  self.foundations = {
    Foundation(logic, 33 * 0 + 50, 11, 1),
    Foundation(logic, 33 * 1 + 50, 11, 2),
    Foundation(logic, 33 * 2 + 50, 11, 3),
    Foundation(logic, 33 * 3 + 50, 11, 4),
    Foundation(logic, 33 * 4 + 50, 11, 5),
    Foundation(logic, 33 * 5 + 50, 11, 6),
    Foundation(logic, 33 * 6 + 50, 11, 7),
  }

  self.stock = CardStack(8, 8, 0.1)
  self.waste = CardStack(8, 40 + 8 + 8)


  self.logic = logic
end

function Solitaire:drag_start(x, y)

  if self.ds ~= nil then return end

  for _, foun in ipairs(self.foundations) do
    local ds = foun:drag_cut_stack(x, y)
    if ds then
      self.ds = ds
      return
    end
  end
end

function Solitaire:drag_stop(x, y)
  if self.ds ~= nil then

    for _, foun in ipairs(self.foundations) do
      if foun:drag_drop_stack(x, y, self.ds.stack) then
        self.ds:drop(foun)
        return
      end
    end

    if self.ds:cancel() then
      self.ds = nil
    end
  end
end

function Solitaire:deal_stock3(cards)


  for i=1,3 do
    local cardpos = self.stock:remove()


    self.waste:add(RevealCard(cards[i], cardpos.pos))

  end

end

function Solitaire:update(dt)


  if self.ds ~= nil then
    self.ds:update(dt)
  end

  for i, f in ipairs(self.foundations) do
    f:update(dt)
  end

  self.stock:update(dt)
  self.waste:update(dt)

  local im = Mouse:btn()
end

function Solitaire:draw()

  self.bg:draw(sprites2, 0, 0)
  for i, f in ipairs(self.foundations) do
   f:draw(1)
  end

  self.stock:draw()
  self.waste:draw()


  for i, f in ipairs(self.foundations) do
    f:draw(2)
  end

  if self.ds ~= nil then
    self.ds:draw()
  end


end

DragInfoSolitaire = Object:extend()
function DragInfoSolitaire:init(logic, stack, decay, target, orig_data)
  self.stack = stack
  self.decay = decay
  self.decay_target = Vector(-11, -4)
  self.target = target
  self.logic = logic
  self.orig_data = orig_data

  self.drop_sent = false
end

function DragInfoSolitaire:drop(foun)
  --foun:drag_drop(self.stack)
  self.logic:out_drop(self.orig_data, foun.dest_data)
  self.drop_sent = true
end


function DragInfoSolitaire:cancel()
  if self.drop_sent then
    return false
  end
  self.target:drag_cancel(self.stack)
  return true
end

function DragInfoSolitaire:update(dt)
  if self.drop_sent then
    return
  end
  self.stack:smooth_move(Mouse.x + self.decay.x, Mouse.y + self.decay.y)
  self.stack:update(dt)

  self.decay = vlerp_dt(0.1, dt, self.decay, self.decay_target)

end


function DragInfoSolitaire:draw()
  self.stack:draw()
end



UpCard = Object:extend()
UpCard:implement(Card)
function UpCard:init(suit, rank)
  self.suit = suit
  self.rank = rank
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

MouseDraw = Object:extend()
MouseDraw:implement(HasPos)
function MouseDraw:init(drag)
  local x, y = Mouse.x, Mouse.y
  self:init_pos(Vector(x, y))
  self.anim = anim8.newAnimation(g128('1-2', 1), 1)
  self.anim:gotoFrame(1)

  self.drag = drag
end

function MouseDraw:drag_start()
  self.drag:drag_start(Mouse.x, Mouse.y)
end

function MouseDraw:drag_stop()
  self.drag:drag_stop(Mouse.x, Mouse.y)
end


function MouseDraw:update(dt)
  self.pos:set(Mouse.x, Mouse.y)

  local im = Mouse:btn()

  if im > 0 then
    self.anim:gotoFrame(2)
  else
    self.anim:gotoFrame(1)
  end


  if im == 2 then
    self:drag_start()
  elseif im == -1 then
    self:drag_stop()
  end

end

function MouseDraw:draw()

  local x, y = math.round(self.pos.x), math.round(self.pos.y)
  self.anim:draw(sprites, x, y)
end



Showcase = Object:extend()
function Showcase:init()
  self.r = RevealCard(UpCard(1, 1), Vector(50, 50))

  self.r:smooth_move_local(100, 100)
  self.r:smooth_move_stack(10, 10)


  self.cs = CardStack(80, 0)

  self.cs:add(StillCard(UpCard(1, 1), Vector(20, 0)))
  self.cs:add(RevealCard(UpCard(2, 2), Vector(300, 0)))
  self.cs:add(RevealCard(UpCard(2, 2), Vector(300, 0)))
  self.cs:add(RevealCard(UpCard(2, 2), Vector(300, 0)))
end

function Showcase:update(dt)
  self.r:update(dt)
  self.cs:update(dt)
end

function Showcase:draw()
  self.r:draw()
  self.cs:draw()
end



SolitaireLogic = Object:extend()
function SolitaireLogic:init(server)
  self.server = server
  self.scene = ShuffleUpAndSolitaire()
  self.server:get()
end


function SolitaireLogic:update(dt)
  repeat
    local data = self.server:receive()
 
    if data == nil then break end
    local cmd, args = data:match("^(%a*) ?(.*)")

    if cmd == 'load' then


      local fs = {}

      -- 0 1 1;1 3 2 2 2;0;0;0;4 1 2;2 1 2
      for _ff in args:gmatch("([^;]+);?") do
        local ff = {}
        for d in _ff:gmatch("([^ ]+) ?") do
          table.insert(ff, tonumber(d))
        end
        table.insert(fs, ff)
      end

      self:in_load(fs)
    else
      print('Unrecognized cmd', cmd)
    end
  until data == nil
  self.scene:update(dt)
end


function SolitaireLogic:draw()
  self.scene:draw()
end

function SolitaireLogic:out_drop(orig, dest)
  self.server:send(string.format('drop %02d %02d', orig, dest))
end

function SolitaireLogic:in_load(data)
  self.scene = LoadSolitaire(self, data)
end

function SolitaireLogic:in_drop(ok, oreveal)
  if ok then
    if oreveal ~= nil then
    end
  end
end

function SolitaireLogic:in_cancel()
end


SolitaireServer = Object:extend()
function SolitaireServer:init()
  self.messages = {}
end

function SolitaireServer:get()
  table.insert(self.messages, 'load 0 1 1;1 3 2 2 2;0;0;0;4 1 2;2 1 2')
end

function SolitaireServer:send(msg)
  local cmd, args = msg:match("^(%a*) ?(.*)")

  if cmd == 'drop' then
    print(args)
  end
end

function SolitaireServer:receive()
  return table.remove(self.messages)
end



Play = Object:extend()

dbg = ''

function Play:init()

  print('[Init] Play')


  local server = SolitaireServer()
  self.logic = SolitaireLogic(server)
end





function Play:update(dt)

  self.logic:update(dt)
end

function Play:draw()

  self.logic:draw()


  if dbg then
    love.graphics.setColor(1,0,0,1)
    love.graphics.print(dbg, 0, 0)
  end
end
