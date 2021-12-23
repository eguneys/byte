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

function OCardStack:pop(n)
  local res = {}
  for i=1,n do
    table.insert(res, table.remove(self.cards))
  end
  return res
end

function OCardStack:is_empty()
  return #self.cards == 0
end

function OCardStack:push(card)
  table.insert(self.cards, card)
end

function OCardStack:cut(index)
  local res = table_slice(self.cards, index, #self.cards)
  self.cards = table_slice(self.cards, 1, index - 1)
  return res
end

function OCardStack:paste(cards)
  for _, card in ipairs(cards) do
    table.insert(self.cards, card)
  end
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
  self.upturned:paste(stack)
end

function OFoundation:write()
  return #self.downturned.cards .. " " .. self.upturned:write()
end


OSolitaire = Object:extend()
function OSolitaire:init()

  local dstack = OCardStack(deck)

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
end

function OSolitaire:deal()
  if not self.stock:is_empty() then
    local res = self.stock:pop(3)
    self.waste:paste(res)
    return res
  end
end


function OSolitaire:drop(orig_data, dest_data)
  local f_index, stack_index = math.floor(orig_data / 100), orig_data % 100
  local dest_index, hole_index = math.floor(dest_data / 100), (dest_data - 900) / 10

  if f_index == 8 then
    if dest_index == 9 then
      return 'no'
    end
    local stack = self.waste:pop(1)
    self.fs[dest_index]:paste(stack)
    return 'ok'
  else

    local stack, oreveal = self.fs[f_index]:cut(stack_index)

    if dest_index == 9 then
      --self.holes[hole_index]:paste(stack)
      return 'ok', oreveal
    end
    self.fs[dest_index]:paste(stack)
    return 'ok', oreveal
  end
  return 'no'
end

function OSolitaire:write()
  return table.concat(
  table_map(self.fs, fn_write), ';')
end

SolitaireServer = Object:extend()
function SolitaireServer:init()


  self.solitaire = OSolitaire()
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

  if cmd == 'deal' then
    local owaste = self.solitaire:deal()
    if owaste == nil then
      self:message('deal', 'no')
    else
      self:message('deal', OCardStack(owaste):write())
    end
  elseif cmd == 'drop' then

    local _, _, orig_data, dest_data = args:find("(%d*) (%d*)")

    local res, oreveal = self.solitaire:drop(orig_data, dest_data)

    if res == 'no' then
      self:message('drop', 'no')
    elseif res == 'ok' then
      self:message('drop', 'ok' .. (oreveal and ';' .. oreveal:write() or ''))
    end
  end
end

function SolitaireServer:receive()
  return table.remove(self.messages)
end



