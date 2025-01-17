# SDL3 for Nim

This package contains SDL3 bindings for Nim.


# Pre-Requisites

You must install the SDL3 C libraries on your system to use the Nim bindings.
I would recommend building SDL3 from source at this time, particularly on macOS.

Currently, this package is written against the `preview-3.1.8` release of SDL3,
which you can find here:

- [https://github.com/libsdl-org/SDL/releases/tag/preview-3.1.8](https://github.com/libsdl-org/SDL/releases/tag/preview-3.1.8)

Installation instructions for SDL3 can be found here:

- [https://github.com/libsdl-org/SDL/blob/main/INSTALL.md](https://github.com/libsdl-org/SDL/blob/main/INSTALL.md)


# Installation

Add `requires "sdl3"` to your .nimble file if that's how you do things!

You can also install manually with `nimble install sdl3` if you merely want the latest version.

And if you're like me, you can just copy sdl3.nim into your project!

If you require bindings for a specific version of SDL3, or a specfic version of
Nim, there may be a Release for it in this repository. If there isn't one, feel
free to open an issue, submit a PR, or otherwise reach out to me about it.


# Compatibility

This library is written against Nim 2.3.1 devel, and you may encounter issues
with other versions of the language. I will try to make releases compatible with
Nim stable and any other requested language versions soon.

I've tried to make this binding faithful to the C library to keep porting code
and following the official SDL3 documentation simpler, with as few departures as
possible. The only renamed symbols are haptic effect types, because in Nim their
names collide with their corresponding object types.

Here are the renamed symbols:

```nim
SDL_HAPTIC_EFFECT_INVALID       <-- *** ADDED ***
SDL_HAPTIC_EFFECT_CONSTANT      <-- SDL_HAPTIC_CONSTANT
SDL_HAPTIC_EFFECT_SINE          <-- SDL_HAPTIC_SINE
SDL_HAPTIC_EFFECT_SQUARE        <-- SDL_HAPTIC_SQUARE
SDL_HAPTIC_EFFECT_TRIANGLE      <-- SDL_HAPTIC_TRIANGLE
SDL_HAPTIC_EFFECT_SAWTOOTHUP    <-- SDL_HAPTIC_SAWTOOTHUP
SDL_HAPTIC_EFFECT_SAWTOOTHDOWN  <-- SDL_HAPTIC_SAWTOOTHDOWN
SDL_HAPTIC_EFFECT_RAMP          <-- SDL_HAPTIC_RAMP
SDL_HAPTIC_EFFECT_SPRING        <-- SDL_HAPTIC_SPRING
SDL_HAPTIC_EFFECT_DAMPER        <-- SDL_HAPTIC_DAMPER
SDL_HAPTIC_EFFECT_INERTIA       <-- SDL_HAPTIC_INERTIA
SDL_HAPTIC_EFFECT_FRICTION      <-- SDL_HAPTIC_FRICTION
SDL_HAPTIC_EFFECT_LEFTRIGHT     <-- SDL_HAPTIC_LEFTRIGHT
SDL_HAPTIC_EFFECT_RESERVED1     <-- SDL_HAPTIC_RESERVED1
SDL_HAPTIC_EFFECT_RESERVED2     <-- SDL_HAPTIC_RESERVED2
SDL_HAPTIC_EFFECT_RESERVED3     <-- SDL_HAPTIC_RESERVED3
SDL_HAPTIC_EFFECT_CUSTOM        <-- SDL_HAPTIC_CUSTOM
SDL_HAPTIC_EFFECT_GAIN          <-- SDL_HAPTIC_GAIN
SDL_HAPTIC_EFFECT_AUTOCENTER    <-- SDL_HAPTIC_AUTOCENTER
SDL_HAPTIC_EFFECT_STATUS        <-- SDL_HAPTIC_STATUS
SDL_HAPTIC_EFFECT_PAUSE         <-- SDL_HAPTIC_PAUSE
```

# Problems

If anything is busted or _seems_ busted, or has poor ergonomics for you, please
open an issue. I've tried to bind basically everything from SDL3's core API here,
eschewing only some string lib functions and macros, but if something is missing
and you need it, please reach out.


# To-do

- [ ] Test on Windows and Fedora and make sure our library includes are correct.
- [ ] Go implement all the `SDL_FORCE_INLINE` rect utility funcs.
- [ ] Put the examples in and add some instructions for those.
- [ ] Make bindings for SDL3 image, mixer, ttf, etc. and add them here (in separate files).
- [ ] Make a "documented" option with _all_ the copious doc comments from the
      SDL3 headers, for those hoping to explore SDL for the first time with Nim.
      I have neglected this so far because it _dramatically_ increases the file
      size.
- [ ] Publish a release for [SDL preview-3.1.8](https://github.com/libsdl-org/SDL/releases/tag/preview-3.1.8)
- [ ] Update and make a release for SDL [prerelease-3.1.10](https://github.com/libsdl-org/SDL/releases/tag/prerelease-3.1.10)
- [ ] Make sure we're fine on Nim stable and also that the _examples_ are.