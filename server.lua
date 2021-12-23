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
  for i=1,#src do
    if i > to then break end
    if i >= from then

      table.insert(res, src[i])
    end
  end
  return res
end

function table_write(table, sep)
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
  self.cards = cards
end

function OCardStack:pop(n)
  local res = {}
  for i=1,n do
    table.insert(res, table.remove(self.cards))
  end
  return res
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
  return self.upturned:cut(n)
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
end

function OSolitaire:drop(orig_data, dest_data)
  local f_index, stack_index = math.floor(orig_data / 100), orig_data % 100
  local dest_index = dest_data / 100

  local stack = self.fs[f_index]:cut(stack_index)

  self.fs[dest_index]:paste(stack)

  return 'drop'
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

  if cmd == 'drop' then

    local _, _, orig_data, dest_data = args:find("(%d*) (%d*)")

    local res, oreveal = self.solitaire:drop(orig_data, dest_data)

    if res == nil then
      self:message('drop', 'cancel')
    elseif res == 'drop' then
      self:message('drop', 'ok' .. (oreveal and ';' .. oreveal:write() or ''))
    end
  end
end

function SolitaireServer:receive()
  return table.remove(self.messages)
end



