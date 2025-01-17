# This example creates an SDL window and renderer, and then draws some
# rectangles to it every frame.
#
# This code is public domain. Feel free to use it for any purpose!

import ../../../src/sdl3

# We will use this renderer to draw into this window every frame.
var
  window: SDL_Window
  renderer: SDL_Renderer
  quit: bool

const WINDOW_WIDTH = 640
const WINDOW_HEIGHT = 480

discard SDL_SetAppMetadata("Example Renderer Rectangles", "1.0", "com.example.renderer-rectangles")

if not SDL_Init(SDL_INIT_VIDEO):
    echo "Couldn't initialize SDL: ", SDL_GetError()
    quit(QuitFailure)

if not SDL_CreateWindowAndRenderer("examples/renderer/rectangles", WINDOW_WIDTH, WINDOW_HEIGHT, 0, window, renderer):
    echo "Couldn't create window/renderer: ", SDL_GetError()
    quit(QuitFailure)


# Main loop.
while not quit:
  var event: SDL_Event
  while SDL_PollEvent(event):
    if event.type == SDL_EVENT_QUIT:
      quit = true

  let now = SDL_GetTicks()
  var rects: array[16, SDL_FRect]

  # we'll have the rectangles grow and shrink over a few seconds.
  let direction = if (now mod 2000) >= 1000:  1.0  else:  -1.0
  let scale = ((now.int64 mod 1000) - 500).float / 500 * direction

  # as you can see from this, rendering draws over whatever was drawn before it.
  SDL_SetRenderDrawColor(renderer, 0, 0, 0, SDL_ALPHA_OPAQUE)  # black, full alpha
  SDL_RenderClear(renderer)  # start with a blank canvas.

  # Rectangles are comprised of set of X and Y coordinates, plus width and
  # height. (0, 0) is the top left of the window, and larger numbers go
  # down and to the right. This isn't how geometry works, but this is
  # pretty standard in 2D graphics.

  # Let's draw a single rectangle (square, really).
  rects[0].x = 100
  rects[0].y = 100
  rects[0].w = 100 + 100*scale
  rects[0].h = 100 + 100*scale
  SDL_SetRenderDrawColor(renderer, 255, 0, 0, SDL_ALPHA_OPAQUE)  # red, full alpha
  SDL_RenderRect(renderer, rects[0])

  # Now let's draw several rectangles with one function call.
  for i in 0..<3:
    let size = (i+1).float * 50
    rects[i].w = size + size*scale
    rects[i].h = size + size*scale
    rects[i].x = (WINDOW_WIDTH - rects[i].w) / 2  # center it.
    rects[i].y = (WINDOW_HEIGHT - rects[i].h) / 2  # center it.

  SDL_SetRenderDrawColor(renderer, 0, 255, 0, SDL_ALPHA_OPAQUE)  # green, full alpha
  SDL_RenderRects(renderer, rects[0].addr, 3)  # draw three rectangles at once

  # those were rectangle _outlines_, really. You can also draw _filled_ rectangles!
  rects[0].x = 400
  rects[0].y = 50
  rects[0].w = 100 + (100 * scale)
  rects[0].h = 50 + (50 * scale)
  SDL_SetRenderDrawColor(renderer, 0, 0, 255, SDL_ALPHA_OPAQUE)  # blue, full alpha
  SDL_RenderFillRect(renderer, rects[0])

  # ...and also fill a bunch of rectangles at once...
  for i in 0..<rects.len:
    let w = (WINDOW_WIDTH / rects.len).float
    let h = i.float * 8
    rects[i].x = i.float * w
    rects[i].y = WINDOW_HEIGHT - h
    rects[i].w = w
    rects[i].h = h

  SDL_SetRenderDrawColor(renderer, 255, 255, 255, SDL_ALPHA_OPAQUE)  # white, full alpha
  SDL_RenderFillRects(renderer, rects)

  SDL_RenderPresent(renderer)  # put it all on the screen!


SDL_Quit()
