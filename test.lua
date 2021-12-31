require('engine/object')
require('server')

function fn_double(x) return x * x end

function test_solitaire()

  print('[solitaire] drop')

  solitaire = OSolitaire(deck)
  print(solitaire:write())

  solitaire:drop(701, 200)
  print(solitaire:write(), 'drop 701, 200')

  solitaire:drop(701, 200)
  solitaire:drop(701, 200)
  solitaire:drop(701, 200)
  print(solitaire:write(), 'initial')
  solitaire:drop(202, 100)
  print(solitaire:write(), 'drop 202, 100')


  print('[solitaire] undo')

  solitaire = OSolitaire(deck)
  solitaire:drop(701, 200)
  solitaire:drop(701, 200)
  solitaire:drop(701, 200)
  solitaire:drop(701, 200)


  print(solitaire:write())
  solitaire:drop(202, 100)
  print(solitaire:write(), 'drop 202, 100')
  solitaire:_undrop(202, 100)
  print(solitaire:write(), '_undrop')


end

function waste_undo()

  -- deal deal pop deal undeal
  dstack = OCardStack(deck)
  waste = OWaste({}, {})

  waste:deal_stack(dstack:pop(3))
  waste:deal_stack(dstack:pop(3))
  print(waste:write(), 'deal deal')
  waste:pop()
  print(waste:write(), 'pop')
  waste:deal_stack(dstack:pop(3))
  print(waste:write(), 'deal')
  waste:undeal_stack()
  print(waste:write(), 'undeal')

end

function waste_basic()

  dstack = OCardStack(deck)
  waste = OWaste({}, {})

  waste:deal_stack(dstack:pop(3))
  print(waste:write())
  waste:deal_stack(dstack:pop(3))
  print(waste:write())

  local stack = waste:pop()

  print(waste:write(), ' popped ', OCardStack(stack):write(), 'pop')

  stack = waste:pop()
  print(waste:write(), ' popped ', OCardStack(stack):write(), 'pop')

  stack = waste:pop()
  print(waste:write(), ' popped ', OCardStack(stack):write(), 'pop')

  stack = waste:pop()
  print(waste:write(), ' popped ', OCardStack(stack):write(), 'pop')


  waste:unpop(dstack:pop(1))
  print(waste:write(), 'unpop')

  waste:unpop(dstack:pop(1))
  print(waste:write(), 'unpop')

  waste:unpop(dstack:pop(1))
  print(waste:write(), 'unpop')


  stack = waste:undeal_stack()
  print(waste:write(), ' stack ',  OCardStack(stack):write(), 'undeal')

end

function undo_basic()

  print('[undo basic]')
  dstack = OCardStack(deck)

  dfoun = OFoundation(dstack:pop(1), dstack:pop(2))
  print(dfoun:write())

  local stack, reveal = dfoun:cut(2)
  print(OCardStack(stack):write(), reveal:write(), dfoun:write(), 'cut')
  dfoun:uncut(stack, reveal ~= nil)
  print(dfoun:write(), 'uncut')

end

function basic()

  dstack = OCardStack(deck)

  print(OCardStack(dstack:pop(10)):write())
  print(dstack:write())


  tenones = OCardStack(deck)
  tenones:pop(42)

  print(tenones:write())

  tenones:cut(4)
  print(tenones:write())
end

function foundation()

  dstack = OCardStack(deck)
  dfoun = OFoundation(dstack:pop(13), dstack:pop(13))
  print(dfoun:write())
  dfoun:cut(1)
  print(dfoun:write(), 'cut 1')


  dfoun = OFoundation(dstack:pop(1), dstack:pop(2))
  print(dfoun:write())
  local stack, reveal = dfoun:cut(2)
  print(OCardStack(stack):write(), reveal:write(), dfoun:write(), 'cut reveal')
   

  print('[foundation] reveal on empty downturned')
  dfoun = OFoundation(dstack:pop(0), dstack:pop(2))
  print(dfoun:write())

  local stack, reveal = dfoun:cut(2)
  print(OCardStack(stack):write(), reveal, dfoun:write(), 'cut')

end

function test_table()


  a = { 1, 2, 3, 4, 5, 6 }

  print(table_write(a))
  print(table_write(table_slice(a, 2, 4)))
  print(table_write(table_map(a, fn_double)))


  local stack = table_splice(a, 2, 4)
  table_reverse(stack)
  print(table_write(a), table_write(stack), 'splice 2 4')


  print(table_write(table_append(a, stack)), 'append')

end

--test_solitaire()
--waste_basic()
waste_undo()
