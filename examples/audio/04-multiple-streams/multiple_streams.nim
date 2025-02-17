# This example code loads two .wav files, puts them an audio streams and
# binds them for playback, repeating both sounds on loop. This shows several
# streams mixing into a single playback device.
#
# This code is public domain. Feel free to use it for any purpose!

import std/strformat, std/os
import ../../../src/sdl3


# things that are playing sound (the audiostream itself, plus the original data, so we can refill to loop.
type Sound = object
  wavData: ptr[uint8]
  wavDataLen: uint32
  stream: SDL_AudioStream

var audioDevice: SDL_AudioDeviceID
var sounds: seq[Sound]

proc initSound(fname: string): tuple[sound: Sound, ok: bool] =
  # Load the .wav files from wherever the app is being run from.
  result = (Sound(), false)
  let wavPath = &"{os.getCurrentDir()}/test/{fname}"
  var spec: SDL_AudioSpec
  if not SDL_LoadWAV(wavPath.cstring, spec.addr, result.sound.wavData, result.sound.wavDataLen):
    echo "Couldn't load .wav file: ", SDL_GetError()
    return

  # Create an audio stream. Set the source format to the wav's format (what
  # we'll input), leave the dest format nil here (it'll change to what the
  # device wants once we bind it).

  # NOTE: Once bound, it'll start playing when there is data available!
  #   So in this case, we don't need to unpause the SDL_AudioStream.

  result.sound.stream = SDL_CreateAudioStream(spec.addr, nil)
  if result.sound.stream == nil:
    echo "Couldn't create audio stream: ", SDL_GetError()
  elif not SDL_BindAudioStream(audioDevice, result.sound.stream):
    echo "Failed to bind '%s' stream to device: %s", fname, SDL_GetError()
  else:
    result.ok = true  # Success!


#------------------------------------------------------------------------------
# Initialization
#------------------------------------------------------------------------------

discard SDL_SetAppMetadata("Example Audio Multiple Streams", "1.0", "com.example.audio-multiple-streams")

if not SDL_Init(SDL_INIT_VIDEO or SDL_INIT_AUDIO):
  echo "Couldn't initialize SDL: ", SDL_GetError()
  quit(QuitFailure)

var
  window: SDL_Window
  renderer: SDL_Renderer

if not SDL_CreateWindowAndRenderer("examples/audio/multiple-streams", 640, 480, 0, window, renderer):
  echo "Couldn't create window/renderer: ", SDL_GetError()
  quit(QuitFailure)

# Open the default audio device in whatever format it prefers; our audio streams will adjust to it.
audioDevice = SDL_OpenAudioDevice(SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK, nil)
if audioDevice == 0:
  echo "Couldn't open audio device: ", SDL_GetError()
  quit(QuitFailure)

# Load the sounds.
block:
  let (sound, ok) = initSound("sample.wav")
  if ok:  sounds.add(sound)
  else:   quit(QuitFailure)

block:
  let (sound, ok) = initSound("sword.wav")
  if ok:  sounds.add(sound)
  else:   quit(QuitFailure)


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

  for i in 0..<sounds.len:
    # If less than a full copy of the audio is queued for playback, put another copy in there.
    # This is overkill, but easy when lots of RAM is cheap. One could be more careful and
    # queue less at a time, as long as the stream doesn't run dry.
    if SDL_GetAudioStreamAvailable(sounds[i].stream) < sounds[i].wavDataLen.cint:
      discard SDL_PutAudioStreamData(sounds[i].stream, sounds[i].wavData, sounds[i].wavDataLen.cint)

  # Just blank the screen.
  SDL_RenderClear(renderer)
  SDL_RenderPresent(renderer)


#------------------------------------------------------------------------------
# Shutdown
#------------------------------------------------------------------------------

SDL_CloseAudioDevice(audioDevice)

for i in 0..<sounds.len:
  if sounds[i].stream != nil:
    SDL_DestroyAudioStream(sounds[i].stream)
  SDL_free(sounds[i].wavData)

SDL_Quit()
