# This example code creates an SDL window and renderer, and then clears the
# window to a different color every frame, so you'll effectively get a window
# that's smoothly fading between colors.
#
# This code is public domain. Feel free to use it for any purpose!

import ../../../src/sdl3

# We will use this renderer to draw into this window every frame.
var
  window: SDL_Window
  renderer: SDL_Renderer
  quit: bool

discard SDL_SetAppMetadata("Example Renderer Clear", "1.0", "com.example.renderer-clear")

if not SDL_Init(SDL_INIT_VIDEO):
  echo "Couldn't initialize SDL: ", SDL_GetError()
  quit(QuitFailure)

if not SDL_CreateWindowAndRenderer("examples/renderer/clear", 640, 480, 0, window, renderer):
  echo "Couldn't create window/renderer: ", SDL_GetError()
  quit(QuitFailure)

# Main loop.
while not quit:
  var event: SDL_Event
  while SDL_PollEvent(event):
    if event.type == SDL_EVENT_QUIT:
      quit = true

  # Choose the color for the frame we will draw. The sine wave trick makes it fade between colors smoothly.
  let
    now = SDL_GetTicks().float / 1000  # Convert from milliseconds to seconds.
    red: float = 0.5 + 0.5*SDL_sin(now)
    green: float = 0.5 + 0.5*SDL_sin(now + SDL_PI_D * 2/3)
    blue: float = 0.5 + 0.5*SDL_sin(now + SDL_PI_D * 4/3)
  SDL_SetRenderDrawColorFloat(renderer, red, green, blue, SDL_ALPHA_OPAQUE_FLOAT)  # New color, full alpha.
  # Clear the window to the draw color.
  SDL_RenderClear(renderer)
  # Put the newly-cleared rendering on the screen.
  SDL_RenderPresent(renderer)

SDL_Quit()