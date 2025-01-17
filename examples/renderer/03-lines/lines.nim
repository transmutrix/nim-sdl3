# This example creates an SDL window and renderer, and then draws some lines
# to it every frame.
#
# This code is public domain. Feel free to use it for any purpose!

import ../../../src/sdl3

# We will use this renderer to draw into this window every frame.
var
  window: SDL_Window
  renderer: SDL_Renderer
  quit: bool

discard SDL_SetAppMetadata("Example Renderer Lines", "1.0", "com.example.renderer-lines")

if not SDL_Init(SDL_INIT_VIDEO):
  echo "Couldn't initialize SDL: ", SDL_GetError()
  quit(QuitFailure)

if not SDL_CreateWindowAndRenderer("examples/renderer/lines", 640, 480, 0, window, renderer):
  echo "Couldn't create window/renderer: ", SDL_GetError()
  quit(QuitFailure)


# Main loop.
while not quit:
  var event: SDL_Event
  while SDL_PollEvent(event):
    if event.type == SDL_EVENT_QUIT:
      quit = true

  # Lines (line segments, really) are drawn in terms of points: a set of
  # X and Y coordinates, one set for each end of the line.
  # (0, 0) is the top left of the window, and larger numbers go down
  # and to the right. This isn't how geometry works, but this is pretty
  # standard in 2D graphics.
  const linePoints = [
    SDL_FPoint(x: 100, y: 354), SDL_FPoint(x: 220, y: 230),
    SDL_FPoint(x: 140, y: 230), SDL_FPoint(x: 320, y: 100),
    SDL_FPoint(x: 500, y: 230), SDL_FPoint(x: 420, y: 230),
    SDL_FPoint(x: 540, y: 354), SDL_FPoint(x: 400, y: 354),
    SDL_FPoint(x: 100, y: 354)
  ]

  # as you can see from this, rendering draws over whatever was drawn before it.
  SDL_SetRenderDrawColor(renderer, 100, 100, 100, SDL_ALPHA_OPAQUE)  # grey, full alpha
  SDL_RenderClear(renderer)  # start with a blank canvas.

  # You can draw lines, one at a time, like these brown ones...
  SDL_SetRenderDrawColor(renderer, 127, 49, 32, SDL_ALPHA_OPAQUE)
  SDL_RenderLine(renderer, 240, 450, 400, 450)
  SDL_RenderLine(renderer, 240, 356, 400, 356)
  SDL_RenderLine(renderer, 240, 356, 240, 450)
  SDL_RenderLine(renderer, 400, 356, 400, 450)

  # You can also draw a series of connected lines in a single batch...
  SDL_SetRenderDrawColor(renderer, 0, 255, 0, SDL_ALPHA_OPAQUE)
  SDL_RenderLines(renderer, linePoints)

  # here's a bunch of lines drawn out from a center point in a circle.
  # we randomize the color of each line, so it functions as animation.
  for i in 0..<360:
    let
      size = 30.0
      x = 320.0
      y = 95.0 - size/2
    SDL_SetRenderDrawColor(renderer, SDL_rand(256).uint8, SDL_rand(256).uint8, SDL_rand(256).uint8, SDL_ALPHA_OPAQUE)
    SDL_RenderLine(renderer, x, y, x + SDL_sinf((float) i) * size, y + SDL_cosf((float) i) * size)

  SDL_RenderPresent(renderer)  # put it all on the screen!


SDL_Quit()