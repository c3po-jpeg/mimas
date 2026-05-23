const std = @import("std");
const vk = @import("../bindings.zig").vk;

pub const QueueFamilyIndices = struct {
    graphics: ?u32 = null,
    present: ?u32 = null,

    pub fn is_complete(self: QueueFamilyIndices) bool {
        return self.graphics != null and self.present != null;
    }
};

const required_device_extenions = [_][*:0]const u8{
    vk.VK_KHR_SWAPCHAIN_EXTENSION_NAME,
};

pub fn pick(
    allocator: std.mem.Allocator,
    instance: vk.VkInstance,
    surface: vk.VkSurfaceKHR,
) !struct { device: vk.VkPhysicalDevice, indices: QueueFamilyIndices } {
    var count: u32 = 0;
    _ = vk.vkEnumeratePhysicalDevices(instance, &count, null);
    if (count == 0) {
        std.debug.print("Failed to find GPUs with Vulkan support!\n", .{});
        return error.NoVulkanSupport;
    }

    const devices = try allocator.alloc(vk.VkPhysicalDevice, count);
    defer allocator.free(devices);
    _ = vk.vkEnumeratePhysicalDevices(instance, &count, devices.ptr);

    var best_score: i32 = -1;
    var best_device = devices[0];
    var best_indices = QueueFamilyIndices{};

    for (devices) |device| {
        const indices = find_queue_families(allocator, device, surface) catch continue;
        if (!indices.is_complete()) continue;
        if (!supports_extensions(device) catch continue) continue;

        const score = score_device(device);

        if (score > best_score) {
            best_score = score;
            best_device = device;
            best_indices = indices;
        }
    }

    if (best_score == -1) return error.NoSuitableGPU;

    var props: vk.VkPhysicalDeviceProperties = undefined;
    vk.vkGetPhysicalDeviceProperties(best_device, &props);
    std.debug.print("GPU selected: {s}\n", .{@as([*:0]const u8, &props.deviceName)});

    return .{ .device = best_device, .indices = best_indices };
}

fn score_device(device: vk.VkPhysicalDevice) i32 {
    var props: vk.VkPhysicalDeviceProperties = undefined;
    vk.vkGetPhysicalDeviceProperties(device, &props);

    return switch (props.deviceType) {
        vk.VK_PHYSICAL_DEVICE_TYPE_DISCRETE_GPU => 1000,
        vk.VK_PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU => 100,
        vk.VK_PHYSICAL_DEVICE_TYPE_VIRTUAL_GPU => 10,
        vk.VK_PHYSICAL_DEVICE_TYPE_CPU => 1,
        else => 0,
    };
}

pub fn find_queue_families(
    allocator: std.mem.Allocator,
    device: vk.VkPhysicalDevice,
    surface: vk.VkSurfaceKHR,
) !QueueFamilyIndices {
    var indices = QueueFamilyIndices{};

    var count: u32 = 0;
    vk.vkGetPhysicalDeviceQueueFamilyProperties(device, &count, null);

    const families = try allocator.alloc(vk.VkQueueFamilyProperties, count);
    defer allocator.free(families);
    vk.vkGetPhysicalDeviceQueueFamilyProperties(device, &count, families.ptr);

    for (families, 0..) |family, i| {
        const idx: u32 = @intCast(i);

        if (family.queueFlags & vk.VK_QUEUE_GRAPHICS_BIT != 0) {
            indices.graphics = idx;
        }

        var present_support: u32 = 0;
        _ = vk.vkGetPhysicalDeviceSurfaceSupportKHR(device, idx, surface, &present_support);
        if (present_support != 0) {
            indices.present = idx;
        }

        if (indices.is_complete()) break;
    }

    return indices;
}

fn supports_extensions(allocator: std.mem.Allocator, device: vk.VkPhysicalDevice) !bool {
    var ext_count: u32 = 0;
    _ = vk.vkEnumerateDeviceExtensionProperties(device, null, &ext_count, null);

    const extensions = try allocator.alloc(vk.VkExtensionProperties, ext_count);
    defer allocator.free(extensions);
    _ = vk.vkEnumerateDeviceExtensionProperties(device, null, &ext_count, extensions.ptr);

    for (required_device_extenions) |req| {
        var found = false;
        for (extensions) |ext| {
            const ext_name = std.mem.sliceTo(&ext.extensionName, 0);
            const req_name = std.mem.sliceTo(req, 0);
            if (std.mem.eql(u8, ext_name, req_name)) {
                found = true;
                break;
            }
        }
        if (!found) return false;
    }

    return true;
}
