const std = @import("std");
const vk = @import("../bindings.zig").vk;

pub fn load(
    io: std.Io,
    device: vk.VkDevice,
    allocator: std.mem.Allocator,
    path: []const u8,
) !vk.VkShaderModule {
    var file = try std.Io.Dir.cwd().openFile(io, path, .{});
    defer file.close(io);

    var reader = file.reader(io, &.{});
    const spv = try reader.interface.allocRemaining(
        allocator,
        .unlimited,
    );
    defer allocator.free(spv);

    const code: [*]const u32 = @ptrCast(@alignCast(spv.ptr));

    const create_info = vk.VkShaderModuleCreateInfo{
        .sType = vk.VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO,
        .pNext = null,
        .flags = 0,
        .codeSize = spv.len,
        .pCode = code,
    };

    var module: vk.VkShaderModule = undefined;

    const result = vk.vkCreateShaderModule(
        device,
        &create_info,
        null,
        &module,
    );

    if (result != vk.VK_SUCCESS) {
        return error.VulkanShaderModuleFailed;
    }

    return module;
}

pub fn destroy(device: vk.VkDevice, module: vk.VkShaderModule) void {
    vk.vkDestroyShaderModule(device, module, null);
}
