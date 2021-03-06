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
   g82 = anim8.newGrid(8,16,512, 512)
   g8 = anim8.newGrid(8, 8, 512, 512)
   g16 = anim8.newGrid(16, 16, 512, 512)
   g32 = anim8.newGrid(32, 32, 512, 512)

   background = Image('background')

   font = Font('PICO-8', 5)

end

