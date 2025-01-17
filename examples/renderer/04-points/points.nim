# This example creates an SDL window and renderer, and then draws some points
# to it every frame.
#
# This code is public domain. Feel free to use it for any purpose!

import ../../../src/sdl3

# We will use this renderer to draw into this window every frame.
var
  window: SDL_Window
  renderer: SDL_Renderer
  last_time: uint64
  quit: bool

const WINDOW_WIDTH = 640
const WINDOW_HEIGHT = 480

const NUM_POINTS = 500
const MIN_PIXELS_PER_SECOND = 30  # move at least this many pixels per second.
const MAX_PIXELS_PER_SECOND = 60  # move this many pixels per second at most.

# (track everything as parallel arrays instead of a array of structs,
# so we can pass the coordinates to the renderer in a single function call.)

# Points are plotted as a set of X and Y coordinates.
# (0, 0) is the top left of the window, and larger numbers go down
# and to the right. This isn't how geometry works, but this is pretty
# standard in 2D graphics.
var
  points: array[NUM_POINTS, SDL_FPoint]
  point_speeds: array[NUM_POINTS, float]


discard SDL_SetAppMetadata("Example Renderer Points", "1.0", "com.example.renderer-points")

if not SDL_Init(SDL_INIT_VIDEO):
  echo "Couldn't initialize SDL: ", SDL_GetError()
  quit(QuitFailure)

if not SDL_CreateWindowAndRenderer("examples/renderer/points", WINDOW_WIDTH, WINDOW_HEIGHT, 0, window, renderer):
  echo "Couldn't create window/renderer: ", SDL_GetError()
  quit(QuitFailure)

# set up the data for a bunch of points.
for i in 0..<points.len:
  points[i].x = SDL_randf() * WINDOW_WIDTH
  points[i].y = SDL_randf() * WINDOW_HEIGHT
  point_speeds[i] = MIN_PIXELS_PER_SECOND + SDL_randf()*(MAX_PIXELS_PER_SECOND - MIN_PIXELS_PER_SECOND)

last_time = SDL_GetTicks()


# Main loop.
while not quit:
  var event: SDL_Event
  while SDL_PollEvent(event):
    if event.type == SDL_EVENT_QUIT:
      quit = true

  let now = SDL_GetTicks()
  let elapsed = (now - last_time).float / 1000  # seconds since last iteration

  # let's move all our points a little for a new frame.
  for i in 0..<points.len:
    let distance = elapsed * point_speeds[i]
    points[i].x += distance
    points[i].y += distance
    if points[i].x >= WINDOW_WIDTH or points[i].y >= WINDOW_HEIGHT:
      # off the screen; restart it elsewhere!
      if SDL_rand(2) != 0:
          points[i].x = SDL_randf() * WINDOW_WIDTH
          points[i].y = 0
      else:
        points[i].x = 0
        points[i].y = SDL_randf() * WINDOW_HEIGHT
      point_speeds[i] = MIN_PIXELS_PER_SECOND + SDL_randf()*(MAX_PIXELS_PER_SECOND - MIN_PIXELS_PER_SECOND)

  last_time = now

  # as you can see from this, rendering draws over whatever was drawn before it.
  SDL_SetRenderDrawColor(renderer, 0, 0, 0, SDL_ALPHA_OPAQUE)  # black, full alpha
  SDL_RenderClear(renderer)  # start with a blank canvas.
  SDL_SetRenderDrawColor(renderer, 255, 255, 255, SDL_ALPHA_OPAQUE)  # white, full alpha

  # You can also draw single points with SDL_RenderPoint(), but it's
  # cheaper (sometimes significantly so) to do them all at once.
  SDL_RenderPoints(renderer, points)  # draw all the points!

  SDL_RenderPresent(renderer)  # put it all on the screen!


SDL_Quit()