# This example creates an SDL window and renderer, and then draws some
# textures to it every frame.
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

discard SDL_SetAppMetadata("Example Renderer Textures", "1.0", "com.example.renderer-textures")

if not SDL_Init(SDL_INIT_VIDEO):
  echo "Couldn't initialize SDL: ", SDL_GetError()
  quit(QuitFailure)

if not SDL_CreateWindowAndRenderer("examples/renderer/textures", WINDOW_WIDTH, WINDOW_HEIGHT, 0, window, renderer):
  echo "Couldn't create window/renderer: ", SDL_GetError()
  quit(QuitFailure)

# Textures are pixel data that we upload to the video hardware for fast drawing. Lots of 2D
# engines refer to these as "sprites." We'll do a static texture (upload once, draw many
# times) with data from a bitmap file.

# SDL_Surface is pixel data the CPU can access. SDL_Texture is pixel data the GPU can access.
# Load a .bmp into a surface, move it to a texture from there.

block:
  let path = os.getCurrentDir() & "/test/sample.bmp"
  let surface = SDL_LoadBMP(cstring path)
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

  # we'll have some textures move around over a few seconds.
  let now = SDL_GetTicks()
  let direction = if (now mod 2000) >= 1000: 1.0 else: -1.0
  let scale = ((now.int64 mod 1000) - 500).float / 500 * direction

  # as you can see from this, rendering draws over whatever was drawn before it.
  SDL_SetRenderDrawColor(renderer, 0, 0, 0, SDL_ALPHA_OPAQUE)  # black, full alpha
  SDL_RenderClear(renderer)  # start with a blank canvas.

  # Just draw the static texture a few times. You can think of it like a
  # stamp, there isn't a limit to the number of times you can draw with it.

  var dstRect: SDL_FRect

  # top left
  dstRect.x = 100 * scale
  dstRect.y = 0
  dstRect.w = textureWidth.float
  dstRect.h = textureHeight.float
  SDL_RenderTexture(renderer, texture, nil, dstRect.addr)

  # center this one.
  dstRect.x = ((float) (WINDOW_WIDTH - textureWidth)) / 2.0f
  dstRect.y = ((float) (WINDOW_HEIGHT - textureHeight)) / 2.0f
  dstRect.w = (float) textureWidth
  dstRect.h = (float) textureHeight
  SDL_RenderTexture(renderer, texture, nil, dstRect.addr)

  # bottom right.
  dstRect.x = ((float) (WINDOW_WIDTH - textureWidth)) - (100.0f * scale)
  dstRect.y = (float) (WINDOW_HEIGHT - textureHeight)
  dstRect.w = (float) textureWidth
  dstRect.h = (float) textureHeight
  SDL_RenderTexture(renderer, texture, nil, dstRect.addr)

  SDL_RenderPresent(renderer)  # put it all on the screen!


SDL_Quit()
