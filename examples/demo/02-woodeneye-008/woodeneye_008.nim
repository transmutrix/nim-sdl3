# This code is public domain. Feel free to use it for any purpose!

import std/[bitops, strformat]
import ../../../src/sdl3

# In Nim, binary and is either just `and` or you can use `bitand` from bitops.
# Similarly, bitnot from bitops to flip all the bits.
# And there is no built-in equivalent to &=, |= etc. but Nim makes it easy for
# us to define these operators for ourselves!
proc `&`(a,b: SomeInteger): SomeInteger       = bitand(a, b)
proc `~`(a: SomeInteger): SomeInteger         = bitnot(a)
proc `|=`(a: var SomeInteger, b: SomeInteger) = a = bitor(a, b)
proc `&=`(a: var SomeInteger, b: SomeInteger) = a = bitand(a, b)

const
  MAP_BOX_SCALE = 16
  MAP_BOX_EDGES_LEN = 12 + MAP_BOX_SCALE * 2
  MAX_PLAYER_COUNT = 4
  CIRCLE_DRAW_SIDES = 32
  CIRCLE_DRAW_SIDES_LEN = CIRCLE_DRAW_SIDES + 1

type
  Player = object
    mouse: SDL_MouseID
    keyboard: SDL_KeyboardID
    pos, vel: array[3, float64]
    yaw: int64
    pitch: int
    height, radius: float64
    color: array[3, uint8]
    wasd: uint8

  AppState = object
    window: SDL_Window
    renderer: SDL_Renderer
    player_count: int
    players: array[MAX_PLAYER_COUNT, Player]
    edges: array[MAP_BOX_EDGES_LEN, array[6, float32]]
    quit: bool

proc whoseMouse(mouse: SDL_MouseID, players: openarray[Player]): int =
  for i in 0..<players.len:
    if players[i].mouse == mouse:
      return i
  -1

proc whoseKeyboard(keyboard: SDL_KeyboardID, players: openarray[Player]): int =
  for i in 0..<players.len:
    if players[i].keyboard == keyboard:
      return i
  -1

proc shoot(shooter: int, players: var openarray[Player]) =
  let
    x0 = players[shooter].pos[0]
    y0 = players[shooter].pos[1]
    z0 = players[shooter].pos[2]
    bin_rad = SDL_PI_D / 2147483648.0
    yaw_rad   = bin_rad * players[shooter].yaw.float32
    pitch_rad = bin_rad * players[shooter].pitch.float32
    cos_yaw   = SDL_cos(  yaw_rad)
    sin_yaw   = SDL_sin(  yaw_rad)
    cos_pitch = SDL_cos(pitch_rad)
    sin_pitch = SDL_sin(pitch_rad)
    vx = -sin_yaw*cos_pitch
    vy =          sin_pitch
    vz = -cos_yaw*cos_pitch

  for i in 0..<players.len:
    if i == shooter:
      continue

    var
      target = players[i].addr
      hit = 0

    for j in 0..<2:
      let
        r = target.radius
        h = target.height
        dx = target.pos[0] - x0
        dy = target.pos[1] - y0 + (if j == 0:  0'f  else:  (r - h))
        dz = target.pos[2] - z0
        vd = vx*dx + vy*dy + vz*dz
        dd = dx*dx + dy*dy + dz*dz
        vv = vx*vx + vy*vy + vz*vz
        rr = r * r

      if vd < 0:
        continue

      if vd * vd >= vv * (dd - rr):
        hit += 1

    if hit > 0:
      target.pos[0] = (MAP_BOX_SCALE * (SDL_rand(256) - 128)).float64 / 256
      target.pos[1] = (MAP_BOX_SCALE * (SDL_rand(256) - 128)).float64 / 256
      target.pos[2] = (MAP_BOX_SCALE * (SDL_rand(256) - 128)).float64 / 256


proc update(players: openarray[Player], dt_ns: uint64) =
  for i in 0..<players.len:
    var player = players[i].addr
    let
      rate = 6.0
      time = (dt_ns.float64 * 1e-9).float64
      drag = SDL_exp(-time * rate)
      diff = 1.0 - drag
      mult = 60.0
      grav = 25.0
      yaw = player.yaw.float64
      rad = yaw * SDL_PI_D / 2147483648.0
      cos = SDL_cos(rad)
      sin = SDL_sin(rad)
      wasd = player.wasd
      dirX = (if (wasd & 8) != 0: 1.0 else: 0.0) - (if (wasd & 2) != 0:  1.0  else:  0.0)
      dirZ = (if (wasd & 4) != 0: 1.0 else: 0.0) - (if (wasd & 1) != 0:  1.0  else:  0.0)
      norm = dirX * dirX + dirZ * dirZ
      accX = mult * (if norm == 0: 0.0 else: ( cos*dirX + sin*dirZ) / SDL_sqrt(norm))
      accZ = mult * (if norm == 0: 0.0 else: (-sin*dirX + cos*dirZ) / SDL_sqrt(norm))
      velX = player.vel[0]
      velY = player.vel[1]
      velZ = player.vel[2]
    player.vel[0] -= velX * diff
    player.vel[1] -= grav * time
    player.vel[2] -= velZ * diff
    player.vel[0] += diff * accX / rate
    player.vel[2] += diff * accZ / rate
    player.pos[0] += (time - diff/rate) * accX / rate + diff * velX / rate
    player.pos[1] += -0.5 * grav * time * time + velY * time
    player.pos[2] += (time - diff/rate) * accZ / rate + diff * velZ / rate
    let
      scale = MAP_BOX_SCALE.float64
      bound = scale - player.radius
      posX = SDL_max(SDL_min(bound, player.pos[0]), -bound)
      posY = SDL_max(SDL_min(bound, player.pos[1]), player.height - scale)
      posZ = SDL_max(SDL_min(bound, player.pos[2]), -bound)
    if player.pos[0] != posX:  player.vel[0] = 0
    if player.pos[1] != posY:  player.vel[1] = if (wasd & 16) != 0:  8.4375  else:  0
    if player.pos[2] != posZ:  player.vel[2] = 0
    player.pos[0] = posX
    player.pos[1] = posY
    player.pos[2] = posZ


proc drawCircle(renderer: SDL_Renderer, r,x,y: float32) =
  var points = default array[CIRCLE_DRAW_SIDES_LEN, SDL_FPoint]
  for i in 0..<CIRCLE_DRAW_SIDES_LEN:
    let ang = 2.0f * SDL_PI_F * i.float32 / CIRCLE_DRAW_SIDES
    points[i].x = x + r * SDL_cosf(ang)
    points[i].y = y + r * SDL_sinf(ang)
  SDL_RenderLines(renderer, points)


proc drawClippedSegment(renderer: SDL_Renderer, ax,ay,az, bx,by,bz, x,y,z,w: float32) =
  if az >= -w and bz >= -w:
    return

  # Make mutable copies of these parameters.
  var
    ax = ax
    ay = ay
    az = az
    bx = bx
    by = by
    bz = bz

  let
    dx = ax - bx
    dy = ay - by

  if az > -w:
    let t = (-w - bz) / (az - bz)
    ax = bx + dx * t
    ay = by + dy * t
    az = -w
  elif bz > -w:
    let t = (-w - az) / (bz - az)
    bx = ax - dx * t
    by = ay - dy * t
    bz = -w

  ax = -z * ax / az
  ay = -z * ay / az
  bx = -z * bx / bz
  by = -z * by / bz

  SDL_RenderLine(renderer, x + ax, y - ay, x + bx, y - by)

var debug_string: string

proc draw(renderer: SDL_Renderer, edges: openarray[array[6, float32]], players: openarray[Player]) =
  var w: cint = 0
  var h: cint = 0
  if not SDL_GetRenderOutputSize(renderer, w, h):
    return

  SDL_SetRenderDrawColor(renderer, 0, 0, 0, SDL_ALPHA_OPAQUE)
  SDL_RenderClear(renderer)

  if players.len > 0:
    let
      wf = w.float32
      hf = h.float32
      part_hor: int = if players.len > 2:  2  else:  1
      part_ver: int = if players.len > 1:  2  else:  1
      size_hor = wf / part_hor.float32
      size_ver = hf / part_ver.float32
    for i in 0..<players.len:
      var player = players[i].addr
      let
        mod_x = (i mod part_hor).float32
        mod_y = (i div part_hor).float32
        hor_origin = (mod_x + 0.5f) * size_hor
        ver_origin = (mod_y + 0.5f) * size_ver
        cam_origin = (float32)(0.5 * SDL_sqrt(size_hor * size_hor + size_ver * size_ver))
        hor_offset = mod_x * size_hor
        ver_offset = mod_y * size_ver
      var rect = SDL_Rect(
        x: hor_offset.cint,
        y: ver_offset.cint,
        w: size_hor.cint,
        h: size_ver.cint,
      )
      SDL_SetRenderClipRect(renderer, rect)
      let
        x0: float64 = player.pos[0]
        y0: float64 = player.pos[1]
        z0: float64 = player.pos[2]
        bin_rad: float64 = SDL_PI_D / 2147483648.0
        yaw_rad: float64   = bin_rad * player.yaw.float32
        pitch_rad: float64 = bin_rad * player.pitch.float32
        cos_yaw: float64   = SDL_cos(  yaw_rad)
        sin_yaw: float64   = SDL_sin(  yaw_rad)
        cos_pitch: float64 = SDL_cos(pitch_rad)
        sin_pitch: float64 = SDL_sin(pitch_rad)
        mat: array[9, float64] = [
          cos_yaw          ,          0, -sin_yaw          ,
          sin_yaw*sin_pitch,  cos_pitch,  cos_yaw*sin_pitch,
          sin_yaw*cos_pitch, -sin_pitch,  cos_yaw*cos_pitch
        ]
      SDL_SetRenderDrawColor(renderer, 64, 64, 64, 255)
      for k in 0..<MAP_BOX_EDGES_LEN:
        let
          line = edges[k]
          ax = mat[0] * (line[0] - x0) + mat[1] * (line[1] - y0) + mat[2] * (line[2] - z0)
          ay = mat[3] * (line[0] - x0) + mat[4] * (line[1] - y0) + mat[5] * (line[2] - z0)
          az = mat[6] * (line[0] - x0) + mat[7] * (line[1] - y0) + mat[8] * (line[2] - z0)
          bx = mat[0] * (line[3] - x0) + mat[1] * (line[4] - y0) + mat[2] * (line[5] - z0)
          by = mat[3] * (line[3] - x0) + mat[4] * (line[4] - y0) + mat[5] * (line[5] - z0)
          bz = mat[6] * (line[3] - x0) + mat[7] * (line[4] - y0) + mat[8] * (line[5] - z0)
        drawClippedSegment(renderer, ax, ay, az, bx, by, bz, hor_origin, ver_origin, cam_origin, 1)
      for j in 0..<players.len:
        if i == j:
          continue
        let target = players[j].addr
        SDL_SetRenderDrawColor(renderer, target.color[0], target.color[1], target.color[2], 255)
        for k in 0..<2:
          let
            rx: float64 = target.pos[0] - player.pos[0]
            ry: float64 = target.pos[1] - player.pos[1] + (target.radius - target.height) * (float32)k
            rz: float64 = target.pos[2] - player.pos[2]
            dx: float64 = mat[0] * rx + mat[1] * ry + mat[2] * rz
            dy: float64 = mat[3] * rx + mat[4] * ry + mat[5] * rz
            dz: float64 = mat[6] * rx + mat[7] * ry + mat[8] * rz
            r_eff: float64 = target.radius * cam_origin / dz
          if not (dz < 0):
            continue
          drawCircle(renderer, (float32)(r_eff), (float32)(hor_origin - cam_origin*dx/dz), (float32)(ver_origin + cam_origin*dy/dz))
      SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255)
      SDL_RenderLine(renderer, hor_origin, ver_origin-10, hor_origin, ver_origin+10)
      SDL_RenderLine(renderer, hor_origin-10, ver_origin, hor_origin+10, ver_origin)

  SDL_SetRenderClipRect(renderer, nil)
  SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255)
  SDL_RenderDebugText(renderer, 0, 0, debug_string.cstring)
  SDL_RenderPresent(renderer)


proc initPlayers(players: var openarray[Player]) =
    for i in 0..<players.len:
      players[i].pos[0] = 8.0 *
        (if (i & 1) != 0: -1.0 else: 1.0)
      players[i].pos[1] = 0
      players[i].pos[2] = 8.0 *
        (if (i & 1) != 0: -1.0 else: 1.0) *
        (if (i & 2) != 0: -1.0 else: 1.0)
      players[i].vel[0] = 0
      players[i].vel[1] = 0
      players[i].vel[2] = 0
      players[i].yaw = 0x20000000 +
        (if (i & 1) != 0: 0x80000000 else: 0) +
        (if (i & 2) != 0: 0x40000000 else: 0)
      players[i].pitch = -0x08000000
      players[i].radius = 0.5f
      players[i].height = 1.5f
      players[i].wasd = 0
      players[i].mouse = 0
      players[i].keyboard = 0
      players[i].color[0] = if ((1 shl (i div 2)) & 2) != 0: 0 else: 0xff
      players[i].color[1] = if ((1 shl (i div 2)) & 1) != 0: 0 else: 0xff
      players[i].color[2] = if ((1 shl (i div 2)) & 4) != 0: 0 else: 0xff
      players[i].color[0] = if (i & 1) != 0: players[i].color[0] else: ~players[i].color[0]
      players[i].color[1] = if (i & 1) != 0: players[i].color[1] else: ~players[i].color[1]
      players[i].color[2] = if (i & 1) != 0: players[i].color[2] else: ~players[i].color[2]


proc initEdges(scale: int, edges: var openarray[array[6, float32]]) =
  const map: array[24, int] = [
    0,1 , 1,3 , 3,2 , 2,0 ,
    7,6 , 6,4 , 4,5 , 5,7 ,
    6,2 , 3,7 , 0,4 , 5,1
  ]
  let r = scale.float32
  for i in 0..<12:
    for j in 0..<3:
      edges[i][j+0] = if (map[i*2+0] & (1 shl j)) != 0: r else: -r
      edges[i][j+3] = if (map[i*2+1] & (1 shl j)) != 0: r else: -r
  for i in 0..<scale:
    let d = (i * 2).float32
    for j in 0..<2:
      edges[i+12][3*j+0]       = if j != 0: r else: -r
      edges[i+12][3*j+1]       =  -r
      edges[i+12][3*j+2]       = d-r
      edges[i+12+scale][3*j+0] = d-r
      edges[i+12+scale][3*j+1] =  -r
      edges[i+12+scale][3*j+2] = if j != 0: r else: -r


# -----------------------------------------------------------------------------
# Initialization
# -----------------------------------------------------------------------------

if not SDL_SetAppMetadata("Example splitscreen shooter game", "1.0", "com.example.woodeneye-008"):
  echo "Can't set metadata: ", SDL_GetError()
  quit(QuitFailure)

const extendedMetadata = [
  ( SDL_PROP_APP_METADATA_URL_STRING,       cstring "https://examples.libsdl.org/SDL3/demo/02-woodeneye-008/" ),
  ( SDL_PROP_APP_METADATA_CREATOR_STRING,   cstring "SDL team" ),
  ( SDL_PROP_APP_METADATA_COPYRIGHT_STRING, cstring "Placed in the public domain" ),
  ( SDL_PROP_APP_METADATA_TYPE_STRING,      cstring "game" ),
]
for (key, value) in extendedMetadata:
  if not SDL_SetAppMetadataProperty(key, value):
    echo "Can't set metadata property - key: ", key, " value: ", value
    quit(QuitFailure)

if not SDL_Init(SDL_INIT_VIDEO):
  echo "Can't init SDL: ", SDL_GetError()
  quit(QuitFailure)

var app: AppState

if not SDL_CreateWindowAndRenderer("examples/demo/woodeneye-008", 640, 480, 0, app.window, app.renderer):
  echo "Can't create window & renderer: ", SDL_GetError()
  quit(QuitFailure)

app.player_count = 1
initPlayers(app.players)
initEdges(MAP_BOX_SCALE, app.edges)

SDL_SetRenderVSync(app.renderer, 0)
SDL_SetWindowRelativeMouseMode(app.window, true)
SDL_SetHintWithPriority(SDL_HINT_WINDOWS_RAW_KEYBOARD, "1", SDL_HINT_OVERRIDE)

proc handleEvent(app: var AppState, event: SDL_Event) =
  var players = app.players.addr
  let player_count = app.player_count
  case (event.type):
    of SDL_EVENT_QUIT:
      app.quit = true
    of SDL_EVENT_MOUSE_REMOVED:
      for i in 0..<player_count:
        if players[i].mouse == event.mdevice.which:
          players[i].mouse = 0
    of SDL_EVENT_KEYBOARD_REMOVED:
      for i in 0..<player_count:
        if players[i].keyboard == event.kdevice.which:
          players[i].keyboard = 0
    of SDL_EVENT_MOUSE_MOTION:
      let
        id: SDL_MouseID = event.motion.which
        index = whoseMouse(id, players[])
      if index >= 0:
        players[index].yaw -= (event.motion.xrel * 0x00080000).int
        players[index].pitch = SDL_max(
          -0x40000000,
          SDL_min(
            0x40000000,
            players[index].pitch - ((int)event.motion.yrel) * 0x00080000
          )
        )
      elif id != 0:
        for i in 0..<MAX_PLAYER_COUNT:
          if players[i].mouse == 0:
            players[i].mouse = id
            app.player_count = SDL_max(app.player_count, i + 1)
            break
    of SDL_EVENT_MOUSE_BUTTON_DOWN:
      let
        id: SDL_MouseID = event.button.which
        index = whoseMouse(id, players[])
      if index >= 0:
        shoot(index, players[])
    of SDL_EVENT_KEY_DOWN:
      let
        sym: SDL_KeyCode = event.key.key
        id: SDL_KeyboardID = event.key.which
        index = whoseKeyboard(id, players[])
      if index >= 0:
        case sym
        of SDLK_W:      players[index].wasd |= 1
        of SDLK_A:      players[index].wasd |= 2
        of SDLK_S:      players[index].wasd |= 4
        of SDLK_D:      players[index].wasd |= 8
        of SDLK_SPACE:  players[index].wasd |= 16
        else:           discard
      elif id != 0:
        for i in 0..<MAX_PLAYER_COUNT:
          if players[i].keyboard == 0:
            players[i].keyboard = id
            app.player_count = SDL_max(app.player_count, i + 1)
            break
    of SDL_EVENT_KEY_UP:
      let
        sym: SDL_Keycode = event.key.key
        id: SDL_KeyboardID = event.key.which
      if sym == SDLK_ESCAPE:
        app.quit = true
      let index = whoseKeyboard(id, players[])
      if index >= 0:
        case sym
        of SDLK_W:      players[index].wasd &= 30'u8
        of SDLK_A:      players[index].wasd &= 29'u8
        of SDLK_S:      players[index].wasd &= 27'u8
        of SDLK_D:      players[index].wasd &= 23'u8
        of SDLK_SPACE:  players[index].wasd &= 15'u8
        else:           discard
    else:
      discard


# -----------------------------------------------------------------------------
# Main Loop
# -----------------------------------------------------------------------------

while not app.quit:

  # Since we can't use the callbacks, we check for incoming events here.
  var event: SDL_Event
  while SDL_PollEvent(event):
    app.handleEvent(event)

  # Game update.
  var
    accu {.global.}: uint64 = 0
    last {.global.}: uint64 = 0
    past {.global.}: uint64 = 0

  let
    now = SDL_GetTicksNS()
    dt_ns = now - past

  update(app.players, dt_ns)
  draw(app.renderer, app.edges, app.players)

  if now - last > 999999999:
    last = now
    debug_string = &"{accu} fps"
    accu = 0

  past = now
  inc accu

  let elapsed = SDL_GetTicksNS() - now
  if elapsed < 999999:
    SDL_DelayNS(999999 - elapsed)


#------------------------------------------------------------------------------
# Shutdown
#------------------------------------------------------------------------------

SDL_DestroyRenderer(app.renderer)
SDL_DestroyWindow(app.window)
SDL_Quit()
