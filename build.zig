const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const exe = b.addExecutable(.{ 
        .name = "blunt", 
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/" ++ "main" ++ ".zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    const run = b.step("run", "Run blunt");
    run.dependOn(&b.addRunArtifact(exe).step);
}
