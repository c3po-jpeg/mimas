const std = @import("std");
const builtin = @import("builtin");

const sdl = @cImport({
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_vulkan.h");
});

const vk = @cImport({
    @cInclude("vulkan/vulkan.h");
});

pub fn main() !void {
    if (!sdl.SDL_Init(sdl.SDL_INIT_VIDEO)) {
        std.debug.print("SDL init failed: {s}\n", .{sdl.SDL_GetError()});
        return;
    }
    defer sdl.SDL_Quit();

    _ = sdl.SDL_SetHint(sdl.SDL_HINT_VIDEO_DRIVER, "");
    const window = sdl.SDL_CreateWindow("mimas", 800, 600, sdl.SDL_WINDOW_VULKAN);

    if (window == null) {
        std.debug.print("Window creation failed: {s}\n", .{sdl.SDL_GetError()});
        return;
    }

    defer sdl.SDL_DestroyWindow(window);

    var ext_count: u32 = 0;
    const ext_names = sdl.SDL_Vulkan_GetInstanceExtensions(&ext_count);
    if (ext_names == null) {
        std.debug.print("SDL_Vulkan_GetInstanceExtensions failed: {s}\n", .{sdl.SDL_GetError()});
        return error.VulkanExtensionsFailed;
    }

    const app_info = vk.VkApplicationInfo{ .sType = vk.VK_STRUCTURE_TYPE_APPLICATION_INFO, .pNext = null, .pApplicationName = "mimas", .applicationVersion = vk.VK_MAKE_VERSION(0, 0, 1), .pEngineName = "mimas_engine", .engineVersion = vk.VK_MAKE_VERSION(0, 0, 1), .apiVersion = vk.VK_API_VERSION_1_3 };

    const create_info = vk.VkInstanceCreateInfo{
        .sType = vk.VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
        .pNext = null,
        .flags = 0,
        .pApplicationInfo = &app_info,
        .enabledLayerCount = 0,
        .ppEnabledLayerNames = null,
        .enabledExtensionCount = ext_count,
        .ppEnabledExtensionNames = ext_names,
    };

    var instance: vk.VkInstance = undefined;
    const result = vk.vkCreateInstance(&create_info, null, &instance);
    if (result != vk.VK_SUCCESS) {
        std.debug.print("vkCreateInstance failed: {d}\n", .{result});
        return error.VulkanInstanceFailed;
    }
    defer vk.vkDestroyInstance(instance, null);

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
