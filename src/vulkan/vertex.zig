const std = @import("std");
const vk = @import("../bindings.zig").vk;

pub const Vertex3D = struct {
    pos: [3]f32,
    col: [3]f32,

    pub fn get_binding_description() vk.VkVertexInputBindingDescription {
        return vk.VkVertexInputBindingDescription{
            .binding = 0,
            .stride = @sizeOf(Vertex3D),
            .inputRate = vk.VK_VERTEX_INPUT_RATE_VERTEX,
        };
    }

    pub fn get_attribute_descriptions() [2]vk.VkVertexInputAttributeDescription {
        return .{
            .{
                .binding = 0,
                .location = 0,
                .format = vk.VK_FORMAT_R32G32_SFLOAT,
                .offset = @offsetOf(Vertex3D, "pos"),
            },
            .{
                .binding = 0,
                .location = 1,
                .format = vk.VK_FORMAT_R32G32B32_SFLOAT,
                .offset = @offsetOf(Vertex3D, "col"),
            },
        };
    }
};
