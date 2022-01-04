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
  return hit_test_rect(self.pos.x, 
  self.pos.y,
  w, h, x, y)
end

function HasCardWithPos:decay(x, y)
  return Vector(self.pos.x - x, self.pos.y - y)
end


function hit_test_rect(x, y, w, h, ax, ay)
return x < ax and x + w > ax and
  y < ay and y + h > ay
end

function hit_test_rect_big(x, y, w, h, ax, ay, by)
  by = by or 4
return x - by < ax and x + w + by > ax and
  y - by < ay and y + h + by > ay
end




CardStack = Object:extend()
CardStack:implement(HasPos)
function CardStack:init(x, y, margin)

  self:init_pos(Vector(x, y))

  self.margin = margin or 8
  self.cards = { }
end

function CardStack:is_empty()
  return #self.cards == 0
end


function CardStack:remove()
  return table.remove(self.cards)
end

function CardStack:set(cards)
  for i=1,3 do
    self:remove()
  end
  self:paste(cards)
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
      return #self.cards - i + 1, card:decay(x, y)
    end
  end
end

function CardStack:hit_target_front(x, y)
  if #self.cards == 0 then return false end
  local card = self.cards[#self.cards]
  return card:hit(30, 40, x, y)
end

function CardStack:hit_target_empty(x, y)
  if #self.cards ~= 0 then return false end
  return self:hit_target_base(x, y)
end

function CardStack:hit_target_base(x, y)
  local stack_decay = Vector(self.pos.x - x, self.pos.y - y)
  return hit_test_rect(self.pos.x,
  self.pos.y, 30, 40, x, y), stack_decay
end

function CardStack:paste(cards)
  for _, card in ipairs(cards) do
    self:add(card)
  end
end

function CardStack:cut(back_index)
  local index = #self.cards - back_index + 1
  local pos = self.cards[index].pos
  local res = CardStack(pos.x, pos.y)

  local tmp = table_splice(self.cards, index, #self.cards)
  table_reverse(tmp)
  res:paste(tmp)
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

function CardStack:addasis(card)
  card:add_to_stack(self.pos.x, self.pos.y, #self.cards * self.margin)
  table.insert(self.cards, card)
end

function CardStack:update(dt)
  for i, card in ipairs(self.cards) do
    card:update(dt)
  end
end


function CardStack:draw(pass)
  for i, card in ipairs(self.cards) do
    card:draw(pass)
  end
end


Foundation = Object:extend()
Foundation:implement(HasPos)
function Foundation:init(solitaire, x, y, index)
  self:init_pos(Vector(x, y))
  self.solitaire = solitaire
  self.logic = solitaire.logic
  self.downturned = CardStack(x, y)
  self.upturned = CardStack(x, y)
  self.index = index
  self.dest_data = self.index * 100
end

function Foundation:is_empty()
  return self.upturned:is_empty() and self.downturned:is_empty()
end

function Foundation:add_hidden(cardpos)
  self.downturned:add(cardpos)
  local target_pos = self.downturned:top_target_pos()
  self.upturned:smooth_move(target_pos.x, target_pos.y)
end

function Foundation:add_upturned(cardpos)
  self.upturned:add(cardpos)
end


function Foundation:remove_stack(nb)
  return self.upturned:cut(nb)
end

function Foundation:add_stack(stack, hidetop)
  if hidetop then
    local card = self.upturned:remove()
    self.downturned:add(StillCard(BackCard(), card.pos))
    local target_pos = self.downturned:top_target_pos()
    self.upturned:smooth_move(target_pos.x, target_pos.y)
  end
  self.upturned:paste(stack.cards)
end

function Foundation:reveal(card)
  local reveal_at_pos = self.downturned:remove().pos
  local target_pos = self.downturned:top_target_pos()

  self.upturned:smooth_move(target_pos.x, target_pos.y)
  self.upturned:addasis(RevealCard(card, reveal_at_pos))
end

function Foundation:drag_cancel(stack)
  self.upturned:paste(stack.cards) 
end

function Foundation:in_drop(stack)
  for _, card in ipairs(stack.cards) do 
    self.upturned:add(card)
  end
end

function Foundation:orig_data(hit_index)
  return self.dest_data + hit_index
end

function Foundation:drag_test_cut_stack(x, y)
  local hit_index, hit_decay = self.upturned:hit_target_index(x, y)


  if hit_index ~= nil then
    return DragInfoSolitaire(self.solitaire, self.upturned:cut(hit_index), hit_decay, self, self:orig_data(hit_index))
  end
end

function Foundation:drag_test_drop_stack(x, y)

  if self.upturned:is_empty() and self.downturned:is_empty() then
    return self.downturned:hit_target_empty(x, y)
  else
    return self.upturned:hit_target_front(x, y)
  end
end

function Foundation:update(dt)
  self.downturned:update(dt)
  self.upturned:update(dt)
end


function Foundation:draw(pass)
  self.downturned:draw(pass)
  if self.upturned then
    self.upturned:draw(pass)
  end
end


Waste = Object:extend()
Waste:implement(HasPos)
function Waste:init(solitaire, x, y)
  self.solitaire = solitaire
  self.logic = solitaire.logic
  self:init_pos(Vector(x, y))
  self.cards = CardStack(x, y) 
  self.orig_data = 801
end

function Waste:remove_stack(nb)
  return self.cards:cut(nb)
end

function Waste:add_stack(stack)
  return self.cards:paste(stack.cards)
end

function Waste:drag_cancel(stack)
  self.cards:paste(stack.cards) 
end

function Waste:drag_test_cut_stack(x, y)
  local hit_index, hit_decay = self.cards:hit_target_index(x, y)

  if hit_index == 1 then
    return DragInfoSolitaire(self.solitaire,
    self.cards:cut(hit_index), hit_decay,
    self, self.orig_data)
  end
end


function Waste:set(cards)
  self.cards:set(cards)
end

function Waste:update(dt)
  self.cards:update(dt)
end

function Waste:draw()
  self.cards:draw()
end



Stock = Object:extend()
Stock:implement(HasPos)
function Stock:init(solitaire, x, y)
  self.solitaire = solitaire.logic
  self.logic = solitaire.logic
  self:init_pos(Vector(x, y))
  self.visual = StillCard(BackCard(), self.pos)

  self.cards = CardStack(x, y, 0) 
end

function Stock:add_stack(stack)
  -- TODO stock waste remove
  self.cards:paste(stack.cards)
end

function Stock:click_test(x, y)
  return hit_test_rect(self.pos.x, self.pos.y, 30, 40, x, y)
end

function Stock:maybe_click(x, y)
  if self:click_test(x, y) then
    self.logic:out_deal()
    return true
  end
end

function Stock:update(dt)
  self.cards:update(dt)
  self.visual:update(dt)
end

function Stock:draw()
  self.cards:draw()
  --self.visual:draw()
end




Hole = Object:extend()
Hole:implement(HasPos)
function Hole:init(solitaire, x, y, index)
  self.solitaire = solitaire
  self.logic = solitaire.logic
  self:init_pos(Vector(x, y))
  self.cards = CardStack(x, y, 0)

  self.index = index
  self.dest_data = 900 + self.index * 10
  self.orig_data = self.dest_data

  self.suit = index
end

function Hole:add_cards(cards)
  table_map(cards, function(card)
    card.card.no_shadow = true
    return card
  end)
  self.cards:paste(cards)
end

function Hole:remove_stack(nb)
  return self.cards:cut(nb)
end

function Hole:drag_cancel(stack)
  self:add_cards(stack.cards)
end

function Hole:in_drop(stack)
  self:add_cards(stack.cards)
end


function Hole:drag_test_drop_stack(x, y, stack)
  return self.cards:hit_target_base(x, y)
end

function Hole:drag_test_cut_stack(x, y)
  if self.cards:is_empty() then
    return nil
  end
  local hit_index, hit_decay = self.cards:hit_target_base(x, y)

  if hit_index then
    return DragInfoSolitaire(self.solitaire, self.cards:cut(1), hit_decay, self, self.orig_data)
  end

end

function Hole:update(dt)
  self.cards:update(dt)
end

function Hole:draw(n)
  self.cards:draw(n)
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
  if self.idle then
    self:draw_card_pos(pass)
  else
    self.anim:draw(sprites, math.round(self.pos.x), math.round(self.pos.y))
  end
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
function ShuffleUpAndSolitaire:init(logic, data)
  self.solitaire = Solitaire(logic, function()
    self.sidemenu:show()
  end)


  self.sidemenu = SideMenu(self.solitaire)
  self.md = MouseDraw(self.solitaire, self.sidemenu)


  self.sc = {}

  self.t = Trigger()

  for fi = 1,7 do
    local fs = data[fi]
    local foun = self.solitaire.foundations[fi]
    local hidden = fs[1]

    local max_delay = 0

    for j = 1, hidden+1 do
      local delay = random:float(0.4, 0.6 + (1-fi/7) * 0.4)
      if delay > max_delay then
        max_delay = delay
      end
      table.insert(self.sc, ShuffleCard(BackCard()))

      self.t:after(delay, function ()
        local cardpos = table.remove(self.sc)
        foun:add_hidden(cardpos)
      end)
    end 

    for i=2,#fs, 2 do
      local suit, rank = fs[i], fs[i+1]
      self.t:after(max_delay + 0.2, function ()
        foun:reveal(UpCard(suit, rank))
      end)
    end
  end

  -- 28 24
  for i = 1, 24 do
    table.insert(self.sc, ShuffleCard(BackCard()))
  end

  for i = 1, 4 do
    self.t:after(random:float(0.4, 0.6 + (1-i/4)*0.5), function()
      local tmp = {}
      for j=1,6 do
        local cardpos = table.remove(self.sc)
        table.insert(tmp, cardpos)
      end

      self.solitaire.stock:add_stack(OCardStack(tmp))
    end)
  end
end


function ShuffleUpAndSolitaire:update(dt)

  self.t:update(dt)
  self.solitaire:update(dt)

  for _, sc in ipairs(self.sc) do
    sc:update(dt)
  end

  self.sidemenu:update(dt)
  self.md:update(dt)
end


function ShuffleUpAndSolitaire:draw()

  self.solitaire:draw()


  for _, sc in ipairs(self.sc) do
    sc:draw()
  end

  self.sidemenu:draw()
  self.md:draw()
end


LoadSolitaire = Object:extend()
function LoadSolitaire:init(logic, data)

  self.solitaire = Solitaire(logic, function()
    self.sidemenu:show()
  end)
  self.overlays = Overlays(logic)
  self.sidemenu = SideMenu(self.solitaire, self.overlays)
  self.md = MouseDraw(self.solitaire, self.sidemenu, self.overlays)


  for fi=1,7 do
    local fs = data[fi]
    local foun = self.solitaire.foundations[fi]
    local hidden = fs[1]

    for k=1,hidden do
      foun:add_hidden(StillCard(BackCard(),
      foun.downturned.pos
      ))
    end

    for i=2,#fs, 2 do
      local suit, rank = fs[i], fs[i+1]
      foun:add_upturned(StillCard(UpCard(suit, rank), foun.downturned.pos))
    end
  end



  for hi=8,11 do
    local hs = data[hi][1]
    local hole = self.solitaire.holes[hi-7]

    local cards = {}
    for rank=1,hs do
      table.insert(cards, StillCard(UpCard(hole.suit, rank), Vector(hole.pos.x, hole.pos.y - 8)))
    end

    hole:add_cards(cards)
  end

  local waste = data[12]
  if waste ~= nil then
    local tmp = {}
    for i=1,#waste, 2 do
      local suit, rank = waste[i], waste[i+1]
      table.insert(tmp, StillCard(UpCard(suit, rank), self.solitaire.stock.pos))
    end

    self.solitaire.waste:add_stack(OCardStack(tmp))
  end

end

function LoadSolitaire:update(dt)
  self.sidemenu:update(dt)
  self.solitaire:update(dt)
  self.overlays:update(dt)
  self.md:update(dt)
end


function LoadSolitaire:draw()
  self.solitaire:draw()
  self.sidemenu:draw()
  self.overlays:draw()
  self.md:draw()
end



Solitaire = Object:extend()
function Solitaire:init(logic, onmenu)

  self.logic = logic

  self.bg = anim8.newAnimation(gbg(1, 1), 1)


  self.effects = {}

  self.foundations = {
    Foundation(self, 33 * 0 + 50, 11, 1),
    Foundation(self, 33 * 1 + 50, 11, 2),
    Foundation(self, 33 * 2 + 50, 11, 3),
    Foundation(self, 33 * 3 + 50, 11, 4),
    Foundation(self, 33 * 4 + 50, 11, 5),
    Foundation(self, 33 * 5 + 50, 11, 6),
    Foundation(self, 33 * 6 + 50, 11, 7),
  }

  self.stock = Stock(self, 6, 11)
  self.waste = Waste(self, 6, 65)

  self.holes = {
    Hole(self, 33 * 7 + 52, 11 + 42 * 0, 1),
    Hole(self, 33 * 7 + 52, 11 + 42 * 1, 2),
    Hole(self, 33 * 7 + 52, 11 + 42 * 2, 3),
    Hole(self, 33 * 7 + 52, 11 + 42 * 3, 4),
  }

  self.onmenu = onmenu
  self.undo = Undo(self, 6, 140)
  self.gotomenu = GotoMenu(self, 6, 160)
end

function Solitaire:drag_start(x, y)

  if self.stock:maybe_click(x, y) then
    return
  end

  if self.undo:maybe_click(x, y) then
    return
  end

  if self.gotomenu:maybe_click(x, y) then
    return
  end


  if self.ds ~= nil then return end


  local ds = self.waste:drag_test_cut_stack(x, y)
  if ds then
    self.ds = ds
    return
  end

  for _, foun in ipairs(self.foundations) do
    local ds = foun:drag_test_cut_stack(x, y)
    if ds then
      self.ds = ds
      return
    end
  end

  for _, hole in ipairs(self.holes) do
    local ds = hole:drag_test_cut_stack(x, y)
    if ds then
      self.ds = ds
      return
    end
  end
end

function Solitaire:drag_stop(x, y)
  if self.ds ~= nil then

    for _, hole in ipairs(self.holes) do
      if hole:drag_test_drop_stack(x, y) then
        self.ds:drop_hole(hole)
        return
      end
    end

    for _, foun in ipairs(self.foundations) do
      if foun:drag_test_drop_stack(x, y) then
        self.ds:drop(foun)
        return
      end
    end

    if self.ds:cancel() then
      self.ds = nil
    end
  end
end

function Solitaire:in_undo_deal(waste)

  self.waste:set(table_map(waste, function (oc) 
    return RevealCard(UpCard(oc[1], oc[2]), self.stock.pos)
  end))


  ActionText(self.effects, self.stock.pos.x, self.stock.pos.y, a_undo)
end


function Solitaire:in_undo(orig_data, dest_data, has_reveal)
  local f_index, stack_index = math.floor(orig_data / 100), orig_data % 100
  local dest_index, hole_index = math.floor(dest_data / 100), (dest_data - 900) / 10

  local stack

  if f_index == 9 then
    f_index, stack_index = math.floor(orig_data / 100), (orig_data - 900) / 10
    dest_index = math.floor(dest_data / 100)


    stack = self.foundations[dest_index]:remove_stack(1)


    self.holes[stack_index]:add_cards(stack.cards)

    return
  end

  if dest_index == 9 then
    stack = self.holes[hole_index]:remove_stack(stack_index)
  else
    stack = self.foundations[dest_index]:remove_stack(stack_index)
  end

  if f_index == 8 then
    self.waste:add_stack(stack)
  else 
    self.foundations[f_index]:add_stack(stack, has_reveal)
  end

  ActionText(self.effects, stack.pos.x, stack.pos.y, a_undo)
end

function Solitaire:in_deal(waste)

  self.waste:set(table_map(waste, function (oc) 
    return RevealCard(UpCard(oc[1], oc[2]), self.stock.pos)
  end))

  ActionText(self.effects, self.stock.pos.x, self.stock.pos.y, a_deal)
end

function Solitaire:in_drop(oreveal)
  if self.ds == nil then
    -- TODO sync
    return self.logic:sync()
  end

  self.ds:in_drop(oreveal)
  self.ds = nil
end

function Solitaire:in_drop_cancel()
  if self.ds == nil then
    return self.logic:sync()
  end
  self.ds:cancel(true)
  self.ds = nil
end

function Solitaire:goto_menu()
  self.onmenu()
end


function Solitaire:update(dt)

  for _, ef in ipairs(self.effects) do
    ef:update(dt)
  end

  if self.ds ~= nil then
    self.ds:update(dt)
  end

  for i, f in ipairs(self.foundations) do
    f:update(dt)
  end

  for i, h in ipairs(self.holes) do
    h:update(dt)
  end


  self.stock:update(dt)
  self.waste:update(dt)


  self.undo:update(dt)
  self.gotomenu:update(dt)
end

function Solitaire:draw()

  self.bg:draw(sprites2, 0, 0)
  for i, f in ipairs(self.foundations) do
   f:draw(1)
  end

  for i, h in ipairs(self.holes) do
   h:draw(1)
  end


  self.stock:draw()
  self.waste:draw()


  for i, f in ipairs(self.foundations) do
    f:draw(2)
  end


  for i, h in ipairs(self.holes) do
   h:draw(2)
  end


  if self.ds ~= nil then
    self.ds:draw()
  end


  self.undo:draw()
  self.gotomenu:draw()

  for _, ef in ipairs(self.effects) do
    ef:draw()
  end
end

DragInfoSolitaire = Object:extend()
function DragInfoSolitaire:init(solitaire, stack, decay, target, orig_data)
  self.stack = stack
  self.decay = decay
  self.decay_target = Vector(-11, -4)
  self.target = target
  self.solitaire = solitaire
  self.logic = solitaire.logic
  self.orig_data = orig_data

  self.drop_sent = nil
end

function DragInfoSolitaire:drop_effect(orig_data, dest_data)
  local f_index, stack_index = math.floor(orig_data / 100), orig_data % 100
  local dest_index, hole_index = math.floor(dest_data / 100), (dest_data - 900) / 10

  local x, y = self.drop_sent.pos.x, self.drop_sent.pos.y

  local text = a_f2f

  if f_index == 8 then
    text = a_w2f
  end
  if dest_index == 9 then
    text = a_hole
  end

  ActionText(self.solitaire.effects, x, y, text)

  if f_index <= 7 and self.target:is_empty() then
    ActionText2(self.solitaire.effects,
    self.target.pos.x, self.target.pos.y, a2_empty)
  end
end

function DragInfoSolitaire:in_drop(oreveal)
  if oreveal ~= nil then
    self.target:reveal(UpCard(oreveal[1][1], oreveal[1][2]))

    local x, y = self.target.pos.x, self.target.pos.y
    ActionText2(self.solitaire.effects, x, y, a2_reveal)
  end

  self:drop_effect(self.orig_data, self.drop_sent.dest_data)

  self.drop_sent:in_drop(self.stack)
  self.drop_sent = nil
end

function DragInfoSolitaire:drop(foun)
  if self.drop_sent ~= nil then
    return
  end
  self.logic:out_drop(self.orig_data, foun.dest_data)
  self.drop_sent = foun
end

function DragInfoSolitaire:drop_hole(hole)
  if self.drop_sent ~= nil then
    return
  end

  self.logic:out_drop(self.orig_data, hole.dest_data)
  self.drop_sent = hole
end


function DragInfoSolitaire:cancel(force)
  if not force and self.drop_sent ~= nil then
    return false
  end
  self.target:drag_cancel(self.stack)
  return true
end

function DragInfoSolitaire:update(dt)
  if self.drop_sent ~= nil then
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
function UpCard:init(suit, rank, no_shadow)
  self.no_shadow = no_shadow
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

  if not self.no_shadow then
    self.a_shadow:draw(sprites, x + 1, y + 1)
  end
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
function MouseDraw:init(drag, menu, overlays)
  local x, y = Mouse.x, Mouse.y
  self:init_pos(Vector(x, y))
  self.anim = anim8.newAnimation(g128('1-2', 1), 1)
  self.anim:gotoFrame(1)

  self.drag = drag
  self.menu = menu
  self.overlays = overlays
end

function MouseDraw:drag_start()
  if self.overlays:capture_mouse() then
    self.overlays:click(Mouse.x, Mouse.y)
    return
  end
  if self.menu:capture_mouse() then
    self.menu:click(Mouse.x, Mouse.y)
    return
  end
  self.drag:drag_start(Mouse.x, Mouse.y)
end

function MouseDraw:drag_stop()
  if self.menu:capture_mouse() then
    return
  end
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

TooltipText = Object:extend()
TooltipText:implement(HasPos)
function TooltipText:init(group, x, y, w, h, text)
  self:init_pos(Vector(x, y))
  self.w = w
  self.h = h
  self.group = group
  self.text = text
  table.insert(self.group, self)

  self.i = -1 
  self.t = Trigger()
end

function TooltipText:update(dt)
  self.t:update(dt)

  if self.i == -1 then
    if hit_test_rect(self.pos.x, self.pos.y, self.w, self.h, Mouse.x, Mouse.y) then
      self:show()
    end
  elseif self.i == 1 then
    if not hit_test_rect(self.pos.x, self.pos.y, self.w, self.h, Mouse.x, Mouse.y) then
      self.i = -1
    end
  end
end

function TooltipText:show()

  self.i = 0
  self.t:tween(0.2, self, { i = 1 }, math.sine_out, function()
    self.i = 1
  end)

end


function TooltipText:draw()
  if self.i == -1 then return end

  local x, y = math.round(self.pos.x), math.round(self.pos.y - 12)
  local len = self.text:len() * self.i

  graphics.rectangle(x-4, y-4, 4 * len + 8, 5 + 8, 0, 0, colors.black)
  if self.i == 1 then
    graphics.print(self.text, font, x, y, 0, 1, 1, 0, 0, colors.white)
  end
end



a_deal = 1
a_f2f = 2
a_undo = 3
a_w2f = 4
a_hole = 5
a_h2f = 6

ActionText = Object:extend()
ActionText:implement(HasPos)
function ActionText:init(group, x, y, text_index)
  self:init_pos(Vector(x, y))
  self.group = group
  table.insert(self.group, self)

  self.anim = anim8.newAnimation(g177('1-6', 1), 1)
  self.anim:gotoFrame(text_index)



  self.t = Trigger()

  self.off = -8 
  self.w = 4
  self.h = 9
  self.t:tween(0.2, self, { off=0, w=28 }, math.sine_in, function()
    self.t:tween(0.8, self, { off=8, w=24 }, math.sine_out, function()
      self.off = 8
      self.t:tween(0.2, self, { w=4 }, math.sine_out, function()
        table_remove_element(self.group, self)
      end)
    end)
  end)
end

function ActionText:update(dt)
  self.t:update(dt)
end

function ActionText:draw()

  local off = self.off
  local x, y = math.round(self.pos.x), math.round(self.pos.y - 8)
  local w, h = math.round(self.w), self.h 

  if self.off > 0 then
    --x = math.round(x + self.off)
  end
  graphics.rectangle(x, y-1, w, h, 1, 1, colors.white)
  if self.off > 0 and self.off < 8 then
    self.anim:draw(sprites, x + math.round(self.off), y)
  end
end


a2_reveal = 1
a2_empty = 2

ActionText2 = Object:extend()
ActionText2:implement(HasPos)
function ActionText2:init(group, x, y, text_index)
  self:init_pos(Vector(x, y))
  self.group = group
  table.insert(self.group, self)

  self.anim = anim8.newAnimation(g267('1-2', 1), 1)
  self.anim:gotoFrame(text_index)



  self.t = Trigger()


  self.off = -8 
  self.w = 4
  self.h = 9
  self.t:tween(0.2, self, { off=0, w=28 }, math.sine_in, function()
    self.t:tween(0.8, self, { off=4 }, math.sine_out, function()
      self.off = 8
      self.t:tween(0.2, self, { w=4 }, math.sine_out, function()
        table_remove_element(self.group, self)
      end)
    end)
  end)
end

function ActionText2:update(dt)
  self.t:update(dt)
end

function ActionText2:draw()
  local off = self.off
  local x, y = math.round(self.pos.x), math.round(self.pos.y - 8)
  local w, h = math.round(self.w), self.h 

  if self.off > 0 then
    --x = math.round(x + self.off)
  end
  graphics.rectangle(x, y-1, w, h, 1, 1, colors.white)
  if self.off > 0 and self.off < 8 then
    self.anim:draw(sprites, x + math.round(self.off), y)
  end

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
  -- TODO handle nil scene eg. loading scene
  self.scene = nil
  self.server:get()
end


function SolitaireLogic:update(dt)

  if Input:btn('left') == 2 then
    self.server:get()
  end



  repeat
    local data = self.server:receive()
 
    if data == nil then break end
    local cmd, args = data:match("^(%a*) ?(.*)")
    print(cmd, args)

    if cmd == 'newgame' then

      self:in_newgame(read_data(args))

    elseif cmd == 'undo' then
      if args == 'no' then
        print('undo no')
        return
      end

      --local _, _, ok, rest = args:find("^(ok%f[%A]);?(.+)$")

      local undo_data = read_spaces(args)

      local ok, orig_data, dest_data, has_reveal = unpack(undo_data)

      if ok == 'deal' then

        -- split deal and card stack
        local cmd, wastestr = args:match("^(%a*) ?(.*)")
        local waste = read_stack(wastestr)
        self:in_undo_deal(waste)
      elseif ok == 'ok' then
        self:in_undo(orig_data, dest_data, has_reveal == 'reveal')
      end
    elseif cmd == 'deal' then
      if args == 'no' then
        -- TODO in deal no
        print('in deal no')
        return
      end
        self:in_deal(read_stack(args))
    elseif cmd == 'load' then

      self:in_load(read_data(args))
    elseif cmd == 'drop' then
      if args == 'no' then
        self:in_drop_cancel()
      else 
        -- https://stackoverflow.com/questions/70458771/capture-word-a-or-b-and-part-of-optional-extra-arguments
        local _, _, ok, oreveal = args:find("^(ok%f[%A]);?(.+)$")

        oreveal = oreveal ~= nil and read_stack(oreveal) or nil

        self:in_drop(oreveal)
      end
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

function SolitaireLogic:out_newgame()
  self.server:send('newgame')
end

function SolitaireLogic:out_undo()
  self.server:send('undo')
end

function SolitaireLogic:out_deal()
  self.server:send('deal')
end

function SolitaireLogic:in_undo(orig_data, dest_data, has_reveal)
  self.scene.solitaire:in_undo(orig_data, dest_data, has_reveal)
end

function SolitaireLogic:in_undo_deal(waste)
  self.scene.solitaire:in_undo_deal(waste)
end

function SolitaireLogic:in_deal(waste)
  self.scene.solitaire:in_deal(waste)
end

function SolitaireLogic:in_load(data)
  self.scene = LoadSolitaire(self, data)
end

function SolitaireLogic:in_newgame(data)
  self.scene = ShuffleUpAndSolitaire(self, data)
end

function SolitaireLogic:in_drop(oreveal)
  self.scene.solitaire:in_drop(oreveal)
end

function SolitaireLogic:in_drop_cancel()
    self.scene.solitaire:in_drop_cancel()
end

function SolitaireLogic:in_cancel()
end


function read_data(str)
  local fs = {}

  -- 0 1 1;1 3 2 2 2;0;0;0;4 1 2;2 1 2
  for _ff in str:gmatch("([^;]+);?") do
    table.insert(fs, read_numbers(_ff))
  end

  return fs
end

function read_stack(str)
  local ns = read_numbers(str)
  local res = {}
  for i=1,#ns,2 do

    table.insert(res, {ns[i], ns[i+1]})
  end
  return res
end

function read_numbers(str)
  local res = {}
  for d in str:gmatch("([^ ]+) ?") do
    table.insert(res, tonumber(d))
  end
  return res
end


function read_spaces(str)
  local res = {}
  for d in str:gmatch("([^ ]+) ?") do
    table.insert(res, d)
  end
  return res
end


GotoMenu = Object:extend()
GotoMenu:implement(HasPos)
function GotoMenu:init(solitaire, x, y)
  self.solitaire = solitaire
  self:init_pos(Vector(x, y))

  self.anim = anim8.newAnimation(g1212(5, 1), 1)
  self.shadow = anim8.newAnimation(g1212(6, 1), 1)


  TooltipText(self.solitaire.effects, self.pos.x, self.pos.y, 16, 16, 'menu')
end


function GotoMenu:click_test(x, y)
  return hit_test_rect(self.pos.x -2, self.pos.y - 2, 16, 16, x, y)
end

function GotoMenu:maybe_click(x, y)
  if self:click_test(x, y) then
    self.solitaire:goto_menu()
    return true
  end
end



function GotoMenu:update(dt)
  if Input:btn('m') == 2 then
    self.solitaire:goto_menu()
  end
end

function GotoMenu:draw()
  self.shadow:draw(sprites, self.pos.x + 1, self.pos.y + 1)
  self.anim:draw(sprites, self.pos.x, self.pos.y)
end




Undo = Object:extend()
Undo:implement(HasPos)
function Undo:init(solitaire, x, y)
  self.solitaire = solitaire
  self.logic = solitaire.logic
  self:init_pos(Vector(x, y))

  self.anim = anim8.newAnimation(g1212(1, 1), 1)
  self.shadow = anim8.newAnimation(g1212(2, 1), 1)


  TooltipText(self.solitaire.effects, self.pos.x, self.pos.y, 16, 16, 'undo')
end


function Undo:click_test(x, y)
  return hit_test_rect(self.pos.x -2, self.pos.y - 2, 16, 16, x, y)
end

function Undo:maybe_click(x, y)
  if self:click_test(x, y) then
    self.logic:out_undo()
    return true
  end
end



function Undo:update(dt)
  if Input:btn('u') == 2 then
    self.logic:out_undo()
  end
end

function Undo:draw()
  self.shadow:draw(sprites, self.pos.x + 1, self.pos.y + 1)
  self.anim:draw(sprites, self.pos.x, self.pos.y)
end

SideMenu = Object:extend()
function SideMenu:init(solitaire, overlays)


  self.w = 0
  self.t = Trigger()

  self.i = 0

  self.solitaire = solitaire
  self.logic = solitaire.logic

  self.group = {}


  SideButton(self, 1, 160, "close", function()
    self:hide()
  end)


  SideButton(self, 1, 140, "help", function()
  end)
  

  SideButton(self, 1, 120, "settings", function()
    self:hide()
    overlays:show()
  end)
  

  SideButton(self, 1, 100, "new game", function()
    self.logic:out_newgame()
  end)

  SideButton(self, 1, 80, "statistics", function()
  end)

  SideButton(self, 1, 60, "main menu", function()
  end)




end

function SideMenu:capture_mouse()
  return self.w > 0
end

function SideMenu:click(x, y)
  for _, obj in ipairs(self.group) do
    if obj:maybe_click(x, y) then
      return
    end
  end
end

function SideMenu:show()
  self.w = 0
  self.t:tween(0.4, self, { w=60 }, math.sine_out, function() self.w = 60 end, 'show')
end

function SideMenu:hide()
  self.t:tween(0.4, self, { w = 0 }, math.sine_out, function() self.w = 0 end, 'show')
end

function SideMenu:update(dt)
  self.t:update(dt)
  self.i = self.i + dt 
  local r = math.abs(math.sin(((TAU / (6 * ticks.second)) * self.i)))
  bg_shader:send('r', r)

  for _, obj in ipairs(self.group) do
    obj:update(dt)
  end
end

function SideMenu:draw()

  if self.w == 0 then return end

  bg_shader:set()
  love.graphics.draw(noisetex, 0, 0)
  bg_shader:unset()

  graphics.push(0, 0)
  graphics.translate(-60+self.w)
  graphics.rectangle(0, 0, 61, 180, 0, 0, colors.black)
  graphics.rectangle(0, 0, 1, 180, 0, 0, colors.white)
  --graphics.rectangle(60, 0, 1, 180, 0, 0, colors.white)

  graphics.print('solitaire', font, 4, 2, 0, 1, 1, 0, 0, colors.white)

  for _, obj in ipairs(self.group) do
    obj:draw()
  end

  graphics.pop()
end


SideButton = Object:extend()
SideButton:implement(HasPos)
function SideButton:init(menu, x, y, text, onclick)
  self:init_pos(Vector(x, y))
  self.text = text

  self.menu = menu
  table.insert(menu.group, self)

  self.onclick = onclick

  self.hover = 0
  self.t = Trigger()
end

function SideButton:maybe_click(x, y)
  if hit_test_rect_big(self.pos.x,
    self.pos.y-2, 60, 12, x, y) then
    self.onclick()
    return true
  end

end

function SideButton:maybe_click_cancel(x, y)
end

function SideButton:update(dt)
  self.t:update(dt)
  if self.menu:capture_mouse() then
    if hit_test_rect_big(self.pos.x,
      self.pos.y-2, 60, 12, Mouse.x, Mouse.y) then

      if self.hover == 0 then
        self.t:tween(0.2, self, { hover=1 }, math.sine_out, function()
          self.hover = 1
        end, 'hover')
      end
    else
      if self.hover == 1 then
        self.t:tween(0.2, self, { hover=0 }, math.sine_out, function()
          self.hover = 0
        end, 'hover')
      end
    end
  end
end

function SideButton:draw()
  local x, y = math.round(self.pos.x), math.round(self.pos.y)
  local text_color = self.hover == 0 and colors.white or colors.black
  local bg_color = self.hover == 0 and colors.black or colors.white

  graphics.rectangle(x, y-2, self.hover*60, 10, 0, 0, bg_color)
  graphics.print(self.text, font, x+2, y, 0, 1, 1, 0, 0, text_color)

end

Overlays = Object:extend()
function Overlays:init(logic)
 self.settings = SettingsMenu(logic, 100, 20, function()
   self.active = nil
 end) 

 self.active = nil
end

function Overlays:capture_mouse()
  return self.active ~= nil
end


function Overlays:click(x, y)
  if self.active ~= nil then
    self.active:click(x, y)
  end
end



function Overlays:show()
  self.active = self.settings
  self.active:show(true)
end

function Overlays:update(dt)

  if self.active ~= nil then
    self.active:update(dt)
  end

end


function Overlays:draw()

  if self.active ~= nil then
    self.active:draw()
  end
end



SettingsMenu = Object:extend()
SettingsMenu:implement(HasPos)
function SettingsMenu:init(logic, x, y, onhide)
  self:init_pos(Vector(x, y))
  self.logic = logic

  self.group = {}

  self.active = false
  SideButton(self, x + 60, y + 106, "close", onhide)


  SettingsSelectBox(self, x + 10, y + 30 + 18 * 0, "deal type:", {
    "3 cards",
    "1 card"
  }, function(value) end)

  SettingsSelectBox(self, x + 10, y + 30 + 18 * 1, "pass type:", {
    "single",
    "three",
    "no limit"
  }, function(value) end)


  SettingsSelectBox(self, x + 10, y + 30 + 18 * 2, "show help:", {
    "yes",
    "no"
  }, function(value) end)


end

function SettingsMenu:capture_mouse()
  return self.active
end

function SettingsMenu:click(x, y)
  for _, obj in ipairs(self.group) do
    if obj:maybe_click(x, y) then
      break
    end
  end
  for _, obj in ipairs(self.group) do
    obj:maybe_click_cancel(x, y)
  end
end

function SettingsMenu:show(active)
  self.active = active or false
end

function SettingsMenu:update(dt)
  for _, obj in ipairs(self.group) do
    obj:update(dt)
  end
end

function SettingsMenu:draw()

  bg_shader:set()
  love.graphics.draw(noisetex, 0, 0)
  bg_shader:unset()

  local x, y = math.round(self.pos.x), math.round(self.pos.y)

  graphics.rectangle(x, y, 120, 120, 0, 0, colors.black)

  graphics.print('settings', font, x + 2, y + 2, 0, 1, 1, 0, 0, colors.white)

  for _, obj in ipairs(self.group) do
    obj:draw(1)
  end


  for _, obj in ipairs(self.group) do
    obj:draw(2)
  end
end



SettingsSelectBox = Object:extend()
SettingsSelectBox:implement(HasPos)
function SettingsSelectBox:init(menu, x, y, text, options, onselect)
  self:init_pos(Vector(x, y))
  self.text = text

  self.menu = menu
  table.insert(menu.group, self)

  self.dropdown = DropdownOptions(x + 48, y, options, onselect)
end

function SettingsSelectBox:maybe_click(x, y)
  return self.dropdown:maybe_click(x, y)
end

function SettingsSelectBox:maybe_click_cancel(x, y)
  return self.dropdown:maybe_click_cancel(x, y)
end

function SettingsSelectBox:update(dt)
  self.dropdown:update(dt)
end

function SettingsSelectBox:draw(pass)
  local x, y = math.round(self.pos.x), math.round(self.pos.y)

  graphics.print(self.text, font, x+2, y, 0, 1, 1, 0, 0, colors.white)
  self.dropdown:draw(pass)
end

DropdownOptions = Object:extend()
DropdownOptions:implement(HasPos)
function DropdownOptions:init(x, y, options, onselect)
  self:init_pos(Vector(x, y))
  
  self.options = options


  self.anim = anim8.newAnimation(g5(1, 1), 1)

  self.onselect = onselect
  self.selected = 1
  self.hover = nil

  self.i = 0
  self.t = Trigger()

  self.width = 42
end

function DropdownOptions:maybe_click(x, y)
  if self.i == 1 and self.hover ~= nil then
    self.selected = self.hover
    self.onselect(self.selected)
    return true
  end

  if hit_test_rect_big(self.pos.x,
    self.pos.y-2, self.width, 10, x, y) then
    self.t:tween(0.3, self, { i=1 }, math.sine_out, function() 
      self.i = 1
    end, 'dropdown')
    return true
  else
    self.t:tween(0.01, self, { i = 0 }, math.sine_out, function()
      self.i = 0
    end, 'dropdown')
    return false
  end
end

function DropdownOptions:maybe_click_cancel(x, y)

  if hit_test_rect(self.pos.x,
    self.pos.y-2, self.width, 10, x, y) then
  else
    self.t:tween(0.01, self, { i = 0 }, math.sine_out, function()
      self.i = 0
    end, 'dropdown')
  end

end

function DropdownOptions:update(dt)
  local x, y = self.pos.x, self.pos.y
  self.t:update(dt)
  self.hover = nil
  if self.i == 1 then
    for i, opt in ipairs(self.options) do
      if hit_test_rect(x + 2, -2 + y + 10 * i,
        self.width, 10, Mouse.x, Mouse.y) then
        self.hover = i
      end
    end
  end
end

function DropdownOptions:draw(pass)

  local x, y = math.round(self.pos.x), math.round(self.pos.y)

  if pass == 1 then
    graphics.rectangle(x, y-2, self.width, 10, 0, 0, colors.white, 1)
    self.anim:draw(sprites, x + self.width - 8, y)

    graphics.print(self.options[self.selected], font, x + 2, y, 0, 1, 1, 0, 0, colors.white)

  else

    if self.i == 1 then
      graphics.rectangle(x, y - 2, self.width, 6 + (5 + 10 * #self.options) * self.i, 0, 0, colors.black)
      graphics.rectangle(x, y - 2, self.width, 6 + (5 + 10 * #self.options) * self.i, 0, 0, colors.white, 1)
      for i, opt in ipairs(self.options) do
        local text_color = self.hover == i and colors.black or colors.white
        local bg_color = self.hover == i and colors.white or colors.black
        graphics.rectangle(x + 1, y - 1 + 10 * i, self.width - 3, 8, 0, 0, bg_color)
        graphics.print(opt, font, x + 2, y + 10 * i, 0, 1, 1, 0, 0, text_color)
      end
    elseif self.i > 0 then
      graphics.rectangle(x, y - 2, self.width, 6 + (5 + 10 * #self.options) * self.i, 0, 0, colors.black)
      graphics.rectangle(x, y - 2, self.width, 5 + (5 + 10 * #self.options) * self.i, 0, 0, colors.white, 1)
    end
  end
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
