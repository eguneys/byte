require('engine/object')
require('server')

function fn_double(x) return x * x end

function basic()
  a = { 1, 2, 3, 4, 5, 6 }

  print(table_write(a))
  print(table_write(table_slice(a, 2, 4)))
  print(table_write(table_map(a, fn_double)))


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

  print(dfoun:write())


  dfoun = OFoundation(dstack:pop(1), dstack:pop(2))

  print(dfoun:write())

  local stack, reveal = dfoun:cut(1)
  print('cut ', OCardStack(stack):write(), reveal:write())

  print(dfoun:write())

  print('empty downturned')
  dfoun = OFoundation(dstack:pop(0), dstack:pop(2))

  print(dfoun:write())

  local stack, reveal = dfoun:cut(1)
  print('cut ', OCardStack(stack):write(), reveal)

  print(dfoun:write())


end

foundation()
