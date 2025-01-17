# This example code creates an simple audio stream for playing sound, and
# generates a sine wave sound effect for it to play as time goes on. This
# is the simplest way to get up and running with procedural sound.
#
# This code is public domain. Feel free to use it for any purpose!

import ../../../src/sdl3

# -----------------------------------------------------------------------------
# Initialization
# -----------------------------------------------------------------------------

discard SDL_SetAppMetadata("Example Audio Simple Playback", "1.0", "com.example.audio-simple-playback")

if not SDL_Init(SDL_INIT_VIDEO or SDL_INIT_AUDIO):
  echo "Couldn't initialize SDL: ", SDL_GetError()
  quit(QuitFailure)

# we don't _need_ a window for audio-only things but it's good policy to have one.
var
  window: SDL_Window
  renderer: SDL_Renderer

if not SDL_CreateWindowAndRenderer("examples/audio/simple-playback", 640, 480, 0, window, renderer):
  echo "Couldn't create window/renderer: ", SDL_GetError()
  quit(QuitFailure)

# We're just playing a single thing here, so we'll use the simplified option.
# We are always going to feed audio in as mono, float32 data at 8000Hz.
# The stream will convert it to whatever the hardware wants on the other side.
var spec = SDL_AudioSpec(
  channels: 1,
  format: SDL_AUDIO_F32,
  freq: 8000,
)
var stream: SDL_AudioStream = SDL_OpenAudioDeviceStream(SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK, spec.addr, nil, nil)
if stream == nil:
  echo "Couldn't create audio stream: ", SDL_GetError()
  quit(QuitFailure)

# SDL_OpenAudioDeviceStream starts the device paused. You have to tell it to start!
discard SDL_ResumeAudioStreamDevice(stream)


# -----------------------------------------------------------------------------
# Main Loop
# -----------------------------------------------------------------------------

var total_samples_generated = 0
var quit = false
while not quit:

  # Since we can't use the callbacks, we check for incoming events here.
  var event: SDL_Event
  while SDL_PollEvent(event):
    if event.type == SDL_EVENT_QUIT:
      quit = true

  # See if we need to feed the audio stream more data yet.
  # We're being lazy here, but if there's less than half a second queued, generate more.
  # A sine wave is unchanging audio--easy to stream--but for video games, you'll want
  # to generate significantly _less_ audio ahead of time!
  const minimum_audio: int = (8000 * sizeof(float32)) div 2  # 8000 float32 samples per second. Half of that.
  if SDL_GetAudioStreamAvailable(stream) < minimum_audio:
    # this will feed 512 samples each frame until we get to our maximum.
    var samples {.global.}: array[512, float32]

    for i in 0..<samples.len:
      # You don't have to care about this math; we're just generating a simple sine wave as we go.
      # (https://en.wikipedia.org/wiki/Sine_wave)
      const sine_freq = 500.0  # run the wave at 500Hz
      let time = total_samples_generated.float32 / 8000.0
      samples[i] = SDL_sinf(6.283185f * sine_freq * time)
      inc total_samples_generated

    # Feed the new data to the stream. It will queue at the end, and trickle out as the hardware needs more data. */
    discard SDL_PutAudioStreamData(stream, samples.addr, sizeof(samples))

  # We're not doing anything with the renderer, so just blank it out.
  SDL_RenderClear(renderer)
  SDL_RenderPresent(renderer)
