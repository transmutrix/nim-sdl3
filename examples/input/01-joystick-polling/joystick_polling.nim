# This example code looks for the current joystick state once per frame,
# and draws a visual representation of it.
#
# This code is public domain. Feel free to use it for any purpose!

# Joysticks are low-level interfaces: there's something with a bunch of
# buttons, axes and hats, in no understood order or position. This is
# a flexible interface, but you'll need to build some sort of configuration
# UI to let people tell you what button, etc, does what. On top of this
# interface, SDL offers the "gamepad" API, which works with lots of devices,
# and knows how to map arbitrary buttons and such to look like an
# Xbox/PlayStation/etc gamepad. This is easier, and better, for many games,
# but isn't necessarily a good fit for complex apps and hardware. A flight
# simulator, a realistic racing game, etc, might want this interface instead
# of gamepads.

# SDL can handle multiple joysticks, but for simplicity, this program only
# deals with the first stick it sees.

import ../../../src/sdl3

# We will use this renderer to draw into this window every frame.
var window: SDL_Window
var renderer: SDL_Renderer
var joystick: SDL_Joystick
var colors: array[64, SDL_Color]


# -----------------------------------------------------------------------------
# Initialization
# -----------------------------------------------------------------------------

if not SDL_SetAppMetadata("Example Input Joystick Polling", "1.0", "com.example.input-joystick-polling"):
  echo "Can't set metadata: ", SDL_GetError()
  quit(QuitFailure)

if not SDL_Init(SDL_INIT_VIDEO or SDL_INIT_JOYSTICK):
  echo "Can't init SDL: ", SDL_GetError()
  quit(QuitFailure)

if not SDL_CreateWindowAndRenderer("examples/input/joystick-polling", 640, 480, 0, window, renderer):
  echo "Can't create window & renderer: ", SDL_GetError()
  quit(QuitFailure)

SDL_SetRenderVSync(renderer, 1)

for i in 0..<colors.len:
  colors[i].r = SDL_rand(255).uint8
  colors[i].g = SDL_rand(255).uint8
  colors[i].b = SDL_rand(255).uint8
  colors[i].a = 255


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
    elif event.type == SDL_EVENT_JOYSTICK_ADDED:
      # This event is sent for each hotplugged stick, but also each
      # already-connected joystick during SDL_Init().
      if joystick == nil:
        joystick = SDL_OpenJoystick(event.jdevice.which)
        if joystick == nil:
          echo "Failed to open joystick ID ", event.jdevice.which, ": ", SDL_GetError()
    elif event.type == SDL_EVENT_JOYSTICK_REMOVED:
      if joystick != nil and (SDL_GetJoystickID(joystick) == event.jdevice.which):
        SDL_CloseJoystick(joystick)  # Our joystick was unplugged.
        joystick = nil

  # Game update.

  let text = if joystick != nil:  $SDL_GetJoystickName(joystick)
                           else:  "Plug in a joystick, please."

  var winw, winh: int
  discard SDL_GetWindowSize(window, winw, winh)

  SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255)
  SDL_RenderClear(renderer)

  # Note that you can get input as events, instead of polling, which is
  # better since it won't miss button presses if the system is lagging,
  # but often times checking the current state per-frame is good enough,
  # and maybe better if you'd rather _drop_ inputs due to lag.

  if joystick != nil: # We have a stick opened.
    # Draw axes as bars going across middle of screen. We don't know if it's
    # an X or Y or whatever axis, so we can't do more than this.
    const size = 30.0'f32
    var
      total = SDL_GetNumJoystickAxes(joystick)
      y: float32 = (winh.float32 - total.float32 * size) / 2
      x: float32 = winw.float32 / 2
    for i in 0..<total:
      let
        color: ptr SDL_Color = addr colors[i mod colors.len]
        val: float32 = SDL_GetJoystickAxis(joystick, i).float32 / 32767.0  # Make it -1.0 to 1.0
        dx: float32 = val*x + x
        dst = SDL_FRect( x: dx, y: y, w: x - SDL_fabsf(dx), h: size )
      SDL_SetRenderDrawColor(renderer, color.r, color.g, color.b, color.a)
      SDL_RenderFillRect(renderer, dst)
      y += size

    # Fraw buttons as blocks across top of window. We only know the button
    # numbers, but not where they are on the device.
    total = SDL_GetNumJoystickButtons(joystick)
    x = (winw.float32 - (total.float32 * size)) / 2
    for i in 0..<total:
      let
        color: ptr SDL_Color = addr colors[i mod colors.len]
        dst = SDL_FRect( x: x, y: 0.0, w: size, h: size )
      if SDL_GetJoystickButton(joystick, i):
        SDL_SetRenderDrawColor(renderer, color.r, color.g, color.b, color.a)
      else:
        SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255)
      SDL_RenderFillRect(renderer, dst)
      SDL_SetRenderDrawColor(renderer, 255, 255, 255, color.a)
      SDL_RenderRect(renderer, dst)  # Outline it
      x += size

    # Draw hats across the bottom of the screen.
    total = SDL_GetNumJoystickHats(joystick)
    x = (winw.float32 - total.float32*size*2 + size) / 2
    y = winh.float32 - size
    for i in 0..<total:
      let
        color = addr colors[i mod colors.len]
        thirdsize = size / 3
        cross = [
          SDL_FRect( x: x,             y: y + thirdsize, w: size,      h: thirdsize ),
          SDL_FRect( x: x + thirdsize, y: y,             w: thirdsize, h: size ),
        ]
        hat = SDL_GetJoystickHat(joystick, i)

      SDL_SetRenderDrawColor(renderer, 90, 90, 90, 255)
      SDL_RenderFillRects(renderer, cross)
      SDL_SetRenderDrawColor(renderer, color.r, color.g, color.b, color.a)

      if (hat and SDL_HAT_UP) != 0:
        let dst = SDL_FRect( x: x + thirdsize, y: y, w: thirdsize, h: thirdsize )
        SDL_RenderFillRect(renderer, dst)

      if (hat and SDL_HAT_RIGHT) != 0:
        let dst = SDL_FRect( x: x + (thirdsize * 2), y: y + thirdsize, w: thirdsize, h: thirdsize )
        SDL_RenderFillRect(renderer, dst)

      if (hat and SDL_HAT_DOWN) != 0:
        let dst = SDL_FRect( x: x + thirdsize, y: y + (thirdsize * 2), w: thirdsize, h: thirdsize )
        SDL_RenderFillRect(renderer, dst)

      if (hat and SDL_HAT_LEFT) != 0:
        let dst = SDL_FRect( x: x, y: y + thirdsize, w: thirdsize, h: thirdsize )
        SDL_RenderFillRect(renderer, dst)

      x += size * 2

  let
    x = (winw - text.len*SDL_DEBUG_TEXT_FONT_CHARACTER_SIZE).float32 / 2
    y = (winh - SDL_DEBUG_TEXT_FONT_CHARACTER_SIZE).float32 / 2
  SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255)
  SDL_RenderDebugText(renderer, x, y, text.cstring)
  SDL_RenderPresent(renderer)


#------------------------------------------------------------------------------
# Shutdown
#------------------------------------------------------------------------------

if joystick != nil:
  SDL_CloseJoystick(joystick)

SDL_DestroyRenderer(renderer)
SDL_DestroyWindow(window)
SDL_Quit()
