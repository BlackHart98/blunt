const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const exe = b.addExecutable(.{ .name = "blunt", .root_source_file = b.path("src/main.zig"), .target = target, .optimize = optimize });
    const run = b.step("run", "Run blunt.exe");
    run.dependOn(&b.addRunArtifact(exe).step);
}
