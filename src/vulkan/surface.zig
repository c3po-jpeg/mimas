const std = @import("std");
const vk = @import("../bindings.zig").vk;
const sdl = @import("../bindings.zig").sdl;

pub fn create(instance: vk.VkInstance, window: *sdl.SDL_Window) !vk.VkSurfaceKHR {
    var handle: vk.VkSurfaceKHR = undefined;

    if (!sdl.SDL_Vulkan_CreateSurface(
        window,
        @ptrCast(instance),
        null,
        @ptrCast(&handle),
    )) {
        std.debug.print("SDL_Vulkan_CreateSurface failed: {s}\n", .{sdl.SDL_GetError()});
        return error.VulkanSurfaceFailed;
    }

    return handle;
}

pub fn destroy(instance: vk.VkInstance, surface: vk.VkSurfaceKHR) void {
    vk.vkDestroySurfaceKHR(instance, surface, null);
}
