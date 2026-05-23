const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // EXECUTABLE  — the actual game binary
    const exe = b.addExecutable(.{
        .name = "mimas",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
    });

    const os = target.result.os.tag;
    if (os == .windows) {
        // SDL3 LINKING

        exe.root_module.addLibraryPath(b.path("external/SDL3-3.4.8/lib/x64"));
        exe.root_module.addIncludePath(b.path("external/SDL3-3.4.8/include"));
        exe.root_module.linkSystemLibrary("SDL3", .{});
        // INSTALL  — copy the binary to zig-out/bin/
        b.installBinFile("external/SDL3-3.4.8/lib/x64/SDL3.dll", "SDL3.dll");

        exe.root_module.addIncludePath(b.path("external/vulkan-1.4.350.0/Include"));
        exe.root_module.addLibraryPath(b.path("external/vulkan-1.4.350.0/Lib"));
        exe.root_module.linkSystemLibrary("vulkan-1", .{});
    } else if (os == .linux) {
        exe.root_module.linkSystemLibrary("SDL3", .{});
        exe.root_module.linkSystemLibrary("vulkan", .{});
    }

    b.installArtifact(exe);

    // RUN STEP  — `zig build run`
    const run_step = b.step("run", "Run the application");

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    run_step.dependOn(&run_cmd.step);

    // TEST STEP  — `zig build test`
    const exe_test = b.addTest(.{
        .root_module = exe.root_module,
    });

    const run_tests = b.addRunArtifact(exe_test);

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_tests.step);
}
