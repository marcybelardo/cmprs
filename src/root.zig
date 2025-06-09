const std = @import("std");

pub fn encode(T: type, src: []const u8) !T {
    _ = src;
    std.debug.print("TODO: encode file\n", .{});
    return undefined;
}
