const std = @import("std");
const vk = @import("../bindings.zig").vk;
const pd = @import("physical_device.zig");

pub const Queues = struct { graphics: vk.VkQueue, present: vk.VkQueue };

pub fn create(
    physical_device: vk.VkPhysicalDevice,
    indices: pd.QueueFamilyIndices,
) !struct { handle: vk.VkDevice, queues: Queues } {
    const graphics_family = indices.graphics.?;
    const present_family = indices.present.?;

    var queue_create_infos: [2]vk.VkDeviceQueueCreateInfo = undefined;
    var queue_count: u32 = 1;

    const priority: f32 = 1.0;

    queue_create_infos[0] = .{
        .sType = vk.VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO,
        .pNext = null,
        .flags = 0,
        .queueFamilyIndex = graphics_family,
        .queueCount = 1,
        .pQueuePriorities = &priority,
    };

    if (graphics_family != present_family) {
        queue_create_infos[1] = .{
            .sType = vk.VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO,
            .pNext = null,
            .flags = 0,
            .queueFamilyIndex = present_family,
            .queueCount = 1,
            .pQueuePriorities = &priority,
        };
        queue_count = 2;
    }

    const extensions = [_][*:0]const u8{vk.VK_KHR_SWAPCHAIN_EXTENSION_NAME};

    const features = std.mem.zeroes(vk.VkPhysicalDeviceFeatures);

    const create_info = vk.VkDeviceCreateInfo{
        .sType = vk.VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO,
        .pNext = null,
        .flags = 0,
        .queueCreateInfoCount = queue_count,
        .pQueueCreateInfos = &queue_create_infos[0],
        .enabledLayerCount = 0,
        .ppEnabledLayerNames = null,
        .enabledExtensionCount = @intCast(extensions.len),
        .ppEnabledExtensionNames = &extensions,
        .pEnabledFeatures = &features,
    };

    var device: vk.VkDevice = undefined;
    const result = vk.vkCreateDevice(physical_device, &create_info, null, &device);
    if (result != vk.VK_SUCCESS) {
        std.debug.print("vkCreateDevice failed: {d}\n", .{result});
        return error.VulkanDeviceFailed;
    }

    var graphics_queue: vk.VkQueue = undefined;
    var present_queue: vk.VkQueue = undefined;
    vk.vkGetDeviceQueue(device, graphics_family, 0, &graphics_queue);
    vk.vkGetDeviceQueue(device, present_family, 0, &present_queue);

    return .{
        .handle = device,
        .queues = Queues{
            .graphics = graphics_queue,
            .present = present_queue,
        },
    };
}

pub fn destroy(device: vk.VkDevice) void {
    vk.vkDestroyDevice(device, null);
}
