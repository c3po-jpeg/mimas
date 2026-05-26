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
        layout: vk.VkPipelineLayout,
        extent: vk.VkExtent2D,
    ) !vk.VkPipeline {
        const vertex_input = vk.VkPipelineVertexInputStateCreateInfo{
            .sType = vk.VK_STRUCTURE_TYPE_PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO,
            .pNext = null,
            .flags = 0,
            .vertexBindingDescriptionCount = if (self.vertex_binding) 1 else 0,
            .pVertexBindingDescriptions = if (self.vertex_binding) &self.vertex_binding.? else null,
            .vertexAttributeDescriptionCount = @intCast(self.vertex_attributes.len),
            .pVertexAttributeDescriptions = self.vertex_attributes.ptr,
        };

        const input_assembly = vk.VkPipelineInputAssemblyStateCreateInfo{
            .sType = vk.VK_STRUCTURE_TYPE_PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO,
            .pNext = null,
            .flags = 0,
            .topology = self.topology,
            .primitiveRestartEnable = vk.VK_FALSE,
        };

        const viewport = vk.VkViewport{
            .x = 0,
            .y = 0,
            .width = @floatFromInt(extent.width),
            .height = @floatFromInt(extent.height),
            .minDepth = 0,
            .maxDepth = 1,
        };

        const scissor = vk.VkRect2D{
            .offset = vk.VkOffset2D{ .x = 0, .y = 0 },
            .extent = extent,
        };

        const viewport_state = vk.VkPipelineViewportStateCreateInfo{
            .sType = vk.VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_STATE_CREATE_INFO,
            .pNext = null,
            .flags = 0,
            .viewportCount = 1,
            .pViewports = &viewport,
            .scissorCount = 1,
            .pScissors = &scissor,
        };

        const rasterizer = vk.VkPipelineRasterizationStateCreateInfo{
            .sType = vk.VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_STATE_CREATE_INFO,
            .pNext = null,
            .flags = 0,
            .depthClampEnable = vk.VK_FALSE,
            .rasterizerDiscardEnable = vk.VK_FALSE,
            .polygonMode = self.polygon_mode,
            .cullMode = self.cull_mode,
            .frontFace = vk.VK_FRONT_FACE_CLOCKWISE,
            .depthBiasEnable = vk.VK_FALSE,
        };

        const multisampling = vk.VkPipelineMultisampleStateCreateInfo{
            .sType = vk.VK_STRUCTURE_TYPE_PIPELINE_MULTISAMPLE_STATE_CREATE_INFO,
            .pNext = null,
            .flags = 0,
            .rasterizationSamples = vk.VK_SAMPLE_COUNT_1_BIT,
            .sampleShadingEnable = vk.VK_FALSE,
        };

        const depth_stencil = vk.VkPipelineDepthStencilStateCreateInfo{
            .sType = vk.VK_STRUCTURE_TYPE_PIPELINE_DEPTH_STENCIL_STATE_CREATE_INFO,
            .pNext = null,
            .flags = 0,
            .depthTestEnable = if (self.depth_test) vk.VK_TRUE else vk.VK_FALSE,
            .depthWriteEnable = if (self.depth_write) vk.VK_TRUE else vk.VK_FALSE,
            .depthCompareOp = vk.VK_COMPARE_OP_LESS,
            .depthBoundsTestEnable = vk.VK_FALSE,
            .stencilTestEnable = vk.VK_FALSE,
        };

        const color_blend_attachment = vk.VkPipelineColorBlendAttachmentState{
            .blendEnable = if (self.blend_enable) vk.VK_TRUE else vk.VK_FALSE,
            .srcColorBlendFactor = vk.VK_BLEND_FACTOR_SRC_ALPHA,
            .dstColorBlendFactor = vk.VK_BLEND_FACTOR_ONE_MINUS_SRC_ALPHA,
            .colorBlendOp = vk.VK_BLEND_OP_ADD,
            .srcAlphaBlendFactor = vk.VK_BLEND_FACTOR_ONE,
            .dstAlphaBlendFactor = vk.VK_BLEND_FACTOR_ZERO,
            .alphaBlendOp = vk.VK_BLEND_OP_ADD,
            .colorWriteMask = vk.VK_COLOR_COMPONENT_R_BIT |
                vk.VK_COLOR_COMPONENT_G_BIT |
                vk.VK_COLOR_COMPONENT_B_BIT |
                vk.VK_COLOR_COMPONENT_A_BIT,
        };

        const color_blending = vk.VkPipelineColorBlendStateCreateInfo{
            .sType = vk.VK_STRUCTURE_TYPE_PIPELINE_COLOR_BLEND_STATE_CREATE_INFO,
            .pNext = null,
            .flags = 0,
            .logicOpEnable = vk.VK_FALSE,
            .attachmentCount = 1,
            .pAttachments = &color_blend_attachment,
        };

        const pipeline_info = vk.VkGraphicsPipelineCreateInfo{
            .sType = vk.VK_STRUCTURE_TYPE_GRAPHICS_PIPELINE_CREATE_INFO,
            .pNext = null,
            .flags = 0,
            .stageCount = @intCast(self.shader_stages.len),
            .pStages = self.shader_stages.ptr,
            .pVertexInputState = &vertex_input,
            .pInputAssemblyState = &input_assembly,
            .pViewportState = &viewport_state,
            .pRasterizationState = &rasterizer,
            .pMultisampleState = &multisampling,
            .pDepthStencilState = &depth_stencil,
            .pColorBlendState = &color_blending,
            .layout = layout,
            .renderPass = render_pass,
            .subpass = 0,
        };

        var pipeline: vk.VkPipeline = undefined;
        const result = vk.vkCreateGraphicsPipelines(device, vk.VK_NULL_HANDLE, 1, &pipeline_info, null, &pipeline);
        if (result != vk.VK_SUCCESS) {
            std.debug.print("vkCreateGraphicsPipelines failed: {d}\n", .{
                result,
            });
            return error.VulkanPipelineFailed;
        }

        return pipeline;
    }
};

pub fn create_layout(device: vk.VkDevice) !vk.VkPipelineLayout {
    const create_info = vk.VkPipelineLayoutCreateInfo{
        .sType = vk.VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO,
        .pNext = null,
        .flags = 0,
        .setLayoutCount = 0,
        .pSetLayouts = null,
        .pushConstantRangeCount = 0,
        .pPushConstantRanges = null,
    };

    var layout: vk.VkPipelineLayout = undefined;
    const result = vk.vkCreatePipelineLayout(device, &create_info, null, &layout);
    if (result != vk.VK_SUCCESS) {
        std.debug.print("vkCreatePipelineLayout failed: {d}\n", .{result});
        return error.VulkanPipelineLayoutFailed;
    }

    return layout;
}

pub fn destroy(device: vk.VkDevice, pipeline: vk.VkPipeline) void {
    vk.vkDestroyPipeline(device, pipeline, null);
}

pub fn destroy_layout(device: vk.VkDevice, layout: vk.VkPipelineLayout) void {
    vk.vkDestroyPipelineLayout(device, layout, null);
}

pub fn render_pipeline(
    device: vk.VkDevice,
    render_pass: vk.VkRenderPass,
    layout: vk.VkPipelineLayout,
    extent: vk.VkExtent2D,
) !vk.VkPipeline {
    const vert_shader = try shader.load(
        std.Io,
        device,
        std.heap.page_allocator,
        "../zig-out/shaders/vert.spv",
    );
    defer shader.destroy(device, vert_shader);

    const frag_shader = try shader.load(
        std.Io,
        device,
        std.heap.page_allocator,
        "../zig-out/shaders/frag.spv",
    );
    defer shader.destroy(device, frag_shader);

    const stages = shader_stages(vert_shader, frag_shader);

    const builder = PipelineBuilder{
        .shader_stages = stages,
        .depth_test = true,
        .depth_write = true,
        .cull_mode = vk.VK_CULL_MODE_BACK_BIT,
        .vertex_binding = Vertex3D.get_binding_description(),
        .vertex_attributes = Vertex3D.get_attribute_descriptions(),
    };

    return builder.build(device, render_pass, layout, extent);
}

fn shader_stages(vert: vk.VkShaderModule, frag: vk.VkShaderModule) [2]vk.VkPipelineShaderStageCreateInfo {
    return .{
        .{
            .sType = vk.VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO,
            .pNext = null,
            .flags = 0,
            .stage = vk.VK_SHADER_STAGE_VERTEX_BIT,
            .module = vert,
            .pName = "main",
            .pSpecializationInfo = null,
        },
        .{
            .sType = vk.VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO,
            .pNext = null,
            .flags = 0,
            .stage = vk.VK_SHADER_STAGE_FRAGMENT_BIT,
            .module = frag,
            .pName = "main",
            .pSpecializationInfo = null,
        },
    };
}

const shader = @import("shader.zig");
const Vertex3D = @import("vertex.zig").Vertex3D;
