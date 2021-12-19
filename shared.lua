function shared_init()

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
   g86 = anim8.newGrid(8, 6, 512, 512, 0, 16)
   g66 = anim8.newGrid(6, 6, 512, 512, 0, 32)
   g34 = anim8.newGrid(30, 40, 512, 512, 0, 48)

   g12 = anim8.newGrid(12, 12, 512, 512, 112, 0)
   font = Font('PICO-8', 5)
end

