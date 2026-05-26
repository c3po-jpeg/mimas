const std = @import("std");
const builtin = @import("builtin");

const sdl = @import("bindings.zig").sdl;
const vkb = @import("vulkan/backend.zig");

pub fn main() !void {
    const allocator = std.heap.page_allocator;

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

    // ----- Physical device selection ------------------------------------------------
    const physical_device = try vkb.physical_device.pick(allocator, instance, surface);

    // ----- Logical device creation --------------------------------------------------
    const device = try vkb.device.create(physical_device.device, physical_device.indices);
    defer vkb.device.destroy(device.handle);

    // ----- Swapchain creation -------------------------------------------------------
    const swapchain = try vkb.swapchain.create(
        physical_device.device,
        device.handle,
        surface,
        window,
    );
    defer vkb.swapchain.destroy(device.handle, swapchain);

    // ----- Render pass creation ------------------------------------------------------
    const render_pass = try vkb.renderpass.create(device.handle, swapchain.format);
    defer vkb.renderpass.destroy(device.handle, render_pass);

    // ----- Pipeline creation ---------------------------------------------------------
    const pipeline_layout = try vkb.pipeline.create_layout(device.handle);
    defer vkb.pipeline.destroy_layout(device.handle, pipeline_layout);

    const render_pipeline = try vkb.pipeline.render_pipeline(
        device.handle,
        render_pass,
        pipeline_layout,
        swapchain.extent,
    );
    defer vkb.pipeline.destroy(device.handle, render_pipeline);

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
