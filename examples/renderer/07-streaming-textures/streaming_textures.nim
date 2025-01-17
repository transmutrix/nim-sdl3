# This example creates an SDL window and renderer, and then draws a streaming
# texture to it every frame.
#
# This code is public domain. Feel free to use it for any purpose!

import ../../../src/sdl3

# We will use this renderer to draw into this window every frame.
var
  window: SDL_Window
  renderer: SDL_Renderer
  texture: SDL_Texture
  quit: bool


const TEXTURE_SIZE = 150

const WINDOW_WIDTH = 640
const WINDOW_HEIGHT = 480


discard SDL_SetAppMetadata("Example Renderer Streaming Textures", "1.0", "com.example.renderer-streaming-textures")

if not SDL_Init(SDL_INIT_VIDEO):
  echo "Couldn't initialize SDL: ", SDL_GetError()
  quit(QuitFailure)

if not SDL_CreateWindowAndRenderer("examples/renderer/streaming-textures", WINDOW_WIDTH, WINDOW_HEIGHT, 0, window, renderer):
  echo "Couldn't create window/renderer: ", SDL_GetError()
  quit(QuitFailure)

texture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_STREAMING, TEXTURE_SIZE, TEXTURE_SIZE)
if texture == nil:
  echo "Couldn't create streaming texture: ", SDL_GetError()
  quit(QuitFailure)


# Main loop.
while not quit:
  var event: SDL_Event
  while SDL_PollEvent(event):
    if event.type == SDL_EVENT_QUIT:
      quit = true

  # we'll have some color move around over a few seconds.
  let now = SDL_GetTicks()
  let direction = if now mod 2000 >= 1000: 1.0 else: -1.0
  let scale = (now.int64 mod 1000 - 500) / 500 * direction

  # To update a streaming texture, you need to lock it first. This gets you access to the pixels.
  # Note that this is considered a _write-only_ operation: the buffer you get from locking
  # might not acutally have the existing contents of the texture, and you have to write to every
  # locked pixel!

  # You can use SDL_LockTexture() to get an array of raw pixels, but we're going to use
  # SDL_LockTextureToSurface() here, because it wraps that array in a temporary SDL_Surface,
  # letting us use the surface drawing functions instead of lighting up individual pixels.
  var surface: ptr SDL_Surface
  if SDL_LockTextureToSurface(texture, nil, surface):
    # make the whole surface black
    discard SDL_FillSurfaceRect(surface, nil, SDL_MapRGB(SDL_GetPixelFormatDetails(surface.format), nil, 0, 0, 0))
    var r: SDL_Rect
    r.w = TEXTURE_SIZE
    r.h = TEXTURE_SIZE div 10
    r.x = 0
    r.y = cint (TEXTURE_SIZE - r.h).float * ((scale + 1) / 2)
    # make a strip of the surface green
    discard SDL_FillSurfaceRect(surface, r.addr, SDL_MapRGB(SDL_GetPixelFormatDetails(surface.format), nil, 0, 255, 0))
    # upload the changes (and frees the temporary surface)!
    SDL_UnlockTexture(texture)

  # as you can see from this, rendering draws over whatever was drawn before it.
  SDL_SetRenderDrawColor(renderer, 66, 66, 66, SDL_ALPHA_OPAQUE)  # grey, full alpha
  SDL_RenderClear(renderer)  # start with a blank canvas.

  # Just draw the static texture a few times. You can think of it like a
  # stamp, there isn't a limit to the number of times you can draw with it.

  # Center this one. It'll draw the latest version of the texture we drew while it was locked.
  let dstRect = SDL_FRect(
    x: (WINDOW_WIDTH - TEXTURE_SIZE) / 2,
    y: (WINDOW_HEIGHT - TEXTURE_SIZE) / 2,
    w: TEXTURE_SIZE,
    h: TEXTURE_SIZE,
  )
  SDL_RenderTexture(renderer, texture, nil, dstRect.addr)

  SDL_RenderPresent(renderer)  # put it all on the screen!


SDL_Quit()
