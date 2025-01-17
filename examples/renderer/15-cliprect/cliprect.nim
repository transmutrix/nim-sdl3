# This example creates an SDL window and renderer, and then draws a scene
# to it every frame, while sliding around a clipping rectangle.
#
# This code is public domain. Feel free to use it for any purpose!

import std/os
import ../../../src/sdl3

# We will use this renderer to draw into this window every frame.
var
  window: SDL_Window
  renderer: SDL_Renderer
  texture: SDL_Texture
  cliprect_position: SDL_FPoint
  cliprect_direction: SDL_FPoint
  last_time: uint64
  quit: bool

const WINDOW_WIDTH = 640
const WINDOW_HEIGHT = 480
const CLIPRECT_SIZE = 250
const CLIPRECT_SPEED = 200   # pixels per second


# A lot of this program is examples/renderer/02-primitives, so we have a good
# visual that we can slide a clip rect around. The actual new magic in here
# is the SDL_SetRenderClipRect() function.

discard SDL_SetAppMetadata("Example Renderer Clipping Rectangle", "1.0", "com.example.renderer-cliprect")

if not SDL_Init(SDL_INIT_VIDEO):
  echo "Couldn't initialize SDL: ", SDL_GetError()
  quit(QuitFailure)

if not SDL_CreateWindowAndRenderer("examples/renderer/cliprect", WINDOW_WIDTH, WINDOW_HEIGHT, 0, window, renderer):
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

  texture = SDL_CreateTextureFromSurface(renderer, surface)
  if texture == nil:
    echo "Couldn't create static texture: ", SDL_GetError()
    quit(QuitFailure)

  SDL_DestroySurface(surface)  # done with this, the texture has a copy of the pixels now.

cliprect_direction.x = 1
cliprect_direction.y = 1
last_time = SDL_GetTicks()


# Main loop.
while not quit:
  var event: SDL_Event
  while SDL_PollEvent(event):
    if event.type == SDL_EVENT_QUIT:
      quit = true

  let cliprect = SDL_Rect(
    x: cint SDL_roundf(cliprect_position.x),
    y: cint SDL_roundf(cliprect_position.y),
    w: CLIPRECT_SIZE,
    h: CLIPRECT_SIZE,
  )
  let
    now = SDL_GetTicks()
    elapsed = (now - last_time).float / 1000  # seconds since last iteration
    distance = elapsed * CLIPRECT_SPEED

  # Set a new clipping rectangle position
  cliprect_position.x += distance * cliprect_direction.x
  if cliprect_position.x < 0.0:
    cliprect_position.x = 0
    cliprect_direction.x = 1
  elif cliprect_position.x >= WINDOW_WIDTH - CLIPRECT_SIZE:
    cliprect_position.x = (WINDOW_WIDTH - CLIPRECT_SIZE) - 1
    cliprect_direction.x = -1

  cliprect_position.y += distance * cliprect_direction.y
  if cliprect_position.y < 0:
    cliprect_position.y = 0.0
    cliprect_direction.y = 1.0
  elif cliprect_position.y >= WINDOW_HEIGHT - CLIPRECT_SIZE:
    cliprect_position.y = (WINDOW_HEIGHT - CLIPRECT_SIZE) - 1
    cliprect_direction.y = -1.0
  SDL_SetRenderClipRect(renderer, addr cliprect)

  last_time = now

  # okay, now draw!

  # Note that SDL_RenderClear is _not_ affected by the clipping rectangle!
  SDL_SetRenderDrawColor(renderer, 33, 33, 33, SDL_ALPHA_OPAQUE)  # grey, full alpha
  SDL_RenderClear(renderer)  # start with a blank canvas.

  # stretch the texture across the entire window. Only the piece in the
  # clipping rectangle will actually render, though!
  SDL_RenderTexture(renderer, texture, nil, nil)

  SDL_RenderPresent(renderer)  # put it all on the screen!


SDL_DestroyTexture(texture)
SDL_Quit()
