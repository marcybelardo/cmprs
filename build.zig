const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const mod = b.addModule("cmprs", .{
        .root_source_file = b.path("src/root.zig"),
    });

    const exe = b.addExecutable(.{
        .name = "cmprs",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .imports = &.{
                .{ .name = "cmprs", .module = mod },
            },
            .target = target,
            .optimize = optimize,
        }),
    });

    b.installArtifact(exe);
}
