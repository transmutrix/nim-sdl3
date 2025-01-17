
{.hint[Name]: off.}

# NOTE: Opaque pointer types like SDL_Texture are defined as `pointer`, since
#  these are never, ever dereferenced. This lowers syntax noise.

# import std/macros
import std/strutils
export strutils.`%`

{.push warning[user]: off}
when defined(windows):
  const LibName* = "SDL3.dll"
elif defined(macosx):
  const LibName* = "libSDL3.dylib"
# elif defined(openbsd):
#   const LibName* = "libSDL3.so.0.6"
# elif defined(haiku):
#   const LibName* = "libSDL3-2.0.so.0"
elif defined(emscripten):
  const LibName* = "libSDL3.so"
else:
  const LibName* = "libSDL3.so"
{.pop.}

when defined(emscripten):
  {.push callConv: cdecl.}
else:
  {.push callConv: cdecl, dynlib: LibName.}

# Extra C types needed by some functions.
type cva_list* {.importc: "va_list", header: "<stdarg.h>".} = object
type cwchar_t {.importc: "wchar_t", header: "<wchar.h>".} = object


#region SDL3/SDL_revision.h ----------------------------------------------------

const SDL_REVISION* = "SDL3-3.1.8-HEAD-HASH-NOTFOUND"

#endregion


#region SDL3/SDL_version.h ----------------------------------------------------

const SDL_MAJOR_VERSION* =    3
const SDL_MINOR_VERSION* =    1
const SDL_MICRO_VERSION* =    8
template SDL_VERSIONNUM* (major, minor, patch): int = ((major)*1000000 + (minor)*1000 + (patch))
template SDL_VERSIONNUM_MAJOR* (version): int = ((version) / 1000000)
template SDL_VERSIONNUM_MINOR* (version): int = (((version) / 1000) mod 1000)
template SDL_VERSIONNUM_MICRO* (version): int = ((version) mod 1000)
const SDL_VERSION* =  SDL_VERSIONNUM(SDL_MAJOR_VERSION, SDL_MINOR_VERSION, SDL_MICRO_VERSION)
template SDL_VERSION_ATLEAST* (X, Y, Z): bool = SDL_VERSION >= SDL_VERSIONNUM(X, Y, Z)

proc SDL_GetVersion* (): int {.importc.}
proc SDL_GetRevision* (): cstring {.importc.}

#endregion


#region SDL3/SDL_stdinc.h -----------------------------------------------------

# NOTE: Some stuff is left out here, like text encodings, and string funcs.
#   If you would prefer that such things be in the binding, let me know!

proc SDL_malloc* (size: csize_t): pointer {.importc.}
proc SDL_calloc* ( nmemb, size: csize_t ): pointer {.importc.}
proc SDL_realloc* ( mem: pointer, size: csize_t ): pointer {.importc.}
proc SDL_free* ( mem: pointer ): void {.importc.}


type
  SDL_malloc_func* = proc (size: csize_t): pointer {.cdecl.}
  SDL_calloc_func* = proc (nmemb: csize_t; size: csize_t): pointer {.cdecl.}
  SDL_realloc_func* = proc (mem: pointer; size: csize_t): pointer {.cdecl.}
  SDL_free_func* = proc (mem: pointer) {.cdecl.}

proc SDL_GetOriginalMemoryFunctions* ( malloc_func: var SDL_malloc_func, calloc_func: var SDL_calloc_func, realloc_func: var SDL_realloc_func, free_func: var SDL_free_func ): void {.importc.}
proc SDL_GetMemoryFunctions* ( malloc_func: var SDL_malloc_func, calloc_func: var SDL_calloc_func, realloc_func: var SDL_realloc_func, free_func: var SDL_free_func ): void {.importc.}
proc SDL_SetMemoryFunctions* ( malloc_func: SDL_malloc_func, calloc_func: SDL_calloc_func, realloc_func: SDL_realloc_func, free_func: SDL_free_func ): bool {.importc.}

proc SDL_aligned_alloc* ( alignment: csize_t, size: csize_t ): pointer {.importc.}
proc SDL_aligned_free* ( mem: pointer ): void {.importc.}

proc SDL_GetNumAllocations* (): int {.importc.}

type
  SDL_Environment* = pointer

proc SDL_GetEnvironment* (): SDL_Environment {.importc.}
proc SDL_CreateEnvironment* ( populated: bool ): SDL_Environment {.importc.}
proc SDL_GetEnvironmentVariable* ( env: SDL_Environment, name: cstring ): cstring {.importc.}
proc SDL_GetEnvironmentVariables* ( env: SDL_Environment ): ptr UncheckedArray[cstring] {.importc.}
proc SDL_SetEnvironmentVariable* ( env: SDL_Environment, name,value: cstring, overwrite: bool ): bool {.importc.}
proc SDL_UnsetEnvironmentVariable* ( enc: SDL_Environment, name: cstring ): bool {.importc.}
proc SDL_DestroyEnvironment* ( env: SDL_Environment ): void {.importc.}

proc SDL_getenv* ( name: cstring ): string {.importc.}
proc SDL_getenv_unsafe* ( name: cstring ): cstring {.importc.}
proc SDL_setenv_unsafe* ( name,value: cstring, overwrite: int ): int {.importc.}
proc SDL_unsetenv_unsafe* ( name: cstring ): int {.importc.}

type
  SDL_CompareCallback* = proc (a,b: pointer): cint {.cdecl.}

proc SDL_qsort* ( base: pointer, nmemb,size: csize_t, compare: SDL_CompareCallback ): void {.importc.}
proc SDL_bsearch* ( key,base: pointer, nmemb, size: csize_t, compare: SDL_CompareCallback ): pointer {.importc.}

type
  SDL_CompareCallback_r* = proc (userdata, a, b: pointer): cint {.cdecl.}

proc SDL_qsort_r* ( base: pointer, nmemb,size: csize_t, compare: SDL_CompareCallback_r, userdata: pointer ): void {.importc.}
proc SDL_bsearch_r* ( key,base: pointer, nmemb,size: csize_t, comparE: SDL_CompareCallback_r, userdata: pointer): pointer {.importc.}

template SDL_min* (x, y): untyped = (if (x) < (y): (x) else: (y))
template SDL_max* (x, y): untyped = (if (x) > (y): (x) else: (y))
template SDL_clamp* (x, a, b): untyped = (if (x) < (a): (a) else: (if (x) > (b): (b) else: (x)))

proc SDL_isalpha* ( x: int ): bool {.importc.}
proc SDL_isalnum* ( x: int ): bool {.importc.}
proc SDL_isblank* ( x: int ): bool {.importc.}
proc SDL_iscntrl* ( x: int ): bool {.importc.}
proc SDL_isdigit* ( x: int ): bool {.importc.}
proc SDL_isxdigit* ( x: int ): bool {.importc.}
proc SDL_ispunct* ( x: int ): bool {.importc.}
proc SDL_isspace* ( x: int ): bool {.importc.}
proc SDL_isupper* ( x: int ): bool {.importc.}
proc SDL_islower* ( x: int ): bool {.importc.}
proc SDL_isprint* ( x: int ): bool {.importc.}
proc SDL_isgraph* ( x: int ): bool {.importc.}

proc SDL_toupper* ( x: int ): int {.importc.}
proc SDL_tolower* ( x: int ): int {.importc.}

proc SDL_crc16* ( crc: uint16, data: pointer, len: csize_t ): uint16 {.importc.}
proc SDL_crc32* ( crc: uint32, data: pointer, len: csize_t ): uint32 {.importc.}
proc SDL_murmur3_32* ( data: pointer, len: csize_t, seed: uint32 ): uint32 {.importc.}

proc SDL_srand* ( seed: uint64 ): void {.importc.}
proc SDL_rand* ( n: int32 ): int32 {.importc.}
proc SDL_randf* (): cfloat {.importc.}
proc SDL_rand_bits* (): uint32 {.importc.}

proc SDL_rand_r* ( state: var uint64, n: int32 ): int32 {.importc.}
proc SDL_randf_r* ( state: var uint64 ): cfloat {.importc.}
proc SDL_rand_bits_r* ( state: var uint64 ): uint32 {.importc.}

const SDL_PI_D* = 3.141592653589793238462643383279502884'f64  # pi (double)
const SDL_PI_F* = 3.141592653589793238462643383279502884'f32  # pi (float)

proc SDL_abs* ( x: int ): bool {.importc.}
proc SDL_acos* ( x: cdouble ): cdouble {.importc.}
proc SDL_acosf* ( x: cfloat ): cfloat {.importc.}
proc SDL_asin* ( x: cdouble ): cdouble {.importc.}
proc SDL_asinf* ( x: cfloat ): cfloat {.importc.}
proc SDL_atan* ( x: cdouble ): cdouble {.importc.}
proc SDL_atanf* ( x: cfloat ): cfloat {.importc.}
proc SDL_atan2* ( y,x: cdouble ): cdouble {.importc.}
proc SDL_atan2f* ( y,x: cfloat ): cfloat {.importc.}
proc SDL_ceil* ( x: cdouble ): cdouble {.importc.}
proc SDL_ceilf* ( x: cfloat ): cfloat {.importc.}
proc SDL_copysign* ( x: cdouble, y: cdouble ): cdouble {.importc.}
proc SDL_copysignf* ( x,y: cfloat ): cfloat {.importc.}
proc SDL_cos* ( x: cdouble ): cdouble {.importc.}
proc SDL_cosf* ( x: cfloat ): cfloat {.importc.}
proc SDL_exp* ( x: cdouble ): cdouble {.importc.}
proc SDL_expf* ( x: cfloat ): cfloat {.importc.}
proc SDL_fabs* ( x: cdouble ): cdouble {.importc.}
proc SDL_fabsf* ( x: cfloat ): cfloat {.importc.}
proc SDL_floor* ( x: cdouble ): cdouble {.importc.}
proc SDL_floorf* ( x: cfloat ): cfloat {.importc.}
proc SDL_trunc* ( x: cdouble ): cdouble {.importc.}
proc SDL_truncf* ( x: cfloat ): cfloat {.importc.}
proc SDL_fmod* ( x: cdouble, y: cdouble ): cdouble {.importc.}
proc SDL_fmodf* ( x,y: cfloat ): cfloat {.importc.}
proc SDL_isinf* ( x: cdouble ): int {.importc.}
proc SDL_isinff* ( x: cfloat ): int {.importc.}
proc SDL_isnan* ( x: cdouble ): int {.importc.}
proc SDL_isnanf* ( x: cfloat ): int {.importc.}
proc SDL_log* ( x: cdouble ): cdouble {.importc.}
proc SDL_logf* ( x: cfloat ): cfloat {.importc.}
proc SDL_log10* ( x: cdouble ): cdouble {.importc.}
proc SDL_log10f* ( x: cfloat ): cfloat {.importc.}
proc SDL_modf* ( x: cdouble, y: var cdouble ): cdouble {.importc.}
proc SDL_modff* ( x: cfloat, y: var cfloat ): cfloat {.importc.}
proc SDL_pow* ( x: cdouble, y: cdouble ): cdouble {.importc.}
proc SDL_powf* ( x,y: cfloat ): cfloat {.importc.}
proc SDL_round* ( x: cdouble ): cdouble {.importc.}
proc SDL_roundf* ( x: cfloat ): cfloat {.importc.}
proc SDL_lround* ( x: cdouble ): clong {.importc.}
proc SDL_lroundf* ( x: cfloat ): clong {.importc.}
proc SDL_scalbn* ( x: cdouble, n: int ): cdouble {.importc.}
proc SDL_scalbnf* ( x: cfloat, n: int ): cfloat {.importc.}
proc SDL_sin* ( x: cdouble ): cdouble {.importc.}
proc SDL_sinf* ( x: cfloat ): cfloat {.importc.}
proc SDL_sqrt* ( x: cdouble ): cdouble {.importc.}
proc SDL_sqrtf* ( x: cfloat ): cfloat {.importc.}
proc SDL_tan* ( x: cdouble ): cdouble {.importc.}
proc SDL_tanf* ( x: cfloat ): cfloat {.importc.}

type SDL_FunctionPointer* = proc (): void {.cdecl.}

#endregion


#region SDL3/SDL_assert.h -----------------------------------------------------

#endregion


#region SDL3/SDL_asyncio.h ----------------------------------------------------

type
  SDL_AsyncIO* = pointer
  SDL_AsyncIOQueue* = pointer
  SDL_AsyncIOTaskType* {.size: sizeof(cint).} = enum
    SDL_ASYNCIO_TASK_READ, SDL_ASYNCIO_TASK_WRITE, SDL_ASYNCIO_TASK_CLOSE
  SDL_AsyncIOResult* {.size: sizeof(cint).} = enum
    SDL_ASYNCIO_COMPLETE, SDL_ASYNCIO_FAILURE, SDL_ASYNCIO_CANCELED
  SDL_AsyncIOOutcome* {.bycopy.} = object
    asyncio*: ptr SDL_AsyncIO
    `type`*: SDL_AsyncIOTaskType
    result*: SDL_AsyncIOResult
    buffer*: pointer
    offset*: uint64
    bytes_requested*: uint64
    bytes_transferred*: uint64
    userdata*: pointer

proc SDL_AsyncIOFromFile* ( file,mode: cstring): SDL_AsyncIO {.importc.}
proc SDL_GetAsyncIOSize* ( asyncio: SDL_AsyncIO ): int64 {.importc.}
proc SDL_ReadAsyncIO* ( asyncio: SDL_AsyncIO, p: pointer, offset,size: uint64, queue: SDL_AsyncIOQueue, userdata: pointer ): bool {.importc.}
proc SDL_WriteAsyncIO* ( asyncio: SDL_AsyncIO, p: pointer, offset,size: uint64, queue: SDL_AsyncIOQueue, userdata: pointer ): bool {.importc.}
proc SDL_CloseAsyncIO* ( asyncio: SDL_AsyncIO, flush: bool, queue: SDL_AsyncIOQueue, userdata: pointer ): bool {.importc.}
proc SDL_CreateAsyncIOQueue* (): SDL_AsyncIOQueue {.importc.}
proc SDL_DestroyAsyncIOQueue* ( queue: SDL_AsyncIOQueue ): void {.importc.}
proc SDL_GetAsyncIOResult* ( queue: SDL_AsyncIOQueue, outcome: var SDL_AsyncIOOutcome ): bool {.importc.}
proc SDL_WaitAsyncIOResult* ( queue: SDL_AsyncIOQueue, outcome: var SDL_AsyncIOOutcome, timeoutMS: int32 ): bool {.importc.}
proc SDL_SignalAsyncIOQueue* ( queue: SDL_AsyncIOQueue ): void {.importc.}
proc SDL_LoadFileAsync* ( file: cstring, queue: SDL_AsyncIOQueue, userdata: pointer ): bool {.importc.}

#endregion


#region SDL3/SDL_atomic.h -----------------------------------------------------

type SDL_SpinLock* = cint

proc SDL_TryLockSpinlock* ( lock: var SDL_SpinLock ): bool {.importc.}
proc SDL_LockSpinlock* ( lock: var SDL_SpinLock ): void {.importc.}
proc SDL_UnlockSpinlock* ( lock: var SDL_SpinLock ): void {.importc.}
proc SDL_MemoryBarrierReleaseFunction* (): void {.importc.}
proc SDL_MemoryBarrierAcquireFunction* (): void {.importc.}

type SDL_AtomicInt* {.bycopy.} = object
  value*: cint

proc SDL_CompareAndSwapAtomicInt* ( a: var SDL_AtomicInt, oldval,newval: int ): bool {.importc.}
proc SDL_SetAtomicInt* ( a: var SDL_AtomicInt, v: int ): int {.importc.}
proc SDL_GetAtomicInt* ( a: var SDL_AtomicInt ): int {.importc.}
proc SDL_AddAtomicInt* ( a: var SDL_AtomicInt, v: int ): int {.importc.}

type SDL_AtomicU32* {.bycopy.} = object
  value*: uint32

proc SDL_CompareAndSwapAtomicU32* ( a: var SDL_AtomicU32, oldval,newval: uint32 ): bool {.importc.}
proc SDL_SetAtomicU32* ( a: var SDL_AtomicU32, v: uint32 ): uint32 {.importc.}
proc SDL_GetAtomicU32* ( a: var SDL_AtomicU32 ): uint32 {.importc.}

proc SDL_CompareAndSwapAtomicPointer* ( a: var pointer, oldval,newval: pointer ): bool {.importc.}
proc SDL_SetAtomicPointer* ( a: var pointer, v: pointer ): pointer {.importc.}
proc SDL_GetAtomicPointer* ( a: var pointer ): pointer {.importc.}

#endregion


#region SDL3/SDL_properties.h -------------------------------------------------

type
  SDL_PropertiesID* = uint32
  SDL_PropertyType* {.size: sizeof(cint).} = enum
    SDL_PROPERTY_TYPE_INVALID,
    SDL_PROPERTY_TYPE_POINTER,
    SDL_PROPERTY_TYPE_STRING,
    SDL_PROPERTY_TYPE_NUMBER,
    SDL_PROPERTY_TYPE_FLOAT,
    SDL_PROPERTY_TYPE_BOOLEAN

proc SDL_GetGlobalProperties* (): SDL_PropertiesID {.importc.}
proc SDL_CreateProperties* (): SDL_PropertiesID {.importc.}
proc SDL_CopyProperties* ( src,dst: SDL_PropertiesID ): bool {.importc.}
proc SDL_LockProperties* ( props: SDL_PropertiesID ): bool {.importc.}
proc SDL_UnlockProperties* ( props: SDL_PropertiesID ): void {.importc.}

type SDL_CleanupPropertyCallback* = proc (userdata: pointer; value: pointer) {.cdecl.}

proc SDL_SetPointerPropertyWithCleanup* ( props: SDL_PropertiesID, name: cstring, value: pointer, cleanup: SDL_CleanupPropertyCallback, userdata: pointer ): bool {.importc, discardable.}
proc SDL_SetPointerProperty* ( props: SDL_PropertiesID, name: cstring, value: pointer ): bool {.importc, discardable.}
proc SDL_SetStringProperty* ( props: SDL_PropertiesID, name,value: cstring ): bool {.importc, discardable.}
proc SDL_SetNumberProperty* ( props: SDL_PropertiesID, name: cstring, value: int64 ): bool {.importc, discardable.}
proc SDL_SetFloatProperty* ( props: SDL_PropertiesID, name: cstring, value: cfloat ): bool {.importc, discardable.}
proc SDL_SetBooleanProperty* ( props: SDL_PropertiesID, name: cstring, value: bool ): bool {.importc, discardable.}
proc SDL_HasProperty* ( props: SDL_PropertiesID, name: cstring ): bool {.importc.}
proc SDL_GetPropertyType* ( props: SDL_PropertiesID, name: cstring ): SDL_PropertyType {.importc.}
proc SDL_GetPointerProperty* ( props: SDL_PropertiesID, name: cstring, default_value: pointer ): pointer {.importc.}
proc SDL_GetStringProperty* ( props: SDL_PropertiesID, name: cstring, default_value: cstring ): cstring {.importc.}
proc SDL_GetNumberProperty* ( props: SDL_PropertiesID, name: cstring, default_value: int64 ): int64 {.importc.}
proc SDL_GetFloatProperty* ( props: SDL_PropertiesID, name: cstring, default_value: cfloat ): cfloat {.importc.}
proc SDL_GetBooleanProperty* ( props: SDL_PropertiesID, name: cstring, default_value: bool ): bool {.importc.}
proc SDL_ClearProperty* ( props: SDL_PropertiesID, name: cstring ): bool {.importc, discardable.}

type SDL_EnumeratePropertiesCallback* = proc (userdata: pointer;
  props: SDL_PropertiesID; name: cstring) {.cdecl.}

proc SDL_EnumerateProperties* ( props: SDL_PropertiesID, callback: SDL_EnumeratePropertiesCallback, userdata: pointer ): bool {.importc.}
proc SDL_DestroyProperties* ( props: SDL_PropertiesID): void {.importc.}

#endregion


#region SDL3/SDL_iostream.h ---------------------------------------------------

type
  SDL_IOStatus* {.size: sizeof(cint).} = enum
    SDL_IO_STATUS_READY,
    SDL_IO_STATUS_ERROR,
    SDL_IO_STATUS_EOF,
    SDL_IO_STATUS_NOT_READY,
    SDL_IO_STATUS_READONLY,
    SDL_IO_STATUS_WRITEONLY

type
  SDL_IOWhence* {.size: sizeof(cint).} = enum
    SDL_IO_SEEK_SET,
    SDL_IO_SEEK_CUR,
    SDL_IO_SEEK_END

type
  SDL_IOStream* = pointer
  SDL_IOStreamInterface* {.bycopy.} = object
    version*: uint32
    size*: proc (userdata: pointer): int64 {.cdecl.}
    seek*: proc (userdata: pointer; offset: int64; whence: SDL_IOWhence): int64 {.
        cdecl.}
    read*: proc (userdata: pointer; `ptr`: pointer; size: csize_t;
               status: ptr SDL_IOStatus): csize_t {.cdecl.}
    write*: proc (userdata: pointer; `ptr`: pointer; size: csize_t;
                status: ptr SDL_IOStatus): csize_t {.cdecl.}
    flush*: proc (userdata: pointer; status: ptr SDL_IOStatus): bool {.cdecl.}
    close*: proc (userdata: pointer): bool {.cdecl.}

proc SDL_IOFromFile* ( file,mode: cstring ): SDL_IOStream {.importc.}

const SDL_PROP_IOSTREAM_WINDOWS_HANDLE_POINTER* = "SDL.iostream.windows.handle"
const SDL_PROP_IOSTREAM_STDIO_FILE_POINTER*     = "SDL.iostream.stdio.file"
const SDL_PROP_IOSTREAM_FILE_DESCRIPTOR_NUMBER* = "SDL.iostream.file_descriptor"
const SDL_PROP_IOSTREAM_ANDROID_AASSET_POINTER* = "SDL.iostream.android.aasset"

proc SDL_IOFromMem* ( mem: pointer, size: csize_t ): SDL_IOStream {.importc.}

const SDL_PROP_IOSTREAM_MEMORY_POINTER*     = "SDL.iostream.memory.base"
const SDL_PROP_IOSTREAM_MEMORY_SIZE_NUMBER* = "SDL.iostream.memory.size"

proc SDL_IOFromConstMem* ( mem: pointer, size: csize_t ): SDL_IOStream {.importc.}
proc SDL_IOFromDynamicMem* (): SDL_IOStream {.importc.}

const SDL_PROP_IOSTREAM_DYNAMIC_MEMORY_POINTER*   = "SDL.iostream.dynamic.memory"
const SDL_PROP_IOSTREAM_DYNAMIC_CHUNKSIZE_NUMBER* = "SDL.iostream.dynamic.chunksize"

proc SDL_OpenIO* ( iface: ptr SDL_IOStreamInterface, userdata: pointer ): SDL_IOStream {.importc.}
proc SDL_CloseIO* ( context: SDL_IOStream ): bool {.importc, discardable.}
proc SDL_GetIOProperties* ( context: SDL_IOStream ): SDL_PropertiesID {.importc.}
proc SDL_GetIOStatus* ( context: SDL_IOStream ): SDL_IOStatus {.importc.}
proc SDL_GetIOSize* ( context: SDL_IOStream ): int64 {.importc.}
proc SDL_SeekIO* ( context: SDL_IOStream, offset: int64, whence: SDL_IOWhence ): int64 {.importc, discardable.}
proc SDL_TellIO* ( context: SDL_IOStream ): int64 {.importc.}
proc SDL_ReadIO* ( context: SDL_IOStream, p: pointer, size: csize_t ): csize_t {.importc.}
proc SDL_WriteIO* ( context: SDL_IOStream, p: pointer, size: csize_t ): csize_t {.importc.}

proc SDL_IOprintf* ( context: SDL_IOStream, fmt: cstring ): csize_t {.importc, varargs.}
proc SDL_IOvprintf* ( context: SDL_IOStream, fmt: cstring, ap: cva_list ): csize_t {.importc.}

proc SDL_FlushIO* ( context: SDL_IOStream ): bool {.importc.}
proc SDL_LoadFile_IO* ( src: SDL_IOStream, datasoze: var csize_t, closeio: bool ): pointer {.importc.}
proc SDL_LoadFile* ( file: cstring, datasize: var csize_t ): pointer {.importc.}
proc SDL_SaveFile_IO* ( src: SDL_IOStream, data: pointer, datasize: csize_t, closeio: bool ): bool {.importc.}
proc SDL_SaveFile* ( file: cstring, data: pointer, datasize: csize_t ): bool {.importc.}

proc SDL_ReadU8* ( src: SDL_IOStream, value: var uint8 ): bool {.importc.}
proc SDL_ReadS8* ( src: SDL_IOStream, value: var int8 ): bool {.importc.}
proc SDL_ReadU16LE* ( src: SDL_IOStream, value: var uint16 ): bool {.importc.}
proc SDL_ReadS16LE* ( src: SDL_IOStream, value: var int16 ): bool {.importc.}
proc SDL_ReadU16BE* ( src: SDL_IOStream, value: var uint16 ): bool {.importc.}
proc SDL_ReadS16BE* ( src: SDL_IOStream, value: var int16 ): bool {.importc.}
proc SDL_ReadU32LE* ( src: SDL_IOStream, value: var uint32 ): bool {.importc.}
proc SDL_ReadS32LE* ( src: SDL_IOStream, value: var int32 ): bool {.importc.}
proc SDL_ReadU32BE* ( src: SDL_IOStream, value: var uint32 ): bool {.importc.}
proc SDL_ReadS32BE* ( src: SDL_IOStream, value: var int32 ): bool {.importc.}
proc SDL_ReadU64LE* ( src: SDL_IOStream, value: var uint64 ): bool {.importc.}
proc SDL_ReadS64LE* ( src: SDL_IOStream, value: var int64 ): bool {.importc.}
proc SDL_ReadU64BE* ( src: SDL_IOStream, value: var uint64 ): bool {.importc.}
proc SDL_ReadS64BE* ( src: SDL_IOStream, value: var int64 ): bool {.importc.}

proc SDL_WriteU8* ( dst: SDL_IOStream, value: uint8 ): bool {.importc.}
proc SDL_WriteS8* ( dst: SDL_IOStream, value: int8 ): bool {.importc.}
proc SDL_WriteU16LE* ( dst: SDL_IOStream, value: uint16 ): bool {.importc.}
proc SDL_WriteS16LE* ( dst: SDL_IOStream, value: int16 ): bool {.importc.}
proc SDL_WriteU16BE* ( dst: SDL_IOStream, value: uint16 ): bool {.importc.}
proc SDL_WriteS16BE* ( dst: SDL_IOStream, value: int16 ): bool {.importc.}
proc SDL_WriteU32LE* ( dst: SDL_IOStream, value: uint32 ): bool {.importc.}
proc SDL_WriteS32LE* ( dst: SDL_IOStream, value: int32 ): bool {.importc.}
proc SDL_WriteU32BE* ( dst: SDL_IOStream, value: uint32 ): bool {.importc.}
proc SDL_WriteS32BE* ( dst: SDL_IOStream, value: int32 ): bool {.importc.}
proc SDL_WriteU64LE* ( dst: SDL_IOStream, value: uint64 ): bool {.importc.}
proc SDL_WriteS64LE* ( dst: SDL_IOStream, value: int64 ): bool {.importc.}
proc SDL_WriteU64BE* ( dst: SDL_IOStream, value: uint64 ): bool {.importc.}
proc SDL_WriteS64BE* ( dst: SDL_IOStream, value: int64 ): bool {.importc.}

#endregion


#region SDL3/SDL_audio.h ------------------------------------------------------

type
  SDL_AudioFormat* {.size: sizeof(cint).} = enum
    SDL_AUDIO_UNKNOWN = 0x0000, SDL_AUDIO_U8 = 0x0008, SDL_AUDIO_S8 = 0x8008,
    SDL_AUDIO_S16LE = 0x8010, SDL_AUDIO_S32LE = 0x8020, SDL_AUDIO_F32LE = 0x8120,
    SDL_AUDIO_S16BE = 0x9010, SDL_AUDIO_S32BE = 0x9020, SDL_AUDIO_F32BE = 0x9120

const
  SDL_AUDIO_S16* = SDL_AUDIO_S16LE
  SDL_AUDIO_S32* = SDL_AUDIO_S32LE
  SDL_AUDIO_F32* = SDL_AUDIO_F32LE

type
  SDL_AudioDeviceID* = uint32
  SDL_AudioSpec* {.bycopy.} = object
    format*: SDL_AudioFormat
    channels*: cint
    freq*: cint

const SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK* = 0xFFFFFFFF'u32.SDL_AudioDeviceID
const SDL_AUDIO_DEVICE_DEFAULT_RECORDING* = 0xFFFFFFFE'u32.SDL_AudioDeviceID

proc SDL_GetNumAudioDrivers* (): int {.importc.}
proc SDL_GetAudioDriver* ( index: int ): cstring {.importc.}
proc SDL_GetCurrentAudioDriver* (): cstring {.importc.}
proc SDL_GetAudioPlaybackDevices* ( count: var int ): var UncheckedArray[SDL_AudioDeviceID] {.importc.}
proc SDL_GetAudioRecordingDevices* ( count: var int ): var UncheckedArray[SDL_AudioDeviceID] {.importc.}
proc SDL_GetAudioDeviceName* ( devid: SDL_AudioDeviceID ): cstring {.importc.}
proc SDL_GetAudioDeviceFormat* ( devid: SDL_AudioDeviceID, spec: ptr SDL_AudioSpec, sample_frames: ptr cint ): bool {.importc.}
proc SDL_GetAudioDeviceChannelMap* ( devid: SDL_AudioDeviceID, count: var int ): var UncheckedArray[int] {.importc.}
proc SDL_OpenAudioDevice* ( devid: SDL_AudioDeviceID, spec: ptr SDL_AudioSpec ): SDL_AudioDeviceID {.importc.}
proc SDL_IsAudioDevicePhysical* ( devid: SDL_AudioDeviceID ): bool {.importc.}
proc SDL_IsAudioDevicePlayback* ( devid: SDL_AudioDeviceID ): bool {.importc.}
proc SDL_PauseAudioDevice* ( dev: SDL_AudioDeviceID ): bool {.importc.}
proc SDL_ResumeAudioDevice* ( dev: SDL_AudioDeviceID ): bool {.importc.}
proc SDL_AudioDevicePaused* ( dev: SDL_AudioDeviceID ): bool {.importc.}
proc SDL_GetAudioDeviceGain* ( devid: SDL_AudioDeviceID): cfloat {.importc.}
proc SDL_SetAudioDeviceGain* ( devid: SDL_AudioDeviceID, gain: cfloat ): bool {.importc.}
proc SDL_CloseAudioDevice* ( devid: SDL_AudioDeviceID): void {.importc.}

type SDL_AudioStream* = pointer

proc SDL_BindAudioStreams* ( devid: SDL_AudioDeviceID, streams: ptr[SDL_AudioStream], num_streams: int ): bool {.importc.}
proc SDL_BindAudioStreams* ( devid: SDL_AudioDeviceID, streams: openarray[SDL_AudioStream] ): bool {.importc.}
proc SDL_BindAudioStream* ( devid: SDL_AudioDeviceID, stream: SDL_AudioStream ): bool {.importc.}
proc SDL_UnbindAudioStreams* ( streams: ptr[SDL_AudioStream], num_streams: int ): void {.importc.}
proc SDL_UnbindAudioStreams* ( streams: openarray[SDL_AudioStream] ): void {.importc.}
proc SDL_UnbindAudioStream* ( stream: SDL_AudioStream ): void {.importc.}
proc SDL_GetAudioStreamDevice* ( stream: SDL_AudioStream ): SDL_AudioDeviceID {.importc.}
proc SDL_CreateAudioStream* ( src_spec,dst_spec: ptr SDL_AudioSpec ): SDL_AudioStream {.importc.}
proc SDL_GetAudioStreamProperties* ( stream: SDL_AudioStream ): SDL_PropertiesID {.importc.}
proc SDL_GetAudioStreamFormat* ( stream: SDL_AudioStream, src_spec,dst_spec: ptr SDL_AudioSpec ): bool {.importc.}
proc SDL_SetAudioStreamFormat* ( stream: SDL_AudioStream, src_spec,dst_spec: ptr SDL_AudioSpec ): bool {.importc.}
proc SDL_GetAudioStreamFrequencyRatio* ( stream: SDL_AudioStream ): cfloat {.importc.}
proc SDL_SetAudioStreamFrequencyRatio* ( stream: SDL_AudioStream, ratio: cfloat ): bool {.importc.}
proc SDL_GetAudioStreamGain* ( stream: SDL_AudioStream ): cfloat {.importc.}
proc SDL_SetAudioStreamGain* ( stream: SDL_AudioStream, gain: cfloat ): bool {.importc.}
proc SDL_GetAudioStreamInputChannelMap* ( stream: SDL_AudioStream, count: var int ): ptr[int] {.importc.}
proc SDL_GetAudioStreamOutputChannelMap* ( stream: SDL_AudioStream, count: var int ): ptr[int] {.importc.}
proc SDL_SetAudioStreamInputChannelMap* ( stream: SDL_AudioStream, chmap: openarray[int] ): bool {.importc.}
proc SDL_SetAudioStreamOutputChannelMap* ( stream: SDL_AudioStream, chmap: openarray[int] ): bool {.importc.}
proc SDL_PutAudioStreamData* ( stream: SDL_AudioStream, buf: pointer, len: int ): bool {.importc.}
proc SDL_GetAudioStreamData* ( stream: SDL_AudioStream, buf: pointer, len: int ): int {.importc.}
proc SDL_GetAudioStreamAvailable* ( stream: SDL_AudioStream ): int {.importc.}
proc SDL_GetAudioStreamQueued* ( stream: SDL_AudioStream ): int {.importc.}
proc SDL_FlushAudioStream* ( stream: SDL_AudioStream ): bool {.importc.}
proc SDL_ClearAudioStream* ( stream: SDL_AudioStream ): bool {.importc.}
proc SDL_PauseAudioStreamDevice* ( stream: SDL_AudioStream ): bool {.importc.}
proc SDL_ResumeAudioStreamDevice* ( stream: SDL_AudioStream ): bool {.importc.}
proc SDL_LockAudioStream* ( stream: SDL_AudioStream ): bool {.importc.}
proc SDL_UnlockAudioStream* ( stream: SDL_AudioStream ): bool {.importc.}

type SDL_AudioStreamCallback* = proc (userdata: pointer; stream: SDL_AudioStream; additional_amount: cint; total_amount: cint) {.cdecl.}

proc SDL_SetAudioStreamGetCallback* ( stream: SDL_AudioStream, callback: SDL_AudioStreamCallback, userdata: pointer ): bool {.importc.}
proc SDL_SetAudioStreamPutCallback* ( stream: SDL_AudioStream, callback: SDL_AudioStreamCallback, userdata: pointer ): bool {.importc.}
proc SDL_DestroyAudioStream* ( stream: SDL_AudioStream ): void {.importc.}
proc SDL_OpenAudioDeviceStream* ( devid: SDL_AudioDeviceID, spec: ptr SDL_AudioSpec, callback: SDL_AudioStreamCallback, userdata: pointer ): SDL_AudioStream {.importc.}
proc SDL_OpenAudioDeviceStream* ( devid: SDL_AudioDeviceID, spec: SDL_AudioSpec, callback: SDL_AudioStreamCallback, userdata: pointer ): SDL_AudioStream =
  SDL_OpenAudioDeviceStream(devid, spec.addr, callback, userdata)

type SDL_AudioPostmixCallback* = proc (userdata: pointer; spec: ptr SDL_AudioSpec; buffer: ptr cfloat; buflen: cint) {.cdecl.}

proc SDL_SetAudioPostmixCallback* ( devid: SDL_AudioDeviceID, callback: SDL_AudioPostmixCallback, userdata: pointer ): bool {.importc.}
proc SDL_LoadWAV_IO* ( src: SDL_IOStream, closeio: bool, spec: ptr SDL_AudioSpec, audio_buf: var UncheckedArray[uint8], audio_len: var uint32 ): bool {.importc.}
proc SDL_LoadWAV* ( path: cstring, spec: ptr SDL_AudioSpec, audio_buf: var ptr[uint8], audio_len: var uint32 ): bool {.importc.}
proc SDL_MixAudio* ( dst,src: ptr [uint8], format: SDL_AudioFormat, len: uint32, volume: cfloat ): bool {.importc.}
proc SDL_ConvertAudioSamples* ( src_spec: ptr SDL_AudioSpec, src_data: ptr[uint8], src_len: int, dst_spec: ptr SDL_AudioSpec, dst_data: var ptr[uint8], dst_len: var int ): bool {.importc.}
proc SDL_GetAudioFormatName* ( format: SDL_AudioFormat ): cstring {.importc.}
proc SDL_GetSilenceValueForFormat* ( format: SDL_AudioFormat ): int {.importc.}

#endregion


#region SDL3/SDL_bits.h -------------------------------------------------------

template SDL_MostSignificantBitIndex32* ( x: uint32 ): int =
  # Based off of Bit Twiddling Hacks by Sean Eron Anderson
  # <seander@cs.stanford.edu>, released in the public domain.
  # http://graphics.stanford.edu/~seander/bithacks.html#IntegerLog
  const b = [ 0x2'u32, 0xC'u32, 0xF0'u32, 0xFF00'u32, 0xFFFF0000'u32 ]
  const S = [ 1, 2, 4, 8, 16 ]
  var
    x = x
    msbIndex: int
  if x == 0:
    return -1
  for i in countdown(4, 0):
    if x and b[i] != 0:
      x = x shr S[i]
      msbIndex = msbIndex or S[i]
  return msbIndex

template SDL_HasExactlyOneBitSet32* ( x: uint32 ): bool =
  x != 0 and (x and (x - 1) == 0)

#endregion


#region SDL3/SDL_blendmode.h --------------------------------------------------

type SDL_BlendMode* = uint32

const SDL_BLENDMODE_NONE*                = 0x00000000'u32 # no blending: dstRGBA = srcRGBA
const SDL_BLENDMODE_BLEND*               = 0x00000001'u32 # alpha blending: dstRGB = (srcRGB * srcA) + (dstRGB * (1-srcA)), dstA = srcA + (dstA * (1-srcA))
const SDL_BLENDMODE_BLEND_PREMULTIPLIED* = 0x00000010'u32 # pre-multiplied alpha blending: dstRGBA = srcRGBA + (dstRGBA * (1-srcA))
const SDL_BLENDMODE_ADD*                 = 0x00000002'u32 # additive blending: dstRGB = (srcRGB * srcA) + dstRGB, dstA = dstA
const SDL_BLENDMODE_ADD_PREMULTIPLIED*   = 0x00000020'u32 # pre-multiplied additive blending: dstRGB = srcRGB + dstRGB, dstA = dstA
const SDL_BLENDMODE_MOD*                 = 0x00000004'u32 # color modulate: dstRGB = srcRGB * dstRGB, dstA = dstA
const SDL_BLENDMODE_MUL*                 = 0x00000008'u32 # color multiply: dstRGB = (srcRGB * dstRGB) + (dstRGB * (1-srcA)), dstA = dstA
const SDL_BLENDMODE_INVALID*             = 0x7FFFFFFF'u32

type
  SDL_BlendOperation* {.size: sizeof(cint).} = enum
    SDL_BLENDOPERATION_ADD = 0x1,
    SDL_BLENDOPERATION_SUBTRACT = 0x2,
    SDL_BLENDOPERATION_REV_SUBTRACT = 0x3,
    SDL_BLENDOPERATION_MINIMUM = 0x4,
    SDL_BLENDOPERATION_MAXIMUM = 0x5

  SDL_BlendFactor* {.size: sizeof(cint).} = enum
    SDL_BLENDFACTOR_ZERO = 0x1,
    SDL_BLENDFACTOR_ONE = 0x2,
    SDL_BLENDFACTOR_SRC_COLOR = 0x3,
    SDL_BLENDFACTOR_ONE_MINUS_SRC_COLOR = 0x4,
    SDL_BLENDFACTOR_SRC_ALPHA = 0x5,
    SDL_BLENDFACTOR_ONE_MINUS_SRC_ALPHA = 0x6,
    SDL_BLENDFACTOR_DST_COLOR = 0x7,
    SDL_BLENDFACTOR_ONE_MINUS_DST_COLOR = 0x8,
    SDL_BLENDFACTOR_DST_ALPHA = 0x9,
    SDL_BLENDFACTOR_ONE_MINUS_DST_ALPHA = 0xA

proc SDL_ComposeCustomBlendMode* ( srcColorFactor, dstColorFactor: SDL_BlendFactor,
                                   colorOperation: SDL_BlendOperation,
                                   srcAlphaFactor, dstAlphaFactor: SDL_BlendFactor,
                                   alphaOperation: SDL_BlendOperation
                                 ): SDL_BlendMode {.importc.}

#endregion


#region SDL3/SDL_pixels.h -----------------------------------------------------

const SDL_ALPHA_OPAQUE* = 255
const SDL_ALPHA_OPAQUE_FLOAT* = 1.0
const SDL_ALPHA_TRANSPARENT* = 0
const SDL_ALPHA_TRANSPARENT_FLOAT* = 0.0

type
  SDL_PixelType* {.size: sizeof(cint).} = enum
    SDL_PIXELTYPE_UNKNOWN,
    SDL_PIXELTYPE_INDEX1,
    SDL_PIXELTYPE_INDEX4,
    SDL_PIXELTYPE_INDEX8,
    SDL_PIXELTYPE_PACKED8,
    SDL_PIXELTYPE_PACKED16,
    SDL_PIXELTYPE_PACKED32,
    SDL_PIXELTYPE_ARRAYU8,
    SDL_PIXELTYPE_ARRAYU16,
    SDL_PIXELTYPE_ARRAYU32,
    SDL_PIXELTYPE_ARRAYF16,
    SDL_PIXELTYPE_ARRAYF32,
    SDL_PIXELTYPE_INDEX2

  SDL_BitmapOrder* {.size: sizeof(cint).} = enum
    SDL_BITMAPORDER_NONE,
    SDL_BITMAPORDER_4321,
    SDL_BITMAPORDER_1234

  SDL_PackedOrder* {.size: sizeof(cint).} = enum
    SDL_PACKEDORDER_NONE,
    SDL_PACKEDORDER_XRGB,
    SDL_PACKEDORDER_RGBX,
    SDL_PACKEDORDER_ARGB,
    SDL_PACKEDORDER_RGBA,
    SDL_PACKEDORDER_XBGR,
    SDL_PACKEDORDER_BGRX,
    SDL_PACKEDORDER_ABGR,
    SDL_PACKEDORDER_BGRA

  SDL_ArrayOrder* {.size: sizeof(cint).} = enum
    SDL_ARRAYORDER_NONE,
    SDL_ARRAYORDER_RGB,
    SDL_ARRAYORDER_RGBA,
    SDL_ARRAYORDER_ARGB,
    SDL_ARRAYORDER_BGR,
    SDL_ARRAYORDER_BGRA,
    SDL_ARRAYORDER_ABGR

  SDL_PackedLayout* {.size: sizeof(cint).} = enum
    SDL_PACKEDLAYOUT_NONE,
    SDL_PACKEDLAYOUT_332,
    SDL_PACKEDLAYOUT_4444,
    SDL_PACKEDLAYOUT_1555,
    SDL_PACKEDLAYOUT_5551,
    SDL_PACKEDLAYOUT_565,
    SDL_PACKEDLAYOUT_8888,
    SDL_PACKEDLAYOUT_2101010,
    SDL_PACKEDLAYOUT_1010102

type
  SDL_PixelFormat* {.size: sizeof(cint).} = enum
    SDL_PIXELFORMAT_UNKNOWN = 0,
    SDL_PIXELFORMAT_INDEX1LSB = 0x11100100,
    SDL_PIXELFORMAT_INDEX1MSB = 0x11200100,
    SDL_PIXELFORMAT_INDEX4LSB = 0x12100400,
    SDL_PIXELFORMAT_INDEX4MSB = 0x12200400,
    SDL_PIXELFORMAT_INDEX8 = 0x13000801,
    SDL_PIXELFORMAT_RGB332 = 0x14110801,
    SDL_PIXELFORMAT_XRGB4444 = 0x15120c02,
    SDL_PIXELFORMAT_XRGB1555 = 0x15130f02,
    SDL_PIXELFORMAT_RGB565 = 0x15151002,
    SDL_PIXELFORMAT_ARGB4444 = 0x15321002,
    SDL_PIXELFORMAT_ARGB1555 = 0x15331002,
    SDL_PIXELFORMAT_RGBA4444 = 0x15421002,
    SDL_PIXELFORMAT_RGBA5551 = 0x15441002,
    SDL_PIXELFORMAT_XBGR4444 = 0x15520c02,
    SDL_PIXELFORMAT_XBGR1555 = 0x15530f02,
    SDL_PIXELFORMAT_BGR565 = 0x15551002,
    SDL_PIXELFORMAT_ABGR4444 = 0x15721002,
    SDL_PIXELFORMAT_ABGR1555 = 0x15731002,
    SDL_PIXELFORMAT_BGRA4444 = 0x15821002,
    SDL_PIXELFORMAT_BGRA5551 = 0x15841002,
    SDL_PIXELFORMAT_XRGB8888 = 0x16161804,
    SDL_PIXELFORMAT_XRGB2101010 = 0x16172004,
    SDL_PIXELFORMAT_RGBX8888 = 0x16261804,
    SDL_PIXELFORMAT_ARGB8888 = 0x16362004,
    SDL_PIXELFORMAT_ARGB2101010 = 0x16372004,
    SDL_PIXELFORMAT_RGBA8888 = 0x16462004,
    SDL_PIXELFORMAT_XBGR8888 = 0x16561804,
    SDL_PIXELFORMAT_XBGR2101010 = 0x16572004,
    SDL_PIXELFORMAT_BGRX8888 = 0x16661804,
    SDL_PIXELFORMAT_ABGR8888 = 0x16762004,
    SDL_PIXELFORMAT_ABGR2101010 = 0x16772004,
    SDL_PIXELFORMAT_BGRA8888 = 0x16862004,
    SDL_PIXELFORMAT_RGB24 = 0x17101803,
    SDL_PIXELFORMAT_BGR24 = 0x17401803,
    SDL_PIXELFORMAT_RGB48 = 0x18103006,
    SDL_PIXELFORMAT_RGBA64 = 0x18204008,
    SDL_PIXELFORMAT_ARGB64 = 0x18304008,
    SDL_PIXELFORMAT_BGR48 = 0x18403006,
    SDL_PIXELFORMAT_BGRA64 = 0x18504008,
    SDL_PIXELFORMAT_ABGR64 = 0x18604008,
    SDL_PIXELFORMAT_RGB48_FLOAT = 0x1a103006,
    SDL_PIXELFORMAT_RGBA64_FLOAT = 0x1a204008,
    SDL_PIXELFORMAT_ARGB64_FLOAT = 0x1a304008,
    SDL_PIXELFORMAT_BGR48_FLOAT = 0x1a403006,
    SDL_PIXELFORMAT_BGRA64_FLOAT = 0x1a504008,
    SDL_PIXELFORMAT_ABGR64_FLOAT = 0x1a604008,
    SDL_PIXELFORMAT_RGB96_FLOAT = 0x1b10600c,
    SDL_PIXELFORMAT_RGBA128_FLOAT = 0x1b208010,
    SDL_PIXELFORMAT_ARGB128_FLOAT = 0x1b308010,
    SDL_PIXELFORMAT_BGR96_FLOAT = 0x1b40600c,
    SDL_PIXELFORMAT_BGRA128_FLOAT = 0x1b508010,
    SDL_PIXELFORMAT_ABGR128_FLOAT = 0x1b608010,
    SDL_PIXELFORMAT_INDEX2LSB = 0x1c100200,
    SDL_PIXELFORMAT_INDEX2MSB = 0x1c200200,
    SDL_PIXELFORMAT_EXTERNAL_OES = 0x2053454f,
    SDL_PIXELFORMAT_P010 = 0x30313050,
    SDL_PIXELFORMAT_NV21 = 0x3132564e,
    SDL_PIXELFORMAT_NV12 = 0x3231564e,
    SDL_PIXELFORMAT_YV12 = 0x32315659,
    SDL_PIXELFORMAT_YUY2 = 0x32595559,
    SDL_PIXELFORMAT_YVYU = 0x55595659,
    SDL_PIXELFORMAT_IYUV = 0x56555949,
    SDL_PIXELFORMAT_UYVY = 0x59565955

  SDL_ColorType* {.size: sizeof(cint).} = enum
    SDL_COLOR_TYPE_UNKNOWN = 0,
    SDL_COLOR_TYPE_RGB = 1,
    SDL_COLOR_TYPE_YCBCR = 2

  SDL_ColorRange* {.size: sizeof(cint).} = enum
    SDL_COLOR_RANGE_UNKNOWN = 0,
    SDL_COLOR_RANGE_LIMITED = 1,
    SDL_COLOR_RANGE_FULL = 2

  SDL_ColorPrimaries* {.size: sizeof(cint).} = enum
    SDL_COLOR_PRIMARIES_UNKNOWN = 0,
    SDL_COLOR_PRIMARIES_BT709 = 1,
    SDL_COLOR_PRIMARIES_UNSPECIFIED = 2,
    SDL_COLOR_PRIMARIES_BT470M = 4,
    SDL_COLOR_PRIMARIES_BT470BG = 5,
    SDL_COLOR_PRIMARIES_BT601 = 6,
    SDL_COLOR_PRIMARIES_SMPTE240 = 7,
    SDL_COLOR_PRIMARIES_GENERIC_FILM = 8,
    SDL_COLOR_PRIMARIES_BT2020 = 9,
    SDL_COLOR_PRIMARIES_XYZ = 10,
    SDL_COLOR_PRIMARIES_SMPTE431 = 11,
    SDL_COLOR_PRIMARIES_SMPTE432 = 12,
    SDL_COLOR_PRIMARIES_EBU3213 = 22,
    SDL_COLOR_PRIMARIES_CUSTOM = 31

const
  SDL_PIXELFORMAT_RGBA32* = SDL_PIXELFORMAT_ABGR8888
  SDL_PIXELFORMAT_ARGB32* = SDL_PIXELFORMAT_BGRA8888
  SDL_PIXELFORMAT_BGRA32* = SDL_PIXELFORMAT_ARGB8888
  SDL_PIXELFORMAT_ABGR32* = SDL_PIXELFORMAT_RGBA8888
  SDL_PIXELFORMAT_RGBX32* = SDL_PIXELFORMAT_XBGR8888
  SDL_PIXELFORMAT_XRGB32* = SDL_PIXELFORMAT_BGRX8888
  SDL_PIXELFORMAT_BGRX32* = SDL_PIXELFORMAT_XRGB8888
  SDL_PIXELFORMAT_XBGR32* = SDL_PIXELFORMAT_RGBX8888

type
  SDL_TransferCharacteristics* {.size: sizeof(cint).} = enum
    SDL_TRANSFER_CHARACTERISTICS_UNKNOWN = 0,
    SDL_TRANSFER_CHARACTERISTICS_BT709 = 1,
    SDL_TRANSFER_CHARACTERISTICS_UNSPECIFIED = 2,
    SDL_TRANSFER_CHARACTERISTICS_GAMMA22 = 4,
    SDL_TRANSFER_CHARACTERISTICS_GAMMA28 = 5,
    SDL_TRANSFER_CHARACTERISTICS_BT601 = 6,
    SDL_TRANSFER_CHARACTERISTICS_SMPTE240 = 7,
    SDL_TRANSFER_CHARACTERISTICS_LINEAR = 8,
    SDL_TRANSFER_CHARACTERISTICS_LOG100 = 9,
    SDL_TRANSFER_CHARACTERISTICS_LOG100_SQRT10 = 10,
    SDL_TRANSFER_CHARACTERISTICS_IEC61966 = 11,
    SDL_TRANSFER_CHARACTERISTICS_BT1361 = 12,
    SDL_TRANSFER_CHARACTERISTICS_SRGB = 13,
    SDL_TRANSFER_CHARACTERISTICS_BT2020_10BIT = 14,
    SDL_TRANSFER_CHARACTERISTICS_BT2020_12BIT = 15,
    SDL_TRANSFER_CHARACTERISTICS_PQ = 16,
    SDL_TRANSFER_CHARACTERISTICS_SMPTE428 = 17,
    SDL_TRANSFER_CHARACTERISTICS_HLG = 18,
    SDL_TRANSFER_CHARACTERISTICS_CUSTOM = 31


type
  SDL_MatrixCoefficients* {.size: sizeof(cint).} = enum
    SDL_MATRIX_COEFFICIENTS_IDENTITY = 0,
    SDL_MATRIX_COEFFICIENTS_BT709 = 1,
    SDL_MATRIX_COEFFICIENTS_UNSPECIFIED = 2,
    SDL_MATRIX_COEFFICIENTS_FCC = 4,
    SDL_MATRIX_COEFFICIENTS_BT470BG = 5,
    SDL_MATRIX_COEFFICIENTS_BT601 = 6,
    SDL_MATRIX_COEFFICIENTS_SMPTE240 = 7,
    SDL_MATRIX_COEFFICIENTS_YCGCO = 8,
    SDL_MATRIX_COEFFICIENTS_BT2020_NCL = 9,
    SDL_MATRIX_COEFFICIENTS_BT2020_CL = 10,
    SDL_MATRIX_COEFFICIENTS_SMPTE2085 = 11,
    SDL_MATRIX_COEFFICIENTS_CHROMA_DERIVED_NCL = 12,
    SDL_MATRIX_COEFFICIENTS_CHROMA_DERIVED_CL = 13,
    SDL_MATRIX_COEFFICIENTS_ICTCP = 14,
    SDL_MATRIX_COEFFICIENTS_CUSTOM = 31

  SDL_ChromaLocation* {.size: sizeof(cint).} = enum
    SDL_CHROMA_LOCATION_NONE = 0,
    SDL_CHROMA_LOCATION_LEFT = 1,
    SDL_CHROMA_LOCATION_CENTER = 2,
    SDL_CHROMA_LOCATION_TOPLEFT = 3


type
  SDL_Colorspace* {.size: sizeof(cint).} = enum
    SDL_COLORSPACE_UNKNOWN = 0,
    SDL_COLORSPACE_SRGB_LINEAR = 0x12000500,
    SDL_COLORSPACE_SRGB = 0x120005a0,
    SDL_COLORSPACE_HDR10 = 0x12002600,
    SDL_COLORSPACE_BT709_LIMITED = 0x21100421,
    SDL_COLORSPACE_BT601_LIMITED = 0x211018c6,
    SDL_COLORSPACE_BT2020_LIMITED = 0x21102609,
    SDL_COLORSPACE_JPEG = 0x220004c6,
    SDL_COLORSPACE_BT709_FULL = 0x22100421,
    SDL_COLORSPACE_BT601_FULL = 0x221018c6,
    SDL_COLORSPACE_BT2020_FULL = 0x22102609

const
  SDL_COLORSPACE_RGB_DEFAULT* = SDL_COLORSPACE_SRGB
  SDL_COLORSPACE_YUV_DEFAULT* = SDL_COLORSPACE_JPEG

type
  SDL_Color* {.bycopy.} = object
    r*: uint8
    g*: uint8
    b*: uint8
    a*: uint8

  SDL_FColor* {.bycopy.} = object
    r*: cfloat
    g*: cfloat
    b*: cfloat
    a*: cfloat

  SDL_Palette* {.bycopy.} = object
    ncolors*: cint
    colors*: ptr UncheckedArray[SDL_Color]
    version*: uint32
    refcount*: cint

  SDL_PixelFormatDetails* {.bycopy.} = object
    format*: SDL_PixelFormat
    bits_per_pixel*: uint8
    bytes_per_pixel*: uint8
    padding*: array[2, uint8]
    Rmask*: uint32
    Gmask*: uint32
    Bmask*: uint32
    Amask*: uint32
    Rbits*: uint8
    Gbits*: uint8
    Bbits*: uint8
    Abits*: uint8
    Rshift*: uint8
    Gshift*: uint8
    Bshift*: uint8
    Ashift*: uint8

proc SDL_GetPixelFormatName* ( format: SDL_PixelFormat ): cstring {.importc.}
proc SDL_GetMasksForPixelFormat* ( format: SDL_PixelFormat, bpp: var int, Rmask: var uint32, Gmask: var uint32, Bmask: var uint32, Amask: var uint32 ): bool {.importc.}
proc SDL_GetPixelFormatForMasks* ( bpp: int, Rmask: uint32, Gmask: uint32, Bmask: uint32, Amask: uint32 ): SDL_PixelFormat {.importc.}
proc SDL_GetPixelFormatDetails* ( format: SDL_PixelFormat ): ptr SDL_PixelFormatDetails {.importc.}
proc SDL_CreatePalette* ( ncolors: int ): ptr SDL_Palette {.importc.}
proc SDL_SetPaletteColors* ( palette: ptr SDL_Palette, colors: ptr[SDL_Color], firstcolor,ncolors: int ): bool {.importc.}
proc SDL_DestroyPalette* ( palette: ptr SDL_Palette ): void {.importc.}
proc SDL_MapRGB* ( format: ptr SDL_PixelFormatDetails, palette: ptr SDL_Palette, r,g,b: uint8 ): uint32 {.importc.}
proc SDL_MapRGBA* ( format: ptr SDL_PixelFormatDetails, palette: ptr SDL_Palette, r,g,b,a: uint8 ): uint32 {.importc.}
proc SDL_GetRGB* ( pixel: uint32, format: ptr SDL_PixelFormatDetails, palette: ptr SDL_Palette, r,g,b: var uint8 ): void {.importc.}
proc SDL_GetRGBA* ( pixel: uint32, format: ptr SDL_PixelFormatDetails, palette: ptr SDL_Palette, r,g,b,a: var uint8 ): void {.importc.}

# TODO: Fill in missing PixelFormat macros here.

#endregion


#region SDL3/SDL_clipboard.h --------------------------------------------------

proc SDL_SetClipboardText* ( text: cstring ): bool {.importc.}
proc SDL_GetClipboardText* (): cstring {.importc.}
proc SDL_HasClipboardText* (): bool {.importc.}
proc SDL_SetPrimarySelectionText* ( text: cstring ): bool {.importc.}
proc SDL_GetPrimarySelectionText* (): cstring {.importc.}
proc SDL_HasPrimarySelectionText* (): bool {.importc.}

type
  SDL_ClipboardDataCallback* = proc (userdata: pointer; mime_type: cstring;
      size: ptr csize_t): pointer {.cdecl.}
  SDL_ClipboardCleanupCallback* = proc (userdata: pointer) {.cdecl.}

proc SDL_SetClipboardData* ( callback: SDL_ClipboardDataCallback, cleanup: SDL_ClipboardCleanupCallback, userdata: pointer, mime_types: ptr[cstring], num_mime_types: csize_t ): bool {.importc.}
proc SDL_SetClipboardData* ( callback: SDL_ClipboardDataCallback, cleanup: SDL_ClipboardCleanupCallback, userdata: pointer, mime_types: openarray[cstring] ): bool {.importc.}
proc SDL_ClearClipboardData* (): bool {.importc.}
proc SDL_GetClipboardData* ( mime_type: cstring, size: var csize_t ): pointer {.importc.}
proc SDL_HasClipboardData* ( mime_type: cstring ): bool {.importc.}
proc SDL_GetClipboardMimeTypes* ( num_mime_types: var csize_t ): var UncheckedArray[cstring] {.importc.}

#endregion


#region SDL3/SDL_cpuinfo.h ----------------------------------------------------

const SDL_CACHELINE_SIZE* = 128

proc SDL_GetNumLogicalCPUCores* (): int {.importc.}
proc SDL_GetCPUCacheLineSize* (): int {.importc.}
proc SDL_HasAltiVec* (): bool {.importc.}
proc SDL_HasMMX* (): bool {.importc.}
proc SDL_HasSSE* (): bool {.importc.}
proc SDL_HasSSE2* (): bool {.importc.}
proc SDL_HasSSE3* (): bool {.importc.}
proc SDL_HasSSE41* (): bool {.importc.}
proc SDL_HasSSE42* (): bool {.importc.}
proc SDL_HasAVX* (): bool {.importc.}
proc SDL_HasAVX2* (): bool {.importc.}
proc SDL_HasAVX512F* (): bool {.importc.}
proc SDL_HasARMSIMD* (): bool {.importc.}
proc SDL_HasNEON* (): bool {.importc.}
proc SDL_HasLSX* (): bool {.importc.}
proc SDL_HasLASX* (): bool {.importc.}
proc SDL_GetSystemRAM* (): int {.importc.}
proc SDL_GetSIMDAlignment* (): csize_t {.importc.}

#endregion


#region SDL3/SDL_endian.h -----------------------------------------------------
#  Skipped this one for now. Open an issue if you want it.
#endregion


#region SDL3/SDL_error.h ------------------------------------------------------

proc SDL_SetError* ( fmt: cstring ): bool {.importc, varargs.}
proc SDL_SetErrorV* ( fmt: cstring, ap: cva_list ): bool {.importc.}
proc SDL_OutOfMemory* (): bool {.importc.}
proc SDL_GetError* (): cstring {.importc.}
proc SDL_ClearError* (): bool {.importc.}

template SDL_Unsupported* (): untyped =
  SDL_SetError("That operation is not supported")

template SDL_InvalidParamError* (param): untyped =
  var `param` {.inject.}: string = ""
  SDL_SetError("Parameter '%s' is invalid", param.astToString)

#endregion


#region SDL3/SDL_filesystem.h -------------------------------------------------

proc SDL_GetBasePath* (): cstring {.importc.}
proc SDL_GetPrefPath* ( org,app: cstring ): cstring {.importc.}

type
  SDL_Folder* {.size: sizeof(cint).} = enum
    SDL_FOLDER_HOME,
    SDL_FOLDER_DESKTOP,
    SDL_FOLDER_DOCUMENTS,
    SDL_FOLDER_DOWNLOADS,
    SDL_FOLDER_MUSIC,
    SDL_FOLDER_PICTURES,
    SDL_FOLDER_PUBLICSHARE,
    SDL_FOLDER_SAVEDGAMES,
    SDL_FOLDER_SCREENSHOTS,
    SDL_FOLDER_TEMPLATES,
    SDL_FOLDER_VIDEOS,
    SDL_FOLDER_COUNT

proc SDL_GetUserFolder* ( folder: SDL_Folder ): cstring {.importc.}

type
  SDL_PathType* {.size: sizeof(cint).} = enum
    SDL_PATHTYPE_NONE,
    SDL_PATHTYPE_FILE,
    SDL_PATHTYPE_DIRECTORY,
    SDL_PATHTYPE_OTHER

type
  SDL_Time* = distinct int64
  SDL_PathInfo* {.bycopy.} = object
    `type`*: SDL_PathType
    size*: uint64
    create_time*: SDL_Time
    modify_time*: SDL_Time
    access_time*: SDL_Time
  SDL_GlobFlags* = uint32

const SDL_GLOB_CASEINSENSITIVE* = 1'u

proc SDL_CreateDirectory* ( path: cstring ): bool {.importc.}

type
  SDL_EnumerationResult* {.size: sizeof(cint).} = enum
    SDL_ENUM_CONTINUE,
    SDL_ENUM_SUCCESS,
    SDL_ENUM_FAILURE

  SDL_EnumerateDirectoryCallback* = proc (userdata: pointer; dirname: cstring;
      fname: cstring): SDL_EnumerationResult {.cdecl.}

proc SDL_EnumerateDirectory* ( path: cstring, callback: SDL_EnumerateDirectoryCallback, userdata: pointer ): bool {.importc.}
proc SDL_RemovePath* ( path: cstring ): bool {.importc.}
proc SDL_RenamePath* ( oldpath,newpath: cstring ): bool {.importc.}
proc SDL_CopyFile* ( oldpath,newpath: cstring ): bool {.importc.}
proc SDL_GetPathInfo* ( path: cstring, info: var SDL_PathInfo ): bool {.importc.}
proc SDL_GlobDirectory* ( path,pattern: cstring, flags: SDL_GlobFlags, count: var int ): ptr UncheckedArray[cstring] {.importc.}
proc SDL_GetCurrentDirectory* (): cstring {.importc.}

#endregion


#region SDL3/SDL_rect.h -------------------------------------------------------

type
  SDL_Point* {.bycopy.} = object
    x*: cint
    y*: cint

  SDL_FPoint* {.bycopy.} = object
    x*: cfloat
    y*: cfloat

  SDL_Rect* {.bycopy.} = object
    x*: cint
    y*: cint
    w*: cint
    h*: cint

  SDL_FRect* {.bycopy.} = object
    x*: cfloat
    y*: cfloat
    w*: cfloat
    h*: cfloat

proc SDL_RectToFRect* ( rect: ptr SDL_Rect ): SDL_FRect {.inline.} =
  SDL_FRect(
    x: rect.x.float,
    y: rect.y.float,
    w: rect.w.float,
    h: rect.h.float,
  )

proc SDL_RectToFRect* ( rect: ptr SDL_Rect, frect: ptr SDL_FRect ): void {.inline.} =
  frect.x = rect.x.float
  frect.y = rect.y.float
  frect.w = rect.w.float
  frect.h = rect.h.float

# proc SDL_PointInRect* ( p: ptr SDL_Point, r: ptr SDL_Rect ): bool {.importc.} # TODO: IMPLEMENT
# proc SDL_RectEmpty* ( r: ptr SDL_Rect ): bool {.importc.} # TODO: IMPLEMENT
# proc SDL_RectsEqual* ( a, b: ptr SDL_Rect ): bool {.importc.} # TODO: IMPLEMENT
# proc SDL_HasRectIntersection* ( A,B: ptr SDL_Rect ): bool {.importc.} # TODO: IMPLEMENT
# proc SDL_GetRectIntersection* ( A,B: ptr SDL_Rect, result: var SDL_Rect ): bool {.importc.} # TODO: IMPLEMENT
# proc SDL_GetRectUnion* ( A,B: ptr SDL_Rect, result: var SDL_Rect ): bool {.importc.} # TODO: IMPLEMENT
# proc SDL_GetRectEnclosingPoints* ( points: openarray[SDL_Point], clip: ptr SDL_Rect, result: var SDL_Rect ): bool {.importc.} # TODO: IMPLEMENT
# proc SDL_GetRectAndLineIntersection* ( rect: ptr SDL_Rect, X1,Y1,X2,Y2: var int ): bool {.importc.} # TODO: IMPLEMENT
# proc SDL_PointInRectFloat* ( p: ptr SDL_FPoint, r: ptr SDL_FRect ): bool {.importc.} # TODO: IMPLEMENT
# proc SDL_RectEmptyFloat* ( r: ptr SDL_FRect ): bool {.importc.} # TODO: IMPLEMENT
# proc SDL_RectsEqualEpsilon* ( a,b: ptr SDL_FRect, epsilon: cfloat ): bool {.importc.} # TODO: IMPLEMENT
# proc SDL_RectsEqualFloat* ( a,b: ptr SDL_FRect ): bool {.importc.} # TODO: IMPLEMENT
# proc SDL_HasRectIntersectionFloat* ( A,B: ptr SDL_FRect ): bool {.importc.} # TODO: IMPLEMENT
# proc SDL_GetRectIntersectionFloat* ( A,B: ptr SDL_FRect, result: var SDL_FRect ): bool {.importc.} # TODO: IMPLEMENT
# proc SDL_GetRectUnionFloat* ( A,B: ptr SDL_FRect, result: var SDL_FRect ): bool {.importc.} # TODO: IMPLEMENT
# proc SDL_GetRectEnclosingPointsFloat* ( points: openarray[SDL_FPoint], clip: ptr SDL_FRect, result: var SDL_FRect ): bool {.importc.} # TODO: IMPLEMENT
# proc SDL_GetRectAndLineIntersectionFloat* ( rect: ptr SDL_FRect, X1,Y1,X2,Y2: var cfloat ): bool {.importc.} # TODO: IMPLEMENT

#endregion


#region SDL3/SDL_surface.h ----------------------------------------------------

type
  SDL_SurfaceFlags* = uint32
  SDL_ScaleMode* {.size: sizeof(cint).} = enum
    SDL_SCALEMODE_NEAREST,
    SDL_SCALEMODE_LINEAR
  SDL_FlipMode* {.size: sizeof(cint).} = enum
    SDL_FLIP_NONE,
    SDL_FLIP_HORIZONTAL,
    SDL_FLIP_VERTICAL
  SDL_Surface* {.bycopy.} = object
    flags*: SDL_SurfaceFlags
    format*: SDL_PixelFormat
    w*: cint
    h*: cint
    pitch*: cint
    pixels*: ptr UncheckedArray[uint8]
    refcount*: cint
    reserved*: pointer

proc SDL_CreateSurface* ( width,height: int, format: SDL_PixelFormat ): ptr SDL_Surface {.importc.}
proc SDL_CreateSurfaceFrom* ( width,height: int, format: SDL_PixelFormat, pixels: pointer, pitch: int): ptr SDL_Surface {.importc.}
proc SDL_DestroySurface* ( surface: ptr SDL_Surface ): void {.importc.}
proc SDL_GetSurfaceProperties* ( surface: ptr SDL_Surface ): SDL_PropertiesID {.importc.}
proc SDL_SetSurfaceColorspace* ( surface: ptr SDL_Surface, colorspace: SDL_Colorspace ): bool {.importc.}
proc SDL_GetSurfaceColorspace* ( surface: ptr SDL_Surface ): SDL_Colorspace {.importc.}
proc SDL_CreateSurfacePalette* ( surface: ptr SDL_Surface ): ptr SDL_Palette {.importc.}
proc SDL_SetSurfacePalette* ( surface: ptr SDL_Surface, palette: ptr SDL_Palette ): bool {.importc.}
proc SDL_GetSurfacePalette* ( surface: ptr SDL_Surface ): ptr SDL_Palette {.importc.}
proc SDL_AddSurfaceAlternateImage* ( surface: ptr SDL_Surface, image: ptr SDL_Surface ): bool {.importc.}
proc SDL_SurfaceHasAlternateImages* ( surface: ptr SDL_Surface ): bool {.importc.}
proc SDL_GetSurfaceImages* ( surface: ptr SDL_Surface, count: var int ): ptr UncheckedArray[ptr SDL_Surface] {.importc.}
proc SDL_RemoveSurfaceAlternateImages* ( surface: ptr SDL_Surface ): void {.importc.}
proc SDL_LockSurface* ( surface: ptr SDL_Surface ): bool {.importc}
proc SDL_UnlockSurface* ( surface: ptr SDL_Surface ): void {.importc.}
proc SDL_LoadBMP_IO* ( src: SDL_IOStream, closeio: bool ): ptr SDL_Surface {.importc.}
proc SDL_LoadBMP* ( file: cstring ): ptr SDL_Surface {.importc.}
proc SDL_SaveBMP_IO* ( surface: ptr SDL_Surface, dst: SDL_IOStream, closeio: bool ): bool {.importc.}
proc SDL_SaveBMP* ( surface: ptr SDL_Surface, file: cstring ): bool {.importc.}
proc SDL_SetSurfaceRLE* ( surface: ptr SDL_Surface, enabled: bool ): bool {.importc, discardable.}
proc SDL_SurfaceHasRLE* ( surface: ptr SDL_Surface ): bool {.importc.}
proc SDL_SetSurfaceColorKey* ( surface: ptr SDL_Surface, enabled: bool, key: uint32 ): bool {.importc, discardable.}
proc SDL_SurfaceHasColorKey* ( surface: ptr SDL_Surface ): bool {.importc.}
proc SDL_GetSurfaceColorKey* ( surface: ptr SDL_Surface, key: var uint32 ): bool {.importc.}
proc SDL_SetSurfaceColorMod* ( surface: ptr SDL_Surface, r,g,b: uint8 ): bool {.importc.}
proc SDL_GetSurfaceColorMod* ( surface: ptr SDL_Surface, r,g,b: var uint8 ): bool {.importc.}
proc SDL_SetSurfaceAlphaMod* ( surface: ptr SDL_Surface, alpha: uint8 ): bool {.importc, discardable.}
proc SDL_GetSurfaceAlphaMod* ( surface: ptr SDL_Surface, alpha: var uint8 ): bool {.importc.}
proc SDL_SetSurfaceBlendMode* ( surface: ptr SDL_Surface, blendMode: SDL_BlendMode ): bool {.importc, discardable.}
proc SDL_GetSurfaceBlendMode* ( surface: ptr SDL_Surface, blendMode: var SDL_BlendMode ): bool {.importc.}
proc SDL_SetSurfaceClipRect* ( surface: ptr SDL_Surface, rect: ptr SDL_Rect ): bool {.importc.}
proc SDL_GetSurfaceClipRect* ( surface: ptr SDL_Surface, rect: var SDL_Rect ): bool {.importc.}
proc SDL_FlipSurface* ( surface: ptr SDL_Surface, flip: SDL_FlipMode ): bool {.importc.}
proc SDL_DuplicateSurface* ( surface: ptr SDL_Surface ): ptr SDL_Surface {.importc.}
proc SDL_ScaleSurface* ( surface: ptr SDL_Surface, width,height: int, scaleMode: SDL_ScaleMode ): ptr SDL_Surface {.importc.}
proc SDL_ConvertSurface* ( surface: ptr SDL_Surface, format: SDL_PixelFormat ): ptr SDL_Surface {.importc.}
proc SDL_ConvertSurfaceAndColorspace* ( surface: ptr SDL_Surface, format: SDL_PixelFormat, palette: ptr SDL_Palette, colorspace: SDL_Colorspace, props: SDL_PropertiesID): ptr SDL_Surface {.importc.}
proc SDL_ConvertPixels* ( width,height: int, src_format: SDL_PixelFormat, src: pointer, src_pitch: int, dst_format: SDL_PixelFormat, dst: pointer, dst_pitch: int ): bool {.importc.}
proc SDL_ConvertPixelsAndColorspace* ( width,height: int, src_format: SDL_PixelFormat, src_colorspace: SDL_Colorspace, src_properties: SDL_PropertiesID, src: pointer, src_pitch: int, dst_format: SDL_PixelFormat, dst_colorspace: SDL_Colorspace, dst_properties: SDL_PropertiesID, dst: pointer, dst_pitch: int ): bool {.importc.}
proc SDL_PremultiplyAlpha* ( width,height: int, src_format: SDL_PixelFormat, src: pointer, src_pitch: int, dst_format: SDL_PixelFormat, dst: pointer, dst_pitch: int, linear: bool ): bool {.importc.}
proc SDL_PremultiplySurfaceAlpha* ( surface: ptr SDL_Surface, linear: bool ): bool {.importc.}
proc SDL_ClearSurface* ( surface: ptr SDL_Surface, r,g,b,a: cfloat ): bool {.importc.}
proc SDL_FillSurfaceRect* ( dst: ptr SDL_Surface, rect: ptr SDL_Rect, color: uint32 ): bool {.importc.}
proc SDL_FillSurfaceRects* ( dst: ptr SDL_Surface, rect: openarray[SDL_Rect], color: uint32 ): bool {.importc.}
proc SDL_BlitSurface* ( src: ptr SDL_Surface, srcrect: ptr SDL_Rect, dst: ptr SDL_Surface, dstrect: ptr SDL_Rect ): bool {.importc.}
proc SDL_BlitSurfaceUnchecked* ( src: ptr SDL_Surface, srcrect: ptr SDL_Rect, dst: ptr SDL_Surface, dstrect: ptr SDL_Rect ): bool {.importc.}
proc SDL_BlitSurfaceScaled* ( src: ptr SDL_Surface, srcrect: ptr SDL_Rect, dst: ptr SDL_Surface, dstrect: ptr SDL_Rect,  scaleMode: SDL_ScaleMode ): bool {.importc.}
proc SDL_BlitSurfaceUncheckedScaled* ( src: ptr SDL_Surface, srcrect: ptr SDL_Rect, dst: ptr SDL_Surface, dstrect: ptr SDL_Rect, scaleMode: SDL_ScaleMode ): bool {.importc.}
proc SDL_BlitSurfaceTiled* ( src: ptr SDL_Surface, srcrect: ptr SDL_Rect, dst: ptr SDL_Surface, dstrect: ptr SDL_Rect): bool {.importc.}
proc SDL_BlitSurfaceTiledWithScale* ( src: ptr SDL_Surface, srcrect: ptr SDL_Rect, scale: cfloat, scaleMode: SDL_ScaleMode, dst: ptr SDL_Surface, dstrect: ptr SDL_Rect ): bool {.importc.}
proc SDL_BlitSurface9Grid* ( src: ptr SDL_Surface, srcrect: ptr SDL_Rect, left_width,right_width,top_height,bottom_height: int, scale: cfloat, scaleMode: SDL_ScaleMode, dst: ptr SDL_Surface, dstrect: ptr SDL_Rect ): bool {.importc.}
proc SDL_MapSurfaceRGB* ( surface: ptr SDL_Surface, r,g,b: uint8 ): uint32 {.importc.}
proc SDL_MapSurfaceRGBA* ( surface: ptr SDL_Surface, r,g,b,a: uint8 ): uint32 {.importc.}
proc SDL_ReadSurfacePixel* ( surface: ptr SDL_Surface, x,y: int, r,g,b,a: var uint8 ): bool {.importc.}
proc SDL_ReadSurfacePixelFloat* ( surface: ptr SDL_Surface, x,y: int, r,g,b,a: var cfloat ): bool {.importc.}
proc SDL_WriteSurfacePixel* ( surface: ptr SDL_Surface, x,y: int, r,g,b,a: uint8 ): bool {.importc.}
proc SDL_WriteSurfacePixelFloat* ( surface: ptr SDL_Surface, x,y: int, r,g,b,a: cfloat ): bool {.importc.}

const SDL_SURFACE_PREALLOCATED* = 0x00000001'u #  Surface uses preallocated pixel memory
const SDL_SURFACE_LOCK_NEEDED*  = 0x00000002'u #  Surface needs to be locked to access pixels
const SDL_SURFACE_LOCKED*       = 0x00000004'u #  Surface is currently locked
const SDL_SURFACE_SIMD_ALIGNED* = 0x00000008'u #  Surface uses pixel memory allocated with SDL_aligned_alloc()

proc SDL_MUSTLOCK* ( s: ptr SDL_Surface ): bool =
  (s.flags and SDL_SURFACE_LOCK_NEEDED) == SDL_SURFACE_LOCK_NEEDED

const SDL_PROP_SURFACE_SDR_WHITE_POINT_FLOAT* =   "SDL.surface.SDR_white_point"
const SDL_PROP_SURFACE_HDR_HEADROOM_FLOAT* =      "SDL.surface.HDR_headroom"
const SDL_PROP_SURFACE_TONEMAP_OPERATOR_STRING* = "SDL.surface.tonemap"

#endregion


#region SDL3/SDL_video.h ------------------------------------------------------

type
  SDL_Window* = pointer
  SDL_DisplayID* = uint32
  SDL_WindowID* = uint32
  SDL_SystemTheme* {.size: sizeof(cint).} = enum
    SDL_SYSTEM_THEME_UNKNOWN,
    SDL_SYSTEM_THEME_LIGHT,
    SDL_SYSTEM_THEME_DARK

  SDL_DisplayModeData* = object
  SDL_DisplayMode* {.bycopy.} = object
    displayID*: SDL_DisplayID
    format*: SDL_PixelFormat
    w*: cint
    h*: cint
    pixel_density*: cfloat
    refresh_rate*: cfloat
    refresh_rate_numerator*: cint
    refresh_rate_denominator*: cint
    internal*: ptr SDL_DisplayModeData

  SDL_DisplayOrientation* {.size: sizeof(cint).} = enum
    SDL_ORIENTATION_UNKNOWN,
    SDL_ORIENTATION_LANDSCAPE,
    SDL_ORIENTATION_LANDSCAPE_FLIPPED,
    SDL_ORIENTATION_PORTRAIT,
    SDL_ORIENTATION_PORTRAIT_FLIPPED

  # SDL_WindowFlags* {.size: sizeof(uint64).} = enum
  SDL_WindowFlags* = uint64

const SDL_WINDOW_FULLSCREEN*           = 0x0000000000000001'u64 # window is in fullscreen mode
const SDL_WINDOW_OPENGL*               = 0x0000000000000002'u64 # window usable with OpenGL context
const SDL_WINDOW_OCCLUDED*             = 0x0000000000000004'u64 # window is occluded
const SDL_WINDOW_HIDDEN*               = 0x0000000000000008'u64
    # window is neither mapped onto the desktop nor shown in the taskbar/dock/window list; SDL_ShowWindow()  required for it to become visible
const SDL_WINDOW_BORDERLESS*           = 0x0000000000000010'u64 # no window decoration
const SDL_WINDOW_RESIZABLE*            = 0x0000000000000020'u64 # window can be resized
const SDL_WINDOW_MINIMIZED*            = 0x0000000000000040'u64 # window is minimized
const SDL_WINDOW_MAXIMIZED*            = 0x0000000000000080'u64 # window is maximized
const SDL_WINDOW_MOUSE_GRABBED*        = 0x0000000000000100'u64 # window has grabbed mouse input
const SDL_WINDOW_INPUT_FOCUS*          = 0x0000000000000200'u64 # window has input focus
const SDL_WINDOW_MOUSE_FOCUS*          = 0x0000000000000400'u64 # window has mouse focus
const SDL_WINDOW_EXTERNAL*             = 0x0000000000000800'u64 # window not created by SDL
const SDL_WINDOW_MODAL*                = 0x0000000000001000'u64 # window is modal
const SDL_WINDOW_HIGH_PIXEL_DENSITY*   = 0x0000000000002000'u64 # window uses high pixel density back buffer if possible
const SDL_WINDOW_MOUSE_CAPTURE*        = 0x0000000000004000'u64 # window has mouse captured (unrelated to MOUSE_GRABBED)
const SDL_WINDOW_MOUSE_RELATIVE_MODE*  = 0x0000000000008000'u64 # window has relative mode enabled
const SDL_WINDOW_ALWAYS_ON_TOP*        = 0x0000000000010000'u64 # window should always be above others
const SDL_WINDOW_UTILITY*              = 0x0000000000020000'u64 # window should be treated as a utility window, not showing in the task bar and window list
const SDL_WINDOW_TOOLTIP*              = 0x0000000000040000'u64 # window should be treated as a tooltip and does not get mouse or keyboard focus, requires a parent window
const SDL_WINDOW_POPUP_MENU*           = 0x0000000000080000'u64 # window should be treated as a popup menu, requires a parent window
const SDL_WINDOW_KEYBOARD_GRABBED*     = 0x0000000000100000'u64 # window has grabbed keyboard input
const SDL_WINDOW_VULKAN*               = 0x0000000010000000'u64 # window usable for Vulkan surface
const SDL_WINDOW_METAL*                = 0x0000000020000000'u64 # window usable for Metal view
const SDL_WINDOW_TRANSPARENT*          = 0x0000000040000000'u64 # window with transparent buffer
const SDL_WINDOW_NOT_FOCUSABLE*        = 0x0000000080000000'u64 # window should not be focusable

type
  SDL_FlashOperation* {.size: sizeof(cint).} = enum
    SDL_FLASH_CANCEL,
    SDL_FLASH_BRIEFLY,
    SDL_FLASH_UNTIL_FOCUSED

type
  SDL_GLContextState* = object
  SDL_GLContext* = ptr SDL_GLContextState
  SDL_EGLDisplay* = pointer
  SDL_EGLConfig* = pointer
  SDL_EGLSurface* = pointer
  SDL_EGLAttrib* = pointer # intptr_t
  SDL_EGLint* = cint
  SDL_EGLAttribArrayCallback* = proc (userdata: pointer): ptr SDL_EGLAttrib {.cdecl.}
  SDL_EGLIntArrayCallback* = proc (userdata: pointer; display: SDL_EGLDisplay; config: SDL_EGLConfig): ptr SDL_EGLint {.cdecl.}
  SDL_GLAttr* {.size: sizeof(cint).} = enum
    SDL_GL_RED_SIZE,
    SDL_GL_GREEN_SIZE,
    SDL_GL_BLUE_SIZE,
    SDL_GL_ALPHA_SIZE,
    SDL_GL_BUFFER_SIZE,
    SDL_GL_DOUBLEBUFFER,
    SDL_GL_DEPTH_SIZE,
    SDL_GL_STENCIL_SIZE,
    SDL_GL_ACCUM_RED_SIZE,
    SDL_GL_ACCUM_GREEN_SIZE,
    SDL_GL_ACCUM_BLUE_SIZE,
    SDL_GL_ACCUM_ALPHA_SIZE,
    SDL_GL_STEREO,
    SDL_GL_MULTISAMPLEBUFFERS,
    SDL_GL_MULTISAMPLESAMPLES,
    SDL_GL_ACCELERATED_VISUAL,
    SDL_GL_RETAINED_BACKING,
    SDL_GL_CONTEXT_MAJOR_VERSION,
    SDL_GL_CONTEXT_MINOR_VERSION,
    SDL_GL_CONTEXT_FLAGS,
    SDL_GL_CONTEXT_PROFILE_MASK,
    SDL_GL_SHARE_WITH_CURRENT_CONTEXT,
    SDL_GL_FRAMEBUFFER_SRGB_CAPABLE,
    SDL_GL_CONTEXT_RELEASE_BEHAVIOR,
    SDL_GL_CONTEXT_RESET_NOTIFICATION,
    SDL_GL_CONTEXT_NO_ERROR,
    SDL_GL_FLOATBUFFERS,
    SDL_GL_EGL_PLATFORM

  SDL_GLProfile* = uint32

type
  SDL_GLContextFlag* = uint32
  SDL_GLContextReleaseFlag* = uint32
  # SDL_GLContextResetNotification* = uint32

proc SDL_GetNumVideoDrivers* (): int {.importc.}
proc SDL_GetVideoDriver* ( index: int ): cstring {.importc.}
proc SDL_GetCurrentVideoDriver* (): cstring {.importc.}
proc SDL_GetSystemTheme* (): SDL_SystemTheme {.importc.}
proc SDL_GetDisplays* ( count: var int ): ptr UncheckedArray[SDL_DisplayID] {.importc.}
proc SDL_GetPrimaryDisplay* (): SDL_DisplayID {.importc.}
proc SDL_GetDisplayProperties* ( displayID: SDL_DisplayID ): SDL_PropertiesID {.importc.}
proc SDL_GetDisplayName* ( displayID: SDL_DisplayID ): cstring {.importc.}
proc SDL_GetDisplayBounds* ( displayID: SDL_DisplayID, rect: var SDL_Rect ): bool {.importc.}
proc SDL_GetDisplayUsableBounds* ( displayID: SDL_DisplayID, rect: var SDL_Rect ): bool {.importc.}
proc SDL_GetNaturalDisplayOrientation* ( displayID: SDL_DisplayID ): SDL_DisplayOrientation {.importc.}
proc SDL_GetCurrentDisplayOrientation* ( displayID: SDL_DisplayID ): SDL_DisplayOrientation {.importc.}
proc SDL_GetDisplayContentScale* ( displayID: SDL_DisplayID ): cfloat {.importc.}
proc SDL_GetFullscreenDisplayModes* ( displayID: SDL_DisplayID, count: var int ): ptr UncheckedArray[ptr SDL_DisplayMode] {.importc.}
proc SDL_GetClosestFullscreenDisplayMode* ( displayID: SDL_DisplayID, w,h: int, refresh_rate: cfloat, include_high_density_modes: bool, closest: var SDL_DisplayMode ): bool {.importc.}
proc SDL_GetDesktopDisplayMode* ( displayID: SDL_DisplayID ): ptr SDL_DisplayMode {.importc.}
proc SDL_GetCurrentDisplayMode* ( displayID: SDL_DisplayID ): ptr SDL_DisplayMode {.importc.}
proc SDL_GetDisplayForPoint* ( point: ptr SDL_Point ): SDL_DisplayID {.importc.}
proc SDL_GetDisplayForRect* ( rect: ptr SDL_Rect ): SDL_DisplayID {.importc.}

proc SDL_GetDisplayForWindow* ( window: SDL_Window ): SDL_DisplayID {.importc.}
proc SDL_GetWindowPixelDensity* ( window: SDL_Window ): cfloat {.importc.}
proc SDL_GetWindowDisplayScale* ( window: SDL_Window ): cfloat {.importc.}
proc SDL_SetWindowFullscreenMode* ( window: SDL_Window, mode: ptr SDL_DisplayMode ): bool {.importc.}
proc SDL_GetWindowFullscreenMode* ( window: SDL_Window ): ptr SDL_DisplayMode {.importc.}
proc SDL_GetWindowICCProfile* ( window: SDL_Window, size: var csize_t ): pointer {.importc.}
proc SDL_GetWindowPixelFormat* ( window: SDL_Window ): SDL_PixelFormat {.importc.}
proc SDL_GetWindows* ( count: var int ): ptr UncheckedArray[SDL_Window] {.importc.}
proc SDL_CreateWindow* ( title: cstring, w, h: cint, flags: SDL_WindowFlags ): SDL_Window {.importc.}
proc SDL_CreatePopupWindow* ( parent: SDL_Window, offset_x,offset_y,w,h: int, flags: SDL_WindowFlags ): SDL_Window {.importc.}
proc SDL_CreateWindowWithProperties* ( props: SDL_PropertiesID ): SDL_Window {.importc.}
proc SDL_GetWindowID* ( window: SDL_Window ): SDL_WindowID {.importc.}
proc SDL_GetWindowFromID* ( id: SDL_WindowID ): SDL_Window {.importc.}
proc SDL_GetWindowParent* ( window: SDL_Window ): SDL_Window {.importc.}
proc SDL_GetWindowProperties* ( window: SDL_Window ): SDL_PropertiesID {.importc.}
proc SDL_GetWindowFlags* ( window: SDL_Window ): SDL_WindowFlags {.importc.}
proc SDL_SetWindowTitle* ( window: SDL_Window, title: cstring ): bool {.importc, discardable.}
proc SDL_GetWindowTitle* ( window: SDL_Window ): cstring {.importc.}
proc SDL_SetWindowIcon* ( window: SDL_Window, icon: ptr SDL_Surface ): bool {.importc.}
proc SDL_SetWindowPosition* ( window: SDL_Window, x,y: int ): bool {.importc.}
proc SDL_GetWindowPosition* ( window: SDL_Window, x,y: var int ): bool {.importc.}
proc SDL_SetWindowSize* ( window: SDL_Window, w,h: int ): bool {.importc, discardable.}
proc SDL_GetWindowSize* ( window: SDL_Window, w,h: var int ): bool {.importc.}
proc SDL_GetWindowSafeArea* ( window: SDL_Window, rect: var SDL_Rect ): bool {.importc.}
proc SDL_SetWindowAspectRatio* ( window: SDL_Window, min_aspect,max_aspect: cfloat ): bool {.importc, discardable.}
proc SDL_GetWindowAspectRatio* ( window: SDL_Window, min_aspect,max_aspect: var cfloat ): bool {.importc.}
proc SDL_GetWindowBordersSize* ( window: SDL_Window, top,left,bottom,right: var int ): bool {.importc.}
proc SDL_GetWindowSizeInPixels* ( window: SDL_Window, w,h: var int ): bool {.importc.}
proc SDL_SetWindowMinimumSize* ( window: SDL_Window, min_w,min_h: int ): bool {.importc, discardable.}
proc SDL_GetWindowMinimumSize* ( window: SDL_Window, w,h: var int ): bool {.importc.}
proc SDL_SetWindowMaximumSize* ( window: SDL_Window, max_w,max_h: int ): bool {.importc, discardable.}
proc SDL_GetWindowMaximumSize* ( window: SDL_Window, w,h: var int ): bool {.importc.}
proc SDL_SetWindowBordered* ( window: SDL_Window, bordered: bool ): bool {.importc, discardable.}
proc SDL_SetWindowResizable* ( window: SDL_Window, resizable: bool ): bool {.importc, discardable.}
proc SDL_SetWindowAlwaysOnTop* ( window: SDL_Window, on_top: bool ): bool {.importc, discardable.}
proc SDL_ShowWindow* ( window: SDL_Window ): bool {.importc, discardable.}
proc SDL_HideWindow* ( window: SDL_Window ): bool {.importc, discardable.}
proc SDL_RaiseWindow* ( window: SDL_Window ): bool {.importc, discardable.}
proc SDL_MaximizeWindow* ( window: SDL_Window ): bool {.importc, discardable.}
proc SDL_MinimizeWindow* ( window: SDL_Window ): bool {.importc, discardable.}
proc SDL_RestoreWindow* ( window: SDL_Window ): bool {.importc, discardable.}
proc SDL_SetWindowFullscreen* ( window: SDL_Window, fullscreen: bool ): bool {.importc, discardable.}
proc SDL_SyncWindow* ( window: SDL_Window ): bool {.importc, discardable.}
proc SDL_WindowHasSurface* ( window: SDL_Window ): bool {.importc.}
proc SDL_GetWindowSurface* ( window: SDL_Window ): ptr SDL_Surface {.importc.}
proc SDL_SetWindowSurfaceVSync* ( window: SDL_Window, vsync: int ): bool {.importc, discardable.}
proc SDL_GetWindowSurfaceVSync* ( window: SDL_Window, vsync: var int ): bool {.importc.}
proc SDL_UpdateWindowSurface* ( window: SDL_Window ): bool {.importc, discardable.}
proc SDL_UpdateWindowSurfaceRects* ( window: SDL_Window, rects: ptr SDL_Rect, numrects: int ): bool {.importc, discardable.}
proc SDL_UpdateWindowSurfaceRects* ( window: SDL_Window, rects: openarray[SDL_Rect] ): bool {.importc, discardable.}
proc SDL_DestroyWindowSurface* ( window: SDL_Window ): bool {.importc, discardable.}

proc SDL_SetWindowKeyboardGrab* ( window: SDL_Window, grabbed: bool ): bool {.importc, discardable.}
proc SDL_SetWindowMouseGrab* ( window: SDL_Window, grabbed: bool ): bool {.importc, discardable.}
proc SDL_GetWindowKeyboardGrab* ( window: SDL_Window ): bool {.importc.}
proc SDL_GetWindowMouseGrab* ( window: SDL_Window ): bool {.importc.}
proc SDL_GetGrabbedWindow* (): SDL_Window {.importc.}
proc SDL_SetWindowMouseRect* ( window: SDL_Window, rect: ptr SDL_Rect ): bool {.importc, discardable.}
proc SDL_SetWindowMouseRect* ( window: SDL_Window, rect: SDL_Rect ): bool {.discardable.} =
  SDL_SetWindowMouseRect(window, rect.addr)
proc SDL_GetWindowMouseRect* ( window: SDL_Window ): ptr SDL_Rect {.importc.}
proc SDL_SetWindowOpacity* ( window: SDL_Window, opacity: cfloat ): bool {.importc, discardable.}
proc SDL_GetWindowOpacity* ( window: SDL_Window ): cfloat {.importc.}
proc SDL_SetWindowParent* ( window: SDL_Window, parent: SDL_Window ): bool {.importc, discardable.}
proc SDL_SetWindowModal* ( window: SDL_Window, modal: bool ): bool {.importc, discardable.}
proc SDL_SetWindowFocusable* ( window: SDL_Window, focusable: bool ): bool {.importc, discardable.}
proc SDL_ShowWindowSystemMenu* ( window: SDL_Window, x,y: int ): bool {.importc, discardable.}

type
  SDL_HitTestResult* {.size: sizeof(cint).} = enum
    SDL_HITTEST_NORMAL,
    SDL_HITTEST_DRAGGABLE,
    SDL_HITTEST_RESIZE_TOPLEFT,
    SDL_HITTEST_RESIZE_TOP,
    SDL_HITTEST_RESIZE_TOPRIGHT,
    SDL_HITTEST_RESIZE_RIGHT,
    SDL_HITTEST_RESIZE_BOTTOMRIGHT,
    SDL_HITTEST_RESIZE_BOTTOM,
    SDL_HITTEST_RESIZE_BOTTOMLEFT,
    SDL_HITTEST_RESIZE_LEFT

type
  SDL_HitTest* = proc (win: SDL_Window; area: ptr SDL_Point; data: pointer): SDL_HitTestResult {.cdecl.}

proc SDL_SetWindowHitTest* ( window: SDL_Window, callback: SDL_HitTest, callback_data: pointer ): bool {.importc, discardable.}
proc SDL_SetWindowShape* ( window: SDL_Window, shape: ptr SDL_Surface ): bool {.importc, discardable.}
proc SDL_FlashWindow* ( window: SDL_Window, operation: SDL_FlashOperation ): bool {.importc, discardable.}
proc SDL_DestroyWindow* ( window: SDL_Window ): void {.importc.}
proc SDL_ScreenSaverEnabled* (): bool {.importc.}
proc SDL_EnableScreenSaver* (): bool {.importc, discardable.}
proc SDL_DisableScreenSaver* (): bool {.importc, discardable.}

proc SDL_GL_LoadLibrary* ( path: cstring ): bool {.importc.}
proc SDL_GL_GetProcAddress* ( procname: cstring ): SDL_FunctionPointer {.importc.}
proc SDL_EGL_GetProcAddress* ( procname: cstring ): SDL_FunctionPointer {.importc.}
proc SDL_GL_UnloadLibrary* (): void {.importc.}
proc SDL_GL_ExtensionSupported* ( extension: cstring ): bool {.importc.}
proc SDL_GL_ResetAttributes* (): void {.importc.}
proc SDL_GL_SetAttribute* ( attr: SDL_GLAttr, value: int ): bool {.importc, discardable.}
proc SDL_GL_GetAttribute* ( attr: SDL_GLAttr, value: var int ): bool {.importc.}
proc SDL_GL_CreateContext* ( window: SDL_Window ): SDL_GLContext {.importc.}
proc SDL_GL_MakeCurrent* ( window: SDL_Window, context: SDL_GLContext ): bool {.importc.}
proc SDL_GL_GetCurrentWindow* (): SDL_Window {.importc.}
proc SDL_GL_GetCurrentContext* (): SDL_GLContext {.importc.}
proc SDL_EGL_GetCurrentDisplay* (): SDL_EGLDisplay {.importc.}
proc SDL_EGL_GetCurrentConfig* (): SDL_EGLConfig {.importc.}
proc SDL_EGL_GetWindowSurface* ( window: SDL_Window ): SDL_EGLSurface {.importc.}
proc SDL_EGL_SetAttributeCallbacks* ( platformAttribCallback: SDL_EGLAttribArrayCallback, surfaceAttribCallback: SDL_EGLIntArrayCallback, contextAttribCallback: SDL_EGLIntArrayCallback, userdata: pointer ): void {.importc.}
proc SDL_GL_SetSwapInterval* ( interval: int ): bool {.importc, discardable.}
proc SDL_GL_GetSwapInterval* ( interval: var int ): bool {.importc.}
proc SDL_GL_SwapWindow* ( window: SDL_Window ): bool {.importc, discardable.}
proc SDL_GL_DestroyContext* ( context: SDL_GLContext ): bool {.importc, discardable.}

const SDL_PROP_GLOBAL_VIDEO_WAYLAND_WL_DISPLAY_POINTER* = "SDL.video.wayland.wl_display"

const    SDL_WINDOWPOS_UNDEFINED_MASK* = 0x1FFF0000'u
template SDL_WINDOWPOS_UNDEFINED_DISPLAY* (x): untyped = SDL_WINDOWPOS_UNDEFINED_MASK or (x)
const    SDL_WINDOWPOS_UNDEFINED* = SDL_WINDOWPOS_UNDEFINED_DISPLAY(0)
template SDL_WINDOWPOS_ISUNDEFINED* (x): untyped = ((x) and 0xFFFF0000) == SDL_WINDOWPOS_UNDEFINED_MASK
const    SDL_WINDOWPOS_CENTERED_MASK* = 0x2FFF0000'u
template SDL_WINDOWPOS_CENTERED_DISPLAY* (x): untyped = SDL_WINDOWPOS_CENTERED_MASK or (x)
const    SDL_WINDOWPOS_CENTERED* = SDL_WINDOWPOS_CENTERED_DISPLAY(0)
template SDL_WINDOWPOS_ISCENTERED* (x): untyped = ((x) and 0xFFFF0000) == SDL_WINDOWPOS_CENTERED_MASK

const SDL_GL_CONTEXT_PROFILE_CORE*            = 0x0001  # OpenGL Core Profile context
const SDL_GL_CONTEXT_PROFILE_COMPATIBILITY*   = 0x0002  # OpenGL Compatibility Profile context
const SDL_GL_CONTEXT_PROFILE_ES*              = 0x0004  # GLX_CONTEXT_ES2_PROFILE_BIT_EXT
const SDL_GL_CONTEXT_DEBUG_FLAG*              = 0x0001
const SDL_GL_CONTEXT_FORWARD_COMPATIBLE_FLAG* = 0x0002
const SDL_GL_CONTEXT_ROBUST_ACCESS_FLAG*      = 0x0004
const SDL_GL_CONTEXT_RESET_ISOLATION_FLAG*    = 0x0008
const SDL_GL_CONTEXT_RELEASE_BEHAVIOR_NONE*   = 0x0000
const SDL_GL_CONTEXT_RELEASE_BEHAVIOR_FLUSH*  = 0x0001
const SDL_GL_CONTEXT_RESET_NO_NOTIFICATION*   = 0x0000
const SDL_GL_CONTEXT_RESET_LOSE_CONTEXT*      = 0x0001

const SDL_PROP_DISPLAY_HDR_ENABLED_BOOLEAN* =             "SDL.display.HDR_enabled"
const SDL_PROP_DISPLAY_KMSDRM_PANEL_ORIENTATION_NUMBER* = "SDL.display.KMSDRM.panel_orientation"

const SDL_PROP_WINDOW_CREATE_ALWAYS_ON_TOP_BOOLEAN* =               "SDL.window.create.always_on_top"
const SDL_PROP_WINDOW_CREATE_BORDERLESS_BOOLEAN* =                  "SDL.window.create.borderless"
const SDL_PROP_WINDOW_CREATE_FOCUSABLE_BOOLEAN* =                   "SDL.window.create.focusable"
const SDL_PROP_WINDOW_CREATE_EXTERNAL_GRAPHICS_CONTEXT_BOOLEAN* =   "SDL.window.create.external_graphics_context"
const SDL_PROP_WINDOW_CREATE_FLAGS_NUMBER* =                        "SDL.window.create.flags"
const SDL_PROP_WINDOW_CREATE_FULLSCREEN_BOOLEAN* =                  "SDL.window.create.fullscreen"
const SDL_PROP_WINDOW_CREATE_HEIGHT_NUMBER* =                       "SDL.window.create.height"
const SDL_PROP_WINDOW_CREATE_HIDDEN_BOOLEAN* =                      "SDL.window.create.hidden"
const SDL_PROP_WINDOW_CREATE_HIGH_PIXEL_DENSITY_BOOLEAN* =          "SDL.window.create.high_pixel_density"
const SDL_PROP_WINDOW_CREATE_MAXIMIZED_BOOLEAN* =                   "SDL.window.create.maximized"
const SDL_PROP_WINDOW_CREATE_MENU_BOOLEAN* =                        "SDL.window.create.menu"
const SDL_PROP_WINDOW_CREATE_METAL_BOOLEAN* =                       "SDL.window.create.metal"
const SDL_PROP_WINDOW_CREATE_MINIMIZED_BOOLEAN* =                   "SDL.window.create.minimized"
const SDL_PROP_WINDOW_CREATE_MODAL_BOOLEAN* =                       "SDL.window.create.modal"
const SDL_PROP_WINDOW_CREATE_MOUSE_GRABBED_BOOLEAN* =               "SDL.window.create.mouse_grabbed"
const SDL_PROP_WINDOW_CREATE_OPENGL_BOOLEAN* =                      "SDL.window.create.opengl"
const SDL_PROP_WINDOW_CREATE_PARENT_POINTER* =                      "SDL.window.create.parent"
const SDL_PROP_WINDOW_CREATE_RESIZABLE_BOOLEAN* =                   "SDL.window.create.resizable"
const SDL_PROP_WINDOW_CREATE_TITLE_STRING* =                        "SDL.window.create.title"
const SDL_PROP_WINDOW_CREATE_TRANSPARENT_BOOLEAN* =                 "SDL.window.create.transparent"
const SDL_PROP_WINDOW_CREATE_TOOLTIP_BOOLEAN* =                     "SDL.window.create.tooltip"
const SDL_PROP_WINDOW_CREATE_UTILITY_BOOLEAN* =                     "SDL.window.create.utility"
const SDL_PROP_WINDOW_CREATE_VULKAN_BOOLEAN* =                      "SDL.window.create.vulkan"
const SDL_PROP_WINDOW_CREATE_WIDTH_NUMBER* =                        "SDL.window.create.width"
const SDL_PROP_WINDOW_CREATE_X_NUMBER* =                            "SDL.window.create.x"
const SDL_PROP_WINDOW_CREATE_Y_NUMBER* =                            "SDL.window.create.y"
const SDL_PROP_WINDOW_CREATE_COCOA_WINDOW_POINTER* =                "SDL.window.create.cocoa.window"
const SDL_PROP_WINDOW_CREATE_COCOA_VIEW_POINTER* =                  "SDL.window.create.cocoa.view"
const SDL_PROP_WINDOW_CREATE_WAYLAND_SURFACE_ROLE_CUSTOM_BOOLEAN* = "SDL.window.create.wayland.surface_role_custom"
const SDL_PROP_WINDOW_CREATE_WAYLAND_CREATE_EGL_WINDOW_BOOLEAN* =   "SDL.window.create.wayland.create_egl_window"
const SDL_PROP_WINDOW_CREATE_WAYLAND_WL_SURFACE_POINTER* =          "SDL.window.create.wayland.wl_surface"
const SDL_PROP_WINDOW_CREATE_WIN32_HWND_POINTER* =                  "SDL.window.create.win32.hwnd"
const SDL_PROP_WINDOW_CREATE_WIN32_PIXEL_FORMAT_HWND_POINTER* =     "SDL.window.create.win32.pixel_format_hwnd"
const SDL_PROP_WINDOW_CREATE_X11_WINDOW_NUMBER* =                   "SDL.window.create.x11.window"
const SDL_PROP_WINDOW_SHAPE_POINTER* =                               "SDL.window.shape"
const SDL_PROP_WINDOW_HDR_ENABLED_BOOLEAN* =                         "SDL.window.HDR_enabled"
const SDL_PROP_WINDOW_SDR_WHITE_LEVEL_FLOAT* =                       "SDL.window.SDR_white_level"
const SDL_PROP_WINDOW_HDR_HEADROOM_FLOAT* =                          "SDL.window.HDR_headroom"
const SDL_PROP_WINDOW_ANDROID_WINDOW_POINTER* =                      "SDL.window.android.window"
const SDL_PROP_WINDOW_ANDROID_SURFACE_POINTER* =                     "SDL.window.android.surface"
const SDL_PROP_WINDOW_UIKIT_WINDOW_POINTER* =                        "SDL.window.uikit.window"
const SDL_PROP_WINDOW_UIKIT_METAL_VIEW_TAG_NUMBER* =                 "SDL.window.uikit.metal_view_tag"
const SDL_PROP_WINDOW_UIKIT_OPENGL_FRAMEBUFFER_NUMBER* =             "SDL.window.uikit.opengl.framebuffer"
const SDL_PROP_WINDOW_UIKIT_OPENGL_RENDERBUFFER_NUMBER* =            "SDL.window.uikit.opengl.renderbuffer"
const SDL_PROP_WINDOW_UIKIT_OPENGL_RESOLVE_FRAMEBUFFER_NUMBER* =     "SDL.window.uikit.opengl.resolve_framebuffer"
const SDL_PROP_WINDOW_KMSDRM_DEVICE_INDEX_NUMBER* =                  "SDL.window.kmsdrm.dev_index"
const SDL_PROP_WINDOW_KMSDRM_DRM_FD_NUMBER* =                        "SDL.window.kmsdrm.drm_fd"
const SDL_PROP_WINDOW_KMSDRM_GBM_DEVICE_POINTER* =                   "SDL.window.kmsdrm.gbm_dev"
const SDL_PROP_WINDOW_COCOA_WINDOW_POINTER* =                        "SDL.window.cocoa.window"
const SDL_PROP_WINDOW_COCOA_METAL_VIEW_TAG_NUMBER* =                 "SDL.window.cocoa.metal_view_tag"
const SDL_PROP_WINDOW_OPENVR_OVERLAY_ID* =                           "SDL.window.openvr.overlay_id"
const SDL_PROP_WINDOW_VIVANTE_DISPLAY_POINTER* =                     "SDL.window.vivante.display"
const SDL_PROP_WINDOW_VIVANTE_WINDOW_POINTER* =                      "SDL.window.vivante.window"
const SDL_PROP_WINDOW_VIVANTE_SURFACE_POINTER* =                     "SDL.window.vivante.surface"
const SDL_PROP_WINDOW_WIN32_HWND_POINTER* =                          "SDL.window.win32.hwnd"
const SDL_PROP_WINDOW_WIN32_HDC_POINTER* =                           "SDL.window.win32.hdc"
const SDL_PROP_WINDOW_WIN32_INSTANCE_POINTER* =                      "SDL.window.win32.instance"
const SDL_PROP_WINDOW_WAYLAND_DISPLAY_POINTER* =                     "SDL.window.wayland.display"
const SDL_PROP_WINDOW_WAYLAND_SURFACE_POINTER* =                     "SDL.window.wayland.surface"
const SDL_PROP_WINDOW_WAYLAND_VIEWPORT_POINTER* =                    "SDL.window.wayland.viewport"
const SDL_PROP_WINDOW_WAYLAND_EGL_WINDOW_POINTER* =                  "SDL.window.wayland.egl_window"
const SDL_PROP_WINDOW_WAYLAND_XDG_SURFACE_POINTER* =                 "SDL.window.wayland.xdg_surface"
const SDL_PROP_WINDOW_WAYLAND_XDG_TOPLEVEL_POINTER* =                "SDL.window.wayland.xdg_toplevel"
const SDL_PROP_WINDOW_WAYLAND_XDG_TOPLEVEL_EXPORT_HANDLE_STRING* =   "SDL.window.wayland.xdg_toplevel_export_handle"
const SDL_PROP_WINDOW_WAYLAND_XDG_POPUP_POINTER* =                   "SDL.window.wayland.xdg_popup"
const SDL_PROP_WINDOW_WAYLAND_XDG_POSITIONER_POINTER* =              "SDL.window.wayland.xdg_positioner"
const SDL_PROP_WINDOW_X11_DISPLAY_POINTER* =                         "SDL.window.x11.display"
const SDL_PROP_WINDOW_X11_SCREEN_NUMBER* =                           "SDL.window.x11.screen"
const SDL_PROP_WINDOW_X11_WINDOW_NUMBER* =                           "SDL.window.x11.window"

const SDL_WINDOW_SURFACE_VSYNC_DISABLED* = 0
const SDL_WINDOW_SURFACE_VSYNC_ADAPTIVE* = (-1)

#endregion


#region SDL3/SDL_gpu.h --------------------------------------------------------

type
  SDL_GPUDevice* = pointer
  SDL_GPUComputePipeline* = pointer
  SDL_GPUGraphicsPipeline* = pointer
  SDL_GPUCommandBuffer* = pointer
  SDL_GPURenderPass* = pointer
  SDL_GPUComputePass* = pointer
  SDL_GPUCopyPass* = pointer
  SDL_GPUFence* = pointer

  SDL_GPUPrimitiveType* {.size: sizeof(cint).} = enum
    SDL_GPU_PRIMITIVETYPE_TRIANGLELIST,
    SDL_GPU_PRIMITIVETYPE_TRIANGLESTRIP,
    SDL_GPU_PRIMITIVETYPE_LINELIST,
    SDL_GPU_PRIMITIVETYPE_LINESTRIP,
    SDL_GPU_PRIMITIVETYPE_POINTLIST

  SDL_GPULoadOp* {.size: sizeof(cint).} = enum
    SDL_GPU_LOADOP_LOAD,
    SDL_GPU_LOADOP_CLEAR,
    SDL_GPU_LOADOP_DONT_CARE

  SDL_GPUStoreOp* {.size: sizeof(cint).} = enum
    SDL_GPU_STOREOP_STORE,
    SDL_GPU_STOREOP_DONT_CARE,
    SDL_GPU_STOREOP_RESOLVE,
    SDL_GPU_STOREOP_RESOLVE_AND_STORE

  SDL_GPUIndexElementSize* {.size: sizeof(cint).} = enum
    SDL_GPU_INDEXELEMENTSIZE_16BIT,
    SDL_GPU_INDEXELEMENTSIZE_32BIT

  SDL_GPUTextureFormat* {.size: sizeof(cint).} = enum
    SDL_GPU_TEXTUREFORMAT_INVALID = 0,
    SDL_GPU_TEXTUREFORMAT_A8_UNORM,
    SDL_GPU_TEXTUREFORMAT_R8_UNORM,
    SDL_GPU_TEXTUREFORMAT_R8G8_UNORM,
    SDL_GPU_TEXTUREFORMAT_R8G8B8A8_UNORM,
    SDL_GPU_TEXTUREFORMAT_R16_UNORM,
    SDL_GPU_TEXTUREFORMAT_R16G16_UNORM,
    SDL_GPU_TEXTUREFORMAT_R16G16B16A16_UNORM,
    SDL_GPU_TEXTUREFORMAT_R10G10B10A2_UNORM,
    SDL_GPU_TEXTUREFORMAT_B5G6R5_UNORM,
    SDL_GPU_TEXTUREFORMAT_B5G5R5A1_UNORM,
    SDL_GPU_TEXTUREFORMAT_B4G4R4A4_UNORM,
    SDL_GPU_TEXTUREFORMAT_B8G8R8A8_UNORM,
    SDL_GPU_TEXTUREFORMAT_BC1_RGBA_UNORM,
    SDL_GPU_TEXTUREFORMAT_BC2_RGBA_UNORM,
    SDL_GPU_TEXTUREFORMAT_BC3_RGBA_UNORM,
    SDL_GPU_TEXTUREFORMAT_BC4_R_UNORM,
    SDL_GPU_TEXTUREFORMAT_BC5_RG_UNORM,
    SDL_GPU_TEXTUREFORMAT_BC7_RGBA_UNORM,
    SDL_GPU_TEXTUREFORMAT_BC6H_RGB_FLOAT,
    SDL_GPU_TEXTUREFORMAT_BC6H_RGB_UFLOAT,
    SDL_GPU_TEXTUREFORMAT_R8_SNORM,
    SDL_GPU_TEXTUREFORMAT_R8G8_SNORM,
    SDL_GPU_TEXTUREFORMAT_R8G8B8A8_SNORM,
    SDL_GPU_TEXTUREFORMAT_R16_SNORM,
    SDL_GPU_TEXTUREFORMAT_R16G16_SNORM,
    SDL_GPU_TEXTUREFORMAT_R16G16B16A16_SNORM,
    SDL_GPU_TEXTUREFORMAT_R16_FLOAT,
    SDL_GPU_TEXTUREFORMAT_R16G16_FLOAT,
    SDL_GPU_TEXTUREFORMAT_R16G16B16A16_FLOAT,
    SDL_GPU_TEXTUREFORMAT_R32_FLOAT,
    SDL_GPU_TEXTUREFORMAT_R32G32_FLOAT,
    SDL_GPU_TEXTUREFORMAT_R32G32B32A32_FLOAT,
    SDL_GPU_TEXTUREFORMAT_R11G11B10_UFLOAT,
    SDL_GPU_TEXTUREFORMAT_R8_UINT,
    SDL_GPU_TEXTUREFORMAT_R8G8_UINT,
    SDL_GPU_TEXTUREFORMAT_R8G8B8A8_UINT,
    SDL_GPU_TEXTUREFORMAT_R16_UINT,
    SDL_GPU_TEXTUREFORMAT_R16G16_UINT,
    SDL_GPU_TEXTUREFORMAT_R16G16B16A16_UINT,
    SDL_GPU_TEXTUREFORMAT_R32_UINT,
    SDL_GPU_TEXTUREFORMAT_R32G32_UINT,
    SDL_GPU_TEXTUREFORMAT_R32G32B32A32_UINT,
    SDL_GPU_TEXTUREFORMAT_R8_INT,
    SDL_GPU_TEXTUREFORMAT_R8G8_INT,
    SDL_GPU_TEXTUREFORMAT_R8G8B8A8_INT,
    SDL_GPU_TEXTUREFORMAT_R16_INT,
    SDL_GPU_TEXTUREFORMAT_R16G16_INT,
    SDL_GPU_TEXTUREFORMAT_R16G16B16A16_INT,
    SDL_GPU_TEXTUREFORMAT_R32_INT,
    SDL_GPU_TEXTUREFORMAT_R32G32_INT,
    SDL_GPU_TEXTUREFORMAT_R32G32B32A32_INT,
    SDL_GPU_TEXTUREFORMAT_R8G8B8A8_UNORM_SRGB,
    SDL_GPU_TEXTUREFORMAT_B8G8R8A8_UNORM_SRGB,
    SDL_GPU_TEXTUREFORMAT_BC1_RGBA_UNORM_SRGB,
    SDL_GPU_TEXTUREFORMAT_BC2_RGBA_UNORM_SRGB,
    SDL_GPU_TEXTUREFORMAT_BC3_RGBA_UNORM_SRGB,
    SDL_GPU_TEXTUREFORMAT_BC7_RGBA_UNORM_SRGB,
    SDL_GPU_TEXTUREFORMAT_D16_UNORM,
    SDL_GPU_TEXTUREFORMAT_D24_UNORM,
    SDL_GPU_TEXTUREFORMAT_D32_FLOAT,
    SDL_GPU_TEXTUREFORMAT_D24_UNORM_S8_UINT,
    SDL_GPU_TEXTUREFORMAT_D32_FLOAT_S8_UINT,
    SDL_GPU_TEXTUREFORMAT_ASTC_4x4_UNORM,
    SDL_GPU_TEXTUREFORMAT_ASTC_5x4_UNORM,
    SDL_GPU_TEXTUREFORMAT_ASTC_5x5_UNORM,
    SDL_GPU_TEXTUREFORMAT_ASTC_6x5_UNORM,
    SDL_GPU_TEXTUREFORMAT_ASTC_6x6_UNORM,
    SDL_GPU_TEXTUREFORMAT_ASTC_8x5_UNORM,
    SDL_GPU_TEXTUREFORMAT_ASTC_8x6_UNORM,
    SDL_GPU_TEXTUREFORMAT_ASTC_8x8_UNORM,
    SDL_GPU_TEXTUREFORMAT_ASTC_10x5_UNORM,
    SDL_GPU_TEXTUREFORMAT_ASTC_10x6_UNORM,
    SDL_GPU_TEXTUREFORMAT_ASTC_10x8_UNORM,
    SDL_GPU_TEXTUREFORMAT_ASTC_10x10_UNORM,
    SDL_GPU_TEXTUREFORMAT_ASTC_12x10_UNORM,
    SDL_GPU_TEXTUREFORMAT_ASTC_12x12_UNORM,
    SDL_GPU_TEXTUREFORMAT_ASTC_4x4_UNORM_SRGB,
    SDL_GPU_TEXTUREFORMAT_ASTC_5x4_UNORM_SRGB,
    SDL_GPU_TEXTUREFORMAT_ASTC_5x5_UNORM_SRGB,
    SDL_GPU_TEXTUREFORMAT_ASTC_6x5_UNORM_SRGB,
    SDL_GPU_TEXTUREFORMAT_ASTC_6x6_UNORM_SRGB,
    SDL_GPU_TEXTUREFORMAT_ASTC_8x5_UNORM_SRGB,
    SDL_GPU_TEXTUREFORMAT_ASTC_8x6_UNORM_SRGB,
    SDL_GPU_TEXTUREFORMAT_ASTC_8x8_UNORM_SRGB,
    SDL_GPU_TEXTUREFORMAT_ASTC_10x5_UNORM_SRGB,
    SDL_GPU_TEXTUREFORMAT_ASTC_10x6_UNORM_SRGB,
    SDL_GPU_TEXTUREFORMAT_ASTC_10x8_UNORM_SRGB,
    SDL_GPU_TEXTUREFORMAT_ASTC_10x10_UNORM_SRGB,
    SDL_GPU_TEXTUREFORMAT_ASTC_12x10_UNORM_SRGB,
    SDL_GPU_TEXTUREFORMAT_ASTC_12x12_UNORM_SRGB,
    SDL_GPU_TEXTUREFORMAT_ASTC_4x4_FLOAT,
    SDL_GPU_TEXTUREFORMAT_ASTC_5x4_FLOAT,
    SDL_GPU_TEXTUREFORMAT_ASTC_5x5_FLOAT,
    SDL_GPU_TEXTUREFORMAT_ASTC_6x5_FLOAT,
    SDL_GPU_TEXTUREFORMAT_ASTC_6x6_FLOAT,
    SDL_GPU_TEXTUREFORMAT_ASTC_8x5_FLOAT,
    SDL_GPU_TEXTUREFORMAT_ASTC_8x6_FLOAT,
    SDL_GPU_TEXTUREFORMAT_ASTC_8x8_FLOAT,
    SDL_GPU_TEXTUREFORMAT_ASTC_10x5_FLOAT,
    SDL_GPU_TEXTUREFORMAT_ASTC_10x6_FLOAT,
    SDL_GPU_TEXTUREFORMAT_ASTC_10x8_FLOAT,
    SDL_GPU_TEXTUREFORMAT_ASTC_10x10_FLOAT,
    SDL_GPU_TEXTUREFORMAT_ASTC_12x10_FLOAT,
    SDL_GPU_TEXTUREFORMAT_ASTC_12x12_FLOAT

  SDL_GPUTextureUsageFlags* = uint32
  SDL_GPUTextureType* {.size: sizeof(cint).} = enum
    SDL_GPU_TEXTURETYPE_2D,
    SDL_GPU_TEXTURETYPE_2D_ARRAY,
    SDL_GPU_TEXTURETYPE_3D,
    SDL_GPU_TEXTURETYPE_CUBE,
    SDL_GPU_TEXTURETYPE_CUBE_ARRAY

  SDL_GPUSampleCount* {.size: sizeof(cint).} = enum
    SDL_GPU_SAMPLECOUNT_1,
    SDL_GPU_SAMPLECOUNT_2,
    SDL_GPU_SAMPLECOUNT_4,
    SDL_GPU_SAMPLECOUNT_8

  SDL_GPUCubeMapFace* {.size: sizeof(cint).} = enum
    SDL_GPU_CUBEMAPFACE_POSITIVEX,
    SDL_GPU_CUBEMAPFACE_NEGATIVEX,
    SDL_GPU_CUBEMAPFACE_POSITIVEY,
    SDL_GPU_CUBEMAPFACE_NEGATIVEY,
    SDL_GPU_CUBEMAPFACE_POSITIVEZ,
    SDL_GPU_CUBEMAPFACE_NEGATIVEZ

  SDL_GPUBufferUsageFlags* = uint32
  SDL_GPUTransferBufferUsage* {.size: sizeof(cint).} = enum
    SDL_GPU_TRANSFERBUFFERUSAGE_UPLOAD,
    SDL_GPU_TRANSFERBUFFERUSAGE_DOWNLOAD

  SDL_GPUShaderStage* {.size: sizeof(cint).} = enum
    SDL_GPU_SHADERSTAGE_VERTEX,
    SDL_GPU_SHADERSTAGE_FRAGMENT

  SDL_GPUShaderFormat* = uint32
  SDL_GPUVertexElementFormat* {.size: sizeof(cint).} = enum
    SDL_GPU_VERTEXELEMENTFORMAT_INVALID,
    SDL_GPU_VERTEXELEMENTFORMAT_INT,
    SDL_GPU_VERTEXELEMENTFORMAT_INT2,
    SDL_GPU_VERTEXELEMENTFORMAT_INT3,
    SDL_GPU_VERTEXELEMENTFORMAT_INT4,
    SDL_GPU_VERTEXELEMENTFORMAT_UINT,
    SDL_GPU_VERTEXELEMENTFORMAT_UINT2,
    SDL_GPU_VERTEXELEMENTFORMAT_UINT3,
    SDL_GPU_VERTEXELEMENTFORMAT_UINT4,
    SDL_GPU_VERTEXELEMENTFORMAT_FLOAT,
    SDL_GPU_VERTEXELEMENTFORMAT_FLOAT2,
    SDL_GPU_VERTEXELEMENTFORMAT_FLOAT3,
    SDL_GPU_VERTEXELEMENTFORMAT_FLOAT4,
    SDL_GPU_VERTEXELEMENTFORMAT_BYTE2,
    SDL_GPU_VERTEXELEMENTFORMAT_BYTE4,
    SDL_GPU_VERTEXELEMENTFORMAT_UBYTE2,
    SDL_GPU_VERTEXELEMENTFORMAT_UBYTE4,
    SDL_GPU_VERTEXELEMENTFORMAT_BYTE2_NORM,
    SDL_GPU_VERTEXELEMENTFORMAT_BYTE4_NORM,
    SDL_GPU_VERTEXELEMENTFORMAT_UBYTE2_NORM,
    SDL_GPU_VERTEXELEMENTFORMAT_UBYTE4_NORM,
    SDL_GPU_VERTEXELEMENTFORMAT_SHORT2,
    SDL_GPU_VERTEXELEMENTFORMAT_SHORT4,
    SDL_GPU_VERTEXELEMENTFORMAT_USHORT2,
    SDL_GPU_VERTEXELEMENTFORMAT_USHORT4,
    SDL_GPU_VERTEXELEMENTFORMAT_SHORT2_NORM,
    SDL_GPU_VERTEXELEMENTFORMAT_SHORT4_NORM,
    SDL_GPU_VERTEXELEMENTFORMAT_USHORT2_NORM,
    SDL_GPU_VERTEXELEMENTFORMAT_USHORT4_NORM,
    SDL_GPU_VERTEXELEMENTFORMAT_HALF2,
    SDL_GPU_VERTEXELEMENTFORMAT_HALF4

  SDL_GPUVertexInputRate* {.size: sizeof(cint).} = enum
    SDL_GPU_VERTEXINPUTRATE_VERTEX,
    SDL_GPU_VERTEXINPUTRATE_INSTANCE

  SDL_GPUFillMode* {.size: sizeof(cint).} = enum
    SDL_GPU_FILLMODE_FILL,
    SDL_GPU_FILLMODE_LINE

  SDL_GPUCullMode* {.size: sizeof(cint).} = enum
    SDL_GPU_CULLMODE_NONE,
    SDL_GPU_CULLMODE_FRONT,
    SDL_GPU_CULLMODE_BACK

  SDL_GPUFrontFace* {.size: sizeof(cint).} = enum
    SDL_GPU_FRONTFACE_COUNTER_CLOCKWISE,
    SDL_GPU_FRONTFACE_CLOCKWISE

  SDL_GPUCompareOp* {.size: sizeof(cint).} = enum
    SDL_GPU_COMPAREOP_INVALID,
    SDL_GPU_COMPAREOP_NEVER,
    SDL_GPU_COMPAREOP_LESS,
    SDL_GPU_COMPAREOP_EQUAL,
    SDL_GPU_COMPAREOP_LESS_OR_EQUAL,
    SDL_GPU_COMPAREOP_GREATER,
    SDL_GPU_COMPAREOP_NOT_EQUAL,
    SDL_GPU_COMPAREOP_GREATER_OR_EQUAL,
    SDL_GPU_COMPAREOP_ALWAYS

  SDL_GPUStencilOp* {.size: sizeof(cint).} = enum
    SDL_GPU_STENCILOP_INVALID,
    SDL_GPU_STENCILOP_KEEP,
    SDL_GPU_STENCILOP_ZERO,
    SDL_GPU_STENCILOP_REPLACE,
    SDL_GPU_STENCILOP_INCREMENT_AND_CLAMP,
    SDL_GPU_STENCILOP_DECREMENT_AND_CLAMP,
    SDL_GPU_STENCILOP_INVERT,
    SDL_GPU_STENCILOP_INCREMENT_AND_WRAP,
    SDL_GPU_STENCILOP_DECREMENT_AND_WRAP

  SDL_GPUBlendOp* {.size: sizeof(cint).} = enum
    SDL_GPU_BLENDOP_INVALID,
    SDL_GPU_BLENDOP_ADD,
    SDL_GPU_BLENDOP_SUBTRACT,
    SDL_GPU_BLENDOP_REVERSE_SUBTRACT,
    SDL_GPU_BLENDOP_MIN,
    SDL_GPU_BLENDOP_MAX

  SDL_GPUBlendFactor* {.size: sizeof(cint).} = enum
    SDL_GPU_BLENDFACTOR_INVALID,
    SDL_GPU_BLENDFACTOR_ZERO,
    SDL_GPU_BLENDFACTOR_ONE,
    SDL_GPU_BLENDFACTOR_SRC_COLOR,
    SDL_GPU_BLENDFACTOR_ONE_MINUS_SRC_COLOR,
    SDL_GPU_BLENDFACTOR_DST_COLOR,
    SDL_GPU_BLENDFACTOR_ONE_MINUS_DST_COLOR,
    SDL_GPU_BLENDFACTOR_SRC_ALPHA,
    SDL_GPU_BLENDFACTOR_ONE_MINUS_SRC_ALPHA,
    SDL_GPU_BLENDFACTOR_DST_ALPHA,
    SDL_GPU_BLENDFACTOR_ONE_MINUS_DST_ALPHA,
    SDL_GPU_BLENDFACTOR_CONSTANT_COLOR,
    SDL_GPU_BLENDFACTOR_ONE_MINUS_CONSTANT_COLOR,
    SDL_GPU_BLENDFACTOR_SRC_ALPHA_SATURATE

  SDL_GPUColorComponentFlags* = uint8
  SDL_GPUFilter* {.size: sizeof(cint).} = enum
    SDL_GPU_FILTER_NEAREST,
    SDL_GPU_FILTER_LINEAR

  SDL_GPUSamplerMipmapMode* {.size: sizeof(cint).} = enum
    SDL_GPU_SAMPLERMIPMAPMODE_NEAREST,
    SDL_GPU_SAMPLERMIPMAPMODE_LINEAR

  SDL_GPUSamplerAddressMode* {.size: sizeof(cint).} = enum
    SDL_GPU_SAMPLERADDRESSMODE_REPEAT,
    SDL_GPU_SAMPLERADDRESSMODE_MIRRORED_REPEAT,
    SDL_GPU_SAMPLERADDRESSMODE_CLAMP_TO_EDGE

  SDL_GPUPresentMode* {.size: sizeof(cint).} = enum
    SDL_GPU_PRESENTMODE_VSYNC,
    SDL_GPU_PRESENTMODE_IMMEDIATE,
    SDL_GPU_PRESENTMODE_MAILBOX

  SDL_GPUSwapchainComposition* {.size: sizeof(cint).} = enum
    SDL_GPU_SWAPCHAINCOMPOSITION_SDR,
    SDL_GPU_SWAPCHAINCOMPOSITION_SDR_LINEAR,
    SDL_GPU_SWAPCHAINCOMPOSITION_HDR_EXTENDED_LINEAR,
    SDL_GPU_SWAPCHAINCOMPOSITION_HDR10_ST2084

  SDL_GPUViewport* {.bycopy.} = object
    x*: cfloat
    y*: cfloat
    w*: cfloat
    h*: cfloat
    min_depth*: cfloat
    max_depth*: cfloat

  SDL_GPUTransferBuffer* = pointer

  SDL_GPUTextureTransferInfo* {.bycopy.} = object
    transfer_buffer*: ptr SDL_GPUTransferBuffer
    offset*: uint32
    pixels_per_row*: uint32
    rows_per_layer*: uint32

  SDL_GPUTransferBufferLocation* {.bycopy.} = object
    transfer_buffer*: ptr SDL_GPUTransferBuffer
    offset*: uint32

  SDL_GPUTexture* = pointer

  SDL_GPUTextureLocation* {.bycopy.} = object
    texture*: ptr SDL_GPUTexture
    mip_level*: uint32
    layer*: uint32
    x*: uint32
    y*: uint32
    z*: uint32

  SDL_GPUTextureRegion* {.bycopy.} = object
    texture*: ptr SDL_GPUTexture
    mip_level*: uint32
    layer*: uint32
    x*: uint32
    y*: uint32
    z*: uint32
    w*: uint32
    h*: uint32
    d*: uint32

  SDL_GPUBlitRegion* {.bycopy.} = object
    texture*: ptr SDL_GPUTexture
    mip_level*: uint32
    layer_or_depth_plane*: uint32
    x*: uint32
    y*: uint32
    w*: uint32
    h*: uint32

  SDL_GPUBuffer* = pointer

  SDL_GPUBufferLocation* {.bycopy.} = object
    buffer*: ptr SDL_GPUBuffer
    offset*: uint32

  SDL_GPUBufferRegion* {.bycopy.} = object
    buffer*: ptr SDL_GPUBuffer
    offset*: uint32
    size*: uint32

  SDL_GPUIndirectDrawCommand* {.bycopy.} = object
    num_vertices*: uint32
    num_instances*: uint32
    first_vertex*: uint32
    first_instance*: uint32

  SDL_GPUIndexedIndirectDrawCommand* {.bycopy.} = object
    num_indices*: uint32
    num_instances*: uint32
    first_index*: uint32
    vertex_offset*: int32
    first_instance*: uint32

  SDL_GPUIndirectDispatchCommand* {.bycopy.} = object
    groupcount_x*: uint32
    groupcount_y*: uint32
    groupcount_z*: uint32

  SDL_GPUSamplerCreateInfo* {.bycopy.} = object
    min_filter*: SDL_GPUFilter
    mag_filter*: SDL_GPUFilter
    mipmap_mode*: SDL_GPUSamplerMipmapMode
    address_mode_u*: SDL_GPUSamplerAddressMode
    address_mode_v*: SDL_GPUSamplerAddressMode
    address_mode_w*: SDL_GPUSamplerAddressMode
    mip_lod_bias*: cfloat
    max_anisotropy*: cfloat
    compare_op*: SDL_GPUCompareOp
    min_lod*: cfloat
    max_lod*: cfloat
    enable_anisotropy*: bool
    enable_compare*: bool
    padding1*: uint8
    padding2*: uint8
    props*: SDL_PropertiesID

  SDL_GPUVertexBufferDescription* {.bycopy.} = object
    slot*: uint32
    pitch*: uint32
    input_rate*: SDL_GPUVertexInputRate
    instance_step_rate*: uint32

  SDL_GPUVertexAttribute* {.bycopy.} = object
    location*: uint32
    buffer_slot*: uint32
    format*: SDL_GPUVertexElementFormat
    offset*: uint32

  SDL_GPUVertexInputState* {.bycopy.} = object
    vertex_buffer_descriptions*: ptr UncheckedArray[SDL_GPUVertexBufferDescription]
    num_vertex_buffers*: uint32
    vertex_attributes*: ptr UncheckedArray[SDL_GPUVertexAttribute]
    num_vertex_attributes*: uint32

  SDL_GPUStencilOpState* {.bycopy.} = object
    fail_op*: SDL_GPUStencilOp
    pass_op*: SDL_GPUStencilOp
    depth_fail_op*: SDL_GPUStencilOp
    compare_op*: SDL_GPUCompareOp

  SDL_GPUColorTargetBlendState* {.bycopy.} = object
    src_color_blendfactor*: SDL_GPUBlendFactor
    dst_color_blendfactor*: SDL_GPUBlendFactor
    color_blend_op*: SDL_GPUBlendOp
    src_alpha_blendfactor*: SDL_GPUBlendFactor
    dst_alpha_blendfactor*: SDL_GPUBlendFactor
    alpha_blend_op*: SDL_GPUBlendOp
    color_write_mask*: SDL_GPUColorComponentFlags
    enable_blend*: bool
    enable_color_write_mask*: bool
    padding1*: uint8
    padding2*: uint8

  SDL_GPUShaderCreateInfo* {.bycopy.} = object
    code_size*: csize_t
    code*: ptr UncheckedArray[uint8]
    entrypoint*: cstring
    format*: SDL_GPUShaderFormat
    stage*: SDL_GPUShaderStage
    num_samplers*: uint32
    num_storage_textures*: uint32
    num_storage_buffers*: uint32
    num_uniform_buffers*: uint32
    props*: SDL_PropertiesID

  SDL_GPUTextureCreateInfo* {.bycopy.} = object
    `type`*: SDL_GPUTextureType
    format*: SDL_GPUTextureFormat
    usage*: SDL_GPUTextureUsageFlags
    width*: uint32
    height*: uint32
    layer_count_or_depth*: uint32
    num_levels*: uint32
    sample_count*: SDL_GPUSampleCount
    props*: SDL_PropertiesID

  SDL_GPUBufferCreateInfo* {.bycopy.} = object
    usage*: SDL_GPUBufferUsageFlags
    size*: uint32
    props*: SDL_PropertiesID

  SDL_GPUTransferBufferCreateInfo* {.bycopy.} = object
    usage*: SDL_GPUTransferBufferUsage
    size*: uint32
    props*: SDL_PropertiesID

  SDL_GPURasterizerState* {.bycopy.} = object
    fill_mode*: SDL_GPUFillMode
    cull_mode*: SDL_GPUCullMode
    front_face*: SDL_GPUFrontFace
    depth_bias_constant_factor*: cfloat
    depth_bias_clamp*: cfloat
    depth_bias_slope_factor*: cfloat
    enable_depth_bias*: bool
    enable_depth_clip*: bool
    padding1*: uint8
    padding2*: uint8

  SDL_GPUMultisampleState* {.bycopy.} = object
    sample_count*: SDL_GPUSampleCount
    sample_mask*: uint32
    enable_mask*: bool
    padding1*: uint8
    padding2*: uint8
    padding3*: uint8

  SDL_GPUDepthStencilState* {.bycopy.} = object
    compare_op*: SDL_GPUCompareOp
    back_stencil_state*: SDL_GPUStencilOpState
    front_stencil_state*: SDL_GPUStencilOpState
    compare_mask*: uint8
    write_mask*: uint8
    enable_depth_test*: bool
    enable_depth_write*: bool
    enable_stencil_test*: bool
    padding1*: uint8
    padding2*: uint8
    padding3*: uint8

  SDL_GPUColorTargetDescription* {.bycopy.} = object
    format*: SDL_GPUTextureFormat
    blend_state*: SDL_GPUColorTargetBlendState

  SDL_GPUGraphicsPipelineTargetInfo* {.bycopy.} = object
    color_target_descriptions*: ptr UncheckedArray[SDL_GPUColorTargetDescription]
    num_color_targets*: uint32
    depth_stencil_format*: SDL_GPUTextureFormat
    has_depth_stencil_target*: bool
    padding1*: uint8
    padding2*: uint8
    padding3*: uint8

  SDL_GPUShader* = pointer

  SDL_GPUGraphicsPipelineCreateInfo* {.bycopy.} = object
    vertex_shader*: ptr SDL_GPUShader
    fragment_shader*: ptr SDL_GPUShader
    vertex_input_state*: SDL_GPUVertexInputState
    primitive_type*: SDL_GPUPrimitiveType
    rasterizer_state*: SDL_GPURasterizerState
    multisample_state*: SDL_GPUMultisampleState
    depth_stencil_state*: SDL_GPUDepthStencilState
    target_info*: SDL_GPUGraphicsPipelineTargetInfo
    props*: SDL_PropertiesID

  SDL_GPUComputePipelineCreateInfo* {.bycopy.} = object
    code_size*: csize_t
    code*: ptr UncheckedArray[uint8]
    entrypoint*: cstring
    format*: SDL_GPUShaderFormat
    num_samplers*: uint32
    num_readonly_storage_textures*: uint32
    num_readonly_storage_buffers*: uint32
    num_readwrite_storage_textures*: uint32
    num_readwrite_storage_buffers*: uint32
    num_uniform_buffers*: uint32
    threadcount_x*: uint32
    threadcount_y*: uint32
    threadcount_z*: uint32
    props*: SDL_PropertiesID

  SDL_GPUColorTargetInfo* {.bycopy.} = object
    texture*: ptr SDL_GPUTexture
    mip_level*: uint32
    layer_or_depth_plane*: uint32
    clear_color*: SDL_FColor
    load_op*: SDL_GPULoadOp
    store_op*: SDL_GPUStoreOp
    resolve_texture*: ptr SDL_GPUTexture
    resolve_mip_level*: uint32
    resolve_layer*: uint32
    cycle*: bool
    cycle_resolve_texture*: bool
    padding1*: uint8
    padding2*: uint8

  SDL_GPUDepthStencilTargetInfo* {.bycopy.} = object
    texture*: ptr SDL_GPUTexture
    clear_depth*: cfloat
    load_op*: SDL_GPULoadOp
    store_op*: SDL_GPUStoreOp
    stencil_load_op*: SDL_GPULoadOp
    stencil_store_op*: SDL_GPUStoreOp
    cycle*: bool
    clear_stencil*: uint8
    padding1*: uint8
    padding2*: uint8

  SDL_GPUBlitInfo* {.bycopy.} = object
    source*: SDL_GPUBlitRegion
    destination*: SDL_GPUBlitRegion
    load_op*: SDL_GPULoadOp
    clear_color*: SDL_FColor
    flip_mode*: SDL_FlipMode
    filter*: SDL_GPUFilter
    cycle*: bool
    padding1*: uint8
    padding2*: uint8
    padding3*: uint8

  SDL_GPUBufferBinding* {.bycopy.} = object
    buffer*: ptr SDL_GPUBuffer
    offset*: uint32

  SDL_GPUSampler* = object

  SDL_GPUTextureSamplerBinding* {.bycopy.} = object
    texture*: ptr SDL_GPUTexture
    sampler*: ptr SDL_GPUSampler

  SDL_GPUStorageBufferReadWriteBinding* {.bycopy.} = object
    buffer*: ptr SDL_GPUBuffer
    cycle*: bool
    padding1*: uint8
    padding2*: uint8
    padding3*: uint8

  SDL_GPUStorageTextureReadWriteBinding* {.bycopy.} = object
    texture*: ptr SDL_GPUTexture
    mip_level*: uint32
    layer*: uint32
    cycle*: bool
    padding1*: uint8
    padding2*: uint8
    padding3*: uint8

proc SDL_GPUSupportsShaderFormats* ( format_flags: SDL_GPUShaderFormat, name: cstring ): bool {.importc.}
proc SDL_GPUSupportsProperties* ( props: SDL_PropertiesID ): bool {.importc.}

proc SDL_CreateGPUDevice* ( format_flags: SDL_GPUShaderFormat, debug_mode: bool, name: cstring ): SDL_GPUDevice {.importc.}
proc SDL_CreateGPUDeviceWithProperties* ( props: SDL_PropertiesID): SDL_GPUDevice {.importc.}
proc SDL_DestroyGPUDevice* ( device: SDL_GPUDevice ): void {.importc.}
proc SDL_GetNumGPUDrivers* (): int {.importc.}
proc SDL_GetGPUDriver* ( index: int ): cstring {.importc.}
proc SDL_GetGPUDeviceDriver* ( device: SDL_GPUDevice ): cstring {.importc.}
proc SDL_GetGPUShaderFormats* ( device: SDL_GPUDevice ): SDL_GPUShaderFormat {.importc.}
proc SDL_CreateGPUComputePipeline* ( device: SDL_GPUDevice, createinfo: ptr SDL_GPUComputePipelineCreateInfo ): SDL_GPUComputePipeline {.importc.}
proc SDL_CreateGPUGraphicsPipeline* ( device: SDL_GPUDevice, createinfo: ptr SDL_GPUGraphicsPipelineCreateInfo ): SDL_GPUGraphicsPipeline {.importc.}
proc SDL_CreateGPUSampler* ( device: SDL_GPUDevice, createinfo: ptr SDL_GPUSamplerCreateInfo ): SDL_GPUSampler {.importc.}
proc SDL_CreateGPUShader* ( device: SDL_GPUDevice, createinfo: ptr SDL_GPUShaderCreateInfo ): SDL_GPUShader {.importc.}
proc SDL_CreateGPUTexture* ( device: SDL_GPUDevice, createinfo: ptr SDL_GPUTextureCreateInfo ): SDL_GPUTexture {.importc.}
proc SDL_CreateGPUBuffer* ( device: SDL_GPUDevice, createinfo: ptr SDL_GPUBufferCreateInfo ): SDL_GPUBuffer {.importc.}
proc SDL_CreateGPUTransferBuffer* ( device: SDL_GPUDevice, createinfo: ptr SDL_GPUTransferBufferCreateInfo ): SDL_GPUTransferBuffer {.importc.}
proc SDL_SetGPUBufferName* ( device: SDL_GPUDevice, buffer: SDL_GPUBuffer, text: cstring ): void {.importc.}
proc SDL_SetGPUTextureName* ( device: SDL_GPUDevice, texture: SDL_GPUTexture, text: cstring ): void {.importc.}

proc SDL_InsertGPUDebugLabel* ( command_buffer: SDL_GPUCommandBuffer, text: cstring ): void {.importc.}
proc SDL_PushGPUDebugGroup* ( command_buffer: SDL_GPUCommandBuffer, name: cstring ): void {.importc.}
proc SDL_PopGPUDebugGroup* ( command_buffer: SDL_GPUCommandBuffer ): void {.importc.}
proc SDL_ReleaseGPUTexture* ( device: SDL_GPUDevice, texture: SDL_GPUTexture ): void {.importc.}
proc SDL_ReleaseGPUSampler* ( device: SDL_GPUDevice, sampler: SDL_GPUSampler ): void {.importc.}
proc SDL_ReleaseGPUBuffer* ( device: SDL_GPUDevice, buffer: SDL_GPUBuffer ): void {.importc.}
proc SDL_ReleaseGPUTransferBuffer* ( device: SDL_GPUDevice, transfer_buffer: SDL_GPUTransferBuffer ): void {.importc.}
proc SDL_ReleaseGPUComputePipeline* ( device: SDL_GPUDevice, compute_pipeline: SDL_GPUComputePipeline ): void {.importc.}
proc SDL_ReleaseGPUShader* ( device: SDL_GPUDevice, shader: SDL_GPUShader ): void {.importc.}
proc SDL_ReleaseGPUGraphicsPipeline* ( device: SDL_GPUDevice, graphics_pipeline: SDL_GPUGraphicsPipeline ): void {.importc.}
proc SDL_AcquireGPUCommandBuffer* ( device: SDL_GPUDevice ): SDL_GPUCommandBuffer {.importc.}
proc SDL_PushGPUVertexUniformData* ( command_buffer: SDL_GPUCommandBuffer, slot_index: uint32, data: pointer, length: uint32 ): void {.importc.}
proc SDL_PushGPUFragmentUniformData* ( command_buffer: SDL_GPUCommandBuffer, slot_index: uint32, data: pointer, length: uint32 ): void {.importc.}
proc SDL_PushGPUComputeUniformData* ( command_buffer: SDL_GPUCommandBuffer, slot_index: uint32, data: pointer, length: uint32 ): void {.importc.}

proc SDL_BeginGPURenderPass* ( command_buffer: SDL_GPUCommandBuffer, color_target_infos: ptr SDL_GPUColorTargetInfo, num_color_targets: uint32, depth_stencil_target_info: ptr SDL_GPUDepthStencilTargetInfo ): SDL_GPURenderPass {.importc.}
proc SDL_BindGPUGraphicsPipeline* ( render_pass: SDL_GPURenderPass, graphics_pipeline: SDL_GPUGraphicsPipeline ): void {.importc.}
proc SDL_SetGPUViewport* ( render_pass: SDL_GPURenderPass, viewport: ptr SDL_GPUViewport ): void {.importc.}
proc SDL_SetGPUScissor* ( render_pass: SDL_GPURenderPass, scissor: ptr SDL_Rect ): void {.importc.}
proc SDL_SetGPUBlendConstants* ( render_pass: SDL_GPURenderPass, blend_constants: SDL_FColor ): void {.importc.}
proc SDL_SetGPUStencilReference* ( render_pass: SDL_GPURenderPass, reference: uint8 ): void {.importc.}
proc SDL_BindGPUVertexBuffers* ( render_pass: SDL_GPURenderPass, first_slot: uint32, bindings: ptr SDL_GPUBufferBinding, num_bindings: uint32 ): void {.importc.}
proc SDL_BindGPUIndexBuffer* ( render_pass: SDL_GPURenderPass, binding: ptr SDL_GPUBufferBinding, index_element_size: SDL_GPUIndexElementSize ): void {.importc.}
proc SDL_BindGPUVertexSamplers* ( render_pass: SDL_GPURenderPass, first_slot: uint32, texture_sampler_bindings: ptr SDL_GPUTextureSamplerBinding, num_bindings: uint32 ): void {.importc.}
proc SDL_BindGPUVertexStorageTextures* ( render_pass: SDL_GPURenderPass, first_slot: uint32, storage_textures: ptr[SDL_GPUTexture], num_bindings: uint32 ): void {.importc.}
proc SDL_BindGPUVertexStorageBuffers* ( render_pass: SDL_GPURenderPass, first_slot: uint32, storage_buffers: ptr[SDL_GPUBuffer], num_bindings: uint32 ): void {.importc.}
proc SDL_BindGPUFragmentSamplers* ( render_pass: SDL_GPURenderPass, first_slot: uint32, texture_sampler_bindings: ptr SDL_GPUTextureSamplerBinding, num_bindings: uint32 ): void {.importc.}
proc SDL_BindGPUFragmentStorageTextures* ( render_pass: SDL_GPURenderPass, first_slot: uint32, storage_textures: ptr[SDL_GPUTexture], num_bindings: uint32 ): void {.importc.}
proc SDL_BindGPUFragmentStorageBuffers* ( render_pass: SDL_GPURenderPass, first_slot: uint32, storage_buffers: ptr[SDL_GPUBuffer], num_bindings: uint32 ): void {.importc.}

proc SDL_DrawGPUIndexedPrimitives* ( render_pass: SDL_GPURenderPass, num_indices: uint32, num_instances: uint32, first_index: uint32, vertex_offset: int32, first_instance: uint32 ): void {.importc.}
proc SDL_DrawGPUPrimitives* ( render_pass: SDL_GPURenderPass, num_vertices: uint32, num_instances: uint32, first_vertex: uint32, first_instance: uint32 ): void {.importc.}
proc SDL_DrawGPUPrimitivesIndirect* ( render_pass: SDL_GPURenderPass, buffer: SDL_GPUBuffer, offset: uint32, draw_count: uint32 ): void {.importc.}
proc SDL_DrawGPUIndexedPrimitivesIndirect* ( render_pass: SDL_GPURenderPass, buffer: SDL_GPUBuffer, offset: uint32, draw_count: uint32 ): void {.importc.}
proc SDL_EndGPURenderPass* ( render_pass: SDL_GPURenderPass ): void {.importc.}

proc  SDL_BeginGPUComputePass* ( command_buffer: SDL_GPUCommandBuffer, storage_texture_bindings: ptr[SDL_GPUStorageTextureReadWriteBinding], num_storage_texture_bindings: uint32, storage_buffer_bindings: ptr[SDL_GPUStorageBufferReadWriteBinding], num_storage_buffer_bindings: uint32 ): SDL_GPUComputePass {.importc.}
proc  SDL_BindGPUComputePipeline* ( compute_pass: SDL_GPUComputePass, compute_pipeline: SDL_GPUComputePipeline ): void {.importc.}
proc  SDL_BindGPUComputeSamplers* ( compute_pass: SDL_GPUComputePass, first_slot: uint32, texture_sampler_bindings: ptr SDL_GPUTextureSamplerBinding, num_bindings: uint32 ): void {.importc.}
proc  SDL_BindGPUComputeStorageTextures* ( compute_pass: SDL_GPUComputePass, first_slot: uint32, storage_textures: ptr[SDL_GPUTexture], num_bindings: uint32 ): void {.importc.}
proc  SDL_BindGPUComputeStorageBuffers* ( compute_pass: SDL_GPUComputePass, first_slot: uint32, storage_buffers: ptr[SDL_GPUBuffer], num_bindings: uint32 ): void {.importc.}
proc  SDL_DispatchGPUCompute* ( compute_pass: SDL_GPUComputePass, groupcount_x,groupcount_y,groupcount_z: uint32 ): void {.importc.}
proc  SDL_DispatchGPUComputeIndirect* ( compute_pass: SDL_GPUComputePass, buffer: SDL_GPUBuffer, offset: uint32 ): void {.importc.}
proc  SDL_EndGPUComputePass* ( compute_pass: SDL_GPUComputePass ): void {.importc.}

proc SDL_MapGPUTransferBuffer* ( device: SDL_GPUDevice, transfer_buffer: SDL_GPUTransferBuffer, cycle: bool ): pointer {.importc.}
proc SDL_UnmapGPUTransferBuffer* ( device: SDL_GPUDevice, transfer_buffer: SDL_GPUTransferBuffer ): void {.importc.}

proc SDL_BeginGPUCopyPass* ( command_buffer: SDL_GPUCommandBuffer ): SDL_GPUCopyPass {.importc.}
proc SDL_UploadToGPUTexture* ( copy_pass: SDL_GPUCopyPass, source: ptr SDL_GPUTextureTransferInfo, destination: ptr SDL_GPUTextureRegion, cycle: bool ): void {.importc.}
proc SDL_UploadToGPUBuffer* ( copy_pass: SDL_GPUCopyPass, source: ptr SDL_GPUTransferBufferLocation, destination: ptr SDL_GPUBufferRegion, cycle: bool ): void {.importc.}
proc SDL_CopyGPUTextureToTexture* ( copy_pass: SDL_GPUCopyPass, source: ptr SDL_GPUTextureLocation, destination: ptr SDL_GPUTextureLocation, w,h,d: uint32, cycle: bool ): void {.importc.}
proc SDL_CopyGPUBufferToBuffer* ( copy_pass: SDL_GPUCopyPass, source: ptr SDL_GPUBufferLocation, destination: ptr SDL_GPUBufferLocation, size: uint32, cycle: bool ): void {.importc.}
proc SDL_DownloadFromGPUTexture* ( copy_pass: SDL_GPUCopyPass, source: ptr SDL_GPUTextureRegion, destination: ptr SDL_GPUTextureTransferInfo ): void {.importc.}
proc SDL_DownloadFromGPUBuffer* ( copy_pass: SDL_GPUCopyPass, source: ptr SDL_GPUBufferRegion, destination: ptr SDL_GPUTransferBufferLocation ): void {.importc.}
proc SDL_EndGPUCopyPass* ( copy_pass: SDL_GPUCopyPass ): void {.importc.}
proc SDL_GenerateMipmapsForGPUTexture* ( command_buffer: SDL_GPUCommandBuffer, texture: SDL_GPUTexture ): void {.importc.}
proc SDL_BlitGPUTexture* ( command_buffer: SDL_GPUCommandBuffer, info: ptr SDL_GPUBlitInfo ): void {.importc.}
proc SDL_WindowSupportsGPUSwapchainComposition* ( device: SDL_GPUDevice, window: SDL_Window, swapchain_composition: SDL_GPUSwapchainComposition ): bool {.importc.}
proc SDL_WindowSupportsGPUPresentMode* ( device: SDL_GPUDevice, window: SDL_Window, present_mode: SDL_GPUPresentMode ): bool {.importc.}
proc SDL_ClaimWindowForGPUDevice* ( device: SDL_GPUDevice, window: SDL_Window ): bool {.importc.}
proc SDL_ReleaseWindowFromGPUDevice* ( device: SDL_GPUDevice, window: SDL_Window ): void {.importc.}
proc SDL_SetGPUSwapchainParameters* ( device: SDL_GPUDevice, window: SDL_Window, swapchain_composition: SDL_GPUSwapchainComposition, present_mode: SDL_GPUPresentMode ): bool {.importc.}
proc SDL_SetGPUAllowedFramesInFlight* ( device: SDL_GPUDevice, allowed_frames_in_flight: uint32 ): bool {.importc.}
proc SDL_GetGPUSwapchainTextureFormat* ( device: SDL_GPUDevice, window: SDL_Window ): SDL_GPUTextureFormat {.importc.}
proc SDL_AcquireGPUSwapchainTexture* ( command_buffer: SDL_GPUCommandBuffer, window: SDL_Window, swapchain_texture: SDL_GPUTexture, swapchain_texture_width: var uint32, swapchain_texture_height: var uint32 ): bool {.importc.}
proc SDL_WaitForGPUSwapchain* ( device: SDL_GPUDevice, window: SDL_Window ): bool {.importc.}
proc SDL_WaitAndAcquireGPUSwapchainTexture* ( command_buffer: SDL_GPUCommandBuffer, window: SDL_Window, swapchain_texture: SDL_GPUTexture, swapchain_texture_width: var uint32, swapchain_texture_height: var uint32 ): bool {.importc.}
proc SDL_SubmitGPUCommandBuffer* ( command_buffer: SDL_GPUCommandBuffer ): bool {.importc.}

proc SDL_SubmitGPUCommandBufferAndAcquireFence* ( command_buffer: SDL_GPUCommandBuffer ): SDL_GPUFence {.importc.}
proc SDL_CancelGPUCommandBuffer* ( command_buffer: SDL_GPUCommandBuffer ): bool {.importc.}
proc SDL_WaitForGPUIdle* ( device: SDL_GPUDevice ): bool {.importc.}
proc SDL_WaitForGPUFences* ( device: SDL_GPUDevice, wait_all: bool, fences: ptr[SDL_GPUFence], num_fences: uint32 ): bool {.importc.}
proc SDL_WaitForGPUFences* ( device: SDL_GPUDevice, wait_all: bool, fences: openarray[SDL_GPUFence] ): bool {.importc.}
proc SDL_QueryGPUFence* ( device: SDL_GPUDevice, fence: SDL_GPUFence ): bool {.importc.}
proc SDL_ReleaseGPUFence* ( device: SDL_GPUDevice, fence: SDL_GPUFence ): void {.importc.}
proc SDL_GPUTextureFormatTexelBlockSize* ( format: SDL_GPUTextureFormat ): uint32 {.importc.}
proc SDL_GPUTextureSupportsFormat* ( device: SDL_GPUDevice, format: SDL_GPUTextureFormat, kind: SDL_GPUTextureType, usage: SDL_GPUTextureUsageFlags ): bool {.importc.}
proc SDL_GPUTextureSupportsSampleCount* ( device: SDL_GPUDevice, format: SDL_GPUTextureFormat, sample_count: SDL_GPUSampleCount ): bool {.importc.}
proc SDL_CalculateGPUTextureFormatSize* ( format: SDL_GPUTextureFormat, width,height: uint32, depth_or_layer_count: uint32 ): uint32 {.importc.}

when defined(SDL_PLATFORM_GDK):
  proc SDL_GDKSuspendGPU* ( device: SDL_GPUDevice ): void
  proc SDL_GDKResumeGPU* ( device: SDL_GPUDevice ): void

const SDL_GPU_TEXTUREUSAGE_SAMPLER*               = (1'u shl 0) # Texture supports sampling.
const SDL_GPU_TEXTUREUSAGE_COLOR_TARGET*          = (1'u shl 1) # Texture is a color render target.
const SDL_GPU_TEXTUREUSAGE_DEPTH_STENCIL_TARGET*  = (1'u shl 2) # Texture is a depth stencil target.
const SDL_GPU_TEXTUREUSAGE_GRAPHICS_STORAGE_READ* = (1'u shl 3) # Texture supports storage reads in graphics stages.
const SDL_GPU_TEXTUREUSAGE_COMPUTE_STORAGE_READ*  = (1'u shl 4) # Texture supports storage reads in the compute stage.
const SDL_GPU_TEXTUREUSAGE_COMPUTE_STORAGE_WRITE* = (1'u shl 5) # Texture supports storage writes in the compute stage.
const SDL_GPU_TEXTUREUSAGE_COMPUTE_STORAGE_SIMULTANEOUS_READ_WRITE* = (1'u shl 6) # Texture supports reads and writes in the same compute shader. This is NOT equivalent to READ | WRITE.

const SDL_GPU_BUFFERUSAGE_VERTEX*                = (1'u shl 0) # Buffer is a vertex buffer.
const SDL_GPU_BUFFERUSAGE_INDEX*                 = (1'u shl 1) # Buffer is an index buffer.
const SDL_GPU_BUFFERUSAGE_INDIRECT*              = (1'u shl 2) # Buffer is an indirect buffer.
const SDL_GPU_BUFFERUSAGE_GRAPHICS_STORAGE_READ* = (1'u shl 3) # Buffer supports storage reads in graphics stages.
const SDL_GPU_BUFFERUSAGE_COMPUTE_STORAGE_READ*  = (1'u shl 4) # Buffer supports storage reads in the compute stage.
const SDL_GPU_BUFFERUSAGE_COMPUTE_STORAGE_WRITE* = (1'u shl 5) # Buffer supports storage writes in the compute stage.

const SDL_GPU_SHADERFORMAT_INVALID*  = 0
const SDL_GPU_SHADERFORMAT_PRIVATE*  = (1'u shl 0) # Shaders for NDA'd platforms.
const SDL_GPU_SHADERFORMAT_SPIRV*    = (1'u shl 1) # SPIR-V shaders for Vulkan.
const SDL_GPU_SHADERFORMAT_DXBC*     = (1'u shl 2) # DXBC SM5_1 shaders for D3D12.
const SDL_GPU_SHADERFORMAT_DXIL*     = (1'u shl 3) # DXIL SM6_0 shaders for D3D12.
const SDL_GPU_SHADERFORMAT_MSL*      = (1'u shl 4) # MSL shaders for Metal.
const SDL_GPU_SHADERFORMAT_METALLIB* = (1'u shl 5) # Precompiled metallib shaders for Metal.

const SDL_GPU_COLORCOMPONENT_R* = (1'u shl 0) # the red component
const SDL_GPU_COLORCOMPONENT_G* = (1'u shl 1) # the green component
const SDL_GPU_COLORCOMPONENT_B* = (1'u shl 2) # the blue component
const SDL_GPU_COLORCOMPONENT_A* = (1'u shl 3) # the alpha component

const SDL_PROP_GPU_DEVICE_CREATE_DEBUGMODE_BOOLEAN*          = "SDL.gpu.device.create.debugmode"
const SDL_PROP_GPU_DEVICE_CREATE_PREFERLOWPOWER_BOOLEAN*     = "SDL.gpu.device.create.preferlowpower"
const SDL_PROP_GPU_DEVICE_CREATE_NAME_STRING*                = "SDL.gpu.device.create.name"
const SDL_PROP_GPU_DEVICE_CREATE_SHADERS_PRIVATE_BOOLEAN*    = "SDL.gpu.device.create.shaders.private"
const SDL_PROP_GPU_DEVICE_CREATE_SHADERS_SPIRV_BOOLEAN*      = "SDL.gpu.device.create.shaders.spirv"
const SDL_PROP_GPU_DEVICE_CREATE_SHADERS_DXBC_BOOLEAN*       = "SDL.gpu.device.create.shaders.dxbc"
const SDL_PROP_GPU_DEVICE_CREATE_SHADERS_DXIL_BOOLEAN*       = "SDL.gpu.device.create.shaders.dxil"
const SDL_PROP_GPU_DEVICE_CREATE_SHADERS_MSL_BOOLEAN*        = "SDL.gpu.device.create.shaders.msl"
const SDL_PROP_GPU_DEVICE_CREATE_SHADERS_METALLIB_BOOLEAN*   = "SDL.gpu.device.create.shaders.metallib"
const SDL_PROP_GPU_DEVICE_CREATE_D3D12_SEMANTIC_NAME_STRING* = "SDL.gpu.device.create.d3d12.semantic"

const SDL_PROP_GPU_CREATETEXTURE_D3D12_CLEAR_R_FLOAT*       = "SDL.gpu.createtexture.d3d12.clear.r"
const SDL_PROP_GPU_CREATETEXTURE_D3D12_CLEAR_G_FLOAT*       = "SDL.gpu.createtexture.d3d12.clear.g"
const SDL_PROP_GPU_CREATETEXTURE_D3D12_CLEAR_B_FLOAT*       = "SDL.gpu.createtexture.d3d12.clear.b"
const SDL_PROP_GPU_CREATETEXTURE_D3D12_CLEAR_A_FLOAT*       = "SDL.gpu.createtexture.d3d12.clear.a"
const SDL_PROP_GPU_CREATETEXTURE_D3D12_CLEAR_DEPTH_FLOAT*   = "SDL.gpu.createtexture.d3d12.clear.depth"
const SDL_PROP_GPU_CREATETEXTURE_D3D12_CLEAR_STENCIL_UINT8* = "SDL.gpu.createtexture.d3d12.clear.stencil"

#endregion


#region SDL3/SDL_guid.h -------------------------------------------------------

type
  SDL_GUID* {.bycopy.} = object
    data*: array[16, uint8]

proc SDL_GUIDToString* ( guid: SDL_GUID, pszGUID: var cstring, cbGUID: int ): void {.importc.}
proc SDL_StringToGUID* ( pchGUID: cstring ): SDL_GUID {.importc.}

#endregion


#region SDL3/SDL_hidapi.h -----------------------------------------------------

type
  SDL_hid_device* = pointer

  SDL_hid_bus_type* {.size: sizeof(cint).} = enum
    SDL_HID_API_BUS_UNKNOWN = 0x00,
    SDL_HID_API_BUS_USB = 0x01,
    SDL_HID_API_BUS_BLUETOOTH = 0x02,
    SDL_HID_API_BUS_I2C = 0x03,
    SDL_HID_API_BUS_SPI = 0x04

  SDL_hid_device_info* {.bycopy.} = object
    path*: cstring
    vendor_id*: cushort
    product_id*: cushort
    serial_number*: ptr UncheckedArray[cwchar_t]
    release_number*: cushort
    manufacturer_string*: ptr UncheckedArray[cwchar_t]
    product_string*: ptr UncheckedArray[cwchar_t]
    usage_page*: cushort
    usage*: cushort
    interface_number*: cint
    interface_class*: cint
    interface_subclass*: cint
    interface_protocol*: cint
    bus_type*: SDL_hid_bus_type
    next*: ptr SDL_hid_device_info

proc SDL_hid_init* (): int {.importc.}
proc SDL_hid_exit* (): int {.importc.}
proc SDL_hid_device_change_count* (): uint32 {.importc.}
proc SDL_hid_enumerate* ( vendor_id,product_id: uint16 ): ptr[SDL_hid_device_info] {.importc.}
  ## NOTE: vendor_id was "unsigned short"
proc SDL_hid_free_enumeration* ( devs: ptr[SDL_hid_device_info] ): void {.importc.}
proc SDL_hid_open* ( vendor_id,product_id: uint16, serial_number: ptr[cwchar_t] ): SDL_hid_device {.importc.}
  ## NOTE: vendor_id was "unsigned short"
proc SDL_hid_open_path* ( path: cstring ): SDL_hid_device {.importc.}
proc SDL_hid_write* ( dev: SDL_hid_device, data: ptr[uint8], length: csize_t ): int {.importc.}
proc SDL_hid_read_timeout* ( dev: SDL_hid_device, data: var ptr[uint8], length: csize_t, milliseconds: int ): int {.importc.}
proc SDL_hid_read* ( dev: SDL_hid_device, data: var ptr[uint8], length: csize_t ): int {.importc.}
proc SDL_hid_set_nonblocking* ( dev: SDL_hid_device, nonblock: int ): int {.importc.}
proc SDL_hid_send_feature_report* ( dev: SDL_hid_device, data: ptr[uint8], length: csize_t ): int {.importc.}
proc SDL_hid_get_feature_report* ( dev: SDL_hid_device, data: var ptr[uint8], length: csize_t ): int {.importc.}
proc SDL_hid_get_input_report* ( dev: SDL_hid_device, data: var ptr[uint8], length: csize_t ): int {.importc.}
proc SDL_hid_close* ( dev: SDL_hid_device ): int {.importc.}
proc SDL_hid_get_manufacturer_string* ( dev: SDL_hid_device, str: ptr[cwchar_t], maxlen: csize_t ): int {.importc.}
proc SDL_hid_get_product_string* ( dev: SDL_hid_device, str: ptr[cwchar_t], maxlen: csize_t ): int {.importc.}
proc SDL_hid_get_serial_number_string* ( dev: SDL_hid_device, str: ptr[cwchar_t], maxlen: csize_t ): int {.importc.}
proc SDL_hid_get_indexed_string* ( dev: SDL_hid_device, string_index: int, str: ptr[cwchar_t], maxlen: csize_t ): int {.importc.}
proc SDL_hid_get_device_info* ( dev: SDL_hid_device ): ptr[SDL_hid_device_info] {.importc.}
proc SDL_hid_get_report_descriptor* ( dev: SDL_hid_device, buf: var ptr[uint8], buf_size: csize_t ): int {.importc.}
proc SDL_hid_ble_scan* ( active: bool ): void {.importc.}

#endregion


#region SDL3/SDL_hints.h ------------------------------------------------------

type
  SDL_HintPriority* {.size: sizeof(cint).} = enum
    SDL_HINT_DEFAULT,
    SDL_HINT_NORMAL,
    SDL_HINT_OVERRIDE

  SDL_HintCallback* = proc (userdata: pointer; name: cstring; oldValue: cstring; newValue: cstring) {.cdecl.}

proc SDL_SetHintWithPriority* ( name: cstring, value: cstring, priority: SDL_HintPriority ): bool {.importc, discardable.}
proc SDL_SetHint* ( name: cstring, value: cstring ): bool {.importc, discardable.}
proc SDL_ResetHint* ( name: cstring ): bool {.importc.}
proc SDL_ResetHints* (): void {.importc.}
proc SDL_GetHint* ( name: cstring ): cstring {.importc.}
proc SDL_GetHintBoolean* ( name: cstring, default_value: bool ): bool {.importc.}

proc SDL_AddHintCallback* ( name: cstring, callback: SDL_HintCallback, userdata: pointer ): bool {.importc.}
proc SDL_RemoveHintCallback* ( name: cstring, callback: SDL_HintCallback, userdata: pointer ): void {.importc.}

const SDL_HINT_ALLOW_ALT_TAB_WHILE_GRABBED*: cstring = "SDL_ALLOW_ALT_TAB_WHILE_GRABBED"
const SDL_HINT_ANDROID_ALLOW_RECREATE_ACTIVITY*: cstring = "SDL_ANDROID_ALLOW_RECREATE_ACTIVITY"
const SDL_HINT_ANDROID_BLOCK_ON_PAUSE*: cstring = "SDL_ANDROID_BLOCK_ON_PAUSE"
const SDL_HINT_ANDROID_LOW_LATENCY_AUDIO*: cstring = "SDL_ANDROID_LOW_LATENCY_AUDIO"
const SDL_HINT_ANDROID_TRAP_BACK_BUTTON*: cstring = "SDL_ANDROID_TRAP_BACK_BUTTON"
const SDL_HINT_APP_ID*: cstring = "SDL_APP_ID"
const SDL_HINT_APP_NAME*: cstring = "SDL_APP_NAME"
const SDL_HINT_APPLE_TV_CONTROLLER_UI_EVENTS*: cstring = "SDL_APPLE_TV_CONTROLLER_UI_EVENTS"
const SDL_HINT_APPLE_TV_REMOTE_ALLOW_ROTATION*: cstring = "SDL_APPLE_TV_REMOTE_ALLOW_ROTATION"
const SDL_HINT_AUDIO_ALSA_DEFAULT_DEVICE*: cstring = "SDL_AUDIO_ALSA_DEFAULT_DEVICE"
const SDL_HINT_AUDIO_ALSA_DEFAULT_PLAYBACK_DEVICE*: cstring = "SDL_AUDIO_ALSA_DEFAULT_PLAYBACK_DEVICE"
const SDL_HINT_AUDIO_ALSA_DEFAULT_RECORDING_DEVICE*: cstring = "SDL_AUDIO_ALSA_DEFAULT_RECORDING_DEVICE"
const SDL_HINT_AUDIO_CATEGORY*: cstring = "SDL_AUDIO_CATEGORY"
const SDL_HINT_AUDIO_CHANNELS*: cstring = "SDL_AUDIO_CHANNELS"
const SDL_HINT_AUDIO_DEVICE_APP_ICON_NAME*: cstring = "SDL_AUDIO_DEVICE_APP_ICON_NAME"
const SDL_HINT_AUDIO_DEVICE_SAMPLE_FRAMES*: cstring = "SDL_AUDIO_DEVICE_SAMPLE_FRAMES"
const SDL_HINT_AUDIO_DEVICE_STREAM_NAME*: cstring = "SDL_AUDIO_DEVICE_STREAM_NAME"
const SDL_HINT_AUDIO_DEVICE_STREAM_ROLE*: cstring = "SDL_AUDIO_DEVICE_STREAM_ROLE"
const SDL_HINT_AUDIO_DISK_INPUT_FILE*: cstring = "SDL_AUDIO_DISK_INPUT_FILE"
const SDL_HINT_AUDIO_DISK_OUTPUT_FILE*: cstring = "SDL_AUDIO_DISK_OUTPUT_FILE"
const SDL_HINT_AUDIO_DISK_TIMESCALE*: cstring = "SDL_AUDIO_DISK_TIMESCALE"
const SDL_HINT_AUDIO_DRIVER*: cstring = "SDL_AUDIO_DRIVER"
const SDL_HINT_AUDIO_DUMMY_TIMESCALE*: cstring = "SDL_AUDIO_DUMMY_TIMESCALE"
const SDL_HINT_AUDIO_FORMAT*: cstring = "SDL_AUDIO_FORMAT"
const SDL_HINT_AUDIO_FREQUENCY*: cstring = "SDL_AUDIO_FREQUENCY"
const SDL_HINT_AUDIO_INCLUDE_MONITORS*: cstring = "SDL_AUDIO_INCLUDE_MONITORS"
const SDL_HINT_AUTO_UPDATE_JOYSTICKS*: cstring = "SDL_AUTO_UPDATE_JOYSTICKS"
const SDL_HINT_AUTO_UPDATE_SENSORS*: cstring = "SDL_AUTO_UPDATE_SENSORS"
const SDL_HINT_BMP_SAVE_LEGACY_FORMAT*: cstring = "SDL_BMP_SAVE_LEGACY_FORMAT"
const SDL_HINT_CAMERA_DRIVER*: cstring = "SDL_CAMERA_DRIVER"
const SDL_HINT_CPU_FEATURE_MASK*: cstring = "SDL_CPU_FEATURE_MASK"
const SDL_HINT_JOYSTICK_DIRECTINPUT*: cstring = "SDL_JOYSTICK_DIRECTINPUT"
const SDL_HINT_FILE_DIALOG_DRIVER*: cstring = "SDL_FILE_DIALOG_DRIVER"
const SDL_HINT_DISPLAY_USABLE_BOUNDS*: cstring = "SDL_DISPLAY_USABLE_BOUNDS"
const SDL_HINT_EMSCRIPTEN_ASYNCIFY*: cstring = "SDL_EMSCRIPTEN_ASYNCIFY"
const SDL_HINT_EMSCRIPTEN_CANVAS_SELECTOR*: cstring = "SDL_EMSCRIPTEN_CANVAS_SELECTOR"
const SDL_HINT_EMSCRIPTEN_KEYBOARD_ELEMENT*: cstring = "SDL_EMSCRIPTEN_KEYBOARD_ELEMENT"
const SDL_HINT_ENABLE_SCREEN_KEYBOARD*: cstring = "SDL_ENABLE_SCREEN_KEYBOARD"
const SDL_HINT_EVDEV_DEVICES*: cstring = "SDL_EVDEV_DEVICES"
const SDL_HINT_EVENT_LOGGING*: cstring = "SDL_EVENT_LOGGING"
const SDL_HINT_FORCE_RAISEWINDOW*: cstring = "SDL_FORCE_RAISEWINDOW"
const SDL_HINT_FRAMEBUFFER_ACCELERATION*: cstring = "SDL_FRAMEBUFFER_ACCELERATION"
const SDL_HINT_GAMECONTROLLERCONFIG*: cstring = "SDL_GAMECONTROLLERCONFIG"
const SDL_HINT_GAMECONTROLLERCONFIG_FILE*: cstring = "SDL_GAMECONTROLLERCONFIG_FILE"
const SDL_HINT_GAMECONTROLLERTYPE*: cstring = "SDL_GAMECONTROLLERTYPE"
const SDL_HINT_GAMECONTROLLER_IGNORE_DEVICES*: cstring = "SDL_GAMECONTROLLER_IGNORE_DEVICES"
const SDL_HINT_GAMECONTROLLER_IGNORE_DEVICES_EXCEPT*: cstring = "SDL_GAMECONTROLLER_IGNORE_DEVICES_EXCEPT"
const SDL_HINT_GAMECONTROLLER_SENSOR_FUSION*: cstring = "SDL_GAMECONTROLLER_SENSOR_FUSION"
const SDL_HINT_GDK_TEXTINPUT_DEFAULT_TEXT*: cstring = "SDL_GDK_TEXTINPUT_DEFAULT_TEXT"
const SDL_HINT_GDK_TEXTINPUT_DESCRIPTION*: cstring = "SDL_GDK_TEXTINPUT_DESCRIPTION"
const SDL_HINT_GDK_TEXTINPUT_MAX_LENGTH*: cstring = "SDL_GDK_TEXTINPUT_MAX_LENGTH"
const SDL_HINT_GDK_TEXTINPUT_SCOPE*: cstring = "SDL_GDK_TEXTINPUT_SCOPE"
const SDL_HINT_GDK_TEXTINPUT_TITLE*: cstring = "SDL_GDK_TEXTINPUT_TITLE"
const SDL_HINT_HIDAPI_LIBUSB*: cstring = "SDL_HIDAPI_LIBUSB"
const SDL_HINT_HIDAPI_LIBUSB_WHITELIST*: cstring = "SDL_HIDAPI_LIBUSB_WHITELIST"
const SDL_HINT_HIDAPI_UDEV*: cstring = "SDL_HIDAPI_UDEV"
const SDL_HINT_GPU_DRIVER*: cstring = "SDL_GPU_DRIVER"
const SDL_HINT_HIDAPI_ENUMERATE_ONLY_CONTROLLERS*: cstring = "SDL_HIDAPI_ENUMERATE_ONLY_CONTROLLERS"
const SDL_HINT_HIDAPI_IGNORE_DEVICES*: cstring = "SDL_HIDAPI_IGNORE_DEVICES"
const SDL_HINT_IME_IMPLEMENTED_UI*: cstring = "SDL_IME_IMPLEMENTED_UI"
const SDL_HINT_IOS_HIDE_HOME_INDICATOR*: cstring = "SDL_IOS_HIDE_HOME_INDICATOR"
const SDL_HINT_JOYSTICK_ALLOW_BACKGROUND_EVENTS*: cstring = "SDL_JOYSTICK_ALLOW_BACKGROUND_EVENTS"
const SDL_HINT_JOYSTICK_ARCADESTICK_DEVICES*: cstring = "SDL_JOYSTICK_ARCADESTICK_DEVICES"
const SDL_HINT_JOYSTICK_ARCADESTICK_DEVICES_EXCLUDED*: cstring = "SDL_JOYSTICK_ARCADESTICK_DEVICES_EXCLUDED"
const SDL_HINT_JOYSTICK_BLACKLIST_DEVICES*: cstring = "SDL_JOYSTICK_BLACKLIST_DEVICES"
const SDL_HINT_JOYSTICK_BLACKLIST_DEVICES_EXCLUDED*: cstring = "SDL_JOYSTICK_BLACKLIST_DEVICES_EXCLUDED"
const SDL_HINT_JOYSTICK_DEVICE*: cstring = "SDL_JOYSTICK_DEVICE"
const SDL_HINT_JOYSTICK_ENHANCED_REPORTS*: cstring = "SDL_JOYSTICK_ENHANCED_REPORTS"
const SDL_HINT_JOYSTICK_FLIGHTSTICK_DEVICES*: cstring = "SDL_JOYSTICK_FLIGHTSTICK_DEVICES"
const SDL_HINT_JOYSTICK_FLIGHTSTICK_DEVICES_EXCLUDED*: cstring = "SDL_JOYSTICK_FLIGHTSTICK_DEVICES_EXCLUDED"
const SDL_HINT_JOYSTICK_GAMEINPUT*: cstring = "SDL_JOYSTICK_GAMEINPUT"
const SDL_HINT_JOYSTICK_GAMECUBE_DEVICES*: cstring = "SDL_JOYSTICK_GAMECUBE_DEVICES"
const SDL_HINT_JOYSTICK_GAMECUBE_DEVICES_EXCLUDED*: cstring = "SDL_JOYSTICK_GAMECUBE_DEVICES_EXCLUDED"
const SDL_HINT_JOYSTICK_HIDAPI*: cstring = "SDL_JOYSTICK_HIDAPI"
const SDL_HINT_JOYSTICK_HIDAPI_COMBINE_JOY_CONS*: cstring = "SDL_JOYSTICK_HIDAPI_COMBINE_JOY_CONS"
const SDL_HINT_JOYSTICK_HIDAPI_GAMECUBE*: cstring = "SDL_JOYSTICK_HIDAPI_GAMECUBE"
const SDL_HINT_JOYSTICK_HIDAPI_GAMECUBE_RUMBLE_BRAKE*: cstring = "SDL_JOYSTICK_HIDAPI_GAMECUBE_RUMBLE_BRAKE"
const SDL_HINT_JOYSTICK_HIDAPI_JOY_CONS*: cstring = "SDL_JOYSTICK_HIDAPI_JOY_CONS"
const SDL_HINT_JOYSTICK_HIDAPI_JOYCON_HOME_LED*: cstring = "SDL_JOYSTICK_HIDAPI_JOYCON_HOME_LED"
const SDL_HINT_JOYSTICK_HIDAPI_LUNA*: cstring = "SDL_JOYSTICK_HIDAPI_LUNA"
const SDL_HINT_JOYSTICK_HIDAPI_NINTENDO_CLASSIC*: cstring = "SDL_JOYSTICK_HIDAPI_NINTENDO_CLASSIC"
const SDL_HINT_JOYSTICK_HIDAPI_PS3*: cstring = "SDL_JOYSTICK_HIDAPI_PS3"
const SDL_HINT_JOYSTICK_HIDAPI_PS3_SIXAXIS_DRIVER*: cstring = "SDL_JOYSTICK_HIDAPI_PS3_SIXAXIS_DRIVER"
const SDL_HINT_JOYSTICK_HIDAPI_PS4*: cstring = "SDL_JOYSTICK_HIDAPI_PS4"
const SDL_HINT_JOYSTICK_HIDAPI_PS4_REPORT_INTERVAL*: cstring = "SDL_JOYSTICK_HIDAPI_PS4_REPORT_INTERVAL"
const SDL_HINT_JOYSTICK_HIDAPI_PS5*: cstring = "SDL_JOYSTICK_HIDAPI_PS5"
const SDL_HINT_JOYSTICK_HIDAPI_PS5_PLAYER_LED*: cstring = "SDL_JOYSTICK_HIDAPI_PS5_PLAYER_LED"
const SDL_HINT_JOYSTICK_HIDAPI_SHIELD*: cstring = "SDL_JOYSTICK_HIDAPI_SHIELD"
const SDL_HINT_JOYSTICK_HIDAPI_STADIA*: cstring = "SDL_JOYSTICK_HIDAPI_STADIA"
const SDL_HINT_JOYSTICK_HIDAPI_STEAM*: cstring = "SDL_JOYSTICK_HIDAPI_STEAM"
const SDL_HINT_JOYSTICK_HIDAPI_STEAM_HOME_LED*: cstring = "SDL_JOYSTICK_HIDAPI_STEAM_HOME_LED"
const SDL_HINT_JOYSTICK_HIDAPI_STEAMDECK*: cstring = "SDL_JOYSTICK_HIDAPI_STEAMDECK"
const SDL_HINT_JOYSTICK_HIDAPI_STEAM_HORI*: cstring = "SDL_JOYSTICK_HIDAPI_STEAM_HORI"
const SDL_HINT_JOYSTICK_HIDAPI_SWITCH*: cstring = "SDL_JOYSTICK_HIDAPI_SWITCH"
const SDL_HINT_JOYSTICK_HIDAPI_SWITCH_HOME_LED*: cstring = "SDL_JOYSTICK_HIDAPI_SWITCH_HOME_LED"
const SDL_HINT_JOYSTICK_HIDAPI_SWITCH_PLAYER_LED*: cstring = "SDL_JOYSTICK_HIDAPI_SWITCH_PLAYER_LED"
const SDL_HINT_JOYSTICK_HIDAPI_VERTICAL_JOY_CONS*: cstring = "SDL_JOYSTICK_HIDAPI_VERTICAL_JOY_CONS"
const SDL_HINT_JOYSTICK_HIDAPI_WII*: cstring = "SDL_JOYSTICK_HIDAPI_WII"
const SDL_HINT_JOYSTICK_HIDAPI_WII_PLAYER_LED*: cstring = "SDL_JOYSTICK_HIDAPI_WII_PLAYER_LED"
const SDL_HINT_JOYSTICK_HIDAPI_XBOX*: cstring = "SDL_JOYSTICK_HIDAPI_XBOX"
const SDL_HINT_JOYSTICK_HIDAPI_XBOX_360*: cstring = "SDL_JOYSTICK_HIDAPI_XBOX_360"
const SDL_HINT_JOYSTICK_HIDAPI_XBOX_360_PLAYER_LED*: cstring = "SDL_JOYSTICK_HIDAPI_XBOX_360_PLAYER_LED"
const SDL_HINT_JOYSTICK_HIDAPI_XBOX_360_WIRELESS*: cstring = "SDL_JOYSTICK_HIDAPI_XBOX_360_WIRELESS"
const SDL_HINT_JOYSTICK_HIDAPI_XBOX_ONE*: cstring = "SDL_JOYSTICK_HIDAPI_XBOX_ONE"
const SDL_HINT_JOYSTICK_HIDAPI_XBOX_ONE_HOME_LED*: cstring = "SDL_JOYSTICK_HIDAPI_XBOX_ONE_HOME_LED"
const SDL_HINT_JOYSTICK_IOKIT*: cstring = "SDL_JOYSTICK_IOKIT"
const SDL_HINT_JOYSTICK_LINUX_CLASSIC*: cstring = "SDL_JOYSTICK_LINUX_CLASSIC"
const SDL_HINT_JOYSTICK_LINUX_DEADZONES*: cstring = "SDL_JOYSTICK_LINUX_DEADZONES"
const SDL_HINT_JOYSTICK_LINUX_DIGITAL_HATS*: cstring = "SDL_JOYSTICK_LINUX_DIGITAL_HATS"
const SDL_HINT_JOYSTICK_LINUX_HAT_DEADZONES*: cstring = "SDL_JOYSTICK_LINUX_HAT_DEADZONES"
const SDL_HINT_JOYSTICK_MFI*: cstring = "SDL_JOYSTICK_MFI"
const SDL_HINT_JOYSTICK_RAWINPUT*: cstring = "SDL_JOYSTICK_RAWINPUT"
const SDL_HINT_JOYSTICK_RAWINPUT_CORRELATE_XINPUT*: cstring = "SDL_JOYSTICK_RAWINPUT_CORRELATE_XINPUT"
const SDL_HINT_JOYSTICK_ROG_CHAKRAM*: cstring = "SDL_JOYSTICK_ROG_CHAKRAM"
const SDL_HINT_JOYSTICK_THREAD*: cstring = "SDL_JOYSTICK_THREAD"
const SDL_HINT_JOYSTICK_THROTTLE_DEVICES*: cstring = "SDL_JOYSTICK_THROTTLE_DEVICES"
const SDL_HINT_JOYSTICK_THROTTLE_DEVICES_EXCLUDED*: cstring = "SDL_JOYSTICK_THROTTLE_DEVICES_EXCLUDED"
const SDL_HINT_JOYSTICK_WGI*: cstring = "SDL_JOYSTICK_WGI"
const SDL_HINT_JOYSTICK_WHEEL_DEVICES*: cstring = "SDL_JOYSTICK_WHEEL_DEVICES"
const SDL_HINT_JOYSTICK_WHEEL_DEVICES_EXCLUDED*: cstring = "SDL_JOYSTICK_WHEEL_DEVICES_EXCLUDED"
const SDL_HINT_JOYSTICK_ZERO_CENTERED_DEVICES*: cstring = "SDL_JOYSTICK_ZERO_CENTERED_DEVICES"
const SDL_HINT_KEYCODE_OPTIONS*: cstring = "SDL_KEYCODE_OPTIONS"
const SDL_HINT_KMSDRM_DEVICE_INDEX*: cstring = "SDL_KMSDRM_DEVICE_INDEX"
const SDL_HINT_KMSDRM_REQUIRE_DRM_MASTER*: cstring = "SDL_KMSDRM_REQUIRE_DRM_MASTER"
const SDL_HINT_LOGGING*: cstring = "SDL_LOGGING"
const SDL_HINT_MAC_BACKGROUND_APP*: cstring = "SDL_MAC_BACKGROUND_APP"
const SDL_HINT_MAC_CTRL_CLICK_EMULATE_RIGHT_CLICK*: cstring = "SDL_MAC_CTRL_CLICK_EMULATE_RIGHT_CLICK"
const SDL_HINT_MAC_OPENGL_ASYNC_DISPATCH*: cstring = "SDL_MAC_OPENGL_ASYNC_DISPATCH"
const SDL_HINT_MAC_SCROLL_MOMENTUM*: cstring = "SDL_MAC_SCROLL_MOMENTUM"
const SDL_HINT_MAIN_CALLBACK_RATE*: cstring = "SDL_MAIN_CALLBACK_RATE"
const SDL_HINT_MOUSE_AUTO_CAPTURE*: cstring = "SDL_MOUSE_AUTO_CAPTURE"
const SDL_HINT_MOUSE_DOUBLE_CLICK_RADIUS*: cstring = "SDL_MOUSE_DOUBLE_CLICK_RADIUS"
const SDL_HINT_MOUSE_DOUBLE_CLICK_TIME*: cstring = "SDL_MOUSE_DOUBLE_CLICK_TIME"
const SDL_HINT_MOUSE_DEFAULT_SYSTEM_CURSOR*: cstring = "SDL_MOUSE_DEFAULT_SYSTEM_CURSOR"
const SDL_HINT_MOUSE_EMULATE_WARP_WITH_RELATIVE*: cstring = "SDL_MOUSE_EMULATE_WARP_WITH_RELATIVE"
const SDL_HINT_MOUSE_FOCUS_CLICKTHROUGH*: cstring = "SDL_MOUSE_FOCUS_CLICKTHROUGH"
const SDL_HINT_MOUSE_NORMAL_SPEED_SCALE*: cstring = "SDL_MOUSE_NORMAL_SPEED_SCALE"
const SDL_HINT_MOUSE_RELATIVE_MODE_CENTER*: cstring = "SDL_MOUSE_RELATIVE_MODE_CENTER"
const SDL_HINT_MOUSE_RELATIVE_SPEED_SCALE*: cstring = "SDL_MOUSE_RELATIVE_SPEED_SCALE"
const SDL_HINT_MOUSE_RELATIVE_SYSTEM_SCALE*: cstring = "SDL_MOUSE_RELATIVE_SYSTEM_SCALE"
const SDL_HINT_MOUSE_RELATIVE_WARP_MOTION*: cstring = "SDL_MOUSE_RELATIVE_WARP_MOTION"
const SDL_HINT_MOUSE_RELATIVE_CURSOR_VISIBLE*: cstring = "SDL_MOUSE_RELATIVE_CURSOR_VISIBLE"
const SDL_HINT_MOUSE_TOUCH_EVENTS*: cstring = "SDL_MOUSE_TOUCH_EVENTS"
const SDL_HINT_MUTE_CONSOLE_KEYBOARD*: cstring = "SDL_MUTE_CONSOLE_KEYBOARD"
const SDL_HINT_NO_SIGNAL_HANDLERS*: cstring = "SDL_NO_SIGNAL_HANDLERS"
const SDL_HINT_OPENGL_LIBRARY*: cstring = "SDL_OPENGL_LIBRARY"
const SDL_HINT_EGL_LIBRARY*: cstring = "SDL_EGL_LIBRARY"
const SDL_HINT_OPENGL_ES_DRIVER*: cstring = "SDL_OPENGL_ES_DRIVER"
const SDL_HINT_OPENVR_LIBRARY*: cstring =              "SDL_OPENVR_LIBRARY"
const SDL_HINT_ORIENTATIONS*: cstring = "SDL_ORIENTATIONS"
const SDL_HINT_POLL_SENTINEL*: cstring = "SDL_POLL_SENTINEL"
const SDL_HINT_PREFERRED_LOCALES*: cstring = "SDL_PREFERRED_LOCALES"
const SDL_HINT_QUIT_ON_LAST_WINDOW_CLOSE*: cstring = "SDL_QUIT_ON_LAST_WINDOW_CLOSE"
const SDL_HINT_RENDER_DIRECT3D_THREADSAFE*: cstring = "SDL_RENDER_DIRECT3D_THREADSAFE"
const SDL_HINT_RENDER_DIRECT3D11_DEBUG*: cstring = "SDL_RENDER_DIRECT3D11_DEBUG"
const SDL_HINT_RENDER_VULKAN_DEBUG*: cstring = "SDL_RENDER_VULKAN_DEBUG"
const SDL_HINT_RENDER_GPU_DEBUG*: cstring = "SDL_RENDER_GPU_DEBUG"
const SDL_HINT_RENDER_GPU_LOW_POWER*: cstring = "SDL_RENDER_GPU_LOW_POWER"
const SDL_HINT_RENDER_DRIVER*: cstring = "SDL_RENDER_DRIVER"
const SDL_HINT_RENDER_LINE_METHOD*: cstring = "SDL_RENDER_LINE_METHOD"
const SDL_HINT_RENDER_METAL_PREFER_LOW_POWER_DEVICE*: cstring = "SDL_RENDER_METAL_PREFER_LOW_POWER_DEVICE"
const SDL_HINT_RENDER_VSYNC*: cstring = "SDL_RENDER_VSYNC"
const SDL_HINT_RETURN_KEY_HIDES_IME*: cstring = "SDL_RETURN_KEY_HIDES_IME"
const SDL_HINT_ROG_GAMEPAD_MICE*: cstring = "SDL_ROG_GAMEPAD_MICE"
const SDL_HINT_ROG_GAMEPAD_MICE_EXCLUDED*: cstring = "SDL_ROG_GAMEPAD_MICE_EXCLUDED"
const SDL_HINT_RPI_VIDEO_LAYER*: cstring = "SDL_RPI_VIDEO_LAYER"
const SDL_HINT_SCREENSAVER_INHIBIT_ACTIVITY_NAME*: cstring = "SDL_SCREENSAVER_INHIBIT_ACTIVITY_NAME"
const SDL_HINT_SHUTDOWN_DBUS_ON_QUIT*: cstring = "SDL_SHUTDOWN_DBUS_ON_QUIT"
const SDL_HINT_STORAGE_TITLE_DRIVER*: cstring = "SDL_STORAGE_TITLE_DRIVER"
const SDL_HINT_STORAGE_USER_DRIVER*: cstring = "SDL_STORAGE_USER_DRIVER"
const SDL_HINT_THREAD_FORCE_REALTIME_TIME_CRITICAL*: cstring = "SDL_THREAD_FORCE_REALTIME_TIME_CRITICAL"
const SDL_HINT_THREAD_PRIORITY_POLICY*: cstring = "SDL_THREAD_PRIORITY_POLICY"
const SDL_HINT_TIMER_RESOLUTION*: cstring = "SDL_TIMER_RESOLUTION"
const SDL_HINT_TOUCH_MOUSE_EVENTS*: cstring = "SDL_TOUCH_MOUSE_EVENTS"
const SDL_HINT_TRACKPAD_IS_TOUCH_ONLY*: cstring = "SDL_TRACKPAD_IS_TOUCH_ONLY"
const SDL_HINT_TV_REMOTE_AS_JOYSTICK*: cstring = "SDL_TV_REMOTE_AS_JOYSTICK"
const SDL_HINT_VIDEO_ALLOW_SCREENSAVER*: cstring = "SDL_VIDEO_ALLOW_SCREENSAVER"
const SDL_HINT_VIDEO_DISPLAY_PRIORITY*: cstring = "SDL_VIDEO_DISPLAY_PRIORITY"
const SDL_HINT_VIDEO_DOUBLE_BUFFER*: cstring = "SDL_VIDEO_DOUBLE_BUFFER"
const SDL_HINT_VIDEO_DRIVER*: cstring = "SDL_VIDEO_DRIVER"
const SDL_HINT_VIDEO_DUMMY_SAVE_FRAMES*: cstring = "SDL_VIDEO_DUMMY_SAVE_FRAMES"
const SDL_HINT_VIDEO_EGL_ALLOW_GETDISPLAY_FALLBACK*: cstring = "SDL_VIDEO_EGL_ALLOW_GETDISPLAY_FALLBACK"
const SDL_HINT_VIDEO_FORCE_EGL*: cstring = "SDL_VIDEO_FORCE_EGL"
const SDL_HINT_VIDEO_MAC_FULLSCREEN_SPACES*: cstring = "SDL_VIDEO_MAC_FULLSCREEN_SPACES"
const SDL_HINT_VIDEO_MINIMIZE_ON_FOCUS_LOSS*: cstring = "SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS"
const SDL_HINT_VIDEO_OFFSCREEN_SAVE_FRAMES*: cstring = "SDL_VIDEO_OFFSCREEN_SAVE_FRAMES"
const SDL_HINT_VIDEO_SYNC_WINDOW_OPERATIONS*: cstring = "SDL_VIDEO_SYNC_WINDOW_OPERATIONS"
const SDL_HINT_VIDEO_WAYLAND_ALLOW_LIBDECOR*: cstring = "SDL_VIDEO_WAYLAND_ALLOW_LIBDECOR"
const SDL_HINT_VIDEO_WAYLAND_MODE_EMULATION*: cstring = "SDL_VIDEO_WAYLAND_MODE_EMULATION"
const SDL_HINT_VIDEO_WAYLAND_MODE_SCALING*: cstring = "SDL_VIDEO_WAYLAND_MODE_SCALING"
const SDL_HINT_VIDEO_WAYLAND_PREFER_LIBDECOR*: cstring = "SDL_VIDEO_WAYLAND_PREFER_LIBDECOR"
const SDL_HINT_VIDEO_WAYLAND_SCALE_TO_DISPLAY*: cstring = "SDL_VIDEO_WAYLAND_SCALE_TO_DISPLAY"
const SDL_HINT_VIDEO_WIN_D3DCOMPILER*: cstring = "SDL_VIDEO_WIN_D3DCOMPILER"
const SDL_HINT_VIDEO_X11_NET_WM_BYPASS_COMPOSITOR*: cstring = "SDL_VIDEO_X11_NET_WM_BYPASS_COMPOSITOR"
const SDL_HINT_VIDEO_X11_NET_WM_PING*: cstring = "SDL_VIDEO_X11_NET_WM_PING"
const SDL_HINT_VIDEO_X11_NODIRECTCOLOR*: cstring = "SDL_VIDEO_X11_NODIRECTCOLOR"
const SDL_HINT_VIDEO_X11_SCALING_FACTOR*: cstring = "SDL_VIDEO_X11_SCALING_FACTOR"
const SDL_HINT_VIDEO_X11_VISUALID*: cstring = "SDL_VIDEO_X11_VISUALID"
const SDL_HINT_VIDEO_X11_WINDOW_VISUALID*: cstring = "SDL_VIDEO_X11_WINDOW_VISUALID"
const SDL_HINT_VIDEO_X11_XRANDR*: cstring = "SDL_VIDEO_X11_XRANDR"
const SDL_HINT_VITA_ENABLE_BACK_TOUCH*: cstring = "SDL_VITA_ENABLE_BACK_TOUCH"
const SDL_HINT_VITA_ENABLE_FRONT_TOUCH*: cstring = "SDL_VITA_ENABLE_FRONT_TOUCH"
const SDL_HINT_VITA_MODULE_PATH*: cstring = "SDL_VITA_MODULE_PATH"
const SDL_HINT_VITA_PVR_INIT*: cstring = "SDL_VITA_PVR_INIT"
const SDL_HINT_VITA_RESOLUTION*: cstring = "SDL_VITA_RESOLUTION"
const SDL_HINT_VITA_PVR_OPENGL*: cstring = "SDL_VITA_PVR_OPENGL"
const SDL_HINT_VITA_TOUCH_MOUSE_DEVICE*: cstring = "SDL_VITA_TOUCH_MOUSE_DEVICE"
const SDL_HINT_VULKAN_DISPLAY*: cstring = "SDL_VULKAN_DISPLAY"
const SDL_HINT_VULKAN_LIBRARY*: cstring = "SDL_VULKAN_LIBRARY"
const SDL_HINT_WAVE_FACT_CHUNK*: cstring = "SDL_WAVE_FACT_CHUNK"
const SDL_HINT_WAVE_CHUNK_LIMIT*: cstring = "SDL_WAVE_CHUNK_LIMIT"
const SDL_HINT_WAVE_RIFF_CHUNK_SIZE*: cstring = "SDL_WAVE_RIFF_CHUNK_SIZE"
const SDL_HINT_WAVE_TRUNCATION*: cstring = "SDL_WAVE_TRUNCATION"
const SDL_HINT_WINDOW_ACTIVATE_WHEN_RAISED*: cstring = "SDL_WINDOW_ACTIVATE_WHEN_RAISED"
const SDL_HINT_WINDOW_ACTIVATE_WHEN_SHOWN*: cstring = "SDL_WINDOW_ACTIVATE_WHEN_SHOWN"
const SDL_HINT_WINDOW_ALLOW_TOPMOST*: cstring = "SDL_WINDOW_ALLOW_TOPMOST"
const SDL_HINT_WINDOW_FRAME_USABLE_WHILE_CURSOR_HIDDEN*: cstring = "SDL_WINDOW_FRAME_USABLE_WHILE_CURSOR_HIDDEN"
const SDL_HINT_WINDOWS_CLOSE_ON_ALT_F4*: cstring = "SDL_WINDOWS_CLOSE_ON_ALT_F4"
const SDL_HINT_WINDOWS_ENABLE_MENU_MNEMONICS*: cstring = "SDL_WINDOWS_ENABLE_MENU_MNEMONICS"
const SDL_HINT_WINDOWS_ENABLE_MESSAGELOOP*: cstring = "SDL_WINDOWS_ENABLE_MESSAGELOOP"
const SDL_HINT_WINDOWS_GAMEINPUT*: cstring =   "SDL_WINDOWS_GAMEINPUT"
const SDL_HINT_WINDOWS_RAW_KEYBOARD*: cstring = "SDL_WINDOWS_RAW_KEYBOARD"
const SDL_HINT_WINDOWS_FORCE_SEMAPHORE_KERNEL*: cstring = "SDL_WINDOWS_FORCE_SEMAPHORE_KERNEL"
const SDL_HINT_WINDOWS_INTRESOURCE_ICON*: cstring =       "SDL_WINDOWS_INTRESOURCE_ICON"
const SDL_HINT_WINDOWS_INTRESOURCE_ICON_SMALL*: cstring = "SDL_WINDOWS_INTRESOURCE_ICON_SMALL"
const SDL_HINT_WINDOWS_USE_D3D9EX*: cstring = "SDL_WINDOWS_USE_D3D9EX"
const SDL_HINT_WINDOWS_ERASE_BACKGROUND_MODE*: cstring = "SDL_WINDOWS_ERASE_BACKGROUND_MODE"
const SDL_HINT_X11_FORCE_OVERRIDE_REDIRECT*: cstring = "SDL_X11_FORCE_OVERRIDE_REDIRECT"
const SDL_HINT_X11_WINDOW_TYPE*: cstring = "SDL_X11_WINDOW_TYPE"
const SDL_HINT_X11_XCB_LIBRARY*: cstring = "SDL_X11_XCB_LIBRARY"
const SDL_HINT_XINPUT_ENABLED*: cstring = "SDL_XINPUT_ENABLED"
const SDL_HINT_ASSERT*: cstring = "SDL_ASSERT"

#endregion


#region SDL3/SDL_sensor.h -----------------------------------------------------

type
  SDL_Sensor* = pointer
  SDL_SensorID* = uint32
  SDL_SensorType* {.size: sizeof(cint).} = enum
    SDL_SENSOR_INVALID = -1,
    SDL_SENSOR_UNKNOWN,
    SDL_SENSOR_ACCEL,
    SDL_SENSOR_GYRO,
    SDL_SENSOR_ACCEL_L,
    SDL_SENSOR_GYRO_L,
    SDL_SENSOR_ACCEL_R,
    SDL_SENSOR_GYRO_R

const SDL_STANDARD_GRAVITY* = 9.80665

proc SDL_GetSensors* ( count: var int ): ptr UncheckedArray[SDL_SensorID] {.importc.}
proc SDL_GetSensorNameForID* ( instance_id: SDL_SensorID ): cstring {.importc.}
proc SDL_GetSensorTypeForID* ( instance_id: SDL_SensorID ): SDL_SensorType {.importc.}
proc SDL_GetSensorNonPortableTypeForID* ( instance_id: SDL_SensorID ): int {.importc.}
proc SDL_OpenSensor* ( instance_id: SDL_SensorID ): SDL_Sensor {.importc.}
proc SDL_GetSensorFromID* ( instance_id: SDL_SensorID ): SDL_Sensor {.importc.}
proc SDL_GetSensorProperties* ( sensor: SDL_Sensor ): SDL_PropertiesID {.importc.}
proc SDL_GetSensorName* ( sensor: SDL_Sensor ): cstring {.importc.}
proc SDL_GetSensorType* ( sensor: SDL_Sensor ): SDL_SensorType {.importc.}
proc SDL_GetSensorNonPortableType* ( sensor: SDL_Sensor ): int {.importc.}
proc SDL_GetSensorID* ( sensor: SDL_Sensor ): SDL_SensorID {.importc.}
proc SDL_GetSensorData* ( sensor: SDL_Sensor, data: ptr[cfloat], num_values: int ): bool {.importc.}
proc SDL_GetSensorData* ( sensor: SDL_Sensor, data: openarray[cfloat] ): bool {.importc.}
proc SDL_CloseSensor* ( sensor: SDL_Sensor ): void {.importc.}
proc SDL_UpdateSensors* (): void {.importc.}

#endregion


#region SDL3/SDL_power.h ------------------------------------------------------

type
  SDL_PowerState* {.size: sizeof(cint).} = enum
    SDL_POWERSTATE_ERROR = -1,
    SDL_POWERSTATE_UNKNOWN,
    SDL_POWERSTATE_ON_BATTERY,
    SDL_POWERSTATE_NO_BATTERY,
    SDL_POWERSTATE_CHARGING,
    SDL_POWERSTATE_CHARGED

proc SDL_GetPowerInfo* ( seconds: var int, percent: var int ): SDL_PowerState {.importc.}

#endregion


#region SDL3/SDL_joystick.h ---------------------------------------------------

type
  SDL_Joystick* = pointer
  SDL_JoystickID* = uint32
  SDL_JoystickType* {.size: sizeof(cint).} = enum
    SDL_JOYSTICK_TYPE_UNKNOWN,
    SDL_JOYSTICK_TYPE_GAMEPAD,
    SDL_JOYSTICK_TYPE_WHEEL,
    SDL_JOYSTICK_TYPE_ARCADE_STICK,
    SDL_JOYSTICK_TYPE_FLIGHT_STICK,
    SDL_JOYSTICK_TYPE_DANCE_PAD,
    SDL_JOYSTICK_TYPE_GUITAR,
    SDL_JOYSTICK_TYPE_DRUM_KIT,
    SDL_JOYSTICK_TYPE_ARCADE_PAD,
    SDL_JOYSTICK_TYPE_THROTTLE,
    SDL_JOYSTICK_TYPE_COUNT

  SDL_JoystickConnectionState* {.size: sizeof(cint).} = enum
    SDL_JOYSTICK_CONNECTION_INVALID = -1,
    SDL_JOYSTICK_CONNECTION_UNKNOWN,
    SDL_JOYSTICK_CONNECTION_WIRED,
    SDL_JOYSTICK_CONNECTION_WIRELESS

const SDL_JOYSTICK_AXIS_MAX* = 32767
const SDL_JOYSTICK_AXIS_MIN* = -32768

proc SDL_LockJoysticks* (): void {.importc.}
proc SDL_UnlockJoysticks* (): void {.importc.}
proc SDL_HasJoystick* (): bool {.importc.}
proc SDL_GetJoysticks* ( count: var int ): ptr UncheckedArray[SDL_JoystickID] {.importc.}
proc SDL_GetJoystickNameForID* ( instance_id: SDL_JoystickID ): cstring {.importc.}
proc SDL_GetJoystickPathForID* ( instance_id: SDL_JoystickID ): cstring {.importc.}
proc SDL_GetJoystickPlayerIndexForID* ( instance_id: SDL_JoystickID ): int {.importc.}
proc SDL_GetJoystickGUIDForID* ( instance_id: SDL_JoystickID ): SDL_GUID {.importc.}
proc SDL_GetJoystickVendorForID* ( instance_id: SDL_JoystickID ): uint16 {.importc.}
proc SDL_GetJoystickProductForID* ( instance_id: SDL_JoystickID ): uint16 {.importc.}
proc SDL_GetJoystickProductVersionForID* ( instance_id: SDL_JoystickID ): uint16 {.importc.}
proc SDL_GetJoystickTypeForID* ( instance_id: SDL_JoystickID ): SDL_JoystickType {.importc.}
proc SDL_OpenJoystick* ( instance_id: SDL_JoystickID ): SDL_Joystick {.importc.}
proc SDL_GetJoystickFromID* ( instance_id: SDL_JoystickID ): SDL_Joystick {.importc.}
proc SDL_GetJoystickFromPlayerIndex* ( player_index: int ): SDL_Joystick {.importc.}

type
  SDL_VirtualJoystickTouchpadDesc* {.bycopy.} = object
    nfingers*: uint16
    padding*: array[3, uint16]

  SDL_VirtualJoystickSensorDesc* {.bycopy.} = object
    `type`*: SDL_SensorType
    rate*: cfloat

  SDL_VirtualJoystickDesc* {.bycopy.} = object
    version*: uint32
    `type`*: uint16
    padding*: uint16
    vendor_id*: uint16
    product_id*: uint16
    naxes*: uint16
    nbuttons*: uint16
    nballs*: uint16
    nhats*: uint16
    ntouchpads*: uint16
    nsensors*: uint16
    padding2*: array[2, uint16]
    button_mask*: uint32
    axis_mask*: uint32
    name*: cstring
    touchpads*: ptr UncheckedArray[SDL_VirtualJoystickTouchpadDesc]
    sensors*: ptr UncheckedArray[SDL_VirtualJoystickSensorDesc]
    userdata*: pointer
    Update*: proc (userdata: pointer) {.cdecl.}
    SetPlayerIndex*: proc (userdata: pointer; player_index: cint) {.cdecl.}
    Rumble*: proc (userdata: pointer; low_frequency_rumble: uint16; high_frequency_rumble: uint16): bool {.cdecl.}
    RumbleTriggers*: proc (userdata: pointer; left_rumble: uint16; right_rumble: uint16): bool {.cdecl.}
    SetLED*: proc (userdata: pointer; red: uint8; green: uint8; blue: uint8): bool {.cdecl.}
    SendEffect*: proc (userdata: pointer; data: pointer; size: cint): bool {.cdecl.}
    SetSensorsEnabled*: proc (userdata: pointer; enabled: bool): bool {.cdecl.}
    Cleanup*: proc (userdata: pointer) {.cdecl.}

proc SDL_AttachVirtualJoystick* ( desc: ptr SDL_VirtualJoystickDesc ): SDL_JoystickID {.importc.}
proc SDL_DetachVirtualJoystick* ( instance_id: SDL_JoystickID ): bool {.importc.}
proc SDL_IsJoystickVirtual* ( instance_id: SDL_JoystickID ): bool {.importc.}
proc SDL_SetJoystickVirtualAxis* ( joystick: SDL_Joystick, axis: int, value: int16 ): bool {.importc.}
proc SDL_SetJoystickVirtualBall* ( joystick: SDL_Joystick, ball: int, xrel: int16, yrel: int16 ): bool {.importc.}
proc SDL_SetJoystickVirtualButton* ( joystick: SDL_Joystick, button: int, down: bool ): bool {.importc.}
proc SDL_SetJoystickVirtualHat* ( joystick: SDL_Joystick, hat: int, value: uint8 ): bool {.importc.}
proc SDL_SetJoystickVirtualTouchpad* ( joystick: SDL_Joystick, touchpad,finger: int, down: bool, x,y: cfloat, pressure: cfloat ): bool {.importc.}
proc SDL_SendJoystickVirtualSensorData* ( joystick: SDL_Joystick, kind: SDL_SensorType, sensor_timestamp: uint64, data: ptr[cfloat], num_values: int ): bool {.importc.}
proc SDL_SendJoystickVirtualSensorData* ( joystick: SDL_Joystick, kind: SDL_SensorType, sensor_timestamp: uint64, data: openarray[cfloat] ): bool {.importc.}

proc SDL_GetJoystickProperties* ( joystick: SDL_Joystick ): SDL_PropertiesID {.importc.}

const SDL_PROP_JOYSTICK_CAP_MONO_LED_BOOLEAN*       = "SDL.joystick.cap.mono_led"
const SDL_PROP_JOYSTICK_CAP_RGB_LED_BOOLEAN*        = "SDL.joystick.cap.rgb_led"
const SDL_PROP_JOYSTICK_CAP_PLAYER_LED_BOOLEAN*     = "SDL.joystick.cap.player_led"
const SDL_PROP_JOYSTICK_CAP_RUMBLE_BOOLEAN*         = "SDL.joystick.cap.rumble"
const SDL_PROP_JOYSTICK_CAP_TRIGGER_RUMBLE_BOOLEAN* = "SDL.joystick.cap.trigger_rumble"

proc SDL_GetJoystickName* ( joystick: SDL_Joystick ): cstring {.importc.}
proc SDL_GetJoystickPath* ( joystick: SDL_Joystick ): cstring {.importc.}
proc SDL_GetJoystickPlayerIndex* ( joystick: SDL_Joystick ): int {.importc.}
proc SDL_SetJoystickPlayerIndex* ( joystick: SDL_Joystick, player_index: int ): bool {.importc.}
proc SDL_GetJoystickGUID* ( joystick: SDL_Joystick ): SDL_GUID {.importc.}
proc SDL_GetJoystickVendor* ( joystick: SDL_Joystick ): uint16 {.importc.}
proc SDL_GetJoystickProduct* ( joystick: SDL_Joystick ): uint16 {.importc.}
proc SDL_GetJoystickProductVersion* ( joystick: SDL_Joystick ): uint16 {.importc.}
proc SDL_GetJoystickFirmwareVersion* ( joystick: SDL_Joystick ): uint16 {.importc.}
proc SDL_GetJoystickSerial* ( joystick: SDL_Joystick ): cstring {.importc.}
proc SDL_GetJoystickType* ( joystick: SDL_Joystick ): SDL_JoystickType {.importc.}
proc SDL_GetJoystickGUIDInfo* ( guid: SDL_GUID, vendor,product,version,crc16: var uint16 ): void {.importc.}
proc SDL_JoystickConnected* ( joystick: SDL_Joystick ): bool {.importc.}
proc SDL_GetJoystickID* ( joystick: SDL_Joystick ): SDL_JoystickID {.importc.}
proc SDL_GetNumJoystickAxes* ( joystick: SDL_Joystick ): int {.importc.}
proc SDL_GetNumJoystickBalls* ( joystick: SDL_Joystick ): int {.importc.}
proc SDL_GetNumJoystickHats* ( joystick: SDL_Joystick ): int {.importc.}
proc SDL_GetNumJoystickButtons* ( joystick: SDL_Joystick ): int {.importc.}
proc SDL_SetJoystickEventsEnabled* ( enabled: bool ): void {.importc.}
proc SDL_JoystickEventsEnabled* (): bool {.importc.}
proc SDL_UpdateJoysticks* (): void {.importc.}
proc SDL_GetJoystickAxis* ( joystick: SDL_Joystick, axis: int): int16 {.importc.}
proc SDL_GetJoystickAxisInitialState* ( joystick: SDL_Joystick, axis: int, state: var int16 ): bool {.importc.}
proc SDL_GetJoystickBall* ( joystick: SDL_Joystick, ball: int, dx,dy: var int ): bool {.importc.}

proc SDL_GetJoystickHat* ( joystick: SDL_Joystick, hat: int ): uint8 {.importc.}

const SDL_HAT_CENTERED*  = 0x00'u
const SDL_HAT_UP*        = 0x01'u
const SDL_HAT_RIGHT*     = 0x02'u
const SDL_HAT_DOWN*      = 0x04'u
const SDL_HAT_LEFT*      = 0x08'u
const SDL_HAT_RIGHTUP*   = SDL_HAT_RIGHT.uint or SDL_HAT_UP.uint
const SDL_HAT_RIGHTDOWN* = SDL_HAT_RIGHT.uint or SDL_HAT_DOWN.uint
const SDL_HAT_LEFTUP*    = SDL_HAT_LEFT.uint or SDL_HAT_UP.uint
const SDL_HAT_LEFTDOWN*  = SDL_HAT_LEFT.uint or SDL_HAT_DOWN.uint

proc SDL_GetJoystickButton* ( joystick: SDL_Joystick, button: int ): bool {.importc.}
proc SDL_RumbleJoystick* ( joystick: SDL_Joystick, low_frequency_rumble,high_frequency_rumble: uint16, duration_ms: uint32 ): bool {.importc.}
proc SDL_RumbleJoystickTriggers* ( joystick: SDL_Joystick, left_rumble,right_rumble: uint16, duration_ms: uint32 ): bool {.importc.}
proc SDL_SetJoystickLED* ( joystick: SDL_Joystick, red,green,blue: uint8 ): bool {.importc.}
proc SDL_SendJoystickEffect* ( joystick: SDL_Joystick, data: pointer, size: int ): bool {.importc.}
proc SDL_CloseJoystick* ( joystick: SDL_Joystick ): void {.importc.}
proc SDL_GetJoystickConnectionState* ( joystick: SDL_Joystick ): SDL_JoystickConnectionState {.importc.}
proc SDL_GetJoystickPowerInfo* ( joystick: SDL_Joystick, percent: var int ): SDL_PowerState {.importc.}

#endregion


#region SDL3/SDL_haptic.h -----------------------------------------------------

type
  SDL_Haptic* = pointer
  SDL_HapticID* = uint32

  # NOTE: These are, thus far, the only symbols to have their names _changed_
  #  in this set of bindings. It was unavoidable.
  SDL_HapticEffectType* {.size: sizeof(uint16).} = enum
    SDL_HAPTIC_EFFECT_INVALID       = 0'u
    SDL_HAPTIC_EFFECT_CONSTANT      = 1'u shl 0   # SDL_HAPTIC_CONSTANT
    SDL_HAPTIC_EFFECT_SINE          = 1'u shl 1   # SDL_HAPTIC_SINE
    SDL_HAPTIC_EFFECT_SQUARE        = 1'u shl 2   # SDL_HAPTIC_SQUARE
    SDL_HAPTIC_EFFECT_TRIANGLE      = 1'u shl 3   # SDL_HAPTIC_TRIANGLE
    SDL_HAPTIC_EFFECT_SAWTOOTHUP    = 1'u shl 4   # SDL_HAPTIC_SAWTOOTHUP
    SDL_HAPTIC_EFFECT_SAWTOOTHDOWN  = 1'u shl 5   # SDL_HAPTIC_SAWTOOTHDOWN
    SDL_HAPTIC_EFFECT_RAMP          = 1'u shl 6   # SDL_HAPTIC_RAMP
    SDL_HAPTIC_EFFECT_SPRING        = 1'u shl 7   # SDL_HAPTIC_SPRING
    SDL_HAPTIC_EFFECT_DAMPER        = 1'u shl 8   # SDL_HAPTIC_DAMPER
    SDL_HAPTIC_EFFECT_INERTIA       = 1'u shl 9   # SDL_HAPTIC_INERTIA
    SDL_HAPTIC_EFFECT_FRICTION      = 1'u shl 10  # SDL_HAPTIC_FRICTION
    SDL_HAPTIC_EFFECT_LEFTRIGHT     = 1'u shl 11  # SDL_HAPTIC_LEFTRIGHT
    SDL_HAPTIC_EFFECT_RESERVED1     = 1'u shl 12  # SDL_HAPTIC_RESERVED1
    SDL_HAPTIC_EFFECT_RESERVED2     = 1'u shl 13  # SDL_HAPTIC_RESERVED2
    SDL_HAPTIC_EFFECT_RESERVED3     = 1'u shl 14  # SDL_HAPTIC_RESERVED3
    SDL_HAPTIC_EFFECT_CUSTOM        = 1'u shl 15  # SDL_HAPTIC_CUSTOM
    SDL_HAPTIC_EFFECT_GAIN          = 1'u shl 16  # SDL_HAPTIC_GAIN
    SDL_HAPTIC_EFFECT_AUTOCENTER    = 1'u shl 17  # SDL_HAPTIC_AUTOCENTER
    SDL_HAPTIC_EFFECT_STATUS        = 1'u shl 18  # SDL_HAPTIC_STATUS
    SDL_HAPTIC_EFFECT_PAUSE         = 1'u shl 19  # SDL_HAPTIC_PAUSE

  SDL_HapticDirection* {.bycopy.} = object
    `type`*: uint8
    dir*: array[3, int32]

  SDL_HapticConstant* {.bycopy.} = object
    `type`*: SDL_HapticEffectType
    direction*: SDL_HapticDirection
    length*: uint32
    delay*: uint16
    button*: uint16
    interval*: uint16
    level*: int16
    attack_length*: uint16
    attack_level*: uint16
    fade_length*: uint16
    fade_level*: uint16

  SDL_HapticPeriodic* {.bycopy.} = object
    `type`*: SDL_HapticEffectType
    direction*: SDL_HapticDirection
    length*: uint32
    delay*: uint16
    button*: uint16
    interval*: uint16
    period*: uint16
    magnitude*: int16
    offset*: int16
    phase*: uint16
    attack_length*: uint16
    attack_level*: uint16
    fade_length*: uint16
    fade_level*: uint16

  SDL_HapticCondition* {.bycopy.} = object
    `type`*: SDL_HapticEffectType
    direction*: SDL_HapticDirection
    length*: uint32
    delay*: uint16
    button*: uint16
    interval*: uint16
    right_sat*: array[3, uint16]
    left_sat*: array[3, uint16]
    right_coeff*: array[3, int16]
    left_coeff*: array[3, int16]
    deadband*: array[3, uint16]
    center*: array[3, int16]

  SDL_HapticRamp* {.bycopy.} = object
    `type`*: SDL_HapticEffectType
    direction*: SDL_HapticDirection
    length*: uint32
    delay*: uint16
    button*: uint16
    interval*: uint16
    start*: int16
    `end`*: int16
    attack_length*: uint16
    attack_level*: uint16
    fade_length*: uint16
    fade_level*: uint16

  SDL_HapticLeftRight* {.bycopy.} = object
    `type`*: SDL_HapticEffectType
    length*: uint32
    large_magnitude*: uint16
    small_magnitude*: uint16

  SDL_HapticCustom* {.bycopy.} = object
    `type`*: SDL_HapticEffectType
    direction*: SDL_HapticDirection
    length*: uint32
    delay*: uint16
    button*: uint16
    interval*: uint16
    channels*: uint8
    period*: uint16
    samples*: uint16
    data*: ptr UncheckedArray[uint16]
    attack_length*: uint16
    attack_level*: uint16
    fade_length*: uint16
    fade_level*: uint16

  SDL_HapticEffect* {.bycopy, union.} = object
    `type`*: SDL_HapticEffectType
    constant*: SDL_HapticConstant
    periodic*: SDL_HapticPeriodic
    condition*: SDL_HapticCondition
    ramp*: SDL_HapticRamp
    leftright*: SDL_HapticLeftRight
    custom*: SDL_HapticCustom

const SDL_HAPTIC_POLAR*         = 0
const SDL_HAPTIC_CARTESIAN*     = 1
const SDL_HAPTIC_SPHERICAL*     = 2
const SDL_HAPTIC_STEERING_AXIS* = 3
const SDL_HAPTIC_INFINITY*      = 4294967295'u

proc SDL_GetHaptics* ( count: var int ): ptr UncheckedArray[SDL_HapticID] {.importc.}
proc SDL_GetHapticNameForID* ( instance_id: SDL_HapticID ): cstring {.importc.}
proc SDL_OpenHaptic* ( instance_id: SDL_HapticID ): SDL_Haptic {.importc.}
proc SDL_GetHapticFromID* ( instance_id: SDL_HapticID ): SDL_Haptic {.importc.}
proc SDL_GetHapticID* ( haptic: SDL_Haptic ): SDL_HapticID {.importc.}
proc SDL_GetHapticName* ( haptic: SDL_Haptic ): cstring {.importc.}
proc SDL_IsMouseHaptic* (): bool {.importc.}
proc SDL_OpenHapticFromMouse* (): SDL_Haptic {.importc.}
proc SDL_IsJoystickHaptic* ( joystick: SDL_Joystick ): bool {.importc.}
proc SDL_OpenHapticFromJoystick* ( joystick: SDL_Joystick ): SDL_Haptic {.importc.}
proc SDL_CloseHaptic* ( haptic: SDL_Haptic ): void {.importc.}
proc SDL_GetMaxHapticEffects* ( haptic: SDL_Haptic ): int {.importc.}
proc SDL_GetMaxHapticEffectsPlaying* ( haptic: SDL_Haptic ): int {.importc.}
proc SDL_GetHapticFeatures* ( haptic: SDL_Haptic ): uint32 {.importc.}
proc SDL_GetNumHapticAxes* ( haptic: SDL_Haptic ): int {.importc.}
proc SDL_HapticEffectSupported* ( haptic: SDL_Haptic, effect: ptr SDL_HapticEffect ): bool {.importc.}
proc SDL_CreateHapticEffect* ( haptic: SDL_Haptic, effect: ptr SDL_HapticEffect ): int {.importc.}
proc SDL_UpdateHapticEffect* ( haptic: SDL_Haptic, effect: int, data: ptr SDL_HapticEffect ): bool {.importc.}
proc SDL_RunHapticEffect* ( haptic: SDL_Haptic, effect: int, iterations: uint32 ): bool {.importc.}
proc SDL_StopHapticEffect* ( haptic: SDL_Haptic, effect: int ): bool {.importc.}
proc SDL_DestroyHapticEffect* ( haptic: SDL_Haptic, effect: int ): void {.importc.}
proc SDL_GetHapticEffectStatus* ( haptic: SDL_Haptic, effect: int ): bool {.importc.}
proc SDL_SetHapticGain* ( haptic: SDL_Haptic, gain: int ): bool {.importc.}
proc SDL_SetHapticAutocenter* ( haptic: SDL_Haptic, autocenter: int ): bool {.importc.}
proc SDL_PauseHaptic* ( haptic: SDL_Haptic ): bool {.importc.}
proc SDL_ResumeHaptic* ( haptic: SDL_Haptic ): bool {.importc.}
proc SDL_StopHapticEffects* ( haptic: SDL_Haptic ): bool {.importc.}
proc SDL_HapticRumbleSupported* ( haptic: SDL_Haptic ): bool {.importc.}
proc SDL_InitHapticRumble* ( haptic: SDL_Haptic ): bool {.importc.}
proc SDL_PlayHapticRumble* ( haptic: SDL_Haptic, strength: cfloat, length: uint32 ): bool {.importc.}
proc SDL_StopHapticRumble* ( haptic: SDL_Haptic ): bool {.importc.}

#endregion


#region SDL3/SDL_gamepad.h ----------------------------------------------------

type
  SDL_Gamepad* = pointer

  SDL_GamepadType* {.size: sizeof(cint).} = enum
    SDL_GAMEPAD_TYPE_UNKNOWN = 0,
    SDL_GAMEPAD_TYPE_STANDARD,
    SDL_GAMEPAD_TYPE_XBOX360,
    SDL_GAMEPAD_TYPE_XBOXONE,
    SDL_GAMEPAD_TYPE_PS3,
    SDL_GAMEPAD_TYPE_PS4,
    SDL_GAMEPAD_TYPE_PS5,
    SDL_GAMEPAD_TYPE_NINTENDO_SWITCH_PRO,
    SDL_GAMEPAD_TYPE_NINTENDO_SWITCH_JOYCON_LEFT,
    SDL_GAMEPAD_TYPE_NINTENDO_SWITCH_JOYCON_RIGHT,
    SDL_GAMEPAD_TYPE_NINTENDO_SWITCH_JOYCON_PAIR,
    SDL_GAMEPAD_TYPE_COUNT

  SDL_GamepadButton* {.size: sizeof(cint).} = enum
    SDL_GAMEPAD_BUTTON_INVALID = -1,
    SDL_GAMEPAD_BUTTON_SOUTH,
    SDL_GAMEPAD_BUTTON_EAST,
    SDL_GAMEPAD_BUTTON_WEST,
    SDL_GAMEPAD_BUTTON_NORTH,
    SDL_GAMEPAD_BUTTON_BACK,
    SDL_GAMEPAD_BUTTON_GUIDE,
    SDL_GAMEPAD_BUTTON_START,
    SDL_GAMEPAD_BUTTON_LEFT_STICK,
    SDL_GAMEPAD_BUTTON_RIGHT_STICK,
    SDL_GAMEPAD_BUTTON_LEFT_SHOULDER,
    SDL_GAMEPAD_BUTTON_RIGHT_SHOULDER,
    SDL_GAMEPAD_BUTTON_DPAD_UP,
    SDL_GAMEPAD_BUTTON_DPAD_DOWN,
    SDL_GAMEPAD_BUTTON_DPAD_LEFT,
    SDL_GAMEPAD_BUTTON_DPAD_RIGHT,
    SDL_GAMEPAD_BUTTON_MISC1,
    SDL_GAMEPAD_BUTTON_RIGHT_PADDLE1,
    SDL_GAMEPAD_BUTTON_LEFT_PADDLE1,
    SDL_GAMEPAD_BUTTON_RIGHT_PADDLE2,
    SDL_GAMEPAD_BUTTON_LEFT_PADDLE2,
    SDL_GAMEPAD_BUTTON_TOUCHPAD,
    SDL_GAMEPAD_BUTTON_MISC2,
    SDL_GAMEPAD_BUTTON_MISC3,
    SDL_GAMEPAD_BUTTON_MISC4,
    SDL_GAMEPAD_BUTTON_MISC5,
    SDL_GAMEPAD_BUTTON_MISC6,
    SDL_GAMEPAD_BUTTON_COUNT

  SDL_GamepadButtonLabel* {.size: sizeof(cint).} = enum
    SDL_GAMEPAD_BUTTON_LABEL_UNKNOWN,
    SDL_GAMEPAD_BUTTON_LABEL_A,
    SDL_GAMEPAD_BUTTON_LABEL_B,
    SDL_GAMEPAD_BUTTON_LABEL_X,
    SDL_GAMEPAD_BUTTON_LABEL_Y,
    SDL_GAMEPAD_BUTTON_LABEL_CROSS,
    SDL_GAMEPAD_BUTTON_LABEL_CIRCLE,
    SDL_GAMEPAD_BUTTON_LABEL_SQUARE,
    SDL_GAMEPAD_BUTTON_LABEL_TRIANGLE

  SDL_GamepadAxis* {.size: sizeof(cint).} = enum
    SDL_GAMEPAD_AXIS_INVALID = -1,
    SDL_GAMEPAD_AXIS_LEFTX,
    SDL_GAMEPAD_AXIS_LEFTY,
    SDL_GAMEPAD_AXIS_RIGHTX,
    SDL_GAMEPAD_AXIS_RIGHTY,
    SDL_GAMEPAD_AXIS_LEFT_TRIGGER,
    SDL_GAMEPAD_AXIS_RIGHT_TRIGGER,
    SDL_GAMEPAD_AXIS_COUNT

  SDL_GamepadBindingType* {.size: sizeof(cint).} = enum
    SDL_GAMEPAD_BINDTYPE_NONE = 0,
    SDL_GAMEPAD_BINDTYPE_BUTTON,
    SDL_GAMEPAD_BINDTYPE_AXIS,
    SDL_GAMEPAD_BINDTYPE_HAT

  # TODO: Clean these up!
  INNER_C_STRUCT_SDL_6* {.bycopy.} = object
    axis*: cint
    axis_min*: cint
    axis_max*: cint

  INNER_C_STRUCT_SDL_7* {.bycopy.} = object
    hat*: cint
    hat_mask*: cint

  INNER_C_UNION_SDL_5* {.bycopy, union.} = object
    button*: cint
    axis*: INNER_C_STRUCT_SDL_6
    hat*: INNER_C_STRUCT_SDL_7

  INNER_C_STRUCT_SDL_9* {.bycopy.} = object
    axis*: SDL_GamepadAxis
    axis_min*: cint
    axis_max*: cint

  INNER_C_UNION_SDL_8* {.bycopy, union.} = object
    button*: SDL_GamepadButton
    axis*: INNER_C_STRUCT_SDL_9

  SDL_GamepadBinding* {.bycopy.} = object
    input_type*: SDL_GamepadBindingType
    input*: INNER_C_UNION_SDL_5
    output_type*: SDL_GamepadBindingType
    output*: INNER_C_UNION_SDL_8

proc SDL_AddGamepadMapping* ( mapping: cstring ): int {.importc.}
proc SDL_AddGamepadMappingsFromIO* ( src: SDL_IOStream, closeio: bool ): int {.importc.}
proc SDL_AddGamepadMappingsFromFile* ( file: cstring ): int {.importc.}
proc SDL_ReloadGamepadMappings* (): bool {.importc.}
proc SDL_GetGamepadMappings* ( count: var int ): ptr UncheckedArray[cstring] {.importc.}
proc SDL_GetGamepadMappingForGUID* ( guid: SDL_GUID ): cstring {.importc.}

proc SDL_GetGamepadMapping* ( gamepad: SDL_Gamepad ): cstring {.importc.}
proc SDL_SetGamepadMapping* ( instance_id: SDL_JoystickID, mapping: cstring ): bool {.importc.}
proc SDL_HasGamepad* (): bool {.importc.}
proc SDL_GetGamepads* ( count: var int ): ptr UncheckedArray[SDL_JoystickID] {.importc.}
proc SDL_IsGamepad* ( instance_id: SDL_JoystickID ): bool {.importc.}
proc SDL_GetGamepadNameForID* ( instance_id: SDL_JoystickID ): cstring {.importc.}
proc SDL_GetGamepadPathForID* ( instance_id: SDL_JoystickID ): cstring {.importc.}
proc SDL_GetGamepadPlayerIndexForID* ( instance_id: SDL_JoystickID ): int {.importc.}
proc SDL_GetGamepadGUIDForID* ( instance_id: SDL_JoystickID ): SDL_GUID {.importc.}
proc SDL_GetGamepadVendorForID* ( instance_id: SDL_JoystickID ): uint16 {.importc.}
proc SDL_GetGamepadProductForID* ( instance_id: SDL_JoystickID ): uint16 {.importc.}
proc SDL_GetGamepadProductVersionForID* ( instance_id: SDL_JoystickID ): uint16 {.importc.}
proc SDL_GetGamepadTypeForID* ( instance_id: SDL_JoystickID ): SDL_GamepadType {.importc.}
proc SDL_GetRealGamepadTypeForID* ( instance_id: SDL_JoystickID ): SDL_GamepadType {.importc.}
proc SDL_GetGamepadMappingForID* ( instance_id: SDL_JoystickID ): cstring {.importc.}
proc SDL_OpenGamepad* ( instance_id: SDL_JoystickID ): SDL_Gamepad {.importc.}
proc SDL_GetGamepadFromID* ( instance_id: SDL_JoystickID ): SDL_Gamepad {.importc.}
proc SDL_GetGamepadFromPlayerIndex* ( player_index: int ): SDL_Gamepad {.importc.}
proc SDL_GetGamepadProperties* ( gamepad: SDL_Gamepad ): SDL_PropertiesID {.importc.}

const SDL_PROP_GAMEPAD_CAP_MONO_LED_BOOLEAN*       = SDL_PROP_JOYSTICK_CAP_MONO_LED_BOOLEAN
const SDL_PROP_GAMEPAD_CAP_RGB_LED_BOOLEAN*        = SDL_PROP_JOYSTICK_CAP_RGB_LED_BOOLEAN
const SDL_PROP_GAMEPAD_CAP_PLAYER_LED_BOOLEAN*     = SDL_PROP_JOYSTICK_CAP_PLAYER_LED_BOOLEAN
const SDL_PROP_GAMEPAD_CAP_RUMBLE_BOOLEAN*         = SDL_PROP_JOYSTICK_CAP_RUMBLE_BOOLEAN
const SDL_PROP_GAMEPAD_CAP_TRIGGER_RUMBLE_BOOLEAN* = SDL_PROP_JOYSTICK_CAP_TRIGGER_RUMBLE_BOOLEAN

proc SDL_GetGamepadID* ( gamepad: SDL_Gamepad ): SDL_JoystickID {.importc.}
proc SDL_GetGamepadName* ( gamepad: SDL_Gamepad ): cstring {.importc.}
proc SDL_GetGamepadPath* ( gamepad: SDL_Gamepad ): cstring {.importc.}
proc SDL_GetGamepadType* ( gamepad: SDL_Gamepad ): SDL_GamepadType {.importc.}
proc SDL_GetRealGamepadType* ( gamepad: SDL_Gamepad ): SDL_GamepadType {.importc.}
proc SDL_GetGamepadPlayerIndex* ( gamepad: SDL_Gamepad ): int {.importc.}
proc SDL_SetGamepadPlayerIndex* ( gamepad: SDL_Gamepad, player_index: int ): bool {.importc.}
proc SDL_GetGamepadVendor* ( gamepad: SDL_Gamepad ): uint16 {.importc.}
proc SDL_GetGamepadProduct* ( gamepad: SDL_Gamepad ): uint16 {.importc.}
proc SDL_GetGamepadProductVersion* ( gamepad: SDL_Gamepad ): uint16 {.importc.}
proc SDL_GetGamepadFirmwareVersion* ( gamepad: SDL_Gamepad ): uint16 {.importc.}
proc SDL_GetGamepadSerial* ( gamepad: SDL_Gamepad ): cstring {.importc.}
proc SDL_GetGamepadSteamHandle* ( gamepad: SDL_Gamepad ): uint64 {.importc.}
proc SDL_GetGamepadConnectionState* ( gamepad: SDL_Gamepad ): SDL_JoystickConnectionState {.importc.}
proc SDL_GetGamepadPowerInfo* ( gamepad: SDL_Gamepad, percent: var int ): SDL_PowerState {.importc.}
proc SDL_GamepadConnected* ( gamepad: SDL_Gamepad ): bool {.importc.}
proc SDL_GetGamepadJoystick* ( gamepad: SDL_Gamepad ): SDL_Joystick {.importc.}
proc SDL_SetGamepadEventsEnabled* ( enabled: bool ): void {.importc.}
proc SDL_GamepadEventsEnabled* (): bool {.importc.}
proc SDL_GetGamepadBindings* ( gamepad: SDL_Gamepad, count: var int ): ptr UncheckedArray[ptr SDL_GamepadBinding] {.importc.}
proc SDL_UpdateGamepads* (): void {.importc.}
proc SDL_GetGamepadTypeFromString* ( str: cstring ): SDL_GamepadType {.importc.}
proc SDL_GetGamepadStringForType* ( kind: SDL_GamepadType ): cstring {.importc.}
proc SDL_GetGamepadAxisFromString* ( str: cstring ): SDL_GamepadAxis {.importc.}
proc SDL_GetGamepadStringForAxis* ( axis: SDL_GamepadAxis ): cstring {.importc.}
proc SDL_GamepadHasAxis* ( gamepad: SDL_Gamepad, axis: SDL_GamepadAxis): bool {.importc.}
# TODO: MAke helper to get this as a normalized cfloat.
proc SDL_GetGamepadAxis* ( gamepad: SDL_Gamepad, axis: SDL_GamepadAxis ): int16 {.importc.}
proc SDL_GetGamepadButtonFromString* ( str: cstring ): SDL_GamepadButton {.importc.}
proc SDL_GetGamepadStringForButton* ( button: SDL_GamepadButton ): cstring {.importc.}
proc SDL_GamepadHasButton* ( gamepad: SDL_Gamepad, button: SDL_GamepadButton ): bool {.importc.}
proc SDL_GetGamepadButton* ( gamepad: SDL_Gamepad, button: SDL_GamepadButton ): bool {.importc.}
proc SDL_GetGamepadButtonLabelForType* ( kind: SDL_GamepadType, button: SDL_GamepadButton ): SDL_GamepadButtonLabel {.importc.}
proc SDL_GetGamepadButtonLabel* ( gamepad: SDL_Gamepad, button: SDL_GamepadButton ): SDL_GamepadButtonLabel {.importc.}
proc SDL_GetNumGamepadTouchpads* ( gamepad: SDL_Gamepad ): int {.importc.}
proc SDL_GetNumGamepadTouchpadFingers* ( gamepad: SDL_Gamepad, touchpad: int ): int {.importc.}
proc SDL_GetGamepadTouchpadFinger* ( gamepad: SDL_Gamepad, touchpad,finger: int, down: var bool, x,y,pressure: cfloat ): bool {.importc.}
proc SDL_GamepadHasSensor* ( gamepad: SDL_Gamepad, kind: SDL_SensorType ): bool {.importc.}
proc SDL_SetGamepadSensorEnabled* ( gamepad: SDL_Gamepad, kind: SDL_SensorType, enabled: bool ): bool {.importc.}
proc SDL_GamepadSensorEnabled* ( gamepad: SDL_Gamepad, kind: SDL_SensorType ): bool {.importc.}
proc SDL_GetGamepadSensorDataRate* ( gamepad: SDL_Gamepad, kind: SDL_SensorType ): cfloat {.importc.}
proc SDL_GetGamepadSensorData* ( gamepad: SDL_Gamepad, kind: SDL_SensorType, data: ptr[cfloat], num_values: int ): bool {.importc.}
proc SDL_GetGamepadSensorData* ( gamepad: SDL_Gamepad, kind: SDL_SensorType, data: openarray[cfloat] ): bool {.importc.}
proc SDL_RumbleGamepad* ( gamepad: SDL_Gamepad, low_frequency_rumble,high_frequency_rumble: uint16, duration_ms: uint32 ): bool {.importc.}
proc SDL_RumbleGamepadTriggers* ( gamepad: SDL_Gamepad, left_rumble,right_rumble: uint16, duration_ms: uint32 ): bool {.importc.}
proc SDL_SetGamepadLED* ( gamepad: SDL_Gamepad, red,green,blue: uint8 ): bool {.importc.}
proc SDL_SendGamepadEffect* ( gamepad: SDL_Gamepad, data: pointer, size: int ): bool {.importc.}
proc SDL_CloseGamepad* ( gamepad: SDL_Gamepad ): void {.importc.}
proc SDL_GetGamepadAppleSFSymbolsNameForButton* ( gamepad: SDL_Gamepad, button: SDL_GamepadButton ): cstring {.importc.}
proc SDL_GetGamepadAppleSFSymbolsNameForAxis* ( gamepad: SDL_Gamepad, axis: SDL_GamepadAxis ): cstring {.importc.}

#endregion


#region SDL3/SDL_scancode.h ---------------------------------------------------

type
  SDL_Scancode* {.size: sizeof(cint).} = enum
    SDL_SCANCODE_UNKNOWN = 0,
    SDL_SCANCODE_A = 4,
    SDL_SCANCODE_B = 5,
    SDL_SCANCODE_C = 6,
    SDL_SCANCODE_D = 7,
    SDL_SCANCODE_E = 8,
    SDL_SCANCODE_F = 9,
    SDL_SCANCODE_G = 10,
    SDL_SCANCODE_H = 11,
    SDL_SCANCODE_I = 12,
    SDL_SCANCODE_J = 13,
    SDL_SCANCODE_K = 14,
    SDL_SCANCODE_L = 15,
    SDL_SCANCODE_M = 16,
    SDL_SCANCODE_N = 17,
    SDL_SCANCODE_O = 18,
    SDL_SCANCODE_P = 19,
    SDL_SCANCODE_Q = 20,
    SDL_SCANCODE_R = 21,
    SDL_SCANCODE_S = 22,
    SDL_SCANCODE_T = 23,
    SDL_SCANCODE_U = 24,
    SDL_SCANCODE_V = 25,
    SDL_SCANCODE_W = 26,
    SDL_SCANCODE_X = 27,
    SDL_SCANCODE_Y = 28,
    SDL_SCANCODE_Z = 29,
    SDL_SCANCODE_1 = 30,
    SDL_SCANCODE_2 = 31,
    SDL_SCANCODE_3 = 32,
    SDL_SCANCODE_4 = 33,
    SDL_SCANCODE_5 = 34,
    SDL_SCANCODE_6 = 35,
    SDL_SCANCODE_7 = 36,
    SDL_SCANCODE_8 = 37,
    SDL_SCANCODE_9 = 38,
    SDL_SCANCODE_0 = 39,
    SDL_SCANCODE_RETURN = 40,
    SDL_SCANCODE_ESCAPE = 41,
    SDL_SCANCODE_BACKSPACE = 42,
    SDL_SCANCODE_TAB = 43,
    SDL_SCANCODE_SPACE = 44,
    SDL_SCANCODE_MINUS = 45,
    SDL_SCANCODE_EQUALS = 46,
    SDL_SCANCODE_LEFTBRACKET = 47,
    SDL_SCANCODE_RIGHTBRACKET = 48,
    SDL_SCANCODE_BACKSLASH = 49,
    SDL_SCANCODE_NONUSHASH = 50,
    SDL_SCANCODE_SEMICOLON = 51,
    SDL_SCANCODE_APOSTROPHE = 52,
    SDL_SCANCODE_GRAVE = 53,
    SDL_SCANCODE_COMMA = 54,
    SDL_SCANCODE_PERIOD = 55,
    SDL_SCANCODE_SLASH = 56,
    SDL_SCANCODE_CAPSLOCK = 57,
    SDL_SCANCODE_F1 = 58,
    SDL_SCANCODE_F2 = 59,
    SDL_SCANCODE_F3 = 60,
    SDL_SCANCODE_F4 = 61,
    SDL_SCANCODE_F5 = 62,
    SDL_SCANCODE_F6 = 63,
    SDL_SCANCODE_F7 = 64,
    SDL_SCANCODE_F8 = 65,
    SDL_SCANCODE_F9 = 66,
    SDL_SCANCODE_F10 = 67,
    SDL_SCANCODE_F11 = 68,
    SDL_SCANCODE_F12 = 69,
    SDL_SCANCODE_PRINTSCREEN = 70,
    SDL_SCANCODE_SCROLLLOCK = 71,
    SDL_SCANCODE_PAUSE = 72,
    SDL_SCANCODE_INSERT = 73,
    SDL_SCANCODE_HOME = 74,
    SDL_SCANCODE_PAGEUP = 75,
    SDL_SCANCODE_DELETE = 76,
    SDL_SCANCODE_END = 77,
    SDL_SCANCODE_PAGEDOWN = 78,
    SDL_SCANCODE_RIGHT = 79,
    SDL_SCANCODE_LEFT = 80,
    SDL_SCANCODE_DOWN = 81,
    SDL_SCANCODE_UP = 82,
    SDL_SCANCODE_NUMLOCKCLEAR = 83,
    SDL_SCANCODE_KP_DIVIDE = 84,
    SDL_SCANCODE_KP_MULTIPLY = 85,
    SDL_SCANCODE_KP_MINUS = 86,
    SDL_SCANCODE_KP_PLUS = 87,
    SDL_SCANCODE_KP_ENTER = 88,
    SDL_SCANCODE_KP_1 = 89,
    SDL_SCANCODE_KP_2 = 90,
    SDL_SCANCODE_KP_3 = 91,
    SDL_SCANCODE_KP_4 = 92,
    SDL_SCANCODE_KP_5 = 93,
    SDL_SCANCODE_KP_6 = 94,
    SDL_SCANCODE_KP_7 = 95,
    SDL_SCANCODE_KP_8 = 96,
    SDL_SCANCODE_KP_9 = 97,
    SDL_SCANCODE_KP_0 = 98,
    SDL_SCANCODE_KP_PERIOD = 99,
    SDL_SCANCODE_NONUSBACKSLASH = 100,
    SDL_SCANCODE_APPLICATION = 101,
    SDL_SCANCODE_POWER = 102,
    SDL_SCANCODE_KP_EQUALS = 103,
    SDL_SCANCODE_F13 = 104,
    SDL_SCANCODE_F14 = 105,
    SDL_SCANCODE_F15 = 106,
    SDL_SCANCODE_F16 = 107,
    SDL_SCANCODE_F17 = 108,
    SDL_SCANCODE_F18 = 109,
    SDL_SCANCODE_F19 = 110,
    SDL_SCANCODE_F20 = 111,
    SDL_SCANCODE_F21 = 112,
    SDL_SCANCODE_F22 = 113,
    SDL_SCANCODE_F23 = 114,
    SDL_SCANCODE_F24 = 115,
    SDL_SCANCODE_EXECUTE = 116,
    SDL_SCANCODE_HELP = 117,
    SDL_SCANCODE_MENU = 118,
    SDL_SCANCODE_SELECT = 119,
    SDL_SCANCODE_STOP = 120,
    SDL_SCANCODE_AGAIN = 121,
    SDL_SCANCODE_UNDO = 122,
    SDL_SCANCODE_CUT = 123,
    SDL_SCANCODE_COPY = 124,
    SDL_SCANCODE_PASTE = 125,
    SDL_SCANCODE_FIND = 126,
    SDL_SCANCODE_MUTE = 127,
    SDL_SCANCODE_VOLUMEUP = 128,
    SDL_SCANCODE_VOLUMEDOWN = 129,
    SDL_SCANCODE_KP_COMMA = 133,
    SDL_SCANCODE_KP_EQUALSAS400 = 134,
    SDL_SCANCODE_INTERNATIONAL1 = 135,
    SDL_SCANCODE_INTERNATIONAL2 = 136,
    SDL_SCANCODE_INTERNATIONAL3 = 137,
    SDL_SCANCODE_INTERNATIONAL4 = 138,
    SDL_SCANCODE_INTERNATIONAL5 = 139,
    SDL_SCANCODE_INTERNATIONAL6 = 140,
    SDL_SCANCODE_INTERNATIONAL7 = 141,
    SDL_SCANCODE_INTERNATIONAL8 = 142,
    SDL_SCANCODE_INTERNATIONAL9 = 143,
    SDL_SCANCODE_LANG1 = 144,
    SDL_SCANCODE_LANG2 = 145,
    SDL_SCANCODE_LANG3 = 146,
    SDL_SCANCODE_LANG4 = 147,
    SDL_SCANCODE_LANG5 = 148,
    SDL_SCANCODE_LANG6 = 149,
    SDL_SCANCODE_LANG7 = 150,
    SDL_SCANCODE_LANG8 = 151,
    SDL_SCANCODE_LANG9 = 152,
    SDL_SCANCODE_ALTERASE = 153,
    SDL_SCANCODE_SYSREQ = 154,
    SDL_SCANCODE_CANCEL = 155,
    SDL_SCANCODE_CLEAR = 156,
    SDL_SCANCODE_PRIOR = 157,
    SDL_SCANCODE_RETURN2 = 158,
    SDL_SCANCODE_SEPARATOR = 159,
    SDL_SCANCODE_OUT = 160,
    SDL_SCANCODE_OPER = 161,
    SDL_SCANCODE_CLEARAGAIN = 162,
    SDL_SCANCODE_CRSEL = 163,
    SDL_SCANCODE_EXSEL = 164,
    SDL_SCANCODE_KP_00 = 176,
    SDL_SCANCODE_KP_000 = 177,
    SDL_SCANCODE_THOUSANDSSEPARATOR = 178,
    SDL_SCANCODE_DECIMALSEPARATOR = 179,
    SDL_SCANCODE_CURRENCYUNIT = 180,
    SDL_SCANCODE_CURRENCYSUBUNIT = 181,
    SDL_SCANCODE_KP_LEFTPAREN = 182,
    SDL_SCANCODE_KP_RIGHTPAREN = 183,
    SDL_SCANCODE_KP_LEFTBRACE = 184,
    SDL_SCANCODE_KP_RIGHTBRACE = 185,
    SDL_SCANCODE_KP_TAB = 186,
    SDL_SCANCODE_KP_BACKSPACE = 187,
    SDL_SCANCODE_KP_A = 188,
    SDL_SCANCODE_KP_B = 189,
    SDL_SCANCODE_KP_C = 190,
    SDL_SCANCODE_KP_D = 191,
    SDL_SCANCODE_KP_E = 192,
    SDL_SCANCODE_KP_F = 193,
    SDL_SCANCODE_KP_XOR = 194,
    SDL_SCANCODE_KP_POWER = 195,
    SDL_SCANCODE_KP_PERCENT = 196,
    SDL_SCANCODE_KP_LESS = 197,
    SDL_SCANCODE_KP_GREATER = 198,
    SDL_SCANCODE_KP_AMPERSAND = 199,
    SDL_SCANCODE_KP_DBLAMPERSAND = 200,
    SDL_SCANCODE_KP_VERTICALBAR = 201,
    SDL_SCANCODE_KP_DBLVERTICALBAR = 202,
    SDL_SCANCODE_KP_COLON = 203,
    SDL_SCANCODE_KP_HASH = 204,
    SDL_SCANCODE_KP_SPACE = 205,
    SDL_SCANCODE_KP_AT = 206,
    SDL_SCANCODE_KP_EXCLAM = 207,
    SDL_SCANCODE_KP_MEMSTORE = 208,
    SDL_SCANCODE_KP_MEMRECALL = 209,
    SDL_SCANCODE_KP_MEMCLEAR = 210,
    SDL_SCANCODE_KP_MEMADD = 211,
    SDL_SCANCODE_KP_MEMSUBTRACT = 212,
    SDL_SCANCODE_KP_MEMMULTIPLY = 213,
    SDL_SCANCODE_KP_MEMDIVIDE = 214,
    SDL_SCANCODE_KP_PLUSMINUS = 215,
    SDL_SCANCODE_KP_CLEAR = 216,
    SDL_SCANCODE_KP_CLEARENTRY = 217,
    SDL_SCANCODE_KP_BINARY = 218,
    SDL_SCANCODE_KP_OCTAL = 219,
    SDL_SCANCODE_KP_DECIMAL = 220,
    SDL_SCANCODE_KP_HEXADECIMAL = 221,
    SDL_SCANCODE_LCTRL = 224,
    SDL_SCANCODE_LSHIFT = 225,
    SDL_SCANCODE_LALT = 226,
    SDL_SCANCODE_LGUI = 227,
    SDL_SCANCODE_RCTRL = 228,
    SDL_SCANCODE_RSHIFT = 229,
    SDL_SCANCODE_RALT = 230,
    SDL_SCANCODE_RGUI = 231,
    SDL_SCANCODE_MODE = 257,
    SDL_SCANCODE_SLEEP = 258,
    SDL_SCANCODE_WAKE = 259,
    SDL_SCANCODE_CHANNEL_INCREMENT = 260,
    SDL_SCANCODE_CHANNEL_DECREMENT = 261,
    SDL_SCANCODE_MEDIA_PLAY = 262,
    SDL_SCANCODE_MEDIA_PAUSE = 263,
    SDL_SCANCODE_MEDIA_RECORD = 264,
    SDL_SCANCODE_MEDIA_FAST_FORWARD = 265,
    SDL_SCANCODE_MEDIA_REWIND = 266,
    SDL_SCANCODE_MEDIA_NEXT_TRACK = 267,
    SDL_SCANCODE_MEDIA_PREVIOUS_TRACK = 268,
    SDL_SCANCODE_MEDIA_STOP = 269,
    SDL_SCANCODE_MEDIA_EJECT = 270,
    SDL_SCANCODE_MEDIA_PLAY_PAUSE = 271,
    SDL_SCANCODE_MEDIA_SELECT = 272,
    SDL_SCANCODE_AC_NEW = 273,
    SDL_SCANCODE_AC_OPEN = 274,
    SDL_SCANCODE_AC_CLOSE = 275,
    SDL_SCANCODE_AC_EXIT = 276,
    SDL_SCANCODE_AC_SAVE = 277,
    SDL_SCANCODE_AC_PRINT = 278,
    SDL_SCANCODE_AC_PROPERTIES = 279,
    SDL_SCANCODE_AC_SEARCH = 280,
    SDL_SCANCODE_AC_HOME = 281,
    SDL_SCANCODE_AC_BACK = 282,
    SDL_SCANCODE_AC_FORWARD = 283,
    SDL_SCANCODE_AC_STOP = 284,
    SDL_SCANCODE_AC_REFRESH = 285,
    SDL_SCANCODE_AC_BOOKMARKS = 286,
    SDL_SCANCODE_SOFTLEFT = 287,
    SDL_SCANCODE_SOFTRIGHT = 288,
    SDL_SCANCODE_CALL = 289,
    SDL_SCANCODE_ENDCALL = 290,
    SDL_SCANCODE_RESERVED = 400,
    SDL_SCANCODE_COUNT = 512

#endregion


#region SDL3/SDL_keycode.h ----------------------------------------------------

type
  SDL_Keycode* = uint32
  SDL_Keymod* = uint16

const SDLK_SCANCODE_MASK* = 1'u shl 30
template SDL_SCANCODE_TO_KEYCODE* (x): untyped = (x or SDLK_SCANCODE_MASK)

const SDLK_UNKNOWN*              = 0x00000000'u32 # 0
const SDLK_RETURN*               = 0x0000000d'u32 # '\r'
const SDLK_ESCAPE*               = 0x0000001b'u32 # '\x1B'
const SDLK_BACKSPACE*            = 0x00000008'u32 # '\b'
const SDLK_TAB*                  = 0x00000009'u32 # '\t'
const SDLK_SPACE*                = 0x00000020'u32 # ' '
const SDLK_EXCLAIM*              = 0x00000021'u32 # '!'
const SDLK_DBLAPOSTROPHE*        = 0x00000022'u32 # '"'
const SDLK_HASH*                 = 0x00000023'u32 # '#'
const SDLK_DOLLAR*               = 0x00000024'u32 # '$'
const SDLK_PERCENT*              = 0x00000025'u32 # '%'
const SDLK_AMPERSAND*            = 0x00000026'u32 # '&'
const SDLK_APOSTROPHE*           = 0x00000027'u32 # '\''
const SDLK_LEFTPAREN*            = 0x00000028'u32 # '('
const SDLK_RIGHTPAREN*           = 0x00000029'u32 # ')'
const SDLK_ASTERISK*             = 0x0000002a'u32 # '*'
const SDLK_PLUS*                 = 0x0000002b'u32 # '+'
const SDLK_COMMA*                = 0x0000002c'u32 # ','
const SDLK_MINUS*                = 0x0000002d'u32 # '-'
const SDLK_PERIOD*               = 0x0000002e'u32 # '.'
const SDLK_SLASH*                = 0x0000002f'u32 # '/'
const SDLK_0*                    = 0x00000030'u32 # '0'
const SDLK_1*                    = 0x00000031'u32 # '1'
const SDLK_2*                    = 0x00000032'u32 # '2'
const SDLK_3*                    = 0x00000033'u32 # '3'
const SDLK_4*                    = 0x00000034'u32 # '4'
const SDLK_5*                    = 0x00000035'u32 # '5'
const SDLK_6*                    = 0x00000036'u32 # '6'
const SDLK_7*                    = 0x00000037'u32 # '7'
const SDLK_8*                    = 0x00000038'u32 # '8'
const SDLK_9*                    = 0x00000039'u32 # '9'
const SDLK_COLON*                = 0x0000003a'u32 # ':'
const SDLK_SEMICOLON*            = 0x0000003b'u32 # ';'
const SDLK_LESS*                 = 0x0000003c'u32 # '<'
const SDLK_EQUALS*               = 0x0000003d'u32 # '='
const SDLK_GREATER*              = 0x0000003e'u32 # '>'
const SDLK_QUESTION*             = 0x0000003f'u32 # '?'
const SDLK_AT*                   = 0x00000040'u32 # '@'
const SDLK_LEFTBRACKET*          = 0x0000005b'u32 # '['
const SDLK_BACKSLASH*            = 0x0000005c'u32 # '\\'
const SDLK_RIGHTBRACKET*         = 0x0000005d'u32 # ']'
const SDLK_CARET*                = 0x0000005e'u32 # '^'
const SDLK_UNDERSCORE*           = 0x0000005f'u32 # '_'
const SDLK_GRAVE*                = 0x00000060'u32 # '`'
const SDLK_A*                    = 0x00000061'u32 # 'a'
const SDLK_B*                    = 0x00000062'u32 # 'b'
const SDLK_C*                    = 0x00000063'u32 # 'c'
const SDLK_D*                    = 0x00000064'u32 # 'd'
const SDLK_E*                    = 0x00000065'u32 # 'e'
const SDLK_F*                    = 0x00000066'u32 # 'f'
const SDLK_G*                    = 0x00000067'u32 # 'g'
const SDLK_H*                    = 0x00000068'u32 # 'h'
const SDLK_I*                    = 0x00000069'u32 # 'i'
const SDLK_J*                    = 0x0000006a'u32 # 'j'
const SDLK_K*                    = 0x0000006b'u32 # 'k'
const SDLK_L*                    = 0x0000006c'u32 # 'l'
const SDLK_M*                    = 0x0000006d'u32 # 'm'
const SDLK_N*                    = 0x0000006e'u32 # 'n'
const SDLK_O*                    = 0x0000006f'u32 # 'o'
const SDLK_P*                    = 0x00000070'u32 # 'p'
const SDLK_Q*                    = 0x00000071'u32 # 'q'
const SDLK_R*                    = 0x00000072'u32 # 'r'
const SDLK_S*                    = 0x00000073'u32 # 's'
const SDLK_T*                    = 0x00000074'u32 # 't'
const SDLK_U*                    = 0x00000075'u32 # 'u'
const SDLK_V*                    = 0x00000076'u32 # 'v'
const SDLK_W*                    = 0x00000077'u32 # 'w'
const SDLK_X*                    = 0x00000078'u32 # 'x'
const SDLK_Y*                    = 0x00000079'u32 # 'y'
const SDLK_Z*                    = 0x0000007a'u32 # 'z'
const SDLK_LEFTBRACE*            = 0x0000007b'u32 # '{'
const SDLK_PIPE*                 = 0x0000007c'u32 # '|'
const SDLK_RIGHTBRACE*           = 0x0000007d'u32 # '}'
const SDLK_TILDE*                = 0x0000007e'u32 # '~'
const SDLK_DELETE*               = 0x0000007f'u32 # '\x7F'
const SDLK_PLUSMINUS*            = 0x000000b1'u32 # '\xB1'
const SDLK_CAPSLOCK*             = 0x40000039'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_CAPSLOCK)
const SDLK_F1*                   = 0x4000003a'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F1)
const SDLK_F2*                   = 0x4000003b'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F2)
const SDLK_F3*                   = 0x4000003c'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F3)
const SDLK_F4*                   = 0x4000003d'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F4)
const SDLK_F5*                   = 0x4000003e'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F5)
const SDLK_F6*                   = 0x4000003f'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F6)
const SDLK_F7*                   = 0x40000040'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F7)
const SDLK_F8*                   = 0x40000041'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F8)
const SDLK_F9*                   = 0x40000042'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F9)
const SDLK_F10*                  = 0x40000043'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F10)
const SDLK_F11*                  = 0x40000044'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F11)
const SDLK_F12*                  = 0x40000045'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F12)
const SDLK_PRINTSCREEN*          = 0x40000046'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_PRINTSCREEN)
const SDLK_SCROLLLOCK*           = 0x40000047'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_SCROLLLOCK)
const SDLK_PAUSE*                = 0x40000048'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_PAUSE)
const SDLK_INSERT*               = 0x40000049'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_INSERT)
const SDLK_HOME*                 = 0x4000004a'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_HOME)
const SDLK_PAGEUP*               = 0x4000004b'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_PAGEUP)
const SDLK_END*                  = 0x4000004d'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_END)
const SDLK_PAGEDOWN*             = 0x4000004e'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_PAGEDOWN)
const SDLK_RIGHT*                = 0x4000004f'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_RIGHT)
const SDLK_LEFT*                 = 0x40000050'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_LEFT)
const SDLK_DOWN*                 = 0x40000051'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_DOWN)
const SDLK_UP*                   = 0x40000052'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_UP)
const SDLK_NUMLOCKCLEAR*         = 0x40000053'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_NUMLOCKCLEAR)
const SDLK_KP_DIVIDE*            = 0x40000054'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_DIVIDE)
const SDLK_KP_MULTIPLY*          = 0x40000055'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_MULTIPLY)
const SDLK_KP_MINUS*             = 0x40000056'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_MINUS)
const SDLK_KP_PLUS*              = 0x40000057'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_PLUS)
const SDLK_KP_ENTER*             = 0x40000058'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_ENTER)
const SDLK_KP_1*                 = 0x40000059'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_1)
const SDLK_KP_2*                 = 0x4000005a'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_2)
const SDLK_KP_3*                 = 0x4000005b'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_3)
const SDLK_KP_4*                 = 0x4000005c'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_4)
const SDLK_KP_5*                 = 0x4000005d'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_5)
const SDLK_KP_6*                 = 0x4000005e'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_6)
const SDLK_KP_7*                 = 0x4000005f'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_7)
const SDLK_KP_8*                 = 0x40000060'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_8)
const SDLK_KP_9*                 = 0x40000061'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_9)
const SDLK_KP_0*                 = 0x40000062'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_0)
const SDLK_KP_PERIOD*            = 0x40000063'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_PERIOD)
const SDLK_APPLICATION*          = 0x40000065'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_APPLICATION)
const SDLK_POWER*                = 0x40000066'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_POWER)
const SDLK_KP_EQUALS*            = 0x40000067'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_EQUALS)
const SDLK_F13*                  = 0x40000068'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F13)
const SDLK_F14*                  = 0x40000069'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F14)
const SDLK_F15*                  = 0x4000006a'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F15)
const SDLK_F16*                  = 0x4000006b'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F16)
const SDLK_F17*                  = 0x4000006c'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F17)
const SDLK_F18*                  = 0x4000006d'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F18)
const SDLK_F19*                  = 0x4000006e'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F19)
const SDLK_F20*                  = 0x4000006f'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F20)
const SDLK_F21*                  = 0x40000070'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F21)
const SDLK_F22*                  = 0x40000071'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F22)
const SDLK_F23*                  = 0x40000072'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F23)
const SDLK_F24*                  = 0x40000073'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F24)
const SDLK_EXECUTE*              = 0x40000074'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_EXECUTE)
const SDLK_HELP*                 = 0x40000075'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_HELP)
const SDLK_MENU*                 = 0x40000076'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_MENU)
const SDLK_SELECT*               = 0x40000077'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_SELECT)
const SDLK_STOP*                 = 0x40000078'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_STOP)
const SDLK_AGAIN*                = 0x40000079'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_AGAIN)
const SDLK_UNDO*                 = 0x4000007a'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_UNDO)
const SDLK_CUT*                  = 0x4000007b'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_CUT)
const SDLK_COPY*                 = 0x4000007c'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_COPY)
const SDLK_PASTE*                = 0x4000007d'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_PASTE)
const SDLK_FIND*                 = 0x4000007e'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_FIND)
const SDLK_MUTE*                 = 0x4000007f'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_MUTE)
const SDLK_VOLUMEUP*             = 0x40000080'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_VOLUMEUP)
const SDLK_VOLUMEDOWN*           = 0x40000081'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_VOLUMEDOWN)
const SDLK_KP_COMMA*             = 0x40000085'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_COMMA)
const SDLK_KP_EQUALSAS400*       = 0x40000086'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_EQUALSAS400)
const SDLK_ALTERASE*             = 0x40000099'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_ALTERASE)
const SDLK_SYSREQ*               = 0x4000009a'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_SYSREQ)
const SDLK_CANCEL*               = 0x4000009b'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_CANCEL)
const SDLK_CLEAR*                = 0x4000009c'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_CLEAR)
const SDLK_PRIOR*                = 0x4000009d'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_PRIOR)
const SDLK_RETURN2*              = 0x4000009e'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_RETURN2)
const SDLK_SEPARATOR*            = 0x4000009f'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_SEPARATOR)
const SDLK_OUT*                  = 0x400000a0'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_OUT)
const SDLK_OPER*                 = 0x400000a1'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_OPER)
const SDLK_CLEARAGAIN*           = 0x400000a2'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_CLEARAGAIN)
const SDLK_CRSEL*                = 0x400000a3'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_CRSEL)
const SDLK_EXSEL*                = 0x400000a4'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_EXSEL)
const SDLK_KP_00*                = 0x400000b0'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_00)
const SDLK_KP_000*               = 0x400000b1'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_000)
const SDLK_THOUSANDSSEPARATOR*   = 0x400000b2'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_THOUSANDSSEPARATOR)
const SDLK_DECIMALSEPARATOR*     = 0x400000b3'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_DECIMALSEPARATOR)
const SDLK_CURRENCYUNIT*         = 0x400000b4'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_CURRENCYUNIT)
const SDLK_CURRENCYSUBUNIT*      = 0x400000b5'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_CURRENCYSUBUNIT)
const SDLK_KP_LEFTPAREN*         = 0x400000b6'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_LEFTPAREN)
const SDLK_KP_RIGHTPAREN*        = 0x400000b7'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_RIGHTPAREN)
const SDLK_KP_LEFTBRACE*         = 0x400000b8'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_LEFTBRACE)
const SDLK_KP_RIGHTBRACE*        = 0x400000b9'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_RIGHTBRACE)
const SDLK_KP_TAB*               = 0x400000ba'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_TAB)
const SDLK_KP_BACKSPACE*         = 0x400000bb'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_BACKSPACE)
const SDLK_KP_A*                 = 0x400000bc'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_A)
const SDLK_KP_B*                 = 0x400000bd'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_B)
const SDLK_KP_C*                 = 0x400000be'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_C)
const SDLK_KP_D*                 = 0x400000bf'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_D)
const SDLK_KP_E*                 = 0x400000c0'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_E)
const SDLK_KP_F*                 = 0x400000c1'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_F)
const SDLK_KP_XOR*               = 0x400000c2'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_XOR)
const SDLK_KP_POWER*             = 0x400000c3'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_POWER)
const SDLK_KP_PERCENT*           = 0x400000c4'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_PERCENT)
const SDLK_KP_LESS*              = 0x400000c5'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_LESS)
const SDLK_KP_GREATER*           = 0x400000c6'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_GREATER)
const SDLK_KP_AMPERSAND*         = 0x400000c7'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_AMPERSAND)
const SDLK_KP_DBLAMPERSAND*      = 0x400000c8'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_DBLAMPERSAND)
const SDLK_KP_VERTICALBAR*       = 0x400000c9'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_VERTICALBAR)
const SDLK_KP_DBLVERTICALBAR*    = 0x400000ca'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_DBLVERTICALBAR)
const SDLK_KP_COLON*             = 0x400000cb'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_COLON)
const SDLK_KP_HASH*              = 0x400000cc'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_HASH)
const SDLK_KP_SPACE*             = 0x400000cd'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_SPACE)
const SDLK_KP_AT*                = 0x400000ce'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_AT)
const SDLK_KP_EXCLAM*            = 0x400000cf'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_EXCLAM)
const SDLK_KP_MEMSTORE*          = 0x400000d0'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_MEMSTORE)
const SDLK_KP_MEMRECALL*         = 0x400000d1'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_MEMRECALL)
const SDLK_KP_MEMCLEAR*          = 0x400000d2'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_MEMCLEAR)
const SDLK_KP_MEMADD*            = 0x400000d3'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_MEMADD)
const SDLK_KP_MEMSUBTRACT*       = 0x400000d4'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_MEMSUBTRACT)
const SDLK_KP_MEMMULTIPLY*       = 0x400000d5'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_MEMMULTIPLY)
const SDLK_KP_MEMDIVIDE*         = 0x400000d6'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_MEMDIVIDE)
const SDLK_KP_PLUSMINUS*         = 0x400000d7'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_PLUSMINUS)
const SDLK_KP_CLEAR*             = 0x400000d8'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_CLEAR)
const SDLK_KP_CLEARENTRY*        = 0x400000d9'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_CLEARENTRY)
const SDLK_KP_BINARY*            = 0x400000da'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_BINARY)
const SDLK_KP_OCTAL*             = 0x400000db'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_OCTAL)
const SDLK_KP_DECIMAL*           = 0x400000dc'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_DECIMAL)
const SDLK_KP_HEXADECIMAL*       = 0x400000dd'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_HEXADECIMAL)
const SDLK_LCTRL*                = 0x400000e0'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_LCTRL)
const SDLK_LSHIFT*               = 0x400000e1'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_LSHIFT)
const SDLK_LALT*                 = 0x400000e2'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_LALT)
const SDLK_LGUI*                 = 0x400000e3'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_LGUI)
const SDLK_RCTRL*                = 0x400000e4'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_RCTRL)
const SDLK_RSHIFT*               = 0x400000e5'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_RSHIFT)
const SDLK_RALT*                 = 0x400000e6'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_RALT)
const SDLK_RGUI*                 = 0x400000e7'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_RGUI)
const SDLK_MODE*                 = 0x40000101'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_MODE)
const SDLK_SLEEP*                = 0x40000102'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_SLEEP)
const SDLK_WAKE*                 = 0x40000103'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_WAKE)
const SDLK_CHANNEL_INCREMENT*    = 0x40000104'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_CHANNEL_INCREMENT)
const SDLK_CHANNEL_DECREMENT*    = 0x40000105'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_CHANNEL_DECREMENT)
const SDLK_MEDIA_PLAY*           = 0x40000106'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_MEDIA_PLAY)
const SDLK_MEDIA_PAUSE*          = 0x40000107'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_MEDIA_PAUSE)
const SDLK_MEDIA_RECORD*         = 0x40000108'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_MEDIA_RECORD)
const SDLK_MEDIA_FAST_FORWARD*   = 0x40000109'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_MEDIA_FAST_FORWARD)
const SDLK_MEDIA_REWIND*         = 0x4000010a'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_MEDIA_REWIND)
const SDLK_MEDIA_NEXT_TRACK*     = 0x4000010b'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_MEDIA_NEXT_TRACK)
const SDLK_MEDIA_PREVIOUS_TRACK* = 0x4000010c'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_MEDIA_PREVIOUS_TRACK)
const SDLK_MEDIA_STOP*           = 0x4000010d'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_MEDIA_STOP)
const SDLK_MEDIA_EJECT*          = 0x4000010e'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_MEDIA_EJECT)
const SDLK_MEDIA_PLAY_PAUSE*     = 0x4000010f'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_MEDIA_PLAY_PAUSE)
const SDLK_MEDIA_SELECT*         = 0x40000110'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_MEDIA_SELECT)
const SDLK_AC_NEW*               = 0x40000111'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_AC_NEW)
const SDLK_AC_OPEN*              = 0x40000112'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_AC_OPEN)
const SDLK_AC_CLOSE*             = 0x40000113'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_AC_CLOSE)
const SDLK_AC_EXIT*              = 0x40000114'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_AC_EXIT)
const SDLK_AC_SAVE*              = 0x40000115'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_AC_SAVE)
const SDLK_AC_PRINT*             = 0x40000116'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_AC_PRINT)
const SDLK_AC_PROPERTIES*        = 0x40000117'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_AC_PROPERTIES)
const SDLK_AC_SEARCH*            = 0x40000118'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_AC_SEARCH)
const SDLK_AC_HOME*              = 0x40000119'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_AC_HOME)
const SDLK_AC_BACK*              = 0x4000011a'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_AC_BACK)
const SDLK_AC_FORWARD*           = 0x4000011b'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_AC_FORWARD)
const SDLK_AC_STOP*              = 0x4000011c'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_AC_STOP)
const SDLK_AC_REFRESH*           = 0x4000011d'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_AC_REFRESH)
const SDLK_AC_BOOKMARKS*         = 0x4000011e'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_AC_BOOKMARKS)
const SDLK_SOFTLEFT*             = 0x4000011f'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_SOFTLEFT)
const SDLK_SOFTRIGHT*            = 0x40000120'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_SOFTRIGHT)
const SDLK_CALL*                 = 0x40000121'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_CALL)
const SDLK_ENDCALL*              = 0x40000122'u32 # SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_ENDCALL)

const SDL_KMOD_NONE*             = 0x0000'u32 # no modifier is applicable.
const SDL_KMOD_LSHIFT*           = 0x0001'u32 # the left Shift key is down.
const SDL_KMOD_RSHIFT*           = 0x0002'u32 # the right Shift key is down.
const SDL_KMOD_LCTRL*            = 0x0040'u32 # the left Ctrl (Control) key is down.
const SDL_KMOD_RCTRL*            = 0x0080'u32 # the right Ctrl (Control) key is down.
const SDL_KMOD_LALT*             = 0x0100'u32 # the left Alt key is down.
const SDL_KMOD_RALT*             = 0x0200'u32 # the right Alt key is down.
const SDL_KMOD_LGUI*             = 0x0400'u32 # the left GUI key (often the Windows key) is down.
const SDL_KMOD_RGUI*             = 0x0800'u32 # the right GUI key (often the Windows key) is down.
const SDL_KMOD_NUM*              = 0x1000'u32 # the Num Lock key (may be located on an extended keypad) is down.
const SDL_KMOD_CAPS*             = 0x2000'u32 # the Caps Lock key is down.
const SDL_KMOD_MODE*             = 0x4000'u32 # the !AltGr key is down.
const SDL_KMOD_SCROLL*           = 0x8000'u32 # the Scroll Lock key is down.
const SDL_KMOD_CTRL*             = (SDL_KMOD_LCTRL or SDL_KMOD_RCTRL)   # Any Ctrl key is down.
const SDL_KMOD_SHIFT*            = (SDL_KMOD_LSHIFT or SDL_KMOD_RSHIFT) # Any Shift key is down.
const SDL_KMOD_ALT*              = (SDL_KMOD_LALT or SDL_KMOD_RALT)     # Any Alt key is down.
const SDL_KMOD_GUI*              = (SDL_KMOD_LGUI or SDL_KMOD_RGUI)     # Any GUI key is down.

#endregion


#region SDL3/SDL_keyboard.h ---------------------------------------------------

type
  SDL_KeyboardID* = uint32

proc SDL_HasKeyboard* (): bool {.importc.}
proc SDL_GetKeyboards* ( count: var int ): ptr UncheckedArray[SDL_KeyboardID] {.importc.}
proc SDL_GetKeyboardNameForID* ( instance_id: SDL_KeyboardID ): cstring {.importc.}
proc SDL_GetKeyboardFocus* (): SDL_Window {.importc.}
proc SDL_GetKeyboardState* ( numkeys: var int ): ptr UncheckedArray[bool] {.importc.}
proc SDL_ResetKeyboard* (): void {.importc.}
proc SDL_GetModState* (): SDL_Keymod {.importc.}
proc SDL_SetModState* ( modstate: SDL_Keymod ): void {.importc.}
proc SDL_GetKeyFromScancode* ( scancode: SDL_Scancode, modstate: SDL_Keymod, key_event: bool ): SDL_Keycode {.importc.}
proc SDL_GetScancodeFromKey* ( key: SDL_Keycode, modstate: var SDL_Keymod ): SDL_Scancode {.importc.}
proc SDL_SetScancodeName* ( scancode: SDL_Scancode, name: cstring ): bool {.importc.}
proc SDL_GetScancodeName* ( scancode: SDL_Scancode ): cstring {.importc.}
proc SDL_GetScancodeFromName* ( name: cstring ): SDL_Scancode {.importc.}
proc SDL_GetKeyName* ( key: SDL_Keycode ): cstring {.importc.}
proc SDL_GetKeyFromName* ( name: cstring ): SDL_Keycode {.importc.}
proc SDL_StartTextInput* ( window: SDL_Window ): bool {.importc.}

type
  SDL_TextInputType* {.size: sizeof(cint).} = enum
    SDL_TEXTINPUT_TYPE_TEXT,
    SDL_TEXTINPUT_TYPE_TEXT_NAME,
    SDL_TEXTINPUT_TYPE_TEXT_EMAIL,
    SDL_TEXTINPUT_TYPE_TEXT_USERNAME,
    SDL_TEXTINPUT_TYPE_TEXT_PASSWORD_HIDDEN,
    SDL_TEXTINPUT_TYPE_TEXT_PASSWORD_VISIBLE,
    SDL_TEXTINPUT_TYPE_NUMBER,
    SDL_TEXTINPUT_TYPE_NUMBER_PASSWORD_HIDDEN,
    SDL_TEXTINPUT_TYPE_NUMBER_PASSWORD_VISIBLE

type
  SDL_Capitalization* {.size: sizeof(cint).} = enum
    SDL_CAPITALIZE_NONE,
    SDL_CAPITALIZE_SENTENCES,
    SDL_CAPITALIZE_WORDS,
    SDL_CAPITALIZE_LETTERS

proc SDL_StartTextInputWithProperties* ( window: SDL_Window, props: SDL_PropertiesID): bool {.importc.}
proc SDL_TextInputActive* ( window: SDL_Window ): bool {.importc.}
proc SDL_StopTextInput* ( window: SDL_Window ): bool {.importc.}
proc SDL_ClearComposition* ( window: SDL_Window ): bool {.importc.}
proc SDL_SetTextInputArea* ( window: SDL_Window, rect: ptr SDL_Rect, cursor: int ): bool {.importc.}
proc SDL_GetTextInputArea* ( window: SDL_Window, rect: var SDL_Rect, cursor: var int ): bool {.importc.}
proc SDL_HasScreenKeyboardSupport* (): bool {.importc.}
proc SDL_ScreenKeyboardShown* ( window: SDL_Window ): bool {.importc.}

const SDL_PROP_TEXTINPUT_TYPE_NUMBER* =              "SDL.textinput.type"
const SDL_PROP_TEXTINPUT_CAPITALIZATION_NUMBER* =    "SDL.textinput.capitalization"
const SDL_PROP_TEXTINPUT_AUTOCORRECT_BOOLEAN* =      "SDL.textinput.autocorrect"
const SDL_PROP_TEXTINPUT_MULTILINE_BOOLEAN* =        "SDL.textinput.multiline"
const SDL_PROP_TEXTINPUT_ANDROID_INPUTTYPE_NUMBER* = "SDL.textinput.android.inputtype"

#endregion


#region SDL3/SDL_loadso.h -----------------------------------------------------

type
  SDL_SharedObject* = pointer

proc SDL_LoadObject* ( sofile: cstring ): SDL_SharedObject {.importc.}
proc SDL_LoadFunction* ( handle: SDL_SharedObject, name: cstring ): SDL_FunctionPointer {.importc.}
proc SDL_UnloadObject* ( handle: SDL_SharedObject ): void {.importc.}

#endregion


#region SDL3/SDL_locale.h -----------------------------------------------------

type
  SDL_Locale* {.bycopy.} = object
    language*: cstring
    country*: cstring

proc SDL_GetPreferredLocales* ( count: var int ): ptr UncheckedArray[ptr SDL_Locale] {.importc.}

#endregion


#region SDL3/SDL_log.h --------------------------------------------------------

type
  SDL_LogCategory* {.size: sizeof(cint).} = enum
    SDL_LOG_CATEGORY_APPLICATION,
    SDL_LOG_CATEGORY_ERROR,
    SDL_LOG_CATEGORY_ASSERT,
    SDL_LOG_CATEGORY_SYSTEM,
    SDL_LOG_CATEGORY_AUDIO,
    SDL_LOG_CATEGORY_VIDEO,
    SDL_LOG_CATEGORY_RENDER,
    SDL_LOG_CATEGORY_INPUT,
    SDL_LOG_CATEGORY_TEST,
    SDL_LOG_CATEGORY_GPU,
    SDL_LOG_CATEGORY_RESERVED2,
    SDL_LOG_CATEGORY_RESERVED3,
    SDL_LOG_CATEGORY_RESERVED4,
    SDL_LOG_CATEGORY_RESERVED5,
    SDL_LOG_CATEGORY_RESERVED6,
    SDL_LOG_CATEGORY_RESERVED7,
    SDL_LOG_CATEGORY_RESERVED8,
    SDL_LOG_CATEGORY_RESERVED9,
    SDL_LOG_CATEGORY_RESERVED10,
    SDL_LOG_CATEGORY_CUSTOM

  SDL_LogPriority* {.size: sizeof(cint).} = enum
    SDL_LOG_PRIORITY_INVALID,
    SDL_LOG_PRIORITY_TRACE,
    SDL_LOG_PRIORITY_VERBOSE,
    SDL_LOG_PRIORITY_DEBUG,
    SDL_LOG_PRIORITY_INFO,
    SDL_LOG_PRIORITY_WARN,
    SDL_LOG_PRIORITY_ERROR,
    SDL_LOG_PRIORITY_CRITICAL,
    SDL_LOG_PRIORITY_COUNT

proc SDL_SetLogPriorities* ( priority: SDL_LogPriority ): void {.importc.}
proc SDL_SetLogPriority* ( category: int, priority: SDL_LogPriority ): void {.importc.}
proc SDL_GetLogPriority* ( category: int ): SDL_LogPriority {.importc.}
proc SDL_ResetLogPriorities* (): void {.importc.}
proc SDL_SetLogPriorityPrefix* ( priority: SDL_LogPriority, prefix: cstring ): bool {.importc.}

proc SDL_Log* ( fmt: cstring ): void {.importc, varargs.}
proc SDL_LogTrace* ( category: int, fmt: cstring ): void {.importc, varargs.}
proc SDL_LogVerbose* ( category: int, fmt: cstring ): void {.importc, varargs.}
proc SDL_LogDebug* ( category: int, fmt: cstring ): void {.importc, varargs.}
proc SDL_LogInfo* ( category: int, fmt: cstring ): void {.importc, varargs.}
proc SDL_LogWarn* ( category: int, fmt: cstring ): void {.importc, varargs.}
proc SDL_LogError* ( category: int, fmt: cstring ): void {.importc, varargs.}
proc SDL_LogCritical* ( category: int, fmt: cstring ): void {.importc, varargs.}

proc SDL_LogMessage* ( category: int, priority: SDL_LogPriority, fmt: cstring ): void {.importc, varargs.}
proc SDL_LogMessageV* ( category: int, priority: SDL_LogPriority, fmt: cstring, ap: cva_list ): void {.importc, varargs.}

type
  SDL_LogOutputFunction* = proc (userdata: pointer; category: cint; priority: SDL_LogPriority; message: cstring) {.cdecl.}

proc SDL_GetDefaultLogOutputFunction* (): SDL_LogOutputFunction {.importc.}
proc SDL_GetLogOutputFunction* ( callback: var SDL_LogOutputFunction, userdata: var pointer ): void {.importc.}
proc SDL_SetLogOutputFunction* ( callback: SDL_LogOutputFunction, userdata: pointer ): void {.importc.}

#endregion


#region SDL3/SDL_messagebox.h -------------------------------------------------

type
  SDL_MessageBoxFlags* = uint32
  SDL_MessageBoxButtonFlags* = uint32
  SDL_MessageBoxButtonData* {.bycopy.} = object
    flags*: SDL_MessageBoxButtonFlags
    buttonID*: cint
    text*: cstring

  SDL_MessageBoxColor* {.bycopy.} = object
    r*: uint8
    g*: uint8
    b*: uint8

  SDL_MessageBoxColorType* {.size: sizeof(cint).} = enum
    SDL_MESSAGEBOX_COLOR_BACKGROUND,
    SDL_MESSAGEBOX_COLOR_TEXT,
    SDL_MESSAGEBOX_COLOR_BUTTON_BORDER,
    SDL_MESSAGEBOX_COLOR_BUTTON_BACKGROUND,
    SDL_MESSAGEBOX_COLOR_BUTTON_SELECTED,
    SDL_MESSAGEBOX_COLOR_COUNT

  SDL_MessageBoxColorScheme* {.bycopy.} = object
    colors*: array[SDL_MESSAGEBOX_COLOR_COUNT, SDL_MessageBoxColor]

  SDL_MessageBoxData* {.bycopy.} = object
    flags*: SDL_MessageBoxFlags
    window*: SDL_Window
    title*: cstring
    message*: cstring
    numbuttons*: cint
    buttons*: ptr UncheckedArray[SDL_MessageBoxButtonData]
    colorScheme*: ptr SDL_MessageBoxColorScheme

const SDL_MESSAGEBOX_ERROR* =                 0x00000010'u32 # error dialog
const SDL_MESSAGEBOX_WARNING* =               0x00000020'u32 # warning dialog
const SDL_MESSAGEBOX_INFORMATION* =           0x00000040'u32 # informational dialog
const SDL_MESSAGEBOX_BUTTONS_LEFT_TO_RIGHT* = 0x00000080'u32 # buttons placed left to right
const SDL_MESSAGEBOX_BUTTONS_RIGHT_TO_LEFT* = 0x00000100'u32 # buttons placed right to left

const SDL_MESSAGEBOX_BUTTON_RETURNKEY_DEFAULT* = 0x00000001'u # Marks the default button when return is hit
const SDL_MESSAGEBOX_BUTTON_ESCAPEKEY_DEFAULT* = 0x00000002'u # Marks the default button when escape is hit


proc SDL_ShowMessageBox* ( messageboxdata: ptr SDL_MessageBoxData, buttonid: var int ): bool {.importc.}
proc SDL_ShowSimpleMessageBox* ( flags: SDL_MessageBoxFlags, title,message: cstring, window: SDL_Window ): bool {.importc.}

#endregion


#region SDL3/SDL_metal.h ------------------------------------------------------

type
  SDL_MetalView* = pointer

proc SDL_Metal_CreateView* ( window: SDL_Window ): SDL_MetalView {.importc.}
proc SDL_Metal_DestroyView* ( view: SDL_MetalView ): void {.importc.}
proc SDL_Metal_GetLayer* ( view: SDL_MetalView ): pointer {.importc.}

#endregion


#region SDL3/SDL_misc.h -------------------------------------------------------

proc SDL_OpenURL* ( url: cstring ): bool {.importc.}

#endregion


#region SDL3/SDL_mouse.h ------------------------------------------------------

type
  SDL_MouseID* = uint32
  SDL_SystemCursor* {.size: sizeof(cint).} = enum
    SDL_SYSTEM_CURSOR_DEFAULT,
    SDL_SYSTEM_CURSOR_TEXT,
    SDL_SYSTEM_CURSOR_WAIT,
    SDL_SYSTEM_CURSOR_CROSSHAIR,
    SDL_SYSTEM_CURSOR_PROGRESS,
    SDL_SYSTEM_CURSOR_NWSE_RESIZE,
    SDL_SYSTEM_CURSOR_NESW_RESIZE,
    SDL_SYSTEM_CURSOR_EW_RESIZE,
    SDL_SYSTEM_CURSOR_NS_RESIZE,
    SDL_SYSTEM_CURSOR_MOVE,
    SDL_SYSTEM_CURSOR_NOT_ALLOWED,
    SDL_SYSTEM_CURSOR_POINTER,
    SDL_SYSTEM_CURSOR_NW_RESIZE,
    SDL_SYSTEM_CURSOR_N_RESIZE,
    SDL_SYSTEM_CURSOR_NE_RESIZE,
    SDL_SYSTEM_CURSOR_E_RESIZE,
    SDL_SYSTEM_CURSOR_SE_RESIZE,
    SDL_SYSTEM_CURSOR_S_RESIZE,
    SDL_SYSTEM_CURSOR_SW_RESIZE,
    SDL_SYSTEM_CURSOR_W_RESIZE,
    SDL_SYSTEM_CURSOR_COUNT
  SDL_MouseWheelDirection* {.size: sizeof(cint).} = enum
    SDL_MOUSEWHEEL_NORMAL,
    SDL_MOUSEWHEEL_FLIPPED
  SDL_MouseButtonFlags* = uint32

const SDL_BUTTON_LEFT* =     1
const SDL_BUTTON_MIDDLE* =   2
const SDL_BUTTON_RIGHT* =    3
const SDL_BUTTON_X1* =       4
const SDL_BUTTON_X2* =       5
proc SDL_BUTTON_MASK* (x: uint): uint = 1'u shl ((x)-1)
const SDL_BUTTON_LMASK* =    SDL_BUTTON_MASK(SDL_BUTTON_LEFT)
const SDL_BUTTON_MMASK* =    SDL_BUTTON_MASK(SDL_BUTTON_MIDDLE)
const SDL_BUTTON_RMASK* =    SDL_BUTTON_MASK(SDL_BUTTON_RIGHT)
const SDL_BUTTON_X1MASK* =   SDL_BUTTON_MASK(SDL_BUTTON_X1)
const SDL_BUTTON_X2MASK* =   SDL_BUTTON_MASK(SDL_BUTTON_X2)

proc SDL_HasMouse* (): bool {.importc.}
proc SDL_GetMice* ( count: var int ): ptr UncheckedArray[SDL_MouseID] {.importc.}
proc SDL_GetMouseNameForID* ( instance_id: SDL_MouseID ): cstring {.importc.}
proc SDL_GetMouseFocus* (): SDL_Window {.importc.}
proc SDL_GetMouseState* ( x,y: var cfloat ): SDL_MouseButtonFlags {.importc.}
proc SDL_GetGlobalMouseState* ( x,y: var cfloat ): SDL_MouseButtonFlags {.importc.}
proc SDL_GetRelativeMouseState* ( x,y: var cfloat ): SDL_MouseButtonFlags {.importc.}
proc SDL_WarpMouseInWindow* ( window: SDL_Window, x,y: cfloat ): void {.importc.}
proc SDL_WarpMouseGlobal* ( x,y: cfloat ): bool {.importc.}
proc SDL_SetWindowRelativeMouseMode* ( window: SDL_Window, enabled: bool ): bool {.importc, discardable.}
proc SDL_GetWindowRelativeMouseMode* ( window: SDL_Window ): bool {.importc.}
proc SDL_CaptureMouse* ( enabled: bool ): bool {.importc, discardable.}

type
  SDL_Cursor* = pointer

proc SDL_CreateCursor* ( data,mask: ptr uint8, w,h: int, hot_x,hot_y: int ): SDL_Cursor {.importc.}
proc SDL_CreateColorCursor* ( surface: ptr SDL_Surface, hot_x,hot_y: int ): SDL_Cursor {.importc.}
proc SDL_CreateSystemCursor* ( id: SDL_SystemCursor ): SDL_Cursor {.importc.}
proc SDL_SetCursor* ( cursor: SDL_Cursor ): bool {.importc.}
proc SDL_GetCursor* (): SDL_Cursor {.importc.}
proc SDL_GetDefaultCursor* (): SDL_Cursor {.importc.}
proc SDL_DestroyCursor* ( cursor: SDL_Cursor ): void {.importc.}
proc SDL_ShowCursor* (): bool {.importc.}
proc SDL_HideCursor* (): bool {.importc.}
proc SDL_CursorVisible* (): bool {.importc.}

#endregion


#region SDL3/SDL_mutex.h ------------------------------------------------------

type
  SDL_ThreadID* = uint64
  SDL_TLSID* = SDL_AtomicInt
  SDL_ThreadPriority* {.size: sizeof(cint).} = enum
    SDL_THREAD_PRIORITY_LOW,
    SDL_THREAD_PRIORITY_NORMAL,
    SDL_THREAD_PRIORITY_HIGH,
    SDL_THREAD_PRIORITY_TIME_CRITICAL

type
  SDL_ThreadState* {.size: sizeof(cint).} = enum
    SDL_THREAD_UNKNOWN,
    SDL_THREAD_ALIVE,
    SDL_THREAD_DETACHED,
    SDL_THREAD_COMPLETE

type
  SDL_Thread* = pointer
  SDL_ThreadFunction* = proc (data: pointer): cint {.cdecl.}

proc SDL_CreateThreadRuntime* ( fn: SDL_ThreadFunction, name: cstring, data: pointer, pfnBeginThread: SDL_FunctionPointer, pfnEndThread: SDL_FunctionPointer ): SDL_Thread {.importc.}
proc SDL_CreateThreadWithPropertiesRuntime* ( props: SDL_PropertiesID, pfnBeginThread: SDL_FunctionPointer, pfnEndThread: SDL_FunctionPointer ): SDL_Thread {.importc.}
proc SDL_GetThreadName* ( thread: SDL_Thread ): cstring {.importc.}
proc SDL_GetCurrentThreadID* (): SDL_ThreadID {.importc.}
proc SDL_GetThreadID* ( thread: SDL_Thread ): SDL_ThreadID {.importc.}
proc SDL_SetCurrentThreadPriority* ( priority: SDL_ThreadPriority ): bool {.importc.}
proc SDL_WaitThread* ( thread: SDL_Thread, status: var int ): void {.importc.}
proc SDL_GetThreadState* ( thread: SDL_Thread ): SDL_ThreadState {.importc.}
proc SDL_DetachThread* ( thread: SDL_Thread ): void {.importc.}
proc SDL_GetTLS* ( id: ptr SDL_TLSID ): pointer {.importc.}

type SDL_TLSDestructorCallback* = proc (value: pointer) {.cdecl.}

proc SDL_SetTLS* ( id: ptr SDL_TLSID, value: pointer, destructor: SDL_TLSDestructorCallback ): bool {.importc.}
proc SDL_CleanupTLS* (): void {.importc.}

type SDL_Mutex* = pointer

proc SDL_CreateMutex* (): SDL_Mutex {.importc.}
proc SDL_LockMutex* ( mutex: SDL_Mutex ): void {.importc.}
proc SDL_TryLockMutex* ( mutex: SDL_Mutex ): bool {.importc.}
proc SDL_UnlockMutex* ( mutex: SDL_Mutex ): void {.importc.}
proc SDL_DestroyMutex* ( mutex: SDL_Mutex ): void {.importc.}

type SDL_RWLock* = pointer

proc SDL_CreateRWLock* (): SDL_RWLock {.importc.}
proc SDL_LockRWLockForReading* ( rwlock: SDL_RWLock ): void {.importc.}
proc SDL_LockRWLockForWriting* ( rwlock: SDL_RWLock ): void {.importc.}
proc SDL_TryLockRWLockForReading* ( rwlock: SDL_RWLock ): bool {.importc.}
proc SDL_TryLockRWLockForWriting* ( rwlock: SDL_RWLock ): bool {.importc.}
proc SDL_UnlockRWLock* ( rwlock: SDL_RWLock ): void {.importc.}
proc SDL_DestroyRWLock* ( rwlock: SDL_RWLock ): void {.importc.}

type SDL_Semaphore* = pointer

proc SDL_CreateSemaphore* ( initial_value: uint32 ): SDL_Semaphore {.importc.}
proc SDL_DestroySemaphore* ( sem: SDL_Semaphore ): void {.importc.}
proc SDL_WaitSemaphore* ( sem: SDL_Semaphore ): void {.importc.}
proc SDL_TryWaitSemaphore* ( sem: SDL_Semaphore ): bool {.importc.}
proc SDL_WaitSemaphoreTimeout* ( sem: SDL_Semaphore, timeoutMS: int32 ): bool {.importc.}
proc SDL_SignalSemaphore* ( sem: SDL_Semaphore ): void {.importc.}
proc SDL_GetSemaphoreValue* ( sem: SDL_Semaphore ): uint32 {.importc.}

type SDL_Condition* = pointer

proc SDL_CreateCondition* (): SDL_Condition {.importc.}
proc SDL_DestroyCondition* ( cond: SDL_Condition ): void {.importc.}
proc SDL_SignalCondition* ( cond: SDL_Condition ): void {.importc.}
proc SDL_BroadcastCondition* ( cond: SDL_Condition ): void {.importc.}
proc SDL_WaitCondition* ( cond: SDL_Condition, mutex: SDL_Mutex ): void {.importc.}
proc SDL_WaitConditionTimeout* ( cond: SDL_Condition, mutex: SDL_Mutex, timeoutMS: int32 ): bool {.importc.}

type
  SDL_InitStatus* {.size: sizeof(cint).} = enum
    SDL_INIT_STATUS_UNINITIALIZED,
    SDL_INIT_STATUS_INITIALIZING,
    SDL_INIT_STATUS_INITIALIZED,
    SDL_INIT_STATUS_UNINITIALIZING

type
  SDL_InitState* {.bycopy.} = object
    status*: SDL_AtomicInt
    thread*: SDL_ThreadID
    reserved*: pointer

proc SDL_ShouldInit* ( state: ptr SDL_InitState ): bool {.importc.}
proc SDL_ShouldQuit* ( state: ptr SDL_InitState ): bool {.importc.}
proc SDL_SetInitialized* ( statE: SDL_InitState, initialized: bool ): void {.importc.}

#endregion


#region SDL3/SDL_pen.h --------------------------------------------------------

type
  SDL_PenID* = uint32
  SDL_PenInputFlags* = uint32
  SDL_PenAxis* {.size: sizeof(cint).} = enum
    SDL_PEN_AXIS_PRESSURE,
    SDL_PEN_AXIS_XTILT,
    SDL_PEN_AXIS_YTILT,
    SDL_PEN_AXIS_DISTANCE,
    SDL_PEN_AXIS_ROTATION,
    SDL_PEN_AXIS_SLIDER,
    SDL_PEN_AXIS_TANGENTIAL_PRESSURE,
    SDL_PEN_AXIS_COUNT

const SDL_PEN_INPUT_DOWN* =       (1'u shl 0)  # pen is pressed down
const SDL_PEN_INPUT_BUTTON_1* =   (1'u shl 1)  # button 1 is pressed
const SDL_PEN_INPUT_BUTTON_2* =   (1'u shl 2)  # button 2 is pressed
const SDL_PEN_INPUT_BUTTON_3* =   (1'u shl 3)  # button 3 is pressed
const SDL_PEN_INPUT_BUTTON_4* =   (1'u shl 4)  # button 4 is pressed
const SDL_PEN_INPUT_BUTTON_5* =   (1'u shl 5)  # button 5 is pressed
const SDL_PEN_INPUT_ERASER_TIP* = (1'u shl 30) # eraser tip is used

#endregion


#region SDL3/SDL_platform.h ---------------------------------------------------

proc SDL_GetPlatform* (): cstring {.importc.}

#endregion


#region SDL3/SDL_process.h ----------------------------------------------------

type
  SDL_Process* = pointer

proc SDL_CreateProcess* ( args: ptr[cstring], pipe_stdio: bool ): SDL_Process {.importc.}

type
  SDL_ProcessIO* {.size: sizeof(cint).} = enum
    SDL_PROCESS_STDIO_INHERITED,
    SDL_PROCESS_STDIO_NULL,
    SDL_PROCESS_STDIO_APP,
    SDL_PROCESS_STDIO_REDIRECT

proc SDL_CreateProcessWithProperties* ( props: SDL_PropertiesID ): SDL_Process {.importc.}
proc SDL_GetProcessProperties* ( process: SDL_Process ): SDL_PropertiesID {.importc.}

proc SDL_ReadProcess* ( process: SDL_Process, datasize: csize_t, exitcode: var int ): pointer {.importc.}
proc SDL_GetProcessInput* ( process: SDL_Process ): SDL_IOStream {.importc.}
proc SDL_GetProcessOutput* ( process: SDL_Process ): SDL_IOStream {.importc.}

proc SDL_KillProcess* ( process: SDL_Process, force: bool ): bool {.importc.}
proc SDL_WaitProcess* ( process: SDL_Process, blocking: bool, exitcode: var int ): bool {.importc.}
proc SDL_DestroyProcess* ( process: SDL_Process ): void {.importc.}

const SDL_PROP_PROCESS_CREATE_ARGS_POINTER* =             "SDL.process.create.args"
const SDL_PROP_PROCESS_CREATE_ENVIRONMENT_POINTER* =      "SDL.process.create.environment"
const SDL_PROP_PROCESS_CREATE_STDIN_NUMBER* =             "SDL.process.create.stdin_option"
const SDL_PROP_PROCESS_CREATE_STDIN_POINTER* =            "SDL.process.create.stdin_source"
const SDL_PROP_PROCESS_CREATE_STDOUT_NUMBER* =            "SDL.process.create.stdout_option"
const SDL_PROP_PROCESS_CREATE_STDOUT_POINTER* =           "SDL.process.create.stdout_source"
const SDL_PROP_PROCESS_CREATE_STDERR_NUMBER* =            "SDL.process.create.stderr_option"
const SDL_PROP_PROCESS_CREATE_STDERR_POINTER* =           "SDL.process.create.stderr_source"
const SDL_PROP_PROCESS_CREATE_STDERR_TO_STDOUT_BOOLEAN* = "SDL.process.create.stderr_to_stdout"
const SDL_PROP_PROCESS_CREATE_BACKGROUND_BOOLEAN* =       "SDL.process.create.background"
const SDL_PROP_PROCESS_PID_NUMBER* =         "SDL.process.pid"
const SDL_PROP_PROCESS_STDIN_POINTER* =      "SDL.process.stdin"
const SDL_PROP_PROCESS_STDOUT_POINTER* =     "SDL.process.stdout"
const SDL_PROP_PROCESS_STDERR_POINTER* =     "SDL.process.stderr"
const SDL_PROP_PROCESS_BACKGROUND_BOOLEAN* = "SDL.process.background"


#endregion


#region SDL3/SDL_storage.h ----------------------------------------------------

type
  SDL_Storage* = pointer
  SDL_StorageInterface* {.bycopy.} = object
    version*: uint32
    close*: proc (userdata: pointer): bool {.cdecl.}
    ready*: proc (userdata: pointer): bool {.cdecl.}
    enumerate*: proc (userdata: pointer; path: cstring;
                    callback: SDL_EnumerateDirectoryCallback;
                    callback_userdata: pointer): bool {.cdecl.}
    info*: proc (userdata: pointer; path: cstring; info: ptr SDL_PathInfo): bool {.cdecl.}
    read_file*: proc (userdata: pointer; path: cstring; destination: pointer; length: uint64): bool {.cdecl.}
    write_file*: proc (userdata: pointer; path: cstring; source: pointer; length: uint64): bool {.cdecl.}
    mkdir*: proc (userdata: pointer; path: cstring): bool {.cdecl.}
    remove*: proc (userdata: pointer; path: cstring): bool {.cdecl.}
    rename*: proc (userdata: pointer; oldpath: cstring; newpath: cstring): bool {.cdecl.}
    copy*: proc (userdata: pointer; oldpath: cstring; newpath: cstring): bool {.cdecl.}
    space_remaining*: proc (userdata: pointer): uint64 {.cdecl.}

proc SDL_OpenTitleStorage* ( override: cstring, props: SDL_PropertiesID ): SDL_Storage {.importc.}
proc SDL_OpenUserStorage* ( org: cstring, app: cstring, props: SDL_PropertiesID ): SDL_Storage {.importc.}
proc SDL_OpenFileStorage* ( path: cstring ): SDL_Storage {.importc.}
proc SDL_OpenStorage* ( iface: ptr SDL_StorageInterface, userdata: pointer ): SDL_Storage {.importc.}
proc SDL_CloseStorage* ( storage: SDL_Storage ): bool {.importc.}
proc SDL_StorageReady* ( storage: SDL_Storage ): bool {.importc.}
proc SDL_GetStorageFileSize* ( storage: SDL_Storage, path: cstring, length: var uint64 ): bool {.importc.}
proc SDL_ReadStorageFile* ( storage: SDL_Storage, path: cstring, destination: pointer, length: uint64 ): bool {.importc.}
proc SDL_WriteStorageFile* ( storage: SDL_Storage, path: cstring, source: pointer, length: uint64 ): bool {.importc.}
proc SDL_CreateStorageDirectory* ( storage: SDL_Storage, path: cstring ): bool {.importc.}
proc SDL_EnumerateStorageDirectory* ( storage: SDL_Storage, path: cstring, callback: SDL_EnumerateDirectoryCallback, userdata: pointer ): bool {.importc.}
proc SDL_RemoveStoragePath* ( storage: SDL_Storage, path: cstring ): bool {.importc.}
proc SDL_RenameStoragePath* ( storage: SDL_Storage, oldpath,newpath: cstring ): bool {.importc.}
proc SDL_CopyStorageFile* ( storage: SDL_Storage, oldpath,newpath: cstring ): bool {.importc.}
proc SDL_GetStoragePathInfo* ( storage: SDL_Storage, path: cstring, info: var SDL_PathInfo ): bool {.importc.}
proc SDL_GetStorageSpaceRemaining* ( storage: SDL_Storage ): uint64 {.importc.}
proc SDL_GlobStorageDirectory* ( storage: SDL_Storage, path,pattern: cstring, flags: SDL_GlobFlags, count: var int ): ptr[cstring] {.importc.}

#endregion


#region SDL3/SDL_system.h -----------------------------------------------------

when defined(SDL_PLATFORM_WINDOWS):
  type
    MSG* = object
    SDL_WindowsMessageHook* = proc (userdata: pointer, msg: ptr MSG): bool {.cdecl.}
  proc SDL_SetWindowsMessageHook* ( callback: SDL_WindowsMessageHook, userdata: pointer ): void {.importc.}

when defined(SDL_PLATFORM_WIN32) or defined(SDL_PLATFORM_WINGDK):
  proc SDL_GetDirect3D9AdapterIndex* ( displayID: SDL_DisplayID ): int {.importc.}
  proc SDL_GetDXGIOutputInfo* ( displayID: SDL_DisplayID, adapterIndex, outputIndex: ptr int ): bool {.importc.}

type
  XEvent* = object
  SDL_X11EventHook* = proc (userdata: pointer; xevent: ptr XEvent): bool {.
      cdecl.}

proc SDL_SetX11EventHook* ( callback: SDL_X11EventHook, userdata: pointer ): void {.importc.}

when defined(SDL_PLATFORM_LINUX):
  proc SDL_SetLinuxThreadPriority* ( threadID: int64, priority: int ): bool {.importc.}
  proc SDL_SetLinuxThreadPriorityAndPolicy* ( threadID: int64, sdlPriority, schedPolicy: int ): bool {.importc.}

when defined(SDL_PLATFORM_IOS):
  type
    SDL_iOSAnimationCallback* = proc (userdata: poiner): void {.cdecl.}
  proc SDL_SetiOSAnimationCallback* ( window: SDL_Window, interval: int, callback: SDL_iOSAnimationCallback, callbackParam: pointer ): bool {.importc.}
  proc SDL_SetiOSEventPump* ( enabled: bool ): void {.importc.}

when defined(SDL_PLATFORM_ANDROID):
  proc SDL_GetAndroidJNIEnv* (): pointer {.importc.}
  proc SDL_GetAndroidActivity* (): pointer {.importc.}
  proc SDL_GetAndroidSDKVersion* (): int {.importc.}
  proc SDL_IsChromebook* (): bool {.importc.}
  proc SDL_IsDeXMode* (): bool {.importc.}
  proc SDL_SendAndroidBackButton* (): void  {.importc.}
  const SDL_ANDROID_EXTERNAL_STORAGE_READ*  = 0x01
  const SDL_ANDROID_EXTERNAL_STORAGE_WRITE* = 0x02
  proc SDL_GetAndroidInternalStoragePath* (): cstring {.importc.}
  proc SDL_GetAndroidExternalStorageState* (): uint32 {.importc.}
  proc SDL_GetAndroidExternalStoragePath* (): cstring {.importc.}
  proc SDL_GetAndroidCachePath* (): cstring {.importc.}
  type
    SDL_RequestAndroidPermissionCallback* = proc (userdata: void, permission: cstring, granted: bool): void {.cdecl.}
  proc SDL_RequestAndroidPermission* ( permission: cstring, cb: SDL_RequestAndroidPermissionCallback, userdata: pointer ): bool {.importc.}
  proc SDL_ShowAndroidToast* ( message: cstring, duration, gravity, xoffset, yoffset: int ): bool {.importc.}
  proc SDL_SendAndroidMessage* ( command: uint32, param: int ): bool {.importc.}

proc SDL_IsTablet* (): bool {.importc.}
proc SDL_IsTV* (): bool {.importc.}

type
  SDL_Sandbox* {.size: sizeof(cint).} = enum
    SDL_SANDBOX_NONE = 0,
    SDL_SANDBOX_UNKNOWN_CONTAINER,
    SDL_SANDBOX_FLATPAK,
    SDL_SANDBOX_SNAP,
    SDL_SANDBOX_MACOS

proc SDL_GetSandbox* (): SDL_Sandbox {.importc.}

proc SDL_OnApplicationWillTerminate* (): void {.importc.}
proc SDL_OnApplicationDidReceiveMemoryWarning* (): void {.importc.}
proc SDL_OnApplicationWillEnterBackground* (): void {.importc.}
proc SDL_OnApplicationDidEnterBackground* (): void {.importc.}
proc SDL_OnApplicationWillEnterForeground* (): void {.importc.}
proc SDL_OnApplicationDidEnterForeground* (): void {.importc.}

when defined(SDL_PLATFORM_IOS):
  proc SDL_OnApplicationDidChangeStatusBarOrientation* (): void {.importc.}

when defined(SDL_PLATFORM_GDK):
  type
    XTaskQueueHandle* = pointer
    XUserHandle* = pointer
  proc SDL_GetGDKTaskQueue* ( outTaskQueue: XTaskQueueHandle ): bool {.importc.}
  proc SDL_GetGDKDefaultUser* ( outUserHandle: XUserHandle ): bool {.importc.}

#endregion


#region SDL3/SDL_thread.h -----------------------------------------------------

# XXX

#endregion


#region SDL3/SDL_time.h -------------------------------------------------------

type
  SDL_DateTime* {.bycopy.} = object
    year*: cint
    month*: cint
    day*: cint
    hour*: cint
    minute*: cint
    second*: cint
    nanosecond*: cint
    day_of_week*: cint
    utc_offset*: cint

  SDL_DateFormat* {.size: sizeof(cint).} = enum
    SDL_DATE_FORMAT_YYYYMMDD = 0,
    SDL_DATE_FORMAT_DDMMYYYY = 1,
    SDL_DATE_FORMAT_MMDDYYYY = 2

  SDL_TimeFormat* {.size: sizeof(cint).} = enum
    SDL_TIME_FORMAT_24HR = 0,
    SDL_TIME_FORMAT_12HR = 1

proc SDL_GetDateTimeLocalePreferences* ( dateFormat: var SDL_DateFormat, timeFormat: var SDL_TimeFormat ): bool {.importc.}
proc SDL_GetCurrentTime* ( ticks: var SDL_Time ): bool {.importc.}
proc SDL_TimeToDateTime* ( ticks: SDL_Time, dt: var SDL_DateTime, localTime: bool ): bool {.importc.}
proc SDL_DateTimeToTime* ( dt: ptr SDL_DateTime, ticks: var SDL_Time ): bool {.importc.}
proc SDL_TimeToWindows* ( ticks: SDL_Time, dwLowDateTime,dwHighDateTime: var uint32 ): void {.importc.}
proc SDL_TimeFromWindows* ( dwLowDateTime, dwHighDateTime: uint32 ): SDL_Time {.importc.}
proc SDL_GetDaysInMonth* ( year, month: int ): int {.importc.}
proc SDL_GetDayOfYear* ( year, month, day: int): int {.importc.}
proc SDL_GetDayOfWeek* ( year, month, day: int ): int {.importc.}

#endregion


#region SDL3/SDL_timer.h ------------------------------------------------------

const SDL_MS_PER_SECOND* = 1000
const SDL_US_PER_SECOND* = 1000000
const SDL_NS_PER_SECOND* = 1000000000'i64
const SDL_NS_PER_MS*     = 1000000
const SDL_NS_PER_US*     = 1000

proc SDL_SECONDS_TO_NS*(S: SomeNumber): SomeNumber  = S.uint64 * SDL_NS_PER_SECOND
proc SDL_NS_TO_SECONDS*(NS: SomeNumber): SomeNumber = NS / SDL_NS_PER_SECOND
proc SDL_MS_TO_NS*(MS: SomeNumber): SomeNumber      = MS.uint64 * SDL_NS_PER_MS
proc SDL_NS_TO_MS*(NS: SomeNumber): SomeNumber      = NS / SDL_NS_PER_MS
proc SDL_US_TO_NS*(US: SomeNumber): SomeNumber      = US.uint64 * SDL_NS_PER_US
proc SDL_NS_TO_US*(NS: SomeNumber): SomeNumber      = NS / SDL_NS_PER_US

proc SDL_GetTicks*(): uint64 {.importc.}
proc SDL_GetTicksNS* (): uint64 {.importc.}

proc SDL_GetPerformanceCounter* (): uint64 {.importc.}
proc SDL_GetPerformanceFrequency* (): uint64 {.importc.}

proc SDL_Delay*(ms: uint32): void {.importc.}
proc SDL_DelayNS* ( ns: uint64 ): void {.importc.}
proc SDL_DelayPrecise* ( ns: uint64 ): void {.importc.}

type
  SDL_TimerID* = uint32
  SDL_TimerCallback* = proc (userdata: pointer; timerID: SDL_TimerID; interval: uint32): uint32 {.cdecl.}

proc SDL_AddTimer* ( interval: uint32, callback: SDL_TimerCallback, userdata: pointer ): SDL_TimerID {.importc.}

type
  SDL_NSTimerCallback* = proc (userdata: pointer; timerID: SDL_TimerID; interval: uint64): uint64 {.cdecl.}

proc SDL_AddTimerNS* ( interval: uint64, callback: SDL_NSTimerCallback, userdata: pointer ): SDL_TimerID {.importc.}
proc SDL_RemoveTimer* ( id: SDL_TimerID ): bool {.importc.}

#endregion


#region SDL3/SDL_tray.h -------------------------------------------------------

type
  SDL_Tray* = pointer
  SDL_TrayMenu* = pointer
  SDL_TrayEntry* = pointer
  SDL_TrayEntryFlags* = uint32
  SDL_TrayCallback* = proc (userdata: pointer; entry: ptr SDL_TrayEntry) {.cdecl.}

const SDL_TRAYENTRY_BUTTON*   = 0x00000001'u # Make the entry a simple button. Required.
const SDL_TRAYENTRY_CHECKBOX* = 0x00000002'u # Make the entry a checkbox. Required.
const SDL_TRAYENTRY_SUBMENU*  = 0x00000004'u # Prepare the entry to have a submenu. Required
const SDL_TRAYENTRY_DISABLED* = 0x80000000'u # Make the entry disabled. Optional.
const SDL_TRAYENTRY_CHECKED*  = 0x40000000'u # Make the entry checked. This is valid only for checkboxes. Optional.

proc SDL_CreateTray* ( icon: SDL_Surface, tooltip: cstring ): SDL_Tray {.importc.}
proc SDL_SetTrayIcon* ( tray: SDL_Tray, icon: ptr SDL_Surface ): void {.importc.}
proc SDL_SetTrayTooltip* ( tray: SDL_Tray, tooltip: cstring ): void {.importc.}
proc SDL_CreateTrayMenu* ( tray: SDL_Tray ): SDL_TrayMenu {.importc.}
proc SDL_CreateTraySubmenu* ( entry: SDL_TrayEntry ): SDL_TrayMenu {.importc.}
proc SDL_GetTrayMenu* ( tray: SDL_Tray ): SDL_TrayMenu {.importc.}
proc SDL_GetTraySubmenu* ( entry: SDL_TrayEntry ): SDL_TrayMenu {.importc.}
proc SDL_GetTrayEntries* ( menu: SDL_TrayMenu, size: var int ): ptr UncheckedArray[SDL_TrayEntry] {.importc.}
proc SDL_RemoveTrayEntry* ( entry: SDL_TrayEntry ): void {.importc.}
proc SDL_InsertTrayEntryAt* ( menu: SDL_TrayMenu, pos: int, label: cstring, flags: SDL_TrayEntryFlags ): SDL_TrayEntry {.importc.}
proc SDL_SetTrayEntryLabel* ( entry: SDL_TrayEntry, label: cstring ): void {.importc.}
proc SDL_GetTrayEntryLabel* ( entry: SDL_TrayEntry ): cstring {.importc.}
proc SDL_SetTrayEntryChecked* ( entry: SDL_TrayEntry, checked: bool ): void {.importc.}
proc SDL_GetTrayEntryChecked* ( entry: SDL_TrayEntry ): bool {.importc.}
proc SDL_SetTrayEntryEnabled* ( entry: SDL_TrayEntry, enabled: bool ): void {.importc.}
proc SDL_GetTrayEntryEnabled* ( entry: SDL_TrayEntry ): bool {.importc.}
proc SDL_SetTrayEntryCallback* ( entry: SDL_TrayEntry, callback: SDL_TrayCallback, userdata: pointer ): void {.importc.}
proc SDL_DestroyTray* ( tray: SDL_Tray ): void {.importc.}
proc SDL_GetTrayEntryParent* ( entry: SDL_TrayEntry ): SDL_TrayMenu {.importc.}
proc SDL_GetTrayMenuParentEntry* ( menu: SDL_TrayMenu ): SDL_TrayEntry {.importc.}
proc SDL_GetTrayMenuParentTray* ( menu: SDL_TrayMenu ): SDL_Tray {.importc.}

#endregion


#region SDL3/SDL_touch.h ------------------------------------------------------

type
  SDL_TouchID* = uint64
  SDL_FingerID* = uint64
  SDL_TouchDeviceType* {.size: sizeof(cint).} = enum
    SDL_TOUCH_DEVICE_INVALID = -1,
    SDL_TOUCH_DEVICE_DIRECT,
    SDL_TOUCH_DEVICE_INDIRECT_ABSOLUTE,
    SDL_TOUCH_DEVICE_INDIRECT_RELATIVE

  SDL_Finger* {.bycopy.} = object
    id*: SDL_FingerID
    x*: cfloat
    y*: cfloat
    pressure*: cfloat

proc SDL_GetTouchDevices* ( count: var int ): ptr UncheckedArray[SDL_TouchID] {.importc.}
proc SDL_GetTouchDeviceName* ( touchID: SDL_TouchID ): cstring {.importc.}
proc SDL_GetTouchDeviceType* ( touchID: SDL_TouchID ): SDL_TouchDeviceType {.importc.}
proc SDL_GetTouchFingers* ( touchID: SDL_TouchID, count: var int ): ptr UncheckedArray[ptr SDL_Finger] {.importc.}

const SDL_TOUCH_MOUSEID* = cast[SDL_MouseID]( -1 )
const SDL_MOUSE_TOUCHID* = cast[SDL_TouchID]( -1 )

#endregion


#region SDL3/SDL_dialog.h -----------------------------------------------------

type
  SDL_DialogFileFilter* {.bycopy.} = object
    name*: cstring
    pattern*: cstring
  SDL_DialogFileCallback* = proc (userdata: pointer; filelist: cstringArray; filter: cint) {.cdecl.}

proc SDL_ShowOpenFileDialog* ( callback: SDL_DialogFileCallback,
                               userdata: pointer, window: SDL_Window,
                               filters: ptr[SDL_DialogFileFilter], nfilters: int,
                               default_location: cstring, allow_many: bool
                             ): void {.importc.}

proc SDL_ShowOpenFileDialog* ( callback: SDL_DialogFileCallback,
                               userdata: pointer, window: SDL_Window,
                               filters: openarray[SDL_DialogFileFilter],
                               default_location: cstring, allow_many: bool
                             ): void {.importc.}

proc SDL_ShowSaveFileDialog* ( callback: SDL_DialogFileCallback,
                               userdata: pointer, window: SDL_Window,
                               filters: ptr[SDL_DialogFileFilter], nfilters: int,
                               default_location: cstring
                             ): void {.importc.}

proc SDL_ShowSaveFileDialog* ( callback: SDL_DialogFileCallback,
                               userdata: pointer, window: SDL_Window,
                               filters: openarray[SDL_DialogFileFilter],
                               default_location: cstring
                             ): void {.importc.}

proc SDL_ShowOpenFolderDialog* ( callback: SDL_DialogFileCallback,
                                 userdata: pointer, window: SDL_Window,
                                 default_location: cstring, allow_many: bool
                               ): void {.importc.}

type
  SDL_FileDialogType* {.size: sizeof(cint).} = enum
    SDL_FILEDIALOG_OPENFILE,
    SDL_FILEDIALOG_SAVEFILE,
    SDL_FILEDIALOG_OPENFOLDER

proc SDL_ShowFileDialogWithProperties* ( kind: SDL_FileDialogType,
                                         callback: SDL_DialogFileCallback,
                                         userdata: pointer,
                                         props: SDL_PropertiesID
                                       ): void {.importc.}

const SDL_PROP_FILE_DIALOG_FILTERS_POINTER* = "SDL.filedialog.filters"
const SDL_PROP_FILE_DIALOG_NFILTERS_NUMBER* = "SDL.filedialog.nfilters"
const SDL_PROP_FILE_DIALOG_WINDOW_POINTER*  = "SDL.filedialog.window"
const SDL_PROP_FILE_DIALOG_LOCATION_STRING* = "SDL.filedialog.location"
const SDL_PROP_FILE_DIALOG_MANY_BOOLEAN*    = "SDL.filedialog.many"
const SDL_PROP_FILE_DIALOG_TITLE_STRING*    = "SDL.filedialog.title"
const SDL_PROP_FILE_DIALOG_ACCEPT_STRING*   = "SDL.filedialog.accept"
const SDL_PROP_FILE_DIALOG_CANCEL_STRING*   = "SDL.filedialog.cancel"

#endregion


#region SDL3/SDL_camera.h -----------------------------------------------------

type
  SDL_CameraID* = uint32
  SDL_Camera* = pointer
  SDL_CameraSpec* {.bycopy.} = object
    format*: SDL_PixelFormat
    colorspace*: SDL_Colorspace
    width*: cint
    height*: cint
    framerate_numerator*: cint
    framerate_denominator*: cint

  SDL_CameraPosition* {.size: sizeof(cint).} = enum
    SDL_CAMERA_POSITION_UNKNOWN,
    SDL_CAMERA_POSITION_FRONT_FACING,
    SDL_CAMERA_POSITION_BACK_FACING

proc SDL_GetNumCameraDrivers* (): int {.importc.}
proc SDL_GetCameraDriver* ( index: int ): cstring {.importc.}
proc SDL_GetCurrentCameraDriver* (): cstring {.importc.}
proc SDL_GetCameras* ( count: var int ): ptr UncheckedArray[SDL_CameraID] {.importc.}
proc SDL_GetCameraSupportedFormats* ( devid: SDL_CameraID, count: var int ): ptr UncheckedArray[SDL_CameraSpec] {.importc.}
proc SDL_GetCameraName* ( instance_id: SDL_CameraID ): cstring {.importc.}
proc SDL_GetCameraPosition* ( instance_id: SDL_CameraID ): SDL_CameraPosition {.importc.}

proc SDL_OpenCamera* ( instance_id: SDL_CameraID, spec: ptr SDL_CameraSpec ): SDL_Camera {.importc.}
proc SDL_GetCameraPermissionState* ( camera: SDL_Camera ): int {.importc.}
proc SDL_GetCameraID* ( camera: SDL_Camera ): SDL_CameraID {.importc.}
proc SDL_GetCameraProperties* ( camera: SDL_Camera ): SDL_PropertiesID {.importc.}
proc SDL_GetCameraFormat* ( camera: SDL_Camera, spec: ptr SDL_CameraSpec ): bool {.importc.}
proc SDL_AcquireCameraFrame* ( camera: SDL_Camera, timestampNS: var uint64 ): ptr SDL_Surface {.importc.}
proc SDL_ReleaseCameraFrame* ( camera: SDL_Camera, frame: ptr SDL_Surface ): void {.importc.}
proc SDL_CloseCamera* ( camera: SDL_Camera ): void {.importc.}

#endregion


#region SDL3/SDL_events.h -----------------------------------------------------

type
  SDL_EventType* {.size: sizeof(cint).} = enum
    SDL_EVENT_FIRST = 0,
    SDL_EVENT_QUIT = 0x100,
    SDL_EVENT_TERMINATING,
    SDL_EVENT_LOW_MEMORY,
    SDL_EVENT_WILL_ENTER_BACKGROUND,
    SDL_EVENT_DID_ENTER_BACKGROUND,
    SDL_EVENT_WILL_ENTER_FOREGROUND,
    SDL_EVENT_DID_ENTER_FOREGROUND,
    SDL_EVENT_LOCALE_CHANGED,
    SDL_EVENT_SYSTEM_THEME_CHANGED,
    SDL_EVENT_DISPLAY_ORIENTATION = 0x151,
    SDL_EVENT_DISPLAY_ADDED,
    SDL_EVENT_DISPLAY_REMOVED,
    SDL_EVENT_DISPLAY_MOVED,
    SDL_EVENT_DISPLAY_DESKTOP_MODE_CHANGED,
    SDL_EVENT_DISPLAY_CURRENT_MODE_CHANGED,
    SDL_EVENT_DISPLAY_CONTENT_SCALE_CHANGED,
    SDL_EVENT_WINDOW_SHOWN = 0x202,
    SDL_EVENT_WINDOW_HIDDEN,
    SDL_EVENT_WINDOW_EXPOSED,
    SDL_EVENT_WINDOW_MOVED,
    SDL_EVENT_WINDOW_RESIZED,
    SDL_EVENT_WINDOW_PIXEL_SIZE_CHANGED,
    SDL_EVENT_WINDOW_METAL_VIEW_RESIZED,
    SDL_EVENT_WINDOW_MINIMIZED,
    SDL_EVENT_WINDOW_MAXIMIZED,
    SDL_EVENT_WINDOW_RESTORED,
    SDL_EVENT_WINDOW_MOUSE_ENTER,
    SDL_EVENT_WINDOW_MOUSE_LEAVE,
    SDL_EVENT_WINDOW_FOCUS_GAINED,
    SDL_EVENT_WINDOW_FOCUS_LOST,
    SDL_EVENT_WINDOW_CLOSE_REQUESTED,
    SDL_EVENT_WINDOW_HIT_TEST,
    SDL_EVENT_WINDOW_ICCPROF_CHANGED,
    SDL_EVENT_WINDOW_DISPLAY_CHANGED,
    SDL_EVENT_WINDOW_DISPLAY_SCALE_CHANGED,
    SDL_EVENT_WINDOW_SAFE_AREA_CHANGED,
    SDL_EVENT_WINDOW_OCCLUDED,
    SDL_EVENT_WINDOW_ENTER_FULLSCREEN,
    SDL_EVENT_WINDOW_LEAVE_FULLSCREEN,
    SDL_EVENT_WINDOW_DESTROYED,
    SDL_EVENT_WINDOW_HDR_STATE_CHANGED,
    SDL_EVENT_KEY_DOWN = 0x300,
    SDL_EVENT_KEY_UP,
    SDL_EVENT_TEXT_EDITING,
    SDL_EVENT_TEXT_INPUT,
    SDL_EVENT_KEYMAP_CHANGED,
    SDL_EVENT_KEYBOARD_ADDED,
    SDL_EVENT_KEYBOARD_REMOVED,
    SDL_EVENT_TEXT_EDITING_CANDIDATES,
    SDL_EVENT_MOUSE_MOTION = 0x400,
    SDL_EVENT_MOUSE_BUTTON_DOWN,
    SDL_EVENT_MOUSE_BUTTON_UP,
    SDL_EVENT_MOUSE_WHEEL,
    SDL_EVENT_MOUSE_ADDED,
    SDL_EVENT_MOUSE_REMOVED,
    SDL_EVENT_JOYSTICK_AXIS_MOTION = 0x600,
    SDL_EVENT_JOYSTICK_BALL_MOTION,
    SDL_EVENT_JOYSTICK_HAT_MOTION,
    SDL_EVENT_JOYSTICK_BUTTON_DOWN,
    SDL_EVENT_JOYSTICK_BUTTON_UP,
    SDL_EVENT_JOYSTICK_ADDED,
    SDL_EVENT_JOYSTICK_REMOVED,
    SDL_EVENT_JOYSTICK_BATTERY_UPDATED,
    SDL_EVENT_JOYSTICK_UPDATE_COMPLETE,
    SDL_EVENT_GAMEPAD_AXIS_MOTION = 0x650,
    SDL_EVENT_GAMEPAD_BUTTON_DOWN,
    SDL_EVENT_GAMEPAD_BUTTON_UP,
    SDL_EVENT_GAMEPAD_ADDED,
    SDL_EVENT_GAMEPAD_REMOVED,
    SDL_EVENT_GAMEPAD_REMAPPED,
    SDL_EVENT_GAMEPAD_TOUCHPAD_DOWN,
    SDL_EVENT_GAMEPAD_TOUCHPAD_MOTION,
    SDL_EVENT_GAMEPAD_TOUCHPAD_UP,
    SDL_EVENT_GAMEPAD_SENSOR_UPDATE,
    SDL_EVENT_GAMEPAD_UPDATE_COMPLETE,
    SDL_EVENT_GAMEPAD_STEAM_HANDLE_UPDATED,
    SDL_EVENT_FINGER_DOWN = 0x700,
    SDL_EVENT_FINGER_UP,
    SDL_EVENT_FINGER_MOTION,
    SDL_EVENT_FINGER_CANCELED,
    SDL_EVENT_CLIPBOARD_UPDATE = 0x900,
    SDL_EVENT_DROP_FILE = 0x1000,
    SDL_EVENT_DROP_TEXT,
    SDL_EVENT_DROP_BEGIN,
    SDL_EVENT_DROP_COMPLETE,
    SDL_EVENT_DROP_POSITION,
    SDL_EVENT_AUDIO_DEVICE_ADDED = 0x1100,
    SDL_EVENT_AUDIO_DEVICE_REMOVED,
    SDL_EVENT_AUDIO_DEVICE_FORMAT_CHANGED,
    SDL_EVENT_SENSOR_UPDATE = 0x1200,
    SDL_EVENT_PEN_PROXIMITY_IN = 0x1300,
    SDL_EVENT_PEN_PROXIMITY_OUT,
    SDL_EVENT_PEN_DOWN,
    SDL_EVENT_PEN_UP,
    SDL_EVENT_PEN_BUTTON_DOWN,
    SDL_EVENT_PEN_BUTTON_UP,
    SDL_EVENT_PEN_MOTION,
    SDL_EVENT_PEN_AXIS,
    SDL_EVENT_CAMERA_DEVICE_ADDED = 0x1400,
    SDL_EVENT_CAMERA_DEVICE_REMOVED,
    SDL_EVENT_CAMERA_DEVICE_APPROVED,
    SDL_EVENT_CAMERA_DEVICE_DENIED,
    SDL_EVENT_RENDER_TARGETS_RESET = 0x2000,
    SDL_EVENT_RENDER_DEVICE_RESET,
    SDL_EVENT_RENDER_DEVICE_LOST,
    SDL_EVENT_PRIVATE0 = 0x4000,
    SDL_EVENT_PRIVATE1,
    SDL_EVENT_PRIVATE2,
    SDL_EVENT_PRIVATE3,
    SDL_EVENT_POLL_SENTINEL = 0x7F00,
    SDL_EVENT_USER = 0x8000,
    SDL_EVENT_LAST = 0xFFFF,
    SDL_EVENT_ENUM_PADDING = 0x7FFFFFFF

  SDL_CommonEvent* {.bycopy.} = object
    `type`*: uint32
    reserved*: uint32
    timestamp*: uint64

  SDL_DisplayEvent* {.bycopy.} = object
    `type`*: SDL_EventType
    reserved*: uint32
    timestamp*: uint64
    displayID*: SDL_DisplayID
    data1*: int32
    data2*: int32

  SDL_WindowEvent* {.bycopy.} = object
    `type`*: SDL_EventType
    reserved*: uint32
    timestamp*: uint64
    windowID*: SDL_WindowID
    data1*: int32
    data2*: int32

  SDL_KeyboardDeviceEvent* {.bycopy.} = object
    `type`*: SDL_EventType
    reserved*: uint32
    timestamp*: uint64
    which*: SDL_KeyboardID

const SDL_EVENT_DISPLAY_FIRST* = SDL_EVENT_DISPLAY_ORIENTATION
const SDL_EVENT_DISPLAY_LAST*  = SDL_EVENT_DISPLAY_CONTENT_SCALE_CHANGED

const SDL_EVENT_WINDOW_FIRST*  = SDL_EVENT_WINDOW_SHOWN
const SDL_EVENT_WINDOW_LAST*   = SDL_EVENT_WINDOW_HDR_STATE_CHANGED

type
  SDL_KeyboardEvent* {.bycopy.} = object
    `type`*: SDL_EventType
    reserved*: uint32
    timestamp*: uint64
    windowID*: SDL_WindowID
    which*: SDL_KeyboardID
    scancode*: SDL_Scancode
    key*: SDL_Keycode
    `mod`*: SDL_Keymod
    raw*: uint16
    down*: bool
    repeat*: bool

  SDL_TextEditingEvent* {.bycopy.} = object
    `type`*: SDL_EventType
    reserved*: uint32
    timestamp*: uint64
    windowID*: SDL_WindowID
    text*: cstring
    start*: int32
    length*: int32

  SDL_TextEditingCandidatesEvent* {.bycopy.} = object
    `type`*: SDL_EventType
    reserved*: uint32
    timestamp*: uint64
    windowID*: SDL_WindowID
    candidates*: cstringArray
    num_candidates*: int32
    selected_candidate*: int32
    horizontal*: bool
    padding1*: uint8
    padding2*: uint8
    padding3*: uint8

  SDL_TextInputEvent* {.bycopy.} = object
    `type`*: SDL_EventType
    reserved*: uint32
    timestamp*: uint64
    windowID*: SDL_WindowID
    text*: cstring

  SDL_MouseDeviceEvent* {.bycopy.} = object
    `type`*: SDL_EventType
    reserved*: uint32
    timestamp*: uint64
    which*: SDL_MouseID

  SDL_MouseMotionEvent* {.bycopy.} = object
    `type`*: SDL_EventType
    reserved*: uint32
    timestamp*: uint64
    windowID*: SDL_WindowID
    which*: SDL_MouseID
    state*: SDL_MouseButtonFlags
    x*: cfloat
    y*: cfloat
    xrel*: cfloat
    yrel*: cfloat

  SDL_MouseButtonEvent* {.bycopy.} = object
    `type`*: SDL_EventType
    reserved*: uint32
    timestamp*: uint64
    windowID*: SDL_WindowID
    which*: SDL_MouseID
    button*: uint8
    down*: bool
    clicks*: uint8
    padding*: uint8
    x*: cfloat
    y*: cfloat

  SDL_MouseWheelEvent* {.bycopy.} = object
    `type`*: SDL_EventType
    reserved*: uint32
    timestamp*: uint64
    windowID*: SDL_WindowID
    which*: SDL_MouseID
    x*: cfloat
    y*: cfloat
    direction*: SDL_MouseWheelDirection
    mouse_x*: cfloat
    mouse_y*: cfloat

  SDL_JoyAxisEvent* {.bycopy.} = object
    `type`*: SDL_EventType
    reserved*: uint32
    timestamp*: uint64
    which*: SDL_JoystickID
    axis*: uint8
    padding1*: uint8
    padding2*: uint8
    padding3*: uint8
    value*: int16
    padding4*: uint16

  SDL_JoyBallEvent* {.bycopy.} = object
    `type`*: SDL_EventType
    reserved*: uint32
    timestamp*: uint64
    which*: SDL_JoystickID
    ball*: uint8
    padding1*: uint8
    padding2*: uint8
    padding3*: uint8
    xrel*: int16
    yrel*: int16

  SDL_JoyHatEvent* {.bycopy.} = object
    `type`*: SDL_EventType
    reserved*: uint32
    timestamp*: uint64
    which*: SDL_JoystickID
    hat*: uint8
    value*: uint8
    padding1*: uint8
    padding2*: uint8

  SDL_JoyButtonEvent* {.bycopy.} = object
    `type`*: SDL_EventType
    reserved*: uint32
    timestamp*: uint64
    which*: SDL_JoystickID
    button*: uint8
    down*: bool
    padding1*: uint8
    padding2*: uint8

  SDL_JoyDeviceEvent* {.bycopy.} = object
    `type`*: SDL_EventType
    reserved*: uint32
    timestamp*: uint64
    which*: SDL_JoystickID

  SDL_JoyBatteryEvent* {.bycopy.} = object
    `type`*: SDL_EventType
    reserved*: uint32
    timestamp*: uint64
    which*: SDL_JoystickID
    state*: SDL_PowerState
    percent*: cint

  SDL_GamepadAxisEvent* {.bycopy.} = object
    `type`*: SDL_EventType
    reserved*: uint32
    timestamp*: uint64
    which*: SDL_JoystickID
    axis*: uint8
    padding1*: uint8
    padding2*: uint8
    padding3*: uint8
    value*: int16
    padding4*: uint16

  SDL_GamepadButtonEvent* {.bycopy.} = object
    `type`*: SDL_EventType
    reserved*: uint32
    timestamp*: uint64
    which*: SDL_JoystickID
    button*: uint8
    down*: bool
    padding1*: uint8
    padding2*: uint8

  SDL_GamepadDeviceEvent* {.bycopy.} = object
    `type`*: SDL_EventType
    reserved*: uint32
    timestamp*: uint64
    which*: SDL_JoystickID

  SDL_GamepadTouchpadEvent* {.bycopy.} = object
    `type`*: SDL_EventType
    reserved*: uint32
    timestamp*: uint64
    which*: SDL_JoystickID
    touchpad*: int32
    finger*: int32
    x*: cfloat
    y*: cfloat
    pressure*: cfloat

  SDL_GamepadSensorEvent* {.bycopy.} = object
    `type`*: SDL_EventType
    reserved*: uint32
    timestamp*: uint64
    which*: SDL_JoystickID
    sensor*: int32
    data*: array[3, cfloat]
    sensor_timestamp*: uint64

  SDL_AudioDeviceEvent* {.bycopy.} = object
    `type`*: SDL_EventType
    reserved*: uint32
    timestamp*: uint64
    which*: SDL_AudioDeviceID
    recording*: bool
    padding1*: uint8
    padding2*: uint8
    padding3*: uint8

  SDL_CameraDeviceEvent* {.bycopy.} = object
    `type`*: SDL_EventType
    reserved*: uint32
    timestamp*: uint64
    which*: SDL_CameraID

  SDL_RenderEvent* {.bycopy.} = object
    `type`*: SDL_EventType
    reserved*: uint32
    timestamp*: uint64
    windowID*: SDL_WindowID

  SDL_TouchFingerEvent* {.bycopy.} = object
    `type`*: SDL_EventType
    reserved*: uint32
    timestamp*: uint64
    touchID*: SDL_TouchID
    fingerID*: SDL_FingerID
    x*: cfloat
    y*: cfloat
    dx*: cfloat
    dy*: cfloat
    pressure*: cfloat
    windowID*: SDL_WindowID

  SDL_PenProximityEvent* {.bycopy.} = object
    `type`*: SDL_EventType
    reserved*: uint32
    timestamp*: uint64
    windowID*: SDL_WindowID
    which*: SDL_PenID

  SDL_PenMotionEvent* {.bycopy.} = object
    `type`*: SDL_EventType
    reserved*: uint32
    timestamp*: uint64
    windowID*: SDL_WindowID
    which*: SDL_PenID
    pen_state*: SDL_PenInputFlags
    x*: cfloat
    y*: cfloat

  SDL_PenTouchEvent* {.bycopy.} = object
    `type`*: SDL_EventType
    reserved*: uint32
    timestamp*: uint64
    windowID*: SDL_WindowID
    which*: SDL_PenID
    pen_state*: SDL_PenInputFlags
    x*: cfloat
    y*: cfloat
    eraser*: bool
    down*: bool

  SDL_PenButtonEvent* {.bycopy.} = object
    `type`*: SDL_EventType
    reserved*: uint32
    timestamp*: uint64
    windowID*: SDL_WindowID
    which*: SDL_PenID
    pen_state*: SDL_PenInputFlags
    x*: cfloat
    y*: cfloat
    button*: uint8
    down*: bool

  SDL_PenAxisEvent* {.bycopy.} = object
    `type`*: SDL_EventType
    reserved*: uint32
    timestamp*: uint64
    windowID*: SDL_WindowID
    which*: SDL_PenID
    pen_state*: SDL_PenInputFlags
    x*: cfloat
    y*: cfloat
    axis*: SDL_PenAxis
    value*: cfloat

  SDL_DropEvent* {.bycopy.} = object
    `type`*: SDL_EventType
    reserved*: uint32
    timestamp*: uint64
    windowID*: SDL_WindowID
    x*: cfloat
    y*: cfloat
    source*: cstring
    data*: cstring

  SDL_ClipboardEvent* {.bycopy.} = object
    `type`*: SDL_EventType
    reserved*: uint32
    timestamp*: uint64
    owner*: bool
    num_mime_types*: int32
    mime_types*: cstringArray

  SDL_SensorEvent* {.bycopy.} = object
    `type`*: SDL_EventType
    reserved*: uint32
    timestamp*: uint64
    which*: SDL_SensorID
    data*: array[6, cfloat]
    sensor_timestamp*: uint64

  SDL_QuitEvent* {.bycopy.} = object
    `type`*: SDL_EventType
    reserved*: uint32
    timestamp*: uint64

  SDL_UserEvent* {.bycopy.} = object
    `type`*: uint32
    reserved*: uint32
    timestamp*: uint64
    windowID*: SDL_WindowID
    code*: int32
    data1*: pointer
    data2*: pointer

  SDL_Event* {.bycopy, union.} = object
    `type`*: SDL_EventType # uint32 from c2nim, for some reason?
    common*: SDL_CommonEvent
    display*: SDL_DisplayEvent
    window*: SDL_WindowEvent
    kdevice*: SDL_KeyboardDeviceEvent
    key*: SDL_KeyboardEvent
    edit*: SDL_TextEditingEvent
    edit_candidates*: SDL_TextEditingCandidatesEvent
    text*: SDL_TextInputEvent
    mdevice*: SDL_MouseDeviceEvent
    motion*: SDL_MouseMotionEvent
    button*: SDL_MouseButtonEvent
    wheel*: SDL_MouseWheelEvent
    jdevice*: SDL_JoyDeviceEvent
    jaxis*: SDL_JoyAxisEvent
    jball*: SDL_JoyBallEvent
    jhat*: SDL_JoyHatEvent
    jbutton*: SDL_JoyButtonEvent
    jbattery*: SDL_JoyBatteryEvent
    gdevice*: SDL_GamepadDeviceEvent
    gaxis*: SDL_GamepadAxisEvent
    gbutton*: SDL_GamepadButtonEvent
    gtouchpad*: SDL_GamepadTouchpadEvent
    gsensor*: SDL_GamepadSensorEvent
    adevice*: SDL_AudioDeviceEvent
    cdevice*: SDL_CameraDeviceEvent
    sensor*: SDL_SensorEvent
    quit*: SDL_QuitEvent
    user*: SDL_UserEvent
    tfinger*: SDL_TouchFingerEvent
    pproximity*: SDL_PenProximityEvent
    ptouch*: SDL_PenTouchEvent
    pmotion*: SDL_PenMotionEvent
    pbutton*: SDL_PenButtonEvent
    paxis*: SDL_PenAxisEvent
    render*: SDL_RenderEvent
    drop*: SDL_DropEvent
    clipboard*: SDL_ClipboardEvent
    padding*: array[128, uint8]

proc SDL_PumpEvents* (): void {.importc.}

type
  SDL_EventAction* {.size: sizeof(cint).} = enum
    SDL_ADDEVENT,
    SDL_PEEKEVENT,
    SDL_GETEVENT

proc SDL_PeepEvents* ( events: ptr[SDL_Event], numevents: int, action: SDL_EventAction, minType,maxType: uint32 ): int {.importc.}
proc SDL_PeepEvents* ( events: openarray[SDL_Event], action: SDL_EventAction, minType,maxType: uint32 ): int {.importc.}
proc SDL_HasEvent* ( kind: uint32 ): bool {.importc.}
proc SDL_HasEvents* ( minType,maxType: uint32 ): bool {.importc.}
proc SDL_FlushEvent* ( kind: uint32 ): void {.importc.}
proc SDL_FlushEvents* ( minType,maxType: uint32 ): void {.importc.}
proc SDL_PollEvent*(event: var SDL_Event): bool {.importc.}
proc SDL_WaitEvent* ( event: var SDL_Event ): bool {.importc.}
proc SDL_WaitEventTimeout* ( event: var SDL_Event, timeoutMS: int32 ): bool {.importc.}
proc SDL_PushEvent* ( event: var SDL_Event ): bool {.importc.}

type
  SDL_EventFilter* = proc (userdata: pointer; event: ptr SDL_Event): bool {.cdecl.}

proc SDL_SetEventFilter* ( filter: SDL_EventFilter, userdata: pointer ): void {.importc.}
proc SDL_GetEventFilter* ( filter: var SDL_EventFilter, userdata: var pointer ): bool {.importc.}
proc SDL_AddEventWatch* ( filter: SDL_EventFilter, userdata: pointer ): bool {.importc.}
proc SDL_RemoveEventWatch* ( filter: SDL_EventFilter, userdata: pointer ): void {.importc.}
proc SDL_FilterEvents* ( filter: SDL_EventFilter, userdata: pointer ): void {.importc.}
proc SDL_SetEventEnabled* ( kind: uint32, enabled: bool ): void {.importc.}
proc SDL_EventEnabled* ( kind: uint32 ): bool {.importc.}
proc SDL_RegisterEvents* ( numevents: int ): uint32 {.importc.}
proc SDL_GetWindowFromEvent* ( event: ptr SDL_Event ): SDL_Window {.importc.}

#endregion


#region SDL3/SDL_render.h -----------------------------------------------------


type
  SDL_Vertex* {.bycopy.} = object
    position*: SDL_FPoint
    color*: SDL_FColor
    tex_coord*: SDL_FPoint

  SDL_TextureAccess* {.size: sizeof(cint).} = enum
    SDL_TEXTUREACCESS_STATIC,
    SDL_TEXTUREACCESS_STREAMING,
    SDL_TEXTUREACCESS_TARGET

  SDL_RendererLogicalPresentation* {.size: sizeof(cint).} = enum
    SDL_LOGICAL_PRESENTATION_DISABLED,
    SDL_LOGICAL_PRESENTATION_STRETCH,
    SDL_LOGICAL_PRESENTATION_LETTERBOX,
    SDL_LOGICAL_PRESENTATION_OVERSCAN,
    SDL_LOGICAL_PRESENTATION_INTEGER_SCALE

type
  SDL_Renderer* = pointer
  SDL_Texture* = pointer
  # TODO: Not sure about this internal bit.
  # SDL_Texture* {.bycopy.} = object
  #   format*: SDL_PixelFormat
  #   w*: cint
  #   h*: cint
  #   refcount*: cint

proc SDL_GetNumRenderDrivers* (): int {.importc.}
proc SDL_GetRenderDriver* ( index: int ): cstring {.importc.}
proc SDL_CreateWindowAndRenderer*(title: cstring, width, height: int, window_flags: SDL_WindowFlags, window:var SDL_Window, renderer:var SDL_Renderer): bool {.importc.}
proc SDL_CreateRenderer*(window: SDL_Window, name: cstring): SDL_Renderer {.importc.}
proc SDL_CreateRendererWithProperties* ( props: SDL_PropertiesID ): SDL_Renderer {.importc.}
proc SDL_CreateSoftwareRenderer* ( surface: ptr SDL_Surface ): SDL_Renderer {.importc.}
proc SDL_GetRenderer* ( window: SDL_Window ): SDL_Renderer {.importc.}
proc SDL_GetRenderWindow* ( renderer: SDL_Renderer ): SDL_Window {.importc.}
proc SDL_GetRendererName* ( renderer: SDL_Renderer ): cstring {.importc.}
proc SDL_GetRendererProperties* ( renderer: SDL_Renderer ): SDL_PropertiesID {.importc.}
proc SDL_GetRenderOutputSize* ( renderer: SDL_Renderer, w,h: var int ): bool {.importc.}
proc SDL_GetCurrentRenderOutputSize* ( renderer: SDL_Renderer, w,h: var int ): bool {.importc.}
proc SDL_CreateTexture* ( renderer: SDL_Renderer, format: SDL_PixelFormat, access: SDL_TextureAccess, w,h: int ): SDL_Texture {.importc.}
proc SDL_CreateTextureFromSurface* ( renderer: SDL_Renderer, surface: ptr SDL_Surface ): SDL_Texture {.importc.}
proc SDL_CreateTextureWithProperties* ( renderer: SDL_Renderer, props: SDL_PropertiesID ): SDL_Texture {.importc.}
proc SDL_GetTextureProperties* ( texture: SDL_Texture ): SDL_PropertiesID {.importc.}
proc SDL_GetRendererFromTexture* ( texture: SDL_Texture ): SDL_Renderer {.importc.}
proc SDL_GetTextureSize* ( texture: SDL_Texture, w,h: var cfloat ): bool {.importc.}
proc SDL_SetTextureColorMod* ( texture: SDL_Texture, r,g,b: uint8 ): bool {.importc, discardable.}
proc SDL_SetTextureColorModFloat* ( texture: SDL_Texture, r,g,b: cfloat ): bool {.importc, discardable.}
proc SDL_GetTextureColorMod* ( texture: SDL_Texture, r,g,b: uint8 ): bool {.importc.}
proc SDL_GetTextureColorModFloat* ( texture: SDL_Texture, r,g,b: var cfloat ): bool {.importc.}
proc SDL_SetTextureAlphaMod* ( texture: SDL_Texture, alpha: uint8 ): bool {.importc, discardable.}
proc SDL_SetTextureAlphaModFloat* ( texture: SDL_Texture, alpha: cfloat ): bool {.importc.}
proc SDL_GetTextureAlphaMod* ( texture: SDL_Texture, alpha: var uint8 ): bool {.importc.}
proc SDL_GetTextureAlphaModFloat* ( texture: SDL_Texture, alpha: var cfloat ): bool {.importc.}
proc SDL_SetTextureBlendMode* ( texture: SDL_Texture, blendMode: SDL_BlendMode ): bool {.importc, discardable.}
proc SDL_GetTextureBlendMode* ( texture: SDL_Texture, blendMode: var SDL_BlendMode ): bool {.importc.}
proc SDL_SetTextureScaleMode* ( texture: SDL_Texture, scaleMode: SDL_ScaleMode ): bool {.importc, discardable.}
proc SDL_GetTextureScaleMode* ( texture: SDL_Texture, scaleMode: var SDL_ScaleMode ): bool {.importc.}
proc SDL_UpdateTexture* ( texture: SDL_Texture, rect: ptr[SDL_Rect], pixels: ptr[uint8], pitch: int ): bool {.importc.}
proc SDL_UpdateTexture* ( texture: SDL_Texture, rect: ptr[SDL_Rect], pixels: ptr UncheckedArray[uint8], pitch: int ): bool {.importc.}
proc SDL_UpdateYUVTexture* ( texture: SDL_Texture, rect: ptr SDL_Rect, Yplane: ptr[uint8], Ypitch: int, Uplane: ptr[uint8], Upitch: int, Vplane: ptr[uint8], Vpitch: int ): bool {.importc.}
proc SDL_UpdateNVTexture* ( texture: SDL_Texture, rect: ptr SDL_Rect, Yplane: ptr[uint8], Ypitch: int, UVplane: ptr[uint8], UVpitch: int ): bool {.importc.}
proc SDL_LockTexture* ( texture: SDL_Texture, rect: ptr SDL_Rect, pixels: var pointer, pitch: var int): bool {.importc.}
proc SDL_LockTextureToSurface* ( texture: SDL_Texture, rect: ptr SDL_Rect, surface: var ptr SDL_Surface ): bool {.importc.}
proc SDL_UnlockTexture* ( texture: SDL_Texture ): void {.importc.}
proc SDL_SetRenderTarget* ( renderer: SDL_Renderer, texture: SDL_Texture ): bool {.importc, discardable.}
proc SDL_GetRenderTarget* ( renderer: SDL_Renderer ): SDL_Texture {.importc.}
proc SDL_SetRenderLogicalPresentation* ( renderer: SDL_Renderer, w,h: int, mode: SDL_RendererLogicalPresentation ): bool {.importc, discardable.}
proc SDL_GetRenderLogicalPresentation* ( renderer: SDL_Renderer, w,h: var int, mode: var SDL_RendererLogicalPresentation ):bool {.importc.}
proc SDL_GetRenderLogicalPresentationRect* ( renderer: SDL_Renderer, rect: var SDL_FRect ): bool {.importc.}
proc SDL_RenderCoordinatesFromWindow* ( renderer: SDL_Renderer, window_x,window_y: cfloat, x,y: var cfloat ): bool {.importc.}
proc SDL_RenderCoordinatesToWindow* ( renderer: SDL_Renderer, x,y: cfloat, window_x,window_y: var cfloat ): bool {.importc.}
proc SDL_ConvertEventToRenderCoordinates* ( renderer: SDL_Renderer, event: var SDL_Event ): bool {.importc.}
proc SDL_SetRenderViewport* ( renderer: SDL_Renderer, rect: ptr SDL_Rect ): bool {.importc, discardable.}
proc SDL_GetRenderViewport* ( renderer: SDL_Renderer, rect: var SDL_Rect ): bool {.importc.}
proc SDL_RenderViewportSet* ( renderer: SDL_Renderer ): bool {.importc.}
proc SDL_GetRenderSafeArea* ( renderer: SDL_Renderer, rect: var SDL_Rect ):bool {.importc.}
proc SDL_SetRenderClipRect* ( renderer: SDL_Renderer, rect: ptr SDL_Rect ): bool {.importc, discardable.}
proc SDL_SetRenderClipRect* ( renderer: SDL_Renderer, rect: SDL_Rect ): bool {.discardable.} =
  SDL_SetRenderClipRect(renderer, rect.addr)
proc SDL_GetRenderClipRect* ( renderer: SDL_Renderer, rect: var SDL_Rect ): bool {.importc.}
proc SDL_RenderClipEnabled* ( renderer: SDL_Renderer ): bool {.importc.}
proc SDL_SetRenderScale* ( renderer: SDL_Renderer, scaleX,scaleY: cfloat ): bool {.importc, discardable.}
proc SDL_GetRenderScale* ( renderer: SDL_Renderer, scaleX,scaleY: var cfloat ): bool {.importc.}
proc SDL_SetRenderDrawColor* ( renderer: SDL_Renderer, r,g,b,a: uint8): bool {.importc, discardable.}
proc SDL_SetRenderDrawColorFloat* ( renderer: SDL_Renderer, r,g,b,a: cfloat ): bool {.importc, discardable.}
proc SDL_GetRenderDrawColor* ( renderer: SDL_Renderer, r,g,b,a: var uint8 ): bool {.importc.}
proc SDL_GetRenderDrawColorFloat* ( renderer: SDL_Renderer, r,g,b,a: var cfloat ): bool {.importc.}
proc SDL_SetRenderColorScale* ( renderer: SDL_Renderer, scale: cfloat ): bool {.importc, discardable.}
proc SDL_GetRenderColorScale* ( renderer: SDL_Renderer, scale: var cfloat ): bool {.importc.}
proc SDL_SetRenderDrawBlendMode* ( renderer: SDL_Renderer, blendMode: SDL_BlendMode ): bool {.importc, discardable.}
proc SDL_GetRenderDrawBlendMode* ( renderer: SDL_Renderer, blendMode: var SDL_BlendMode ): bool {.importc.}
proc SDL_RenderClear* ( renderer: SDL_Renderer ): bool {.importc, discardable.}
proc SDL_RenderPoint* ( renderer: SDL_Renderer, x,y: cfloat ): bool {.importc, discardable.}
proc SDL_RenderPoints* ( renderer: SDL_Renderer, points: openarray[SDL_FPoint] ): bool {.importc, discardable.}
proc SDL_RenderLine* ( renderer: SDL_Renderer, x1,y1,x2,y2: cfloat ): bool {.importc, discardable.}
proc SDL_RenderLines* ( renderer: SDL_Renderer, points: openarray[SDL_FPoint] ): bool {.importc, discardable.}
proc SDL_RenderRect* ( renderer: SDL_Renderer, rect: ptr SDL_FRect ): bool {.importc, discardable.}
proc SDL_RenderRect* ( renderer: SDL_Renderer, rect: SDL_FRect ): bool {.discardable.} =
  SDL_RenderRect(renderer, rect.addr)
proc SDL_RenderRects* ( renderer: SDL_Renderer, rects: openarray[SDL_FRect] ): bool {.importc, discardable.}
proc SDL_RenderRects* ( renderer: SDL_Renderer, rects: ptr[SDL_FRect], count: int ): bool {.importc, discardable.}
proc SDL_RenderFillRect* ( renderer: SDL_Renderer, rect: ptr SDL_FRect ): bool {.importc, discardable.}
proc SDL_RenderFillRect* ( renderer: SDL_Renderer, rect: SDL_FRect ): bool {.discardable.} =
  SDL_RenderFillRect(renderer, rect.addr)
proc SDL_RenderFillRects* ( renderer: SDL_Renderer, rects: openarray[SDL_FRect] ): bool {.importc, discardable.}
proc SDL_RenderTexture* ( renderer: SDL_Renderer, texture: SDL_Texture, srcrect,dstrect: ptr SDL_FRect ): bool {.importc, discardable.}
proc SDL_RenderTextureRotated* ( renderer: SDL_Renderer, texture: SDL_Texture, srcrect, dstrect: ptr SDL_FRect, angle: cdouble, center: ptr SDL_FPoint, flip: SDL_FlipMode ): bool {.importc, discardable.}
proc SDL_RenderTextureAffine* ( renderer: SDL_Renderer, texture: SDL_Texture, srcrect: ptr SDL_FRect, origin,right,down: ptr SDL_FPoint): bool {.importc, discardable.}
proc SDL_RenderTextureTiled* ( renderer: SDL_Renderer, texture: SDL_Texture, srcrect: ptr SDL_FRect, scale: cfloat, dstrect: ptr SDL_FRect ): bool {.importc, discardable.}
proc SDL_RenderTexture9Grid* ( renderer: SDL_Renderer, texture: SDL_Texture, srcrect: ptr SDL_FRect, left_width, right_width, top_height, bottom_height, scale: cfloat, dstrect: ptr SDL_FRect): bool {.importc, discardable.}
proc SDL_RenderGeometry* ( renderer: SDL_Renderer, texture: SDL_Texture, vertices: ptr[SDL_Vertex], num_vertices: int, indices: ptr[cint], num_indices: int ): bool {.importc, discardable.}
proc SDL_RenderGeometry* ( renderer: SDL_Renderer, texture: SDL_Texture, vertices: openarray[SDL_Vertex], indices: openarray[cint] ): bool {.importc, discardable.}
proc SDL_RenderGeometryRaw* ( renderer: SDL_Renderer, texture: SDL_Texture, xy: ptr cfloat, xy_stride: int, color: ptr SDL_FColor, color_stride: int, uv: ptr cfloat, uv_stride: int, num_vertices: int, indices: pointer, num_indices: int, size_indices: int ): bool {.importc, discardable.}
proc SDL_RenderReadPixels* ( renderer: SDL_Renderer, rect: ptr SDL_Rect ): ptr SDL_Surface {.importc.}
proc SDL_RenderPresent*(renderer: SDL_Renderer): bool {.importc, discardable.}
proc SDL_DestroyTexture* ( texture: SDL_Texture ): void {.importc.}
proc SDL_DestroyRenderer* ( renderer: SDL_Renderer ): void {.importc.}
proc SDL_FlushRenderer* ( renderer: SDL_Renderer ): bool {.importc, discardable.}

proc SDL_GetRenderMetalLayer* ( renderer: SDL_Renderer ): pointer {.importc.}
proc SDL_GetRenderMetalCommandEncoder* ( renderer: SDL_Renderer ): pointer {.importc.}

proc SDL_AddVulkanRenderSemaphores* ( renderer: SDL_Renderer, wait_stage_mask: uint32, wait_semaphore: int64, signal_semaphore: int64 ): bool {.importc.}
proc SDL_SetRenderVSync* ( renderer: SDL_Renderer, vsync: int ): bool {.importc, discardable.}
proc SDL_GetRenderVSync* ( renderer: SDL_Renderer, vsync: var int ): bool {.importc.}
proc SDL_RenderDebugText* ( renderer: SDL_Renderer, x,y: cfloat, str: cstring ): bool {.importc, discardable.}
proc SDL_RenderDebugTextFormat* ( renderer: SDL_Renderer, x,y: cfloat, fmt: cstring ): bool {.importc, varargs, discardable.}

const SDL_SOFTWARE_RENDERER* = cstring "software"

const SDL_PROP_RENDERER_CREATE_NAME_STRING*              = cstring "SDL.renderer.create.name"
const SDL_PROP_RENDERER_CREATE_WINDOW_POINTER*           = cstring "SDL.renderer.create.window"
const SDL_PROP_RENDERER_CREATE_SURFACE_POINTER*          = cstring "SDL.renderer.create.surface"
const SDL_PROP_RENDERER_CREATE_OUTPUT_COLORSPACE_NUMBER* = cstring "SDL.renderer.create.output_colorspace"
const SDL_PROP_RENDERER_CREATE_PRESENT_VSYNC_NUMBER*     = cstring "SDL.renderer.create.present_vsync"

const SDL_PROP_RENDERER_CREATE_VULKAN_INSTANCE_POINTER*                   = cstring "SDL.renderer.create.vulkan.instance"
const SDL_PROP_RENDERER_CREATE_VULKAN_SURFACE_NUMBER*                     = cstring "SDL.renderer.create.vulkan.surface"
const SDL_PROP_RENDERER_CREATE_VULKAN_PHYSICAL_DEVICE_POINTER*            = cstring "SDL.renderer.create.vulkan.physical_device"
const SDL_PROP_RENDERER_CREATE_VULKAN_DEVICE_POINTER*                     = cstring "SDL.renderer.create.vulkan.device"
const SDL_PROP_RENDERER_CREATE_VULKAN_GRAPHICS_QUEUE_FAMILY_INDEX_NUMBER* = cstring "SDL.renderer.create.vulkan.graphics_queue_family_index"
const SDL_PROP_RENDERER_CREATE_VULKAN_PRESENT_QUEUE_FAMILY_INDEX_NUMBER*  = cstring "SDL.renderer.create.vulkan.present_queue_family_index"

const SDL_PROP_RENDERER_NAME_STRING*              = cstring "SDL.renderer.name"
const SDL_PROP_RENDERER_WINDOW_POINTER*           = cstring "SDL.renderer.window"
const SDL_PROP_RENDERER_SURFACE_POINTER*          = cstring "SDL.renderer.surface"
const SDL_PROP_RENDERER_VSYNC_NUMBER*             = cstring "SDL.renderer.vsync"
const SDL_PROP_RENDERER_MAX_TEXTURE_SIZE_NUMBER*  = cstring "SDL.renderer.max_texture_size"
const SDL_PROP_RENDERER_TEXTURE_FORMATS_POINTER*  = cstring "SDL.renderer.texture_formats"
const SDL_PROP_RENDERER_OUTPUT_COLORSPACE_NUMBER* = cstring "SDL.renderer.output_colorspace"

const SDL_PROP_RENDERER_HDR_ENABLED_BOOLEAN*   = cstring "SDL.renderer.HDR_enabled"
const SDL_PROP_RENDERER_SDR_WHITE_POINT_FLOAT* = cstring "SDL.renderer.SDR_white_point"
const SDL_PROP_RENDERER_HDR_HEADROOM_FLOAT*    = cstring "SDL.renderer.HDR_headroom"

const SDL_PROP_RENDERER_D3D9_DEVICE_POINTER* = cstring "SDL.renderer.d3d9.device"

const SDL_PROP_RENDERER_D3D11_DEVICE_POINTER*    = cstring "SDL.renderer.d3d11.device"
const SDL_PROP_RENDERER_D3D11_SWAPCHAIN_POINTER* = cstring "SDL.renderer.d3d11.swap_chain"

const SDL_PROP_RENDERER_D3D12_DEVICE_POINTER*        = cstring "SDL.renderer.d3d12.device"
const SDL_PROP_RENDERER_D3D12_SWAPCHAIN_POINTER*     = cstring "SDL.renderer.d3d12.swap_chain"
const SDL_PROP_RENDERER_D3D12_COMMAND_QUEUE_POINTER* = cstring "SDL.renderer.d3d12.command_queue"

const SDL_PROP_RENDERER_VULKAN_INSTANCE_POINTER*                   = cstring "SDL.renderer.vulkan.instance"
const SDL_PROP_RENDERER_VULKAN_SURFACE_NUMBER*                     = cstring "SDL.renderer.vulkan.surface"
const SDL_PROP_RENDERER_VULKAN_PHYSICAL_DEVICE_POINTER*            = cstring "SDL.renderer.vulkan.physical_device"
const SDL_PROP_RENDERER_VULKAN_DEVICE_POINTER*                     = cstring "SDL.renderer.vulkan.device"
const SDL_PROP_RENDERER_VULKAN_GRAPHICS_QUEUE_FAMILY_INDEX_NUMBER* = cstring "SDL.renderer.vulkan.graphics_queue_family_index"
const SDL_PROP_RENDERER_VULKAN_PRESENT_QUEUE_FAMILY_INDEX_NUMBER*  = cstring "SDL.renderer.vulkan.present_queue_family_index"
const SDL_PROP_RENDERER_VULKAN_SWAPCHAIN_IMAGE_COUNT_NUMBER*       = cstring "SDL.renderer.vulkan.swapchain_image_count"

const SDL_PROP_RENDERER_GPU_DEVICE_POINTER* = cstring "SDL.renderer.gpu.device"

const SDL_PROP_TEXTURE_CREATE_COLORSPACE_NUMBER* = cstring "SDL.texture.create.colorspace"
const SDL_PROP_TEXTURE_CREATE_FORMAT_NUMBER*     = cstring "SDL.texture.create.format"
const SDL_PROP_TEXTURE_CREATE_ACCESS_NUMBER*     = cstring "SDL.texture.create.access"
const SDL_PROP_TEXTURE_CREATE_WIDTH_NUMBER*      = cstring "SDL.texture.create.width"
const SDL_PROP_TEXTURE_CREATE_HEIGHT_NUMBER*     = cstring "SDL.texture.create.height"

const SDL_PROP_TEXTURE_CREATE_SDR_WHITE_POINT_FLOAT* = cstring "SDL.texture.create.SDR_white_point"
const SDL_PROP_TEXTURE_CREATE_HDR_HEADROOM_FLOAT*    = cstring "SDL.texture.create.HDR_headroom"

const SDL_PROP_TEXTURE_CREATE_D3D11_TEXTURE_POINTER*   = cstring "SDL.texture.create.d3d11.texture"
const SDL_PROP_TEXTURE_CREATE_D3D11_TEXTURE_U_POINTER* = cstring "SDL.texture.create.d3d11.texture_u"
const SDL_PROP_TEXTURE_CREATE_D3D11_TEXTURE_V_POINTER* = cstring "SDL.texture.create.d3d11.texture_v"

const SDL_PROP_TEXTURE_CREATE_D3D12_TEXTURE_POINTER*   = cstring "SDL.texture.create.d3d12.texture"
const SDL_PROP_TEXTURE_CREATE_D3D12_TEXTURE_U_POINTER* = cstring "SDL.texture.create.d3d12.texture_u"
const SDL_PROP_TEXTURE_CREATE_D3D12_TEXTURE_V_POINTER* = cstring "SDL.texture.create.d3d12.texture_v"

const SDL_PROP_TEXTURE_CREATE_METAL_PIXELBUFFER_POINTER* = cstring "SDL.texture.create.metal.pixelbuffer"

const SDL_PROP_TEXTURE_CREATE_OPENGL_TEXTURE_NUMBER*    = cstring "SDL.texture.create.opengl.texture"
const SDL_PROP_TEXTURE_CREATE_OPENGL_TEXTURE_UV_NUMBER* = cstring "SDL.texture.create.opengl.texture_uv"
const SDL_PROP_TEXTURE_CREATE_OPENGL_TEXTURE_U_NUMBER*  = cstring "SDL.texture.create.opengl.texture_u"
const SDL_PROP_TEXTURE_CREATE_OPENGL_TEXTURE_V_NUMBER*  = cstring "SDL.texture.create.opengl.texture_v"

const SDL_PROP_TEXTURE_CREATE_OPENGLES2_TEXTURE_NUMBER*    = cstring "SDL.texture.create.opengles2.texture"
const SDL_PROP_TEXTURE_CREATE_OPENGLES2_TEXTURE_UV_NUMBER* = cstring "SDL.texture.create.opengles2.texture_uv"
const SDL_PROP_TEXTURE_CREATE_OPENGLES2_TEXTURE_U_NUMBER*  = cstring "SDL.texture.create.opengles2.texture_u"
const SDL_PROP_TEXTURE_CREATE_OPENGLES2_TEXTURE_V_NUMBER*  = cstring "SDL.texture.create.opengles2.texture_v"

const SDL_PROP_TEXTURE_CREATE_VULKAN_TEXTURE_NUMBER* = cstring "SDL.texture.create.vulkan.texture"

const SDL_PROP_TEXTURE_COLORSPACE_NUMBER* = cstring "SDL.texture.colorspace"
const SDL_PROP_TEXTURE_FORMAT_NUMBER*     = cstring "SDL.texture.format"
const SDL_PROP_TEXTURE_ACCESS_NUMBER*     = cstring "SDL.texture.access"
const SDL_PROP_TEXTURE_WIDTH_NUMBER*      = cstring "SDL.texture.width"
const SDL_PROP_TEXTURE_HEIGHT_NUMBER*     = cstring "SDL.texture.height"

const SDL_PROP_TEXTURE_SDR_WHITE_POINT_FLOAT* = cstring "SDL.texture.SDR_white_point"
const SDL_PROP_TEXTURE_HDR_HEADROOM_FLOAT*    = cstring "SDL.texture.HDR_headroom"

const SDL_PROP_TEXTURE_D3D11_TEXTURE_POINTER*   = cstring "SDL.texture.d3d11.texture"
const SDL_PROP_TEXTURE_D3D11_TEXTURE_U_POINTER* = cstring "SDL.texture.d3d11.texture_u"
const SDL_PROP_TEXTURE_D3D11_TEXTURE_V_POINTER* = cstring "SDL.texture.d3d11.texture_v"

const SDL_PROP_TEXTURE_D3D12_TEXTURE_POINTER*   = cstring "SDL.texture.d3d12.texture"
const SDL_PROP_TEXTURE_D3D12_TEXTURE_U_POINTER* = cstring "SDL.texture.d3d12.texture_u"
const SDL_PROP_TEXTURE_D3D12_TEXTURE_V_POINTER* = cstring "SDL.texture.d3d12.texture_v"

const SDL_PROP_TEXTURE_OPENGL_TEXTURE_NUMBER*        = cstring "SDL.texture.opengl.texture"
const SDL_PROP_TEXTURE_OPENGL_TEXTURE_UV_NUMBER*     = cstring "SDL.texture.opengl.texture_uv"
const SDL_PROP_TEXTURE_OPENGL_TEXTURE_U_NUMBER*      = cstring "SDL.texture.opengl.texture_u"
const SDL_PROP_TEXTURE_OPENGL_TEXTURE_V_NUMBER*      = cstring "SDL.texture.opengl.texture_v"
const SDL_PROP_TEXTURE_OPENGL_TEXTURE_TARGET_NUMBER* = cstring "SDL.texture.opengl.target"
const SDL_PROP_TEXTURE_OPENGL_TEX_W_FLOAT*           = cstring "SDL.texture.opengl.tex_w"
const SDL_PROP_TEXTURE_OPENGL_TEX_H_FLOAT*           = cstring "SDL.texture.opengl.tex_h"

const SDL_PROP_TEXTURE_OPENGLES2_TEXTURE_NUMBER*        = cstring "SDL.texture.opengles2.texture"
const SDL_PROP_TEXTURE_OPENGLES2_TEXTURE_UV_NUMBER*     = cstring "SDL.texture.opengles2.texture_uv"
const SDL_PROP_TEXTURE_OPENGLES2_TEXTURE_U_NUMBER*      = cstring "SDL.texture.opengles2.texture_u"
const SDL_PROP_TEXTURE_OPENGLES2_TEXTURE_V_NUMBER*      = cstring "SDL.texture.opengles2.texture_v"
const SDL_PROP_TEXTURE_OPENGLES2_TEXTURE_TARGET_NUMBER* = cstring "SDL.texture.opengles2.target"

const SDL_PROP_TEXTURE_VULKAN_TEXTURE_NUMBER* = cstring "SDL.texture.vulkan.texture"

const SDL_RENDERER_VSYNC_DISABLED* = 0
const SDL_RENDERER_VSYNC_ADAPTIVE* = -1

const SDL_DEBUG_TEXT_FONT_CHARACTER_SIZE* = 8

#endregion


#region SDL3/SDL_init.h -------------------------------------------------------

type
  SDL_InitFlags* = uint32

const SDL_INIT_AUDIO*: uint32    = 0x00000010 # `SDL_INIT_AUDIO` implies `SDL_INIT_EVENTS`
const SDL_INIT_VIDEO*: uint32    = 0x00000020 # `SDL_INIT_VIDEO` implies `SDL_INIT_EVENTS`, should be initialized on the main thread
const SDL_INIT_JOYSTICK*: uint32 = 0x00000200 # `SDL_INIT_JOYSTICK` implies `SDL_INIT_EVENTS`, should be initialized on the same thread as SDL_INIT_VIDEO on Windows if you don't set SDL_HINT_JOYSTICK_THREAD
const SDL_INIT_HAPTIC*: uint32   = 0x00001000
const SDL_INIT_GAMEPAD*: uint32  = 0x00002000 # `SDL_INIT_GAMEPAD` implies `SDL_INIT_JOYSTICK`
const SDL_INIT_EVENTS*: uint32   = 0x00004000
const SDL_INIT_SENSOR*: uint32   = 0x00008000 # `SDL_INIT_SENSOR` implies `SDL_INIT_EVENTS`
const SDL_INIT_CAMERA*: uint32   = 0x00010000 # `SDL_INIT_CAMERA` implies `SDL_INIT_EVENTS`

type
  SDL_AppResult* {.size: sizeof(cint).} = enum
    SDL_APP_CONTINUE,
    SDL_APP_SUCCESS,
    SDL_APP_FAILURE

type
  SDL_AppInit_func* = proc (appstate: ptr pointer; argc: cint; argv: ptr UncheckedArray[cstring]): SDL_AppResult {.
      cdecl.}
  SDL_AppIterate_func* = proc (appstate: pointer): SDL_AppResult {.cdecl.}
  SDL_AppEvent_func* = proc (appstate: pointer; event: ptr SDL_Event): SDL_AppResult {.
      cdecl.}
  SDL_AppQuit_func* = proc (appstate: pointer; result: SDL_AppResult) {.
      cdecl.}

proc SDL_Init* ( flags: SDL_InitFlags ): bool {.importc.}
proc SDL_InitSubSystem* ( flags: SDL_InitFlags ): bool {.importc.}
proc SDL_QuitSubSystem* ( flags: SDL_InitFlags ): void {.importc.}
proc SDL_WasInit* ( flags: SDL_InitFlags ): SDL_InitFlags {.importc.}
proc SDL_Quit* (): void {.importc.}

proc SDL_IsMainThread* (): bool {.importc.}

type
  SDL_MainThreadCallback* = proc (userdata: pointer) {.cdecl.}

proc SDL_RunOnMainThread* ( callback: SDL_MainThreadCallback, userdata: pointer, wait_complete: bool ): bool {.importc.}
proc SDL_SetAppMetadata* ( appname,appversion,appidentifier: cstring ): bool {.importc.}
proc SDL_SetAppMetadataProperty* ( name,value: cstring ): bool {.importc.}
proc SDL_GetAppMetadataProperty* ( name: cstring ): cstring {.importc.}

const SDL_PROP_APP_METADATA_NAME_STRING*: cstring        = "SDL.app.metadata.name"
const SDL_PROP_APP_METADATA_VERSION_STRING*: cstring     = "SDL.app.metadata.version"
const SDL_PROP_APP_METADATA_IDENTIFIER_STRING*: cstring  = "SDL.app.metadata.identifier"
const SDL_PROP_APP_METADATA_CREATOR_STRING*: cstring     = "SDL.app.metadata.creator"
const SDL_PROP_APP_METADATA_COPYRIGHT_STRING*: cstring   = "SDL.app.metadata.copyright"
const SDL_PROP_APP_METADATA_URL_STRING*: cstring         = "SDL.app.metadata.url"
const SDL_PROP_APP_METADATA_TYPE_STRING*: cstring        = "SDL.app.metadata.type"

#endregion


#region SDL3/SDL_oldnames.h ---------------------------------------------------
#  This one doesn't make a ton of sense to include in the binding, IMO.
#  Make an issue on GH if you'd like to have it, and I'll see what I can do!
#endregion

