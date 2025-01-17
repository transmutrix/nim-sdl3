# This example creates an SDL window and renderer, and then draws some text
# using SDL_RenderDebugText() every frame.
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

discard SDL_SetAppMetadata("Example Renderer Debug Texture", "1.0", "com.example.renderer-debug-text")

if not SDL_Init(SDL_INIT_VIDEO):
  echo "Couldn't initialize SDL: ", SDL_GetError()
  quit(QuitFailure)

if not SDL_CreateWindowAndRenderer("examples/renderer/debug-text", WINDOW_WIDTH, WINDOW_HEIGHT, 0, window, renderer):
  echo "Couldn't create window/renderer: ", SDL_GetError()
  quit(QuitFailure)


# Main loop.
while not quit:
  var event: SDL_Event
  while SDL_PollEvent(event):
    if event.type == SDL_EVENT_QUIT:
      quit = true

  const charsize = SDL_DEBUG_TEXT_FONT_CHARACTER_SIZE

  # as you can see from this, rendering draws over whatever was drawn before it.
  SDL_SetRenderDrawColor(renderer, 0, 0, 0, SDL_ALPHA_OPAQUE)  # black, full alpha
  SDL_RenderClear(renderer)  # start with a blank canvas.

  SDL_SetRenderDrawColor(renderer, 255, 255, 255, SDL_ALPHA_OPAQUE)  # white, full alpha
  SDL_RenderDebugText(renderer, 272, 100, "Hello world!")
  SDL_RenderDebugText(renderer, 224, 150, "This is some debug text.")

  SDL_SetRenderDrawColor(renderer, 51, 102, 255, SDL_ALPHA_OPAQUE)  # light blue, full alpha
  SDL_RenderDebugText(renderer, 184, 200, "You can do it in different colors.")
  SDL_SetRenderDrawColor(renderer, 255, 255, 255, SDL_ALPHA_OPAQUE)  # white, full alpha

  SDL_SetRenderScale(renderer, 4, 4)
  SDL_RenderDebugText(renderer, 14, 65, "It can be scaled.")
  SDL_SetRenderScale(renderer, 1, 1)
  SDL_RenderDebugText(renderer, 64, 350, "This only does ASCII chars. So this laughing emoji won't draw: 🤣")

  SDL_RenderDebugText(
    renderer,
    (WINDOW_WIDTH - (charsize * 46)).float / 2,
    400,
    cstring "(This program has been running for " & $(SDL_GetTicks() div 1000) & " seconds.)"
  )

  SDL_RenderPresent(renderer)  # put it all on the screen!


SDL_Quit()
