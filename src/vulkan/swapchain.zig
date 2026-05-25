const std = @import("std");
const vk = @import("../bindings.zig").vk;
const sdl = @import("../bindings.zig").sdl;

pub const Swapchain = struct {
    handle: vk.VkSwapchainKHR,
    images: []vk.VkImage,
    views: []vk.VkImageView,
    format: vk.VkFormat,
    extent: vk.VkExtent2D,
};

pub fn create(
    pd: vk.VkPhysicalDevice,
    device: vk.VkDevice,
    surface: vk.VkSurfaceKHR,
    window: *sdl.SDL_Window,
) !Swapchain {
    var capabilities: vk.VkSurfaceCapabilitiesKHR = undefined;
    _ = vk.vkGetPhysicalDeviceSurfaceCapabilitiesKHR(pd, surface, &capabilities);

    var format_count: u32 = 0;
    _ = vk.vkGetPhysicalDeviceSurfaceFormatsKHR(pd, surface, &format_count, null);
    const formats = try std.heap.page_allocator.alloc(vk.VkSurfaceFormatKHR, format_count);
    defer std.heap.page_allocator.free(formats);
    _ = vk.vkGetPhysicalDeviceSurfaceFormatsKHR(pd, surface, &format_count, formats.ptr);

    var present_mode_count: u32 = 0;
    _ = vk.vkGetPhysicalDeviceSurfacePresentModesKHR(pd, surface, &present_mode_count, null);
    const present_modes = try std.heap.page_allocator.alloc(vk.VkPresentModeKHR, present_mode_count);
    defer std.heap.page_allocator.free(present_modes);
    _ = vk.vkGetPhysicalDeviceSurfacePresentModesKHR(pd, surface, &present_mode_count, present_modes.ptr);

    const surface_format = choose_surface_format(formats);
    const present_mode = choose_present_mode(present_modes);
    const swap_extent = choose_swap_extent(capabilities, window);

    std.debug.print("Surface format: {s}\n", .{format_name(surface_format.format)});
    std.debug.print("Present mode: {s}\n", .{present_mode_name(present_mode)});
    std.debug.print("Swap extent: {d}x{d}\n", .{ swap_extent.width, swap_extent.height });

    const create_info: vk.VkSwapchainCreateInfoKHR = .{
        .sType = vk.VK_STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO_KHR,
        .surface = surface,
        .minImageCount = capabilities.minImageCount + 1,
        .imageFormat = surface_format.format,
        .imageColorSpace = surface_format.colorSpace,
        .imageExtent = swap_extent,
        .imageArrayLayers = 1,
        .imageUsage = vk.VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT,
        .preTransform = capabilities.currentTransform,
        .compositeAlpha = vk.VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR,
        .presentMode = present_mode,
        .clipped = 1, // true
    };

    var swapchain: vk.VkSwapchainKHR = undefined;
    const result = vk.vkCreateSwapchainKHR(device, &create_info, null, &swapchain);
    if (result != vk.VK_SUCCESS) {
        std.debug.print("vkCreateSwapchainKHR failed: {d}\n", .{result});
        return error.SwapchainCreationFailed;
    }

    var image_count: u32 = 0;
    _ = vk.vkGetSwapchainImagesKHR(device, swapchain, &image_count, null);
    const images = try std.heap.page_allocator.alloc(vk.VkImage, image_count);
    _ = vk.vkGetSwapchainImagesKHR(device, swapchain, &image_count, images.ptr);

    const views = try create_views(device, images, surface_format.format);

    return .{
        .handle = swapchain,
        .images = images,
        .views = views,
        .format = surface_format.format,
        .extent = swap_extent,
    };
}

pub fn destroy(
    device: vk.VkDevice,
    swapchain: Swapchain,
) void {
    for (swapchain.views) |view| {
        vk.vkDestroyImageView(device, view, null);
    }
    std.heap.page_allocator.free(swapchain.views);
    std.heap.page_allocator.free(swapchain.images);

    vk.vkDestroySwapchainKHR(device, swapchain.handle, null);
}

fn create_views(
    device: vk.VkDevice,
    images: []vk.VkImage,
    format: vk.VkFormat,
) ![]vk.VkImageView {
    var views = try std.heap.page_allocator.alloc(vk.VkImageView, images.len);

    for (images, 0..) |image, i| {
        const create_info = vk.VkImageViewCreateInfo{
            .sType = vk.VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO,
            .image = image,
            .viewType = vk.VK_IMAGE_VIEW_TYPE_2D,
            .format = format,
            .components = .{
                .r = vk.VK_COMPONENT_SWIZZLE_IDENTITY,
                .g = vk.VK_COMPONENT_SWIZZLE_IDENTITY,
                .b = vk.VK_COMPONENT_SWIZZLE_IDENTITY,
                .a = vk.VK_COMPONENT_SWIZZLE_IDENTITY,
            },
            .subresourceRange = .{
                .aspectMask = vk.VK_IMAGE_ASPECT_COLOR_BIT,
                .baseMipLevel = 0,
                .levelCount = 1,
                .baseArrayLayer = 0,
                .layerCount = 1,
            },
        };

        var view: vk.VkImageView = undefined;
        const result = vk.vkCreateImageView(device, &create_info, null, &view);
        if (result != vk.VK_SUCCESS) {
            std.debug.print("vkCreateImageView failed: {d}\n", .{result});
            return error.ImageViewCreationFailed;
        }

        views[i] = view;
    }

    return views;
}

fn choose_surface_format(
    formats: []vk.VkSurfaceFormatKHR,
) vk.VkSurfaceFormatKHR {
    for (formats) |format| {
        if (format.format == vk.VK_FORMAT_B8G8R8A8_SRGB and format.colorSpace == vk.VK_COLOR_SPACE_SRGB_NONLINEAR_KHR) {
            return format;
        }
    }

    return formats[0];
}

fn choose_present_mode(
    present_modes: []vk.VkPresentModeKHR,
) vk.VkPresentModeKHR {
    for (present_modes) |mode| {
        if (mode == vk.VK_PRESENT_MODE_MAILBOX_KHR) {
            return mode;
        }
    }

    return vk.VK_PRESENT_MODE_FIFO_KHR;
}

fn choose_swap_extent(
    capabilities: vk.VkSurfaceCapabilitiesKHR,
    window: *sdl.SDL_Window,
) vk.VkExtent2D {
    if (capabilities.currentExtent.width != std.math.maxInt(u32)) {
        return capabilities.currentExtent;
    } else {
        var width: i32 = 0;
        var height: i32 = 0;
        _ = sdl.SDL_GetWindowSize(window, &width, &height);

        var actual_extent = vk.VkExtent2D{
            .width = @intCast(@max(width, 1)),
            .height = @intCast(@max(height, 1)),
        };

        actual_extent.width = std.math.clamp(
            actual_extent.width,
            capabilities.minImageExtent.width,
            capabilities.maxImageExtent.width,
        );
        actual_extent.height = std.math.clamp(
            actual_extent.height,
            capabilities.minImageExtent.height,
            capabilities.maxImageExtent.height,
        );

        return actual_extent;
    }
}

fn format_name(format: vk.VkFormat) []const u8 {
    return switch (format) {
        vk.VK_FORMAT_B8G8R8A8_SRGB => "B8G8R8A8_SRGB",
        vk.VK_FORMAT_R8G8B8A8_SRGB => "R8G8B8A8_SRGB",
        vk.VK_FORMAT_B8G8R8A8_UNORM => "B8G8R8A8_UNORM",
        vk.VK_FORMAT_R8G8B8A8_UNORM => "R8G8B8A8_UNORM",
        else => "Unknown format",
    };
}

fn present_mode_name(mode: vk.VkPresentModeKHR) []const u8 {
    return switch (mode) {
        vk.VK_PRESENT_MODE_IMMEDIATE_KHR => "IMMEDIATE",
        vk.VK_PRESENT_MODE_MAILBOX_KHR => "MAILBOX",
        vk.VK_PRESENT_MODE_FIFO_KHR => "FIFO",
        vk.VK_PRESENT_MODE_FIFO_RELAXED_KHR => "FIFO_RELAXED",
        else => "Unknown present mode",
    };
}
