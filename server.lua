function fn_write(v)
  return v:write()
end

function table_map(src, fn)
  local res = {}
  for _, v in ipairs(src) do
    table.insert(res, fn(v))
  end
  return res
end


function table_slice(src, from, to)
  from = from or 0
  to = to or #src

  local res = {}
  for i=1,to do
    if i >= from then
      table.insert(res, src[i])
    end
  end
  return res
end

function table_splice(src, from, to)
  from = from or 0
  to = to or #src

  local res = {}
  for i=to,from,-1 do
    table.insert(res, table.remove(src, i))
  end
  return res
end

function table_append(a, b)
  for _, v in ipairs(b) do
    table.insert(a, v)
  end
  return a
end

function table_reverse(t)
	local len = #t
	for i = len - 1, 1, -1 do
		t[len] = table.remove(t, i)
	end
  return t
end



function table_write(table, sep)
  sep = sep or ' '
  local res = table[1] 
  for i=2,#table do
    res = res .. sep .. table[i]
  end
  return res
end

OCard = Object:extend()
function OCard:init(suit, rank)
  self.suit = suit
  self.rank = rank
end

function OCard:write()
  return self.suit .. ' ' .. self.rank
end

OCardStack = Object:extend()
function OCardStack:init(cards)
  self.cards = table_slice(cards)
end

function OCardStack:is_empty()
  return #self.cards == 0
end

function OCardStack:push(card)
  return table.insert(self.cards, card)
end

function OCardStack:append(stack)
  table_append(self.cards, stack)
end

function OCardStack:pop(n)
  return table_reverse(table_splice(self.cards, #self.cards - n + 1, #self.cards))
end

function OCardStack:cut(n)
  return self:pop(n)
end


function OCardStack:write()
  return table.concat(
  table_map(self.cards, fn_write), ' ')
end

suits = { 1, 2, 3, 4 }
ranks = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13 }

deck = {}

for _, suit in ipairs(suits) do
  for _, rank in ipairs(ranks) do
    table.insert(deck, OCard(suit, rank))
  end
end

function alternate_color(a, b)
  return (a + b) % 2 == 1
end

function one_higher_rank(a, b)
  return a + 1 == b
end

function top_rank(a)
  return a == 13
end

function bottom_rank(a)
  return a == 1
end

OFoundation = Object:extend()
function OFoundation:init(downturned, upturned)
  self.downturned = OCardStack(downturned)
  self.upturned = OCardStack(upturned)
end

function OFoundation:cut(n)
  local stack = self.upturned:cut(n)
  if self.upturned:is_empty() then
    if not self.downturned:is_empty() then
      -- TODO may not be a pop but shift
      local oreveal = self.downturned:pop(1)[1]
      self.upturned:push(oreveal)
      return stack, oreveal
    end
  end
  return stack
end

function OFoundation:paste(stack)
  self.upturned:append(stack)
end

function OFoundation:uncut(stack, has_reveal)
  if has_reveal then
    local hide = self.upturned:pop(1)[1]
    self.downturned:push(hide)
  end
  self.upturned:append(stack)
end

function OFoundation:unpaste(nb_cards)
  return self.upturned:unpaste(nb_cards)
end


function OFoundation:write()
  return #self.downturned.cards .. " " .. self.upturned:write()
end


OHole = Object:extend()
function OHole:init(cards)
  self.stack = OCardStack(cards)
end

function OHole:cut(nb)
  return self.stack:cut(nb)
end

function OHole:paste(stack)
  self.stack:append(stack)
end

function OHole:write()
  return #self.stack.cards
end


-- 100 700 foundation indexes
-- 101-113 stack indexes
-- 800 waste index
-- 910 920 930 940 hole indexes
OSolitaire = Object:extend()
function OSolitaire:init(_deck)

  local dstack = OCardStack(_deck)

  self.fs = {
    OFoundation(dstack:pop(0), dstack:pop(1)),
    OFoundation(dstack:pop(1), dstack:pop(1)),
    OFoundation(dstack:pop(2), dstack:pop(1)),
    OFoundation(dstack:pop(3), dstack:pop(1)),
    OFoundation(dstack:pop(4), dstack:pop(1)),
    OFoundation(dstack:pop(5), dstack:pop(1)),
    OFoundation(dstack:pop(6), dstack:pop(1))
  }


  self.stock = dstack
  self.waste = OCardStack({})


  self.holes = {
    OHole({}),
    OHole({}),
    OHole({}),
    OHole({})
  }

  self.undo_stack = {}
end

function OSolitaire:undo()

  local undo = table.remove(self.undo_stack)

  if undo == nil then
    return 'no'
  end

  local orig_data, dest_data, oreveal = unpack(undo)

  self:_undrop(orig_data, dest_data, oreveal ~= nil)

  local reveal_data = oreveal ~= nil and 'reveal' or ''

  return 'ok' .. ' ' .. orig_data .. ' ' .. dest_data .. ' ' .. reveal_data

end

function OSolitaire:deal()
  if not self.stock:is_empty() then
    local res = self.stock:pop(3)
    self.waste:append(res)
    return res
  end
end

function OSolitaire:_undrop(orig_data, dest_data, has_reveal)
  local f_index, stack_index = math.floor(orig_data / 100), orig_data % 100
  local dest_index, hole_index = math.floor(dest_data / 100), (dest_data - 900) / 10

  local stack

  if dest_index == 9 then
    stack = self.holes[hole_index]:cut(stack_index)
  else
    stack = self.fs[dest_index]:cut(stack_index)
  end

  self.fs[f_index]:uncut(stack, has_reveal)

end


function OSolitaire:drop(orig_data, dest_data)
  local f_index, stack_index = math.floor(orig_data / 100), orig_data % 100
  local dest_index, hole_index = math.floor(dest_data / 100), (dest_data - 900) / 10

  if f_index == 9 then
    return 'no'
  elseif f_index == 8 then
    if dest_index == 9 then
      return 'no'
    end
    local stack = self.waste:pop(1)
    self.fs[dest_index]:paste(stack)
    return 'ok'
  else

    local stack, oreveal = self.fs[f_index]:cut(stack_index)

    if dest_index == 9 then
      self.holes[hole_index]:paste(stack)
    else
      self.fs[dest_index]:paste(stack)
    end

    table.insert(self.undo_stack, { orig_data, dest_data, oreveal })
    return 'ok', oreveal
  end
  return 'no'
end

function OSolitaire:write()
  return table.concat(
  table_map(self.fs, fn_write), ';') .. ';' ..
  table.concat(
  table_map(self.holes, fn_write), ';')
end

SolitaireServer = Object:extend()
function SolitaireServer:init()


  self.solitaire = OSolitaire(deck)
  print(self.solitaire:write())

  self.messages = {}
end

function SolitaireServer:get()
  self:message('load', self.solitaire:write())
end

function SolitaireServer:message(cmd, msg)
  table.insert(self.messages, cmd .. ' ' .. (msg or ''))
end

function SolitaireServer:send(msg)
  local cmd, args = msg:match("^(%a*) ?(.*)$")
    
  if cmd == 'undo' then

    local res, undo_data = self.solitaire:undo()
    self:message('undo', res, undo_data)

  elseif cmd == 'deal' then
    local owaste = self.solitaire:deal()
    if owaste == nil then
      self:message('deal', 'no')
    else
      self:message('deal', OCardStack(owaste):write())
    end
  elseif cmd == 'drop' then

    local _, _, orig_data, dest_data = args:find("(%d*) (%d*)")
    
    local res, oreveal = self.solitaire:drop(orig_data, dest_data)

    self:message('drop', res .. (oreveal and ';' .. oreveal:write() or ''))
  end
end

function SolitaireServer:receive()
  return table.remove(self.messages)
end



