const std = @import("std");
const vk = @import("../bindings.zig").vk;

// bug in zig 0.16.0 cause a strange error
// will come back to this later, but for now just leave the shader loading code here and use @embededFile for the shader code in pipeline.zig
pub fn shader_loader(
    io: std.Io,
    device: vk.VkDevice,
    allocator: std.mem.Allocator,
    path: []const u8,
) !vk.VkShaderModule {
    const bytes = try std.Io.Dir.cwd().readFileAlloc(io, path, allocator, .unlimited);
    defer allocator.free(bytes);

    const code: [*]const u32 = @ptrCast(@alignCast(bytes));

    const create_info = vk.VkShaderModuleCreateInfo{
        .sType = vk.VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO,
        .pNext = null,
        .flags = 0,
        .codeSize = bytes.len,
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

pub fn load(
    device: vk.VkDevice,
    comptime spv_bytes: []const u8,
) !vk.VkShaderModule {
    const create_info = vk.VkShaderModuleCreateInfo{
        .sType = vk.VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO,
        .pNext = null,
        .flags = 0,
        .codeSize = spv_bytes.len,
        .pCode = @ptrCast(@alignCast(spv_bytes.ptr)),
    };
    var module: vk.VkShaderModule = undefined;
    const result = vk.vkCreateShaderModule(device, &create_info, null, &module);
    if (result != vk.VK_SUCCESS) return error.VulkanShaderModuleFailed;
    return module;
}

pub fn destroy(device: vk.VkDevice, module: vk.VkShaderModule) void {
    vk.vkDestroyShaderModule(device, module, null);
}
