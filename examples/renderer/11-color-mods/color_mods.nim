# This example creates an SDL window and renderer, and then draws some
# textures to it every frame, adjusting their color.
#
# This code is public domain. Feel free to use it for any purpose!

import std/os
import ../../../src/sdl3

# We will use this renderer to draw into this window every frame.
var
  window: SDL_Window
  renderer: SDL_Renderer
  texture: SDL_Texture
  textureWidth: int
  textureHeight: int
  quit: bool

const WINDOW_WIDTH = 640
const WINDOW_HEIGHT = 480

discard SDL_SetAppMetadata("Example Renderer Color Mods", "1.0", "com.example.renderer-color-mods")

if not SDL_Init(SDL_INIT_VIDEO):
  echo "Couldn't initialize SDL: ", SDL_GetError()
  quit(QuitFailure)

if not SDL_CreateWindowAndRenderer("examples/renderer/color-mods", WINDOW_WIDTH, WINDOW_HEIGHT, 0, window, renderer):
  echo "Couldn't create window/renderer: ", SDL_GetError()
  quit(QuitFailure)

block:
  # Textures are pixel data that we upload to the video hardware for fast drawing. Lots of 2D
  # engines refer to these as "sprites." We'll do a static texture (upload once, draw many
  # times) with data from a bitmap file.

  # SDL_Surface is pixel data the CPU can access. SDL_Texture is pixel data the GPU can access.
  # Load a .bmp into a surface, move it to a texture from there.
  let
    path = os.getCurrentDir() & "/test/sample.bmp"
    surface = SDL_LoadBMP(cstring path)
  if surface == nil:
    echo "Couldn't load bitmap: ", SDL_GetError()
    quit(QuitFailure)

  textureWidth = surface.w
  textureHeight = surface.h

  texture = SDL_CreateTextureFromSurface(renderer, surface)
  if texture == nil:
    echo "Couldn't create static texture: ", SDL_GetError()
    quit(QuitFailure)

  SDL_DestroySurface(surface)  # done with this, the texture has a copy of the pixels now.


# Main loop.
while not quit:
  var event: SDL_Event
  while SDL_PollEvent(event):
    if event.type == SDL_EVENT_QUIT:
      quit = true

  # choose the modulation values for the center texture. The sine wave trick makes it fade between colors smoothly.
  let
    now   = SDL_GetTicks().float / 1000  # convert from milliseconds to seconds.
    red   = 0.5 + 0.5 * SDL_sin(now)
    green = 0.5 + 0.5 * SDL_sin(now + SDL_PI_D * 2/3)
    blue  = 0.5 + 0.5 * SDL_sin(now + SDL_PI_D * 4/3)

  # as you can see from this, rendering draws over whatever was drawn before it.
  SDL_SetRenderDrawColor(renderer, 0, 0, 0, SDL_ALPHA_OPAQUE)  # black, full alpha
  SDL_RenderClear(renderer)  # start with a blank canvas.

  # Just draw the static texture a few times. You can think of it like a
  # stamp, there isn't a limit to the number of times you can draw with it.

  # Color modulation multiplies each pixel's red, green, and blue intensities by the mod values,
  # so multiplying by 1.0 will leave a color intensity alone, 0.0 will shut off that color
  # completely, etc.

  var dstRect: SDL_FRect

  # top left. let's make this one blue!
  dstRect.x = 0.0
  dstRect.y = 0.0
  dstRect.w = textureWidth.float
  dstRect.h = textureHeight.float
  SDL_SetTextureColorModFloat(texture, 0, 0, 1)  # kill all red and green.
  SDL_RenderTexture(renderer, texture, nil, addr dstRect)

  # center this one, and have it cycle through red/green/blue modulations.
  dstRect.x = (WINDOW_WIDTH - textureWidth).float / 2
  dstRect.y = (WINDOW_HEIGHT - textureHeight).float / 2
  dstRect.w = textureWidth.float
  dstRect.h = textureHeight.float
  SDL_SetTextureColorModFloat(texture, red, green, blue)
  SDL_RenderTexture(renderer, texture, nil, addr dstRect)

  # bottom right let's make this one red!
  dstRect.x = (WINDOW_WIDTH - textureWidth).float
  dstRect.y = (WINDOW_HEIGHT - textureHeight).float
  dstRect.w = textureWidth.float
  dstRect.h = textureHeight.float
  SDL_SetTextureColorModFloat(texture, 1, 0, 0)  # kill all green and blue.
  SDL_RenderTexture(renderer, texture, nil, addr dstRect)

  SDL_RenderPresent(renderer)  # put it all on the screen!


SDL_DestroyTexture(texture)
SDL_Quit()
