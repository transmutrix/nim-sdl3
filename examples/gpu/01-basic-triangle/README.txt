Render a basic triangle using the new SDL GPU API.

I left as much documentation within the code as I could to help make
the learning process as easy as possible. Check out the offical docs,
it's very straightforward: https://wiki.libsdl.org/SDL3/CategoryGPU

This should work on Windows (tested) and Linux (untested) without any
modifications due to Vulkan support on both OSs.

IMPORTANT:

With this example, you must have Vulkan SDK installed
(https://vulkan.lunarg.com/). It's an easy process and will add the
glslc compiler to your path, which will allow the translation of glsl
shaders (OpenGL) to sir-v, the binary shader format for Vulkan.

IMPORTANT:

If you're using Mac, you'll need to build and install SDL_Shadercross.
Then you'll want to use the Shadercross CLI to translate the spir-v shaders
into metal and update the appropriate code in triangle.nim.

NOTE:

You don't HAVE to translate the shaders from glsl to spir-v, you can
write spir-v directly, but it's much easier (IMO) to write glsl and convert.
Finding glsl shaders to do things is more plentiful than spir-v. Also, you don't
even have to use Vulkan if you're on Windows. You can convert the spir-v into
the appropriate native Windows shader format and simply update the code inside
triangle.nim for the appropriate Windows graphics backend. Directx11 I think?

Enjoy.