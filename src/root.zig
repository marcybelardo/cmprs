const std = @import("std");

pub fn compress(data: []const u8) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var char_freqs = std.AutoArrayHashMap(u8, usize).init(allocator);
    defer char_freqs.deinit();

    for (data) |byte| {
        const entry = try char_freqs.getOrPut(byte);
        if (!entry.found_existing) {
            entry.value_ptr.* = 1;
        } else {
            entry.value_ptr.* += 1;
        }
    }

    const char_vals = CharFrequencies {
        .values = char_freqs.values(),
    };
    char_freqs.sort(char_vals);

    var char_iter = char_freqs.iterator();
    while (char_iter.next()) |entry| {
        std.debug.print("{c}: {}\n", .{ entry.key_ptr.*, entry.value_ptr.* });
    }
}

const CharFrequencies = struct {
    values: []usize,

    pub fn lessThan(self: CharFrequencies, a_index: usize, b_index: usize) bool {
        return self.values[a_index] < self.values[b_index];
    }
};
