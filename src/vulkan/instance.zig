const std = @import("std");
const vk = @import("../bindings.zig").vk;

pub fn create(ext_count: u32, ext_names: [*c]const [*c]const u8) !vk.VkInstance {
    const app_info = vk.VkApplicationInfo{
        .sType = vk.VK_STRUCTURE_TYPE_APPLICATION_INFO,
        .pNext = null,
        .pApplicationName = "mimas",
        .applicationVersion = vk.VK_MAKE_VERSION(0, 0, 1),
        .pEngineName = "mimas_engine",
        .engineVersion = vk.VK_MAKE_VERSION(0, 0, 1),
        .apiVersion = vk.VK_API_VERSION_1_4,
    };

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

    var handle: vk.VkInstance = undefined;
    const result = vk.vkCreateInstance(&create_info, null, &handle);
    if (result != vk.VK_SUCCESS) {
        std.debug.print("vkCreateInstance failed: {d}\n", .{result});
        return error.VulkanInstanceFailed;
    }

    return handle;
}

pub fn destroy(instance: vk.VkInstance) void {
    vk.vkDestroyInstance(instance, null);
}
