# This example code creates an simple audio stream for playing sound, and
# loads a .wav file that is pushed through the stream in a loop.
#
# This code is public domain. Feel free to use it for any purpose!
#
# The .wav file is a sample from Will Provost's song, The Living Proof,
# used with permission.
#
#    From the album The Living Proof
#    Publisher: 5 Guys Named Will
#    Copyright 1996 Will Provost
#    https://itunes.apple.com/us/album/the-living-proof/id4153978
#    http://www.amazon.com/The-Living-Proof-Will-Provost/dp/B00004R8RH

import std/strformat, std/os
import ../../../src/sdl3


# -----------------------------------------------------------------------------
# Initialization
# -----------------------------------------------------------------------------

discard SDL_SetAppMetadata("Example Audio Load Wave", "1.0", "com.example.audio-load-wav")

if not SDL_Init(SDL_INIT_VIDEO or SDL_INIT_AUDIO):
  echo "Couldn't initialize SDL: ", SDL_GetError()
  quit(QuitFailure)

# We don't _need_ a window for audio-only things but it's good policy to have one.
var
  window: SDL_Window
  renderer: SDL_Renderer

if not SDL_CreateWindowAndRenderer("examples/audio/load-wav", 640, 480, 0, window, renderer):
  echo "Couldn't create window/renderer: ", SDL_GetError()
  quit(QuitFailure)

# Load the .wav file.
let wavPath = &"{os.getCurrentDir()}/test/sample.wav"
var
  wavData: ptr[uint8]
  wavDataLen: uint32
  spec: SDL_AudioSpec
if not SDL_LoadWAV(wavPath.cstring, spec.addr, wavData, wavDataLen):
  echo "Couldn't load .wav file: ", SDL_GetError()
  quit(QuitFailure)

# Create our audio stream in the same format as the .wav file. It'll convert to what the audio hardware wants.
var stream = SDL_OpenAudioDeviceStream(SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK, spec.addr, nil, nil);
if stream == nil:
  echo "Couldn't create audio stream: ", SDL_GetError()
  quit(QuitFailure)

# SDL_OpenAudioDeviceStream starts the device paused. You have to tell it to start!
discard SDL_ResumeAudioStreamDevice(stream)


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

  # See if we need to feed the audio stream more data yet.
  # We're being lazy here, but if there's less than the entire wav file left to play,
  # just shove a whole copy of it into the queue, so we always have _tons_ of
  # data queued for playback.
  if SDL_GetAudioStreamAvailable(stream) < wavDataLen.int:
    # Feed more data to the stream. It will queue at the end, and trickle out as the hardware needs more data.
    discard SDL_PutAudioStreamData(stream, wavData, wavDataLen.int)

  # We're not doing anything with the renderer, so just blank it out.
  SDL_RenderClear(renderer);
  SDL_RenderPresent(renderer);


#------------------------------------------------------------------------------
# Shutdown
#------------------------------------------------------------------------------

# Strictly speaking, this isn't necessary because the process is ending, but
# it's here for completeness.
SDL_free(wavData)

SDL_Quit()
