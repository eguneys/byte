function shared_init()

   colors = {
      dark = Color('#1d2b53'),
      light = Color('#fff1e8'),
      red = Color('#ff004d')
   }


   sprites = love.graphics.newImage('assets/sprites.png')
   g8 = anim8.newGrid(8, 8, 128, 128)
   g32 = anim8.newGrid(32, 32, 128, 128)

   background = Image('background')

   font = Font('PICO-8', 5)

end

