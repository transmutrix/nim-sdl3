# This example code creates an simple audio stream for playing sound, and
# generates a sine wave sound effect for it to play as time goes on. Unlike
# the previous example, this uses a callback to generate sound.
#
# This might be the path of least resistance if you're moving an SDL2
# program's audio code to SDL3.
#
# This code is public domain. Feel free to use it for any purpose!

import ../../../src/sdl3

# This function will be called (usually in a background thread) when the audio stream is consuming data.
proc FeedTheAudioStreamMore* (userdata: pointer, astream: SDL_AudioStream, additional_amount,total_amount: cint): void {.cdecl.} =
  # total_amount is how much data the audio stream is eating right now, additional_amount is how much more it needs
  # than what it currently has queued (which might be zero!). You can supply any amount of data here; it will take what
  # it needs and use the extra later. If you don't give it enough, it will take everything and then feed silence to the
  # hardware for the rest. Ideally, though, we always give it what it needs and no extra, so we aren't buffering more
  # than necessary.
  var total_samples_generated {.global.} = 0
  var nsamples = additional_amount div sizeof(float32)  # convert from bytes to samples
  while nsamples > 0:
    var samples: array[128, float32]  # this will feed 128 samples each iteration until we have enough.
    let total: int = SDL_min(nsamples, samples.len)

    for i in 0..<total:
      # You don't have to care about this math; we're just generating a simple sine wave as we go.
      # (https://en.wikipedia.org/wiki/Sine_wave)
      const sine_freq = 500.0   # run the wave at 500Hz
      let time = total_samples_generated.float32 / 8000.0
      samples[i] = SDL_sinf(6.283185f * sine_freq * time)
      inc total_samples_generated

    # feed the new data to the stream. It will queue at the end, and trickle out as the hardware needs more data.
    discard SDL_PutAudioStreamData(astream, samples.addr, cint total * sizeof(float32))
    nsamples -= total  # subtract what we've just fed the stream.


# -----------------------------------------------------------------------------
# Initialization
# -----------------------------------------------------------------------------

discard SDL_SetAppMetadata("Example Simple Audio Playback Callback", "1.0", "com.example.audio-simple-playback-callback")

if not SDL_Init(SDL_INIT_VIDEO or SDL_INIT_AUDIO):
  echo "Couldn't initialize SDL: ", SDL_GetError()
  quit(QuitFailure)

# we don't _need_ a window for audio-only things but it's good policy to have one.
var
  window: SDL_Window
  renderer: SDL_Renderer
if not SDL_CreateWindowAndRenderer("examples/audio/simple-playback-callback", 640, 480, 0, window, renderer):
  echo "Couldn't create window/renderer: ", SDL_GetError()
  quit(QuitFailure)

# We're just playing a single thing here, so we'll use the simplified option.
# We are always going to feed audio in as mono, float32 data at 8000Hz.
# The stream will convert it to whatever the hardware wants on the other side.
let spec = SDL_AudioSpec(channels: 1, format: SDL_AUDIO_F32, freq: 8000 )
let stream = SDL_OpenAudioDeviceStream(SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK, spec.addr, FeedTheAudioStreamMore, nil )
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

  # NOTE: All the work of feeding the audio stream is happening in a callback in a background thread.

  # We're not doing anything with the renderer, so just blank it out.
  SDL_RenderClear(renderer)
  SDL_RenderPresent(renderer)

SDL_Quit()
