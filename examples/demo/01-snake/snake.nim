# Logic implementation of the Snake game. It is designed to efficiently
# represent the state of the game in memory.
#
# This code is public domain. Feel free to use it for any purpose!

import ../../../src/sdl3

const
  StepRateInMillis = 125
  BoardWidth = 24
  BoardHeight = 18
  SnakeBlockSizeInPixels = 24
  WindowWidth = SnakeBlockSizeInPixels * BoardWidth
  WindowHeight = SnakeBlockSizeInPixels * BoardHeight
  MatrixSize = BoardWidth * BoardHeight

type
  SnakeCell = enum
    SNAKE_CELL_NOTHING,
    SNAKE_CELL_SRIGHT,
    SNAKE_CELL_SUP,
    SNAKE_CELL_SLEFT,
    SNAKE_CELL_SDOWN,
    SNAKE_CELL_FOOD,

  SnakeDirection = enum
    SNAKE_DIR_RIGHT,
    SNAKE_DIR_UP,
    SNAKE_DIR_LEFT,
    SNAKE_DIR_DOWN,

type
  SnakeContext = object
    cells: array[MatrixSize, SnakeCell]
    headX: int
    headY: int
    tailX: int
    tailY: int
    nextDir: SnakeDirection
    inhibit_tail_step: int
    nfilled: int

  AppState = object
    window: SDL_Window
    renderer: SDL_Renderer
    snake_ctx: SnakeContext
    lastStepTime: uint64
    quit: bool

proc cellAt(ctx: SnakeContext, x,y: int): SnakeCell =
  ctx.cells[y * BoardWidth + x]

proc setRectXY(r: var SDL_FRect, x,y: int) =
  r.x = (x * SnakeBlockSizeInPixels).float
  r.y = (y * SnakeBlockSizeInPixels).float

proc putCellAt(ctx: var SnakeContext, x,y: int, ct: SnakeCell) =
  ctx.cells[y * BoardWidth + x] = ct

proc areCellsFull(ctx: SnakeContext): bool =
  ctx.nfilled == MatrixSize

proc newFoodPos(ctx: var SnakeContext) =
  while true:
    let
      x = SDL_rand(BoardWidth)
      y = SDL_rand(BoardHeight)
    if cellAt(ctx, x, y) == SNAKE_CELL_NOTHING:
      putCellAt(ctx, x, y, SNAKE_CELL_FOOD)
      break

proc snakeInitialize(ctx: var SnakeContext) =
  ctx.cells.reset()
  ctx.headX = BoardWidth div 2
  ctx.tailX = BoardWidth div 2
  ctx.headY = BoardHeight div 2
  ctx.tailY = BoardHeight div 2
  ctx.nextDir = SNAKE_DIR_RIGHT
  ctx.inhibit_tail_step = 4
  ctx.nfilled = 3
  ctx.putCellAt(ctx.tailX, ctx.tailY, SNAKE_CELL_SRIGHT)
  for i in 0..<4:
    ctx.newFoodPos()
    inc ctx.nfilled

proc snakeRedir(ctx: var SnakeContext, dir: SnakeDirection) =
  # Force the player to _turn_. The snake can't flip 180 degrees.
  let
    ct = ctx.cellAt(ctx.headX, ctx.headY)
    notTryingToMoveOpposite = (
      (dir == SNAKE_DIR_RIGHT and ct != SNAKE_CELL_SLEFT) or
      (dir == SNAKE_DIR_UP and ct != SNAKE_CELL_SDOWN) or
      (dir == SNAKE_DIR_LEFT and ct != SNAKE_CELL_SRIGHT) or
      (dir == SNAKE_DIR_DOWN and ct != SNAKE_CELL_SUP)
    )
  if notTryingToMoveOpposite:
    ctx.nextDir = dir

# Isn't this just euclmod?
proc wrapAround(val: var int, max: int) =
  if val < 0:
    val = max-1
  elif val > max-1:
    val = 0

proc snakeStep(ctx: var SnakeContext) =

  let dirAsCell = (ctx.nextDir.int + 1).SnakeCell # FIXME: Why in the blue fuck?

  # Move tail forward
  dec ctx.inhibit_tail_step
  if ctx.inhibit_tail_step == 0:
    inc ctx.inhibit_tail_step
    let ct = ctx.cellAt(ctx.tailX, ctx.tailY)
    ctx.putCellAt(ctx.tailX, ctx.tailY, SNAKE_CELL_NOTHING)
    case ct:
      of SNAKE_CELL_SRIGHT: inc ctx.tailX
      of SNAKE_CELL_SUP:    dec ctx.tailY
      of SNAKE_CELL_SLEFT:  dec ctx.tailX
      of SNAKE_CELL_SDOWN:  inc ctx.tailY
      else:                 discard
    ctx.tailX.wrapAround(BoardWidth)
    ctx.tailY.wrapAround(BoardHeight)

  # Move head foward
  let
    prevX = ctx.headX
    prevY = ctx.headY
  case ctx.nextDir:
    of SNAKE_DIR_RIGHT: inc ctx.headX
    of SNAKE_DIR_UP:    dec ctx.headY
    of SNAKE_DIR_LEFT:  dec ctx.headX
    of SNAKE_DIR_DOWN:  inc ctx.headY
  ctx.headX.wrapAround(BoardWidth)
  ctx.headY.wrapAround(BoardHeight)

  # Collisions
  let ct = ctx.cellAt(ctx.headX, ctx.headY)
  if ct notin { SNAKE_CELL_NOTHING, SNAKE_CELL_FOOD }:
    ctx.snakeInitialize()
    return
  ctx.putCellAt(prevX, prevY, dirAsCell)
  ctx.putCellAt(ctx.headX, ctx.headY, dirAsCell)
  if ct == SNAKE_CELL_FOOD:
    if ctx.areCellsFull():
      ctx.snakeInitialize()
      return
    ctx.newFoodPos()
    inc ctx.inhibit_tail_step
    inc ctx.nfilled

proc handleKeyEvent(app: var AppState, keyCode: SDL_Scancode) =
  case keyCode
  of SDL_SCANCODE_ESCAPE, SDL_SCANCODE_Q: app.quit = true                           # Quit.
  of SDL_SCANCODE_R:                      app.snake_ctx.snakeInitialize()           # Restart the game.
  of SDL_SCANCODE_RIGHT:                  app.snake_ctx.snakeRedir(SNAKE_DIR_RIGHT) # Turn right.
  of SDL_SCANCODE_UP:                     app.snake_ctx.snakeRedir(SNAKE_DIR_UP)    # Turn up.
  of SDL_SCANCODE_LEFT:                   app.snake_ctx.snakeRedir(SNAKE_DIR_LEFT)  # Turn left.
  of SDL_SCANCODE_DOWN:                   app.snake_ctx.snakeRedir(SNAKE_DIR_DOWN)  # Turn down.
  else:                                   discard


# -----------------------------------------------------------------------------
# Initialization
# -----------------------------------------------------------------------------

if not SDL_SetAppMetadata("Example Snake game", "1.0", "com.example.Snake"):
  echo "Can't set metadata: ", SDL_GetError()
  quit(QuitFailure)

const extendedMetadata = [
  ( SDL_PROP_APP_METADATA_URL_STRING,       cstring "https://examples.libsdl.org/SDL3/demo/01-snake/" ),
  ( SDL_PROP_APP_METADATA_CREATOR_STRING,   cstring "SDL team" ),
  ( SDL_PROP_APP_METADATA_COPYRIGHT_STRING, cstring "Placed in the public domain" ),
  ( SDL_PROP_APP_METADATA_TYPE_STRING,      cstring "game" ),
];

for (key, value) in extendedMetadata:
  if not SDL_SetAppMetadataProperty(key, value):
    echo "Can't set metadata property - key: ", key, " value: ", value
    quit(QuitFailure)

if not SDL_Init(SDL_INIT_VIDEO):
  echo "Can't init SDL: ", SDL_GetError()
  quit(QuitFailure)

var app: AppState

if not SDL_CreateWindowAndRenderer("examples/demo/snake", WindowWidth, WindowHeight, 0, app.window, app.renderer):
  echo "Can't create window and renderer: ", SDL_GetError()
  quit(QuitFailure)

app.snake_ctx.snakeInitialize()
app.lastStepTime = SDL_GetTicks()


# -----------------------------------------------------------------------------
# Main Loop
# -----------------------------------------------------------------------------

while not app.quit:

  # Since we can't use the callbacks, we check for incoming events here.
  var event: SDL_Event
  while SDL_PollEvent(event):
    if event.type == SDL_EVENT_QUIT:
      app.quit = true
    elif event.type == SDL_EVENT_KEY_DOWN:
      app.handleKeyEvent(event.key.scancode)

  let now = SDL_GetTicks()
  var ctx = app.snake_ctx.addr

  # Run game logic if we're at or past the time to run it.
  # If we're _really_ behind the time to run it, run it
  # several times.
  while now - app.lastStepTime >= StepRateInMillis:
    ctx[].snakeStep()
    app.lastStepTime += StepRateInMillis

  SDL_SetRenderDrawColor(app.renderer, 0, 0, 0, 255)
  SDL_RenderClear(app.renderer)

  var r = SDL_FRect(
    w: SnakeBlockSizeInPixels,
    h: SnakeBlockSizeInPixels,
  )
  for i in 0..<BoardWidth:
    for j in 0..<BoardHeight:
      let ct = ctx[].cellAt(i, j)
      if ct != SNAKE_CELL_NOTHING:
        r.setRectXY(i, j)
        if ct == SNAKE_CELL_FOOD:
          SDL_SetRenderDrawColor(app.renderer, 80, 80, 255, 255)
        else: # body
          SDL_SetRenderDrawColor(app.renderer, 0, 128, 0, 255)
        SDL_RenderFillRect(app.renderer, r)

  SDL_SetRenderDrawColor(app.renderer, 255, 255, 0, 255) # head
  r.setRectXY(ctx.headX, ctx.headY)
  SDL_RenderFillRect(app.renderer, r)
  SDL_RenderPresent(app.renderer)


#------------------------------------------------------------------------------
# Shutdown
#------------------------------------------------------------------------------

SDL_DestroyRenderer(app.renderer)
SDL_DestroyWindow(app.window)

SDL_Quit()
