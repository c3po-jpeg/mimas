const std = @import("std");
const vk = @import("vulkan");
const Swapchain = @import("swapchain.zig").Swapchain;

// create swapchain framebuffers for each swapchain image
pub fn create(
    device: vk.VkDevice,
    render_pass: vk.VkRenderPass,
    swapchain: *Swapchain,
) ![]vk.VkFramebuffer {
    var framebuffers = try std.heap.page_allocator.alloc(vk.VkFramebuffer, swapchain.images.len);

    for (swapchain.images, 0..) |image, i| {
        const attachments = &image;

        const framebuffer_info = vk.VkFramebufferCreateInfo{
            .sType = vk.VK_STRUCTURE_TYPE_FRAMEBUFFER_CREATE_INFO,
            .renderPass = render_pass,
            .attachmentCount = 1,
            .pAttachments = attachments,
            .width = swapchain.extent.width,
            .height = swapchain.extent.height,
            .layers = 1,
        };

        var framebuffer: vk.VkFramebuffer = undefined;
        const result = vk.vkCreateFramebuffer(device, &framebuffer_info, null, &framebuffer);
        if (result != vk.VK_SUCCESS) {
            return error.CreateFramebufferFailed;
        }
        framebuffers[i] = framebuffer;
    }

    return framebuffers;
}
