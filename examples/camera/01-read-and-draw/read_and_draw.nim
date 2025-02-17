# This example code reads frames from a camera and draws it to the screen.
#
# This is a very simple approach that is often Good Enough. You can get
# fancier with this: multiple cameras, front/back facing cameras on phones,
# color spaces, choosing formats and framerates...this just requests
# _anything_ and goes with what it is handed.
#
# This code is public domain. Feel free to use it for any purpose!

import ../../../src/sdl3


#------------------------------------------------------------------------------
# Initialization
#------------------------------------------------------------------------------

var
  window: SDL_Window
  renderer: SDL_Renderer
  camera: SDL_Camera
  texture: SDL_Texture

discard SDL_SetAppMetadata("Example Camera Read and Draw", "1.0", "com.example.camera-read-and-draw")

if not SDL_Init(SDL_INIT_VIDEO or SDL_INIT_CAMERA):
  echo "Couldn't initialize SDL: ", SDL_GetError()
  quit(QuitFailure)

if not SDL_CreateWindowAndRenderer("examples/camera/read-and-draw", 640, 480, 0, window, renderer):
    echo "Couldn't create window/renderer: ", SDL_GetError()
    quit(QuitFailure)

var
  devcount: cint
  devices = SDL_GetCameras(devcount)

if devices == nil:
  echo "Couldn't enumerate camera devices: ", SDL_GetError()
  quit(QuitFailure)
elif devcount == 0:
  echo "Couldn't find any camera devices! Please connect a camera and try again."
  quit(QuitFailure)

camera = SDL_OpenCamera(devices[0], nil)  # Just take the first thing we see in any format it wants.
SDL_free(devices)

if camera == nil:
  echo "Couldn't open camera: ", SDL_GetError()
  quit(QuitFailure)


# -----------------------------------------------------------------------------
# Main Loop
# -----------------------------------------------------------------------------

var quit = false
while not quit:

  # Since we can't use the callbacks, we check for incoming events here.
  var event: SDL_Event
  while SDL_PollEvent(event):
    if event.type == SDL_EVENT_QUIT:
      quit = true
    elif event.type == SDL_EVENT_CAMERA_DEVICE_APPROVED:
      echo "Camera use approved by user!"
    elif event.type == SDL_EVENT_CAMERA_DEVICE_DENIED:
      echo "Camera use denied by user!"
      quit(QuitFailure)

  var timestampNS: uint64
  let frame = SDL_AcquireCameraFrame(camera, timestampNS)

  if frame != nil:
    # Some platforms (like Emscripten) don't know _what_ the camera offers
    # until the user gives permission, so we build the texture and resize
    # the window when we get a first frame from the camera. */
    if texture == nil:
      SDL_SetWindowSize(window, frame.w, frame.h)  # Resize the window to match
      texture = SDL_CreateTexture(renderer, frame.format, SDL_TEXTUREACCESS_STREAMING, frame.w, frame.h)

    if texture != nil:
      discard SDL_UpdateTexture(texture, nil, frame.pixels, frame.pitch);

    SDL_ReleaseCameraFrame(camera, frame);

  SDL_SetRenderDrawColor(renderer, 0x99, 0x99, 0x99, 0xFF)
  SDL_RenderClear(renderer)

  if texture != nil: # Draw the latest camera frame, if available.
    SDL_RenderTexture(renderer, texture, nil, nil)

  SDL_RenderPresent(renderer)


#------------------------------------------------------------------------------
# Shutdown
#------------------------------------------------------------------------------

SDL_CloseCamera(camera)
SDL_DestroyTexture(texture)

SDL_Quit()
