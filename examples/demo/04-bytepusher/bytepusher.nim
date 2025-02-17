# An implementation of the BytePusher VM.
#
# For example programs and more information about BytePusher, see
# https://esolangs.org/wiki/BytePusher
#
# This code is public domain. Feel free to use it for any purpose!

import std/[bitops, strutils]
import ../../../src/sdl3

{.checks: off.}

# In Nim, binary and is either just `and` or you can use `bitand` from bitops.
# Similarly, bitnot from bitops to flip all the bits.
# And there is no built-in equivalent to &=, |= etc. but Nim makes it easy for
# us to define these operators for ourselves!
# proc `&`(a,b: SomeInteger): SomeInteger       = bitand(a, b)
proc `~`(a: SomeInteger): SomeInteger         = bitnot(a)
proc `|=`(a: var SomeInteger, b: SomeInteger) = a = bitor(a, b)
proc `&=`(a: var SomeInteger, b: SomeInteger) = a = bitand(a, b)

const SCREEN_W = 256
const SCREEN_H = 256
const RAM_SIZE = 0x1000000
const FRAMES_PER_SECOND = 60
const SAMPLES_PER_FRAME = 256
const INSTRUCTIONS_PER_FRAME = 65536
const NS_PER_SECOND = (uint64)SDL_NS_PER_SECOND
const MAX_AUDIO_LATENCY_FRAMES = 5

const IO_KEYBOARD = 0
const IO_PC = 2
const IO_SCREEN_PAGE = 5
const IO_AUDIO_BANK = 6

type BytePusher = object
  ram: array[RAM_SIZE + 8, byte]
  screenbuf: array[SCREEN_W * SCREEN_H, byte]
  next_tick: uint64
  window: SDL_Window
  renderer: SDL_Renderer
  screen: ptr SDL_Surface
  screentex: SDL_Texture
  rendertarget: SDL_Texture # we need this render target for text to look good
  audiostream: SDL_AudioStream
  status: string
  status_ticks: int
  keystate: uint16
  display_help: bool
  positional_input: bool
  quitting: bool

template read_u16(vm: BytePusher, address: uint32): uint16 =
  (vm.ram[address+0].uint16 shl 8) or vm.ram[address+1].uint16

template read_u24(vm: BytePusher, address: uint32): uint32 =
  (vm.ram[address+0].uint32 shl 16) or (vm.ram[address+1].uint32 shl 8) or vm.ram[address+2].uint32

proc set_status(vm: var BytePusher, message: string) =
  vm.status = message
  vm.status.setLen(min(vm.status.len, SCREEN_W div 8 - 1))
  vm.status_ticks = FRAMES_PER_SECOND * 3

proc load(vm: var BytePusher, stream: SDL_IOStream, closeio: bool): bool =
  vm.ram.reset()

  if stream == nil:
    return

  var
    ok = true
    bytes_read: csize_t = 0

  while bytes_read < RAM_SIZE:
    let read = SDL_ReadIO(stream, vm.ram[bytes_read].addr, RAM_SIZE - bytes_read)
    bytes_read += read
    if read == 0:
      ok = SDL_GetIOStatus(stream) == SDL_IO_STATUS_EOF
      break

  if closeio:
    SDL_CloseIO(stream)

  discard SDL_ClearAudioStream(vm.audiostream)

  vm.display_help = not ok
  ok

proc load_file(vm: var BytePusher, path: string): bool =
  let filename = path.split('/')[^1]
  if vm.load(SDL_IOFromFile(path.cstring, "rb"), true):
    vm.set_status("loaded " & filename)
    return true
  else:
    vm.set_status("load failed: " & filename)
    return false

proc print(vm: var BytePusher, x,y: int, str: string) =
  SDL_SetRenderDrawColor(vm.renderer, 0, 0, 0, SDL_ALPHA_OPAQUE)
  SDL_RenderDebugText(vm.renderer, (float)(x + 1), (float)(y + 1), str)
  SDL_SetRenderDrawColor(vm.renderer, 0xff, 0xff, 0xff, SDL_ALPHA_OPAQUE)
  SDL_RenderDebugText(vm.renderer, (float)x, (float)y, str)
  SDL_SetRenderDrawColor(vm.renderer, 0, 0, 0, SDL_ALPHA_OPAQUE)

proc keycode_mask(key: SDL_Keycode): uint16 =
  var index: int
  if key >= SDLK_0 and key <= SDLK_9:    index = key.int - SDLK_0.int
  elif key >= SDLK_A and key <= SDLK_F:  index = key.int - SDLK_A.int + 10
  else:                                  return 0
  1'u16 shl index

proc scancode_mask(scancode: SDL_Scancode): uint16 =
  var index: int
  case scancode:
    of SDL_SCANCODE_1:  index = 0x1
    of SDL_SCANCODE_2:  index = 0x2
    of SDL_SCANCODE_3:  index = 0x3
    of SDL_SCANCODE_4:  index = 0xc
    of SDL_SCANCODE_Q:  index = 0x4
    of SDL_SCANCODE_W:  index = 0x5
    of SDL_SCANCODE_E:  index = 0x6
    of SDL_SCANCODE_R:  index = 0xd
    of SDL_SCANCODE_A:  index = 0x7
    of SDL_SCANCODE_S:  index = 0x8
    of SDL_SCANCODE_D:  index = 0x9
    of SDL_SCANCODE_F:  index = 0xe
    of SDL_SCANCODE_Z:  index = 0xa
    of SDL_SCANCODE_X:  index = 0x0
    of SDL_SCANCODE_C:  index = 0xb
    of SDL_SCANCODE_V:  index = 0xf
    else:               return 0
  1'u16 shl index

proc handleEvent(vm: var BytePusher, event: SDL_Event) =
  case event.type
  of SDL_EVENT_QUIT:
    vm.quitting = true

  of SDL_EVENT_DROP_FILE:
    discard vm.load_file($event.drop.data)

  of SDL_EVENT_KEY_DOWN:
# TODO: Go look at my other Nim Emcc projects and fix this lol
#ifndef __EMSCRIPTEN__
    if event.key.key == SDLK_ESCAPE:
        vm.quitting = true
#endif
    if event.key.key == SDLK_RETURN:
      vm.positional_input = vm.positional_input
      vm.keystate = 0
      if vm.positional_input:  set_status(vm, "switched to positional input")
      else:                    set_status(vm, "switched to symbolic input")

    if vm.positional_input:  vm.keystate |= scancode_mask(event.key.scancode)
    else:                    vm.keystate |= keycode_mask(event.key.key)

  of SDL_EVENT_KEY_UP:
    if vm.positional_input:  vm.keystate &= ~scancode_mask(event.key.scancode)
    else:                    vm.keystate &= ~keycode_mask(event.key.key)

  else: discard

# -----------------------------------------------------------------------------
# Initialization
# -----------------------------------------------------------------------------

var
  vm: BytePusher
  palette: ptr SDL_Palette
  usable_bounds: SDL_Rect
  audiospec = SDL_AudioSpec(
    format: SDL_AUDIO_S8,
    channels: 1,
    freq: SAMPLES_PER_FRAME * FRAMES_PER_SECOND
  )
  primary_display: SDL_DisplayID
  texprops: SDL_PropertiesID
  zoom: cint = 2

if not SDL_SetAppMetadata("SDL 3 BytePusher", "1.0", "com.example.SDL3BytePusher"):
  echo "Can't set metadata: ", SDL_GetError()
  quit(QuitFailure)

const extended_metadata = [
  ( SDL_PROP_APP_METADATA_URL_STRING,       cstring "https://examples.libsdl.org/SDL3/demo/04-bytepusher/" ),
  ( SDL_PROP_APP_METADATA_CREATOR_STRING,   cstring "SDL team" ),
  ( SDL_PROP_APP_METADATA_COPYRIGHT_STRING, cstring "Placed in the public domain" ),
  ( SDL_PROP_APP_METADATA_TYPE_STRING,      cstring "game" ),
]
for (key, value) in extendedMetadata:
  if not SDL_SetAppMetadataProperty(key, value):
    echo "Can't set metadata property - key: ", key, " value: ", value
    quit(QuitFailure)

if not SDL_Init(SDL_INIT_VIDEO or SDL_INIT_AUDIO):
  echo "Can't init SDL: ", SDL_GetError()
  quit(QuitFailure)

vm.display_help = true

primary_display = SDL_GetPrimaryDisplay()
if SDL_GetDisplayUsableBounds(primary_display, usable_bounds):
  let zoom_w: cint = (usable_bounds.w - usable_bounds.x) * 2 div 3 div SCREEN_W
  let zoom_h: cint = (usable_bounds.h - usable_bounds.y) * 2 div 3 div SCREEN_H
  zoom = max(1, min(zoom_w, zoom_h))

if not SDL_CreateWindowAndRenderer("SDL 3 BytePusher",
  SCREEN_W * zoom,
  SCREEN_H * zoom,
  SDL_WINDOW_RESIZABLE,
  vm.window, vm.renderer
):
  echo "Can't create window/renderer: ", SDL_GetError()
  quit(QuitFailure)

if not SDL_SetRenderLogicalPresentation(
    vm.renderer,
    SCREEN_W,
    SCREEN_H,
    SDL_LOGICAL_PRESENTATION_INTEGER_SCALE
):
  echo "Can't set logical presentation: ", SDL_GetError()
  quit(QuitFailure)

SDL_SetRenderVSync(vm.renderer, 1)

vm.screen = SDL_CreateSurfaceFrom(
  SCREEN_W,
  SCREEN_H,
  SDL_PIXELFORMAT_INDEX8,
  vm.screenbuf.addr,
  SCREEN_W
)
if vm.screen == nil:
  echo "Can't create screen surface: ", SDL_GetError()
  quit(QuitFailure)

palette = SDL_CreateSurfacePalette(vm.screen)
if palette == nil:
  echo "Can't create palette: ", SDL_GetError()
  quit(QuitFailure)

var i = 0
for r in 0'u8..<6:
  for g in 0'u8..<6:
    for b in 0'u8..<6:
      let color = SDL_Color( r: r * 0x33, g: g * 0x33, b: b * 0x33, a: SDL_ALPHA_OPAQUE )
      palette.colors[i] = color
      inc i

for j in i..<256:
  const color = SDL_Color( r: 0, g: 0, b: 0, a: SDL_ALPHA_OPAQUE )
  palette.colors[j] = color

texprops = SDL_CreateProperties()
SDL_SetNumberProperty(texprops, SDL_PROP_TEXTURE_CREATE_ACCESS_NUMBER, SDL_TEXTUREACCESS_STREAMING.int64)
SDL_SetNumberProperty(texprops, SDL_PROP_TEXTURE_CREATE_WIDTH_NUMBER, SCREEN_W.int64)
SDL_SetNumberProperty(texprops, SDL_PROP_TEXTURE_CREATE_HEIGHT_NUMBER, SCREEN_H.int64)
vm.screentex = SDL_CreateTextureWithProperties(vm.renderer, texprops)
if vm.screentex == nil:
  echo "Can't create screen texture: ", SDL_GetError()
  quit(QuitFailure)
SDL_SetNumberProperty(texprops, SDL_PROP_TEXTURE_CREATE_ACCESS_NUMBER, SDL_TEXTUREACCESS_TARGET.int64)
vm.rendertarget = SDL_CreateTextureWithProperties(vm.renderer, texprops)
SDL_DestroyProperties(texprops)
if vm.rendertarget == nil:
  echo "Can't create rendertarget: ", SDL_GetError()
  quit(QuitFailure)
SDL_SetTextureScaleMode(vm.screentex, SDL_SCALEMODE_NEAREST)
SDL_SetTextureScaleMode(vm.rendertarget, SDL_SCALEMODE_NEAREST)

vm.audiostream = SDL_OpenAudioDeviceStream(SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK, audiospec, nil, nil)
if vm.audiostream == nil:
  echo "Can't create audiostream: ", SDL_GetError()
  quit(QuitFailure)

discard SDL_SetAudioStreamGain(vm.audiostream, 0.1) # examples are loud!
discard SDL_ResumeAudioStreamDevice(vm.audiostream)

vm.set_status("renderer: " & $SDL_GetRendererName(vm.renderer))
vm.next_tick = SDL_GetTicksNS()


# -----------------------------------------------------------------------------
# Main Loop
# -----------------------------------------------------------------------------

while not vm.quitting:

  # Since we can't use the callbacks, we check for incoming events here.
  var event: SDL_Event
  while SDL_PollEvent(event):
    vm.handleEvent(event)

  let tick: uint64 = SDL_GetTicksNS()
  let updated = tick >= vm.next_tick
  let skip_audio = tick - vm.next_tick >= MAX_AUDIO_LATENCY_FRAMES * NS_PER_SECOND

  if skip_audio:
    # Don't let audio fall too far behind
    discard SDL_ClearAudioStream(vm.audiostream)

  if updated:
    vm.next_tick += NS_PER_SECOND div FRAMES_PER_SECOND

    # Input
    vm.ram[IO_KEYBOARD] = uint8(vm.keystate shr 8)
    vm.ram[IO_KEYBOARD + 1] = uint8(vm.keystate)

    # CPU
    var pc,src,dst: uint32
    pc = vm.read_u24(IO_PC)
    for i in 0..<INSTRUCTIONS_PER_FRAME:
      src = vm.read_u24(pc)
      dst = vm.read_u24(pc + 3)
      vm.ram[dst] = vm.ram[src]
      pc = vm.read_u24(pc + 6)

    # Audio
    if not skip_audio or updated:
      discard SDL_PutAudioStreamData(
        vm.audiostream,
        vm.ram[vm.read_u16(IO_AUDIO_BANK).uint32 shl 8].addr,
        SAMPLES_PER_FRAME
      )

    # Draw
    var tex: ptr SDL_Surface
    discard SDL_SetRenderTarget(vm.renderer, vm.rendertarget)
    if not SDL_LockTextureToSurface(vm.screentex, nil, tex):
      echo "Couldn't lock texture surface: ", SDL_GetError()
      quit(QuitFailure)
    vm.screen.pixels = cast[ptr UncheckedArray[uint8]](
      vm.ram[vm.ram[IO_SCREEN_PAGE].uint32 shl 16].addr
    )
    discard SDL_BlitSurface(vm.screen, nil, tex, nil)
    SDL_UnlockTexture(vm.screentex)
    SDL_RenderTexture(vm.renderer, vm.screentex, nil, nil)

  if vm.display_help:
    vm.print(4, 4, "Drop a BytePusher file in this")
    vm.print(8, 12, "window to load and run it!")
    vm.print(4, 28, "Press ENTER to switch between")
    vm.print(8, 36, "positional and symbolic input.")

  if vm.status_ticks > 0:
    vm.status_ticks -= 1
    vm.print(4, SCREEN_H - 12, vm.status)

  SDL_SetRenderTarget(vm.renderer, nil)
  SDL_RenderClear(vm.renderer)
  SDL_RenderTexture(vm.renderer, vm.rendertarget, nil, nil)
  SDL_RenderPresent(vm.renderer)


#------------------------------------------------------------------------------
# Shutdown
#------------------------------------------------------------------------------

SDL_DestroyAudioStream(vm.audiostream)
SDL_DestroyTexture(vm.rendertarget)
SDL_DestroyTexture(vm.screentex)
SDL_DestroySurface(vm.screen)
SDL_DestroyRenderer(vm.renderer)
SDL_DestroyWindow(vm.window)
SDL_Quit()
