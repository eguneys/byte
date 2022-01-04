function shared_init()

  PI = 3.14
  TAU = 2 * PI
  rate = 1/60
  ticks = {
    second= rate * 60,
    half= rate * 30,
    third= rate * 20,
    sixth= rate * 10,
    lengths= rate * 5,
    three= rate * 3,
    one= rate * 1
  }


   colors = {
      white=Color('#ffffff'),
      black=Color('#000000'),
      dark = Color('#1d2b53'),
      gray=Color('#5f574f'),
      light = Color('#fff1e8'),
      red = Color('#ff004d'),
      dark_red = Color('#7e2553'),
      violet=Color('#83769c'),
      blue=Color('#29adff')
   }


   sprites = love.graphics.newImage('assets/sprites.png')
   sprites2 = love.graphics.newImage('assets/sprites2.png')
   g86 = anim8.newGrid(8, 6, 512, 512, 0, 16)
   g66 = anim8.newGrid(6, 6, 512, 512, 0, 32)
   g34 = anim8.newGrid(30, 40, 512, 512, 0, 48)

   g128 = anim8.newGrid(12, 8, 512, 512, 144, 0)
   g1212 = anim8.newGrid(12, 12, 512, 512, 176, 0)


   g177 = anim8.newGrid(17, 7, 512, 512, 112, 16)
   g267 = anim8.newGrid(26, 7, 512, 512, 112, 25)

   g5 = anim8.newGrid(5, 5, 512, 512, 272, 16)


   gbg = anim8.newGrid(320, 180, 1024, 1024)
   font = Font('PICO-8', 5)


   noisetex = love.image.newImageData(320, 180)
   noisetex = love.graphics.newImage(noisetex)
   noisetex:setWrap("repeat", "repeat")
   noisetex:setFilter("nearest", "nearest")

   bg_shader = Shader(nil, 'bg.frag')
   --bg_shader:send("noisetex",sprites2)
end

