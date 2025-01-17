# This example creates an SDL window and renderer, and then draws some
# geometry (arbitrary polygons) to it every frame.
#
# This code is public domain. Feel free to use it for any purpose!

#define SDL_MAIN_USE_CALLBACKS 1  # use the callbacks instead of main()
#include <SDL3/SDL.h>
#include <SDL3/SDL_main.h>

import std/os
import ../../../src/sdl3

# We will use this renderer to draw into this window every frame.
var
  window: SDL_Window
  renderer: SDL_Renderer
  texture: SDL_Texture
  textureWidth: int
  textureHeight: int
  quit: bool

const WINDOW_WIDTH = 640
const WINDOW_HEIGHT = 480

discard SDL_SetAppMetadata("Example Renderer Geometry", "1.0", "com.example.renderer-geometry")

if not SDL_Init(SDL_INIT_VIDEO):
  echo "Couldn't initialize SDL: ", SDL_GetError()
  quit(QuitFailure)

if not SDL_CreateWindowAndRenderer("examples/renderer/geometry", WINDOW_WIDTH, WINDOW_HEIGHT, 0, window, renderer):
  echo "Couldn't create window/renderer: ", SDL_GetError()
  quit(QuitFailure)

block:
  # Textures are pixel data that we upload to the video hardware for fast drawing. Lots of 2D
  # engines refer to these as "sprites." We'll do a static texture (upload once, draw many
  # times) with data from a bitmap file.

  # SDL_Surface is pixel data the CPU can access. SDL_Texture is pixel data the GPU can access.
  # Load a .bmp into a surface, move it to a texture from there.
  let
    path = os.getCurrentDir() & "/test/sample.bmp"
    surface = SDL_LoadBMP(cstring path)
  if surface == nil:
    echo "Couldn't load bitmap: ", SDL_GetError()
    quit(QuitFailure)

  textureWidth = surface.w
  textureHeight = surface.h

  texture = SDL_CreateTextureFromSurface(renderer, surface)
  if texture == nil:
    echo "Couldn't create static texture: ", SDL_GetError()
    quit(QuitFailure)

  SDL_DestroySurface(surface)  # done with this, the texture has a copy of the pixels now.


# Main loop.
while not quit:
  var event: SDL_Event
  while SDL_PollEvent(event):
    if event.type == SDL_EVENT_QUIT:
      quit = true

  let now = SDL_GetTicks()

  # we'll have the triangle grow and shrink over a few seconds.
  let
    direction = if ((now mod 2000) >= 1000): 1.0 else: -1.0
    scale = ((float) (((int) (now mod 1000)) - 500) / 500) * direction
    size = 200 + (200 * scale)

  var vertices: array[4, SDL_Vertex]

  # as you can see from this, rendering draws over whatever was drawn before it.
  SDL_SetRenderDrawColor(renderer, 0, 0, 0, SDL_ALPHA_OPAQUE)  # black, full alpha
  SDL_RenderClear(renderer)  # start with a blank canvas.

  # Draw a single triangle with a different color at each vertex. Center this one and make it grow and shrink.
  # You always draw triangles with this, but you can string triangles together to form polygons.
  vertices[0].position.x = ((float) WINDOW_WIDTH) / 2.0
  vertices[0].position.y = (((float) WINDOW_HEIGHT) - size) / 2.0
  vertices[0].color.r = 1.0
  vertices[0].color.a = 1.0
  vertices[1].position.x = (((float) WINDOW_WIDTH) + size) / 2.0
  vertices[1].position.y = (((float) WINDOW_HEIGHT) + size) / 2.0
  vertices[1].color.g = 1.0
  vertices[1].color.a = 1.0
  vertices[2].position.x = (((float) WINDOW_WIDTH) - size) / 2.0
  vertices[2].position.y = (((float) WINDOW_HEIGHT) + size) / 2.0
  vertices[2].color.b = 1.0
  vertices[2].color.a = 1.0

  SDL_RenderGeometry(renderer, nil, addr vertices[0], 3, nil, 0)

  # you can also map a texture to the geometry! Texture coordinates go from 0.0 to 1.0. That will be the location
  # in the texture bound to this vertex.
  vertices.reset()
  vertices[0].position.x = 10.0
  vertices[0].position.y = 10.0
  vertices[0].color = SDL_FColor( r: 1, g: 1, b: 1, a: 1 )
  vertices[0].tex_coord.x = 0.0
  vertices[0].tex_coord.y = 0.0
  vertices[1].position.x = 150.0
  vertices[1].position.y = 10.0
  vertices[1].color = SDL_FColor( r: 1, g: 1, b: 1, a: 1 )
  vertices[1].tex_coord.x = 1.0
  vertices[1].tex_coord.y = 0.0
  vertices[2].position.x = 10.0
  vertices[2].position.y = 150.0
  vertices[2].color = SDL_FColor( r: 1, g: 1, b: 1, a: 1 )
  vertices[2].tex_coord.x = 0.0
  vertices[2].tex_coord.y = 1.0
  SDL_RenderGeometry(renderer, texture, addr vertices[0], 3, nil, 0)

  # Did that only draw half of the texture? You can do multiple triangles sharing some vertices,
  # using indices, to get the whole thing on the screen:

  # Let's just move this over so it doesn't overlap...
  for i in 0..<3:
    vertices[i].position.x += 450

  # we need one more vertex, since the two triangles can share two of them.
  vertices[3].position.x = 600.0
  vertices[3].position.y = 150.0
  vertices[3].color = SDL_FColor( r: 1, g: 1, b: 1, a: 1 )
  vertices[3].tex_coord.x = 1.0
  vertices[3].tex_coord.y = 1.0

  # And an index to tell it to reuse some of the vertices between triangles...
  block:
    # 4 vertices, but 6 actual places they are used. Indices need less bandwidth to
    # transfer and can reorder vertices easily!
    const indices: array[6, cint] = [ 0, 1, 2, 1, 2, 3 ]
    SDL_RenderGeometry(renderer, texture, vertices, indices)

    # NOTE: You could also manually specify the array lengths, like this:
    # SDL_RenderGeometry(renderer, texture, vertices[0].addr, 4, indices[0].addr, indices.len)

  SDL_RenderPresent(renderer)  # put it all on the screen!


SDL_Quit()
