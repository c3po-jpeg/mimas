const std = @import("std");
const builtin = @import("builtin");

const sdl = @import("bindings.zig").sdl;
const vkb = @import("vulkan/backend.zig");

pub fn main() !void {
    if (!sdl.SDL_Init(sdl.SDL_INIT_VIDEO)) {
        std.debug.print("SDL init failed: {s}\n", .{sdl.SDL_GetError()});
        return;
    }
    defer sdl.SDL_Quit();

    _ = sdl.SDL_SetHint(sdl.SDL_HINT_VIDEO_DRIVER, "");
    const window = sdl.SDL_CreateWindow("mimas", 800, 600, sdl.SDL_WINDOW_VULKAN) orelse {
        std.debug.print("Window creation failed: {s}\n", .{sdl.SDL_GetError()});
        return error.SDLWindowFailed;
    };
    defer sdl.SDL_DestroyWindow(window);

    var ext_count: u32 = 0;
    const ext_names = sdl.SDL_Vulkan_GetInstanceExtensions(&ext_count);
    if (ext_names == null) {
        std.debug.print("SDL_Vulkan_GetInstanceExtensions failed: {s}\n", .{sdl.SDL_GetError()});
        return error.VulkanExtensionsFailed;
    }

    // ----- Vulkan instance creation -------------------------------------------------
    const instance = try vkb.instance.create(ext_count, ext_names);
    defer vkb.instance.destroy(instance);

    // ----- Vulkan surface creation --------------------------------------------------
    const surface = try vkb.surface.create(instance, window);
    defer vkb.surface.destroy(instance, surface);

    var running = true;
    while (running) {
        var event: sdl.SDL_Event = undefined;
        while (sdl.SDL_PollEvent(&event)) {
            switch (event.type) {
                sdl.SDL_EVENT_QUIT => {
                    running = false;
                    std.debug.print("closing window!", .{});
                },
                else => {},
            }
        }
    }
}
