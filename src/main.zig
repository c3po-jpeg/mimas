const std = @import("std");

const sdl = @cImport({
    @cInclude("SDL3/SDL.h");
});

pub fn main() void {
    if (!sdl.SDL_Init(sdl.SDL_INIT_VIDEO)) {
        std.debug.print("SDL init failed: {s}\n", .{sdl.SDL_GetError()});
        return;
    }

    defer sdl.SDL_Quit();
    const window = sdl.SDL_CreateWindow("mimas", 800, 600, sdl.SDL_WINDOW_VULKAN);

    if (window == null) {
        std.debug.print("Window creation failed: {s}\n", .{sdl.SDL_GetError()});
        return;
    }

    defer sdl.SDL_DestroyWindow(window);

    var running = true;
    while (running) {
        var event: sdl.SDL_Event = undefined;
        while (sdl.SDL_PollEvent(&event)) {
            switch (event.type) {
                sdl.SDL_EVENT_QUIT => running = false,
                else => {},
            }
        }
    }
}
