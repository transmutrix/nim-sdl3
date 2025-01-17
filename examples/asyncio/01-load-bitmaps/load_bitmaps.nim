# This example code loads a bitmap with asynchronous i/o and renders it.
# This code is public domain. Feel free to use it for any purpose!

# TODO: Figure out how to get this to work!
# {.emit:"""
#   #define SDL_MAIN_USE_CALLBACKS 1
#   #include <SDL3/SDL.h>
# """.}

import std/strformat, std/os
import ../../../src/sdl3

# -----------------------------------------------------------------------------
# Definitions
# -----------------------------------------------------------------------------

const
  TotalTextures = 4
  bmps: array[TotalTextures, string] = [
    "sample.bmp",
    "gamepad_front.bmp",
    "speaker.bmp",
    "icon2x.bmp"
  ]
  textureRects: array[TotalTextures, SDL_FRect] = [
    SDL_FRect( x: 116, y: 156, w: 408, h: 167 ),
    SDL_FRect( x: 20,  y: 200, w: 96,  h: 60 ),
    SDL_FRect( x: 525, y: 180, w: 96,  h: 96 ),
    SDL_FRect( x: 288, y: 375, w: 64,  h: 64 ),
  ]

# TODO: Figure out how to make this work.
# proc SDL_AppInit*(appstate: ptr pointer, argc: int, argv: UncheckedArray[cstring]): SDL_AppResult {.cdecl, exportc.} =
#   discard

# -----------------------------------------------------------------------------
# Initialization
# -----------------------------------------------------------------------------

if not SDL_Init(SDL_INIT_VIDEO):
  discard SDL_ShowSimpleMessageBox(SDL_MESSAGEBOX_ERROR, "Couldn't initialize SDL!", SDL_GetError(), nil)
  quit(QuitFailure)

var
  window: SDL_Window
  renderer: SDL_Renderer

if not SDL_CreateWindowAndRenderer("examples/asyncio/load_bitmaps", 640, 480, 0, window, renderer):
  discard SDL_ShowSimpleMessageBox(SDL_MESSAGEBOX_ERROR, "Couldn't create window/renderer!", SDL_GetError(), nil)
  quit(QuitFailure)

var queue: SDL_AsyncIOQueue = SDL_CreateAsyncIOQueue()
if queue == nil:
  discard SDL_ShowSimpleMessageBox(SDL_MESSAGEBOX_ERROR, "Couldn't create async i/o queue!", SDL_GetError(), nil)
  quit(QuitFailure)

# Load some .bmp files asynchronously from wherever the app is being run from, put them in the same queue.
for i in 0..<bmps.len:
  # allocate a string of the full file path
  # let path = &"{SDL_GetBasePath()}/test/{bmps[i]}" # Note: if using nim -r, will be a temp dir!
  let path = &"{os.getCurrentDir()}/test/{bmps[i]}"
  # you _should_ check for failure, but we'll just go on without files here.
  # attach the filename as app-specific data, so we can see it later.
  discard SDL_LoadFileAsync(path.cstring, queue, bmps[i].addr)


# -----------------------------------------------------------------------------
# Main Loop
# -----------------------------------------------------------------------------

var textures: array[TotalTextures, SDL_Texture]
var quit = false
while not quit:

  # Since we can't use the callbacks, we check for incoming events here.
  var event: SDL_Event
  while SDL_PollEvent(event):
    if event.type == SDL_EVENT_QUIT:
      quit = true

  # Our main tick code.
  var outcome: SDL_AsyncIOOutcome
  if SDL_GetAsyncIOResult(queue, outcome): # a .bmp file load has finished?
    if outcome.result == SDL_ASYNCIO_COMPLETE:
      # this might be _any_ of the bmps; they might finish loading in any order.
      var which = -1
      for i in 0..<bmps.len:
        # this doesn't need a strcmp because we gave the pointer from this array to SDL_LoadFileAsync
        if outcome.userdata == bmps[i].addr:
          which = i
          break

      if which != -1 and which < bmps.len: # "just in case" according to the original?
        let surface: ptr SDL_Surface =
          SDL_LoadBMP_IO(SDL_IOFromConstMem(outcome.buffer, outcome.bytes_transferred.csize_t), true)
        if surface != nil:
          # the renderer is not multithreaded, so create the texture here once the data loads.
          textures[which] = SDL_CreateTextureFromSurface(renderer, surface)
          if textures[which] == nil:
            discard SDL_ShowSimpleMessageBox(SDL_MESSAGEBOX_ERROR, "Couldn't create texture!", SDL_GetError(), nil)
            quit(QuitFailure)
          SDL_DestroySurface(surface)
    SDL_free(outcome.buffer)

  SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255)
  SDL_RenderClear(renderer)

  for i in 0..<textures.len:
    SDL_RenderTexture(renderer, textures[i], nil, textureRects[i].addr)

  SDL_RenderPresent(renderer)


# -----------------------------------------------------------------------------
# Shutdown
# -----------------------------------------------------------------------------

SDL_DestroyAsyncIOQueue(queue)

# Not really necessary.
for i in 0..<textures.len:
  SDL_DestroyTexture(textures[i])

SDL_Quit()
