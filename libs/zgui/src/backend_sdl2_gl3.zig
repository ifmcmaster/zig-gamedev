const gui = @import("gui.zig");

pub const TextureFilterMode = enum(u32) {
    nearest,
    linear,
};

pub const Config = extern struct {
    pipeline_multisample_count: u32 = 1,
    texture_filter_mode: TextureFilterMode = .linear,
};

// This call will install GLFW callbacks to handle GUI interactions.
// Those callbacks will chain-call user's previously installed callbacks, if any.
// This means that custom user's callbacks need to be installed *before* calling zgpu.gui.init().
pub fn initWithConfig(
    window: *const anyopaque,
    sdl_gl_context: *const anyopaque,
    glsl_version: [*c]const u8,
) void {
    if (!ImGui_ImplSDL2_InitForOpenGL(window, sdl_gl_context)) {
        unreachable;
    }

    if (!ImGui_ImplOpenGL3_Init(glsl_version)) {
        unreachable;
    }
}

pub fn init(
    window: *const anyopaque,
    sdl_gl_context: *const anyopaque,
    glsl_version: [*c]const u8,
) void {
    initWithConfig(window, sdl_gl_context, glsl_version);
}

pub fn processEvent(event: *const anyopaque) bool {
    return ImGui_ImplSDL2_ProcessEvent(event);
}

pub fn deinit() void {
    ImGui_ImplOpenGL3_Shutdown();
    ImGui_ImplSDL2_Shutdown();
}

pub fn newFrame(fb_width: u32, fb_height: u32) void {
    ImGui_ImplOpenGL3_NewFrame();
    ImGui_ImplSDL2_NewFrame();

    gui.io.setDisplaySize(@intToFloat(f32, fb_width), @intToFloat(f32, fb_height));
    gui.io.setDisplayFramebufferScale(1.0, 1.0);

    gui.newFrame();
}

pub fn draw() void {
    gui.render();
    ImGui_ImplOpenGL3_RenderDrawData(gui.getDrawData());
}

// Those functions are defined in `imgui_impl_glfw.cpp` and 'imgui_impl_wgpu.cpp`
// (they include few custom changes).
extern fn ImGui_ImplSDL2_InitForOpenGL(window: *const anyopaque, sdl_gl_context: *const anyopaque) bool;
extern fn ImGui_ImplSDL2_NewFrame() void;
extern fn ImGui_ImplSDL2_Shutdown() void;
extern fn ImGui_ImplSDL2_ProcessEvent(event: *const anyopaque) bool;
extern fn ImGui_ImplOpenGL3_Init(
    glsl_version: [*c]const u8,
) bool;
extern fn ImGui_ImplOpenGL3_NewFrame() void;
extern fn ImGui_ImplOpenGL3_RenderDrawData(draw_data: *const anyopaque) void;
extern fn ImGui_ImplOpenGL3_Shutdown() void;
