# This example creates an SDL window and renderer, and then draws some lines,
# rectangles and points to it every frame.
#
# This code is public domain. Feel free to use it for any purpose!

import ../../../src/sdl3

# We will use this renderer to draw into this window every frame.
var
  window: SDL_Window
  renderer: SDL_Renderer
  points: array[500, SDL_FPoint]
  quit: bool

discard SDL_SetAppMetadata("Example Renderer Primitives", "1.0", "com.example.renderer-primitives")

if not SDL_Init(SDL_INIT_VIDEO):
  echo "Couldn't initialize SDL: ", SDL_GetError()
  quit(QuitFailure)

if not SDL_CreateWindowAndRenderer("examples/renderer/primitives", 640, 480, 0, window, renderer):
  echo "Couldn't create window/renderer: ", SDL_GetError()
  quit(QuitFailure)

# Set up some random points.
for i in 0..<points.len:
  points[i].x = SDL_randf()*440 + 100
  points[i].y = SDL_randf()*280 + 100

# Main loop
while not quit:
  var event: SDL_Event
  while SDL_PollEvent(event):
    if event.type == SDL_EVENT_QUIT:
      quit = true

  # As you can see from this, rendering draws over whatever was drawn before it.
  SDL_SetRenderDrawColor(renderer, 33, 33, 33, SDL_ALPHA_OPAQUE)  # dark gray, full alpha
  SDL_RenderClear(renderer)  # start with a blank canvas.

  # Araw a filled rectangle in the middle of the canvas.
  SDL_SetRenderDrawColor(renderer, 0, 0, 255, SDL_ALPHA_OPAQUE)  # blue, full alpha
  var rect = SDL_FRect( x: 100, y: 100, w: 440, h: 280 )
  SDL_RenderFillRect(renderer, rect)

  # Draw some points across the canvas.
  SDL_SetRenderDrawColor(renderer, 255, 0, 0, SDL_ALPHA_OPAQUE)  # red, full alpha
  SDL_RenderPoints(renderer, points)

  # Draw a unfilled rectangle in-set a little bit.
  SDL_SetRenderDrawColor(renderer, 0, 255, 0, SDL_ALPHA_OPAQUE)  # green, full alpha
  rect.x += 30
  rect.y += 30
  rect.w -= 60
  rect.h -= 60
  SDL_RenderRect(renderer, rect)

  # Draw two lines in an X across the whole canvas.
  SDL_SetRenderDrawColor(renderer, 255, 255, 0, SDL_ALPHA_OPAQUE)  # yellow, full alpha
  SDL_RenderLine(renderer, 0, 0, 640, 480)
  SDL_RenderLine(renderer, 0, 480, 640, 0)

  SDL_RenderPresent(renderer)  # Put it all on the screen!


SDL_Quit()