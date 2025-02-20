import std/[os, osproc]
import ../../../src/sdl3


# helper function to read a file into a seq[uint8]
proc readFileAsUint8(filename: string): seq[uint8] =
  let fileSize = getFileSize(filename)
  var file: File
  if not open(file, filename, fmRead):
    raise newException(IOError, "Failed to open shader file: " & filename)
  result = newSeq[uint8](fileSize)  # Allocate the sequence
  let bytesRead = readBytes(file, result, 0, fileSize)  # Read into the sequence
  close(file)
  if bytesRead != fileSize:
    raise newException(IOError, "Failed to read the entire shader file: " & filename)

# helper function to load a shader from a file
proc loadShader(gpu: SDL_GPUDevice; filename: string; stage: SDL_GPUShaderStage; format: SDL_GPUShaderFormat): SDL_GPUShader =

    var code = readFileAsUint8(filename)
    assert code.len > 0, "Failed to read shader file: " & filename

    let shaderInfo = SDL_GPUShaderCreateInfo(
        code_size: code.len.uint32,
        code: cast[ptr UncheckedArray[uint8]](addr code[0]),
        entrypoint: cstring"main",
        format: format,
        stage: stage
    )
    result = SDL_CreateGPUShader(gpu, addr shaderInfo)

proc main =
    # 0.) Setup Logging (Verbose) for debugging
    SDL_SetLogPriorities(SDL_LOG_PRIORITY_VERBOSE)

    # 1.) Initialize SDL
    let init = SDL_Init(SDL_INIT_VIDEO) # initialize only the video subsystem (needed for window creation)
    assert init, "SDL_Init failed: " & $SDL_GetError()

    # 2.) Create a window
    let window = SDL_CreateWindow("Hello, World!", 1280, 720, 0)
    assert window != nil, "SDL_CreateWindow failed: " & $SDL_GetError()

    # 3.) Create a GPU device & assign it to the window
    var gpu = SDL_CreateGPUDevice(SDL_GPU_SHADERFORMAT_SPIRV, false, nil)
    assert gpu != nil, "SDL_CreateGPUDevice failed: " & $SDL_GetError()
    let claimed = SDL_ClaimWindowForGPUDevice(gpu, window)
    assert claimed, "SDL_ClaimWindowForGPUDevice failed: " & $SDL_GetError()

    # 4.) Setup the graphics pipeline
    #     - load shaders
    #     - create a graphics pipeline
    #     - release shaders (if not being reused in other pipelines)
    #     - NOTE: this is a one-time setup, you can reuse the pipeline over and over again
    let
        dir = currentSourcePath.parentDir()
        vertShader = gpu.loadShader(dir / "shader.spv.vert",
                                    SDL_GPU_SHADERSTAGE_VERTEX, SDL_GPU_SHADERFORMAT_SPIRV)
        fragShader = gpu.loadShader(dir / "shader.spv.frag",
                                    SDL_GPU_SHADERSTAGE_FRAGMENT, SDL_GPU_SHADERFORMAT_SPIRV)

    var colorDescriptions: array[1, SDL_GPUColorTargetDescription] = [
    SDL_GPUColorTargetDescription(
        format: SDL_GetGPUSwapchainTextureFormat(gpu, window)
    )
    ]
    let pipelineInfo = SDL_GPUGraphicsPipelineCreateInfo(
        vertex_shader: vertShader,
        fragment_shader: fragShader,
        primitive_type: SDL_GPU_PRIMITIVETYPE_TRIANGLELIST,
        target_info: SDL_GPUGraphicsPipelineTargetInfo(
            num_color_targets: 1,
            color_target_descriptions: cast[ptr UncheckedArray[SDL_GPUColorTargetDescription]](addr colorDescriptions[0])
        )
    )
    let pipeline = SDL_CreateGPUGraphicsPipeline(gpu, addr pipelineInfo)
    assert pipeline != nil, "SDL_CreateGPUGraphicsPipeline failed: " & $SDL_GetError()

    SDL_ReleaseGPUShader(gpu, vertShader) # after creating graphics pipeline you can release shaders
    SDL_ReleaseGPUShader(gpu, fragShader) # if you don't want to reuse the shaders for other pipelines

    # 5.) Main game loop
    var quit = false
    while not quit:
        var event: SDL_Event
        while SDL_PollEvent(event):
            if event.type == SDL_EVENT_QUIT: quit = true
            elif event.type == SDL_EVENT_KEYDOWN:
                if event.key.scancode == SDL_SCANCODE_ESCAPE: quit = true
            else: continue

        # update game state (not needed in this example)

        # render frame
        # - acquire a command buffer # commands are commands you pass from the CPU to the GPU
        var cmdBuff = SDL_AcquireGPUCommandBuffer(gpu)
        # - acquire a swapchain texture (a special texture that represents a window's contents)
        var swapchainTxtr: SDL_GPUTexture
        let acquired: bool = SDL_WaitAndAcquireGPUSwapchainTexture(cmdBuff, window, addr swapchainTxtr, nil, nil)
        assert acquired, "SDL_WaitAndAcquireGPUSwapchainTexture failed: " & $SDL_GetError()
        
        if swapchainTxtr != nil: # this could actually be in (for example, the window is minimized)
            # - begin render pass (now we can try to draw things)
            let colorTargetInfo = SDL_GPUColorTargetInfo(
                texture: swapchainTxtr,
                load_op: SDL_GPULoadOp.SDL_GPU_LOADOP_CLEAR,
                store_op: SDL_GPUStoreOp.SDL_GPU_STOREOP_STORE,
                clear_color: SDL_FColor(r: 0.2, g: 0.2, b: 0.2, a: 1.0)
            )
            let renderPass = SDL_BeginGPURenderPass(cmdBuff, addr colorTargetInfo, 1, nil)
            # - draw stuff:
            #    - bind pipeline
            SDL_BindGPUGraphicsPipeline(renderPass, pipeline)
            #    - bind vertex data (not using in this example, we'll draw in the vertex shader)
            #    - bind uniform data  (not using in this example, we'll draw in the vertex shader)
            #    - draw calls
            SDL_DrawGPUPrimitives(renderPass, 3, 1, 0, 0) # draw a triangle
            # - end render pass
            SDL_EndGPURenderPass(renderPass)
            # - more render passes (as needed)
            # - submit command buffer
            let sumbitted = SDL_SubmitGPUCommandBuffer(cmdBuff)
            assert sumbitted, "SDL_SubmitGPUCommandBuffer failed: " & $SDL_GetError()

    # 6.) Cleanup - release everything in the correct order
    SDL_ReleaseGPUGraphicsPipeline(gpu, pipeline) # release the graphics pipeline
    SDL_ReleaseWindowFromGPUDevice(gpu, window) # Unbind window from GPU device
    SDL_DestroyWindow(window) # destroy the window
    SDL_DestroyGPUDevice(gpu) # destroy the GPU device
    SDL_Quit() # shutdown SDL



when isMainModule:

    # NOTE 1:
    # Must have Vulkan SDK installed via https://vulkan.lunarg.com/
    # It's an easy process and will add the glslc compiler to your path.
    # This is required as we target the Vulkan backend. We're also able
    # to use the glsl shaders (OpenGL) and convert them to spir-v, which
    # is a binary shader format for Vulkan.
    
    # NOTE 2:
    # *** this example should work on Windows (tested), and Linux (not tested) ***
    # If you have a Mac, you'll need to install SDL_Shadercross, and convert
    # the spir-v shaders to metal, then update the appropriate shader info above.

    # NOTE 3:
    # You don't HAVE to translate the shaders from glsl to spir-v, you can
    # write spir-v directly, but it's much easier (IMO) to write glsl and convert.
    # finding glsl shaders to do things is much easier than spir-v.

    let # translates vertex shader from glsl to spir-v
        vertPath = currentSourcePath.parentDir() / "shader.glsl.vert"
        vertCmd = "glslc " & vertPath & " -o " & currentSourcePath.parentDir() / "shader.spv.vert"
        compiledVert = execCmdEx(vertCmd) # Compile the vertex shader
    if compiledVert.exitCode != 0:
        echo compiledVert.output
        quit(QuitFailure)

    let # translates fragment shader from glsl to spir-v
        fragPath = currentSourcePath.parentDir() / "shader.glsl.frag"
        fragCmd = "glslc " & fragPath & " -o " & currentSourcePath.parentDir() / "shader.spv.frag"
        compiledFrag = execCmdEx(fragCmd) # Compile the fragment shader
    if compiledFrag.exitCode != 0:
        echo compiledFrag.output
        quit(QuitFailure)

    main() # start program