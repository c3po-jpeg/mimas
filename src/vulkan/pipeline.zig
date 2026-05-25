const std = @import("std");
const vk = @import("../bindings.zig").vk;

pub const PipelineBuilder = struct {
    shader_stages: []const vk.VkPipelineShaderStageCreateInfo = &.{},
    vertex_binding: ?vk.VkVertexInputBindingDescription = null,
    vertex_attributes: []const vk.VkVertexInputAttributeDescription = &.{},
    topology: vk.VkPrimitiveTopology = vk.VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST,
    polygon_mode: vk.VkPolygonMode = vk.VK_POLYGON_MODE_FILL,
    cull_mode: vk.VkCullModeFlags = vk.VK_CULL_MODE_BACK_BIT,
    depth_test: bool = false,
    depth_write: bool = false,
    blend_enable: bool = false,

    pub fn build(
        self: PipelineBuilder,
        device: vk.VkDevice,
        render_pass: vk.VkRenderPass,
    ) !vk.VkPipeline {}
};
