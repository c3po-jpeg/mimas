pub const sdl = @cImport({
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_vulkan.h");
});

pub const vk = @cImport({
    @cInclude("vulkan/vulkan.h");
});
