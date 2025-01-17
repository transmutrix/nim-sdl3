# This example creates an SDL window and renderer, and then draws some
# textures to it every frame, adjusting the viewport.
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

discard SDL_SetAppMetadata("Example Renderer Viewport", "1.0", "com.example.renderer-viewport")

if not SDL_Init(SDL_INIT_VIDEO):
  echo "Couldn't initialize SDL: ", SDL_GetError()
  quit(QuitFailure)

if not SDL_CreateWindowAndRenderer("examples/renderer/viewport", WINDOW_WIDTH, WINDOW_HEIGHT, 0, window, renderer):
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

  var
    dstRect = SDL_FRect( x: 0, y: 0, w: textureWidth.float, h: textureHeight.float )
    viewport: SDL_Rect
    outline: SDL_FRect

  # Setting a viewport has the effect of limiting the area that rendering
  # can happen, and making coordinate (0, 0) live somewhere else in the
  # window. It does _not_ scale rendering to fit the viewport.

  # as you can see from this, rendering draws over whatever was drawn before it.
  SDL_SetRenderDrawColor(renderer, 0, 0, 0, SDL_ALPHA_OPAQUE)  # black, full alpha
  SDL_RenderClear(renderer)  # start with a blank canvas.

  SDL_SetRenderDrawColor(renderer, 255, 0, 255, SDL_ALPHA_OPAQUE) # magenta, to outline the viewports

  # Draw once with the whole window as the viewport.
  SDL_SetRenderViewport(renderer, nil)  # nil means "use the whole window"
  SDL_RenderTexture(renderer, texture, nil, addr dstRect)

  # top right quarter of the window.
  viewport.x = WINDOW_WIDTH div 2
  viewport.y = WINDOW_HEIGHT div 2
  viewport.w = WINDOW_WIDTH div 2
  viewport.h = WINDOW_HEIGHT div 2
  SDL_SetRenderViewport(renderer, addr viewport)
  SDL_RenderTexture(renderer, texture, nil, addr dstRect)

  # draw an outline of the viewport.
  SDL_SetRenderViewport(renderer, nil)
  SDL_RectToFRect(addr viewport, addr outline)
  SDL_RenderRect(renderer, outline)


  # bottom 20% of the window. Note it clips the width!
  viewport.x = 0
  viewport.y = WINDOW_HEIGHT - (WINDOW_HEIGHT div 5)
  viewport.w = WINDOW_WIDTH div 5
  viewport.h = WINDOW_HEIGHT div 5
  SDL_SetRenderViewport(renderer, addr viewport)
  SDL_RenderTexture(renderer, texture, nil, addr dstRect)

  # draw an outline of the viewport.
  SDL_SetRenderViewport(renderer, nil)
  SDL_RectToFRect(addr viewport, addr outline)
  SDL_RenderRect(renderer, outline)


  # what happens if you try to draw above the viewport? It should clip!
  viewport.x = 100
  viewport.y = 200
  viewport.w = WINDOW_WIDTH
  viewport.h = WINDOW_HEIGHT
  SDL_SetRenderViewport(renderer, addr viewport)
  dstRect.y = -50
  SDL_RenderTexture(renderer, texture, nil, addr dstRect)

  # draw an outline of the viewport.
  SDL_SetRenderViewport(renderer, nil)
  SDL_RectToFRect(addr viewport, addr outline)
  SDL_RenderRect(renderer, outline)

  SDL_RenderPresent(renderer)  # put it all on the screen!


SDL_DestroyTexture(texture)
SDL_Quit()
