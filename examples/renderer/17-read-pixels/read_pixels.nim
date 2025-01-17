# This example creates an SDL window and renderer, and draws a
# rotating texture to it, reads back the rendered pixels, converts them to
# black and white, and then draws the converted image to a corner of the
# screen.
#
# This isn't necessarily an efficient thing to do--in real life one might
# want to do this sort of thing with a render target--but it's just a visual
# example of how to use SDL_RenderReadPixels().
#
# This code is public domain. Feel free to use it for any purpose!

import std/os
import ../../../src/sdl3

# NOTE: Nim doesn't have pointer arithmetic in the way that C does.
# However, Nim allows us to implement pointer arithmetic ourselves, should we
# need it! Note that we're specifically handling UncheckedArray types here. If
# we only did `ptr T`, sizeof would get the size of the UncheckedArray pointed
# to, which is not what we want for this example!
proc `+`[T](p: ptr UncheckedArray[T], i: uint): ptr UncheckedArray[T] =
  cast[ptr UncheckedArray[T]](cast[uint](p) + i * (sizeof T).uint)

# We will use this renderer to draw into this window every frame.
var
  window: SDL_Window
  renderer: SDL_Renderer
  texture: SDL_Texture
  textureWidth: int
  textureHeight: int
  convertedTexture: SDL_Texture
  convertedTextureWidth: int
  convertedTextureHeight: int
  quit: bool

const WINDOW_WIDTH = 640
const WINDOW_HEIGHT = 480

discard SDL_SetAppMetadata("Example Renderer Read Pixels", "1.0", "com.example.renderer-read-pixels")

if not SDL_Init(SDL_INIT_VIDEO):
  echo "Couldn't initialize SDL: ", SDL_GetError()
  quit(QuitFailure)

if not SDL_CreateWindowAndRenderer("examples/renderer/read-pixels", WINDOW_WIDTH, WINDOW_HEIGHT, 0, window, renderer):
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

  let now = SDL_GetTicks();
  var
    surface: ptr SDL_Surface
    center: SDL_FPoint
    dstRect: SDL_FRect

  # we'll have a texture rotate around over 2 seconds (2000 milliseconds). 360 degrees in a circle!
  let rotation = (now.int64 mod 2000).float / 2000 * 360

  # as you can see from this, rendering draws over whatever was drawn before it.
  SDL_SetRenderDrawColor(renderer, 0, 0, 0, SDL_ALPHA_OPAQUE); # black, full alpha
  SDL_RenderClear(renderer); # start with a blank canvas.

  # Center this one, and draw it with some rotation so it spins!
  dstRect.x = (WINDOW_WIDTH - textureWidth).float / 2
  dstRect.y = (WINDOW_HEIGHT - textureHeight).float / 2
  dstRect.w = textureWidth.float
  dstRect.h = textureHeight.float
  # rotate it around the center of the texture; you can rotate it from a different point, too!
  center.x = textureWidth / 2
  center.y = textureHeight / 2
  SDL_RenderTextureRotated(renderer, texture, nil, addr dstRect, rotation, addr center, SDL_FLIP_NONE)

  # this next whole thing is _super_ expensive. Seriously, don't do this in real life.

  # Download the pixels of what has just been rendered. This has to wait for the GPU to finish rendering it and everything before it,
  # and then make an expensive copy from the GPU to system RAM!
  surface = SDL_RenderReadPixels(renderer, nil)

  # This is also expensive, but easier: convert the pixels to a format we want.
  if (surface != nil and
    (surface.format != SDL_PIXELFORMAT_RGBA8888) and
    (surface.format != SDL_PIXELFORMAT_BGRA8888)
  ):
    let converted = SDL_ConvertSurface(surface, SDL_PIXELFORMAT_RGBA8888)
    SDL_DestroySurface(surface)
    surface = converted

  if surface != nil:
    # Rebuild convertedTexture if the dimensions have changed (window resized, etc).
    if surface.w != convertedTextureWidth or surface.h != convertedTextureHeight:
      SDL_DestroyTexture(convertedTexture)
      convertedTexture = SDL_CreateTexture(
        renderer,
        SDL_PIXELFORMAT_RGBA8888,
        SDL_TEXTUREACCESS_STREAMING,
        surface.w,
        surface.h
      )
      if convertedTexture == nil:
        echo "Couldn't (re)create conversion texture: ", SDL_GetError()
        quit(QuitFailure)
      convertedTextureWidth = surface.w
      convertedTextureHeight = surface.h

    # Turn each pixel into either black or white. This is a lousy technique but it works here.
    # In real life, something like Floyd-Steinberg dithering might work
    # better: https://en.wikipedia.org/wiki/Floyd%E2%80%93Steinberg_dithering*/
    for y in 0..<surface.h:
      var pixels: ptr UncheckedArray[uint8] = surface.pixels + (y*surface.pitch).uint
      for x in 0..<surface.w.uint:
        var p: ptr UncheckedArray[uint8] = pixels + x*4
        let average = (p[1].uint32 + p[2].uint32 + p[3].uint32) div 3
        if average == 0:
          # make pure black pixels red.
          p[0] = 0xFF
          p[1] = 0
          p[2] = 0
          p[3] = 0xFF
        else:
          # make everything else either black or white.
          let v: uint8 = if average > 50: 0xFF else: 0x00
          p[1] = v
          p[2] = v
          p[3] = v

    # upload the processed pixels back into a texture.
    if not SDL_UpdateTexture(convertedTexture, nil, surface.pixels, surface.pitch):
      echo "Failed to update texture: ", SDL_GetError()
    SDL_DestroySurface(surface)

    # draw the texture to the top-left of the screen.
    dstRect.x = 0
    dstRect.y = 0
    dstRect.w = WINDOW_WIDTH / 4
    dstRect.h = WINDOW_HEIGHT / 4
    SDL_RenderTexture(renderer, convertedTexture, nil, addr dstRect)

  SDL_RenderPresent(renderer) # put it all on the screen!


SDL_DestroyTexture(convertedTexture)
SDL_DestroyTexture(texture)
SDL_Quit()
