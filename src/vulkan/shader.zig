const std = @import("std");
const vk = @import("../bindings.zig").vk;

pub fn load(
    device: vk.VkDevice,
    allocator: std.mem.Allocator,
    path: []const u8,
) !vk.VkShaderModule {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    const spv = try file.readT(allocator, std.math.maxInt(usize));
    defer allocator.free(spv);

    const code: [*]const u32 = @ptrCast(@alignCast(spv.ptr));

    const create_info = vk.VkShaderModuleCreateInfo{
        .sType = vk.VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO,
        .pNext = null,
        .flags = 0,
        .codeSize = @intCast(spv.len),
        .pCode = code,
    };

    var module: vk.VkShaderModule = undefined;
    const result = vk.vkCreateShaderModule(device, &create_info, null, &module);
    if (result != vk.VK_SUCCESS) {
        std.debug.print("vkCreateShaderModule failed: {d}\n", .{result});
        return error.VulkanShaderModuleFailed;
    }

    return module;
}

pub fn destroy(device: vk.VkDevice, module: vk.VkShaderModule) void {
    vk.vkDestroyShaderModule(device, module, null);
}
