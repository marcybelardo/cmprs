const std = @import("std");

pub fn compress(data: []const u8) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var map = std.AutoHashMap(u8, usize).init(allocator);
    defer map.deinit();

    for (data) |byte| {
        const entry = try map.getOrPut(byte);
        if (!entry.found_existing) {
            entry.value_ptr.* = 1;
        } else {
            entry.value_ptr.* += 1;
        }
    }

    var mapIter = map.iterator();
    while (mapIter.next()) |entry| {
        std.debug.print("{c}: {}\n", .{ entry.key_ptr.*, entry.value_ptr.* });
    }
}
