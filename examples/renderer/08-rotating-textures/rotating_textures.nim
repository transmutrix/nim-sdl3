# This example creates an SDL window and renderer, and then draws some
# rotated textures to it every frame.
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

discard SDL_SetAppMetadata("Example Renderer Rotating Textures", "1.0", "com.example.renderer-rotating-textures")

if not SDL_Init(SDL_INIT_VIDEO):
  echo "Couldn't initialize SDL: ", SDL_GetError()
  quit(QuitFailure)

if not SDL_CreateWindowAndRenderer("examples/renderer/rotating-textures", WINDOW_WIDTH, WINDOW_HEIGHT, 0, window, renderer):
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

  let now = SDL_GetTicks()

  # we'll have a texture rotate around over 2 seconds (2000 milliseconds). 360 degrees in a circle!
  let rotation = (now.int64 mod 2000).float / 2000 * 360

  # as you can see from this, rendering draws over whatever was drawn before it.
  SDL_SetRenderDrawColor(renderer, 0, 0, 0, SDL_ALPHA_OPAQUE)  # black, full alpha
  SDL_RenderClear(renderer)  # start with a blank canvas.

  # Center this one, and draw it with some rotation so it spins!
  let dstRect = SDL_FRect(
    x: (WINDOW_WIDTH - textureWidth).float / 2,
    y: (WINDOW_HEIGHT - textureHeight).float / 2,
    w: textureWidth.float,
    h: textureHeight.float,
  )
  # rotate it around the center of the texture--you can rotate it from a different point, too!
  let center = SDL_FPoint(
    x: textureWidth / 2,
    y: textureHeight / 2,
  )
  SDL_RenderTextureRotated(renderer, texture, nil, dstRect.addr, rotation, center.addr, SDL_FLIP_NONE)

  SDL_RenderPresent(renderer)  # put it all on the screen!


SDL_Quit()

