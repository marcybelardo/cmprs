const std = @import("std");
const cmprs = @import("cmprs");

var PROGRAM_NAME: []const u8 = undefined;

const USAGE_FMT =
    \\Usage: {s} FILENAME [--encode/--decode]
    \\
    \\Options:
    \\  --encode, -E    Encode the file
    \\  --decode, -D    Decode the file
    \\
    \\Arguments:
    \\  FILENAME        The file to be encoded/decoded
    \\
    \\
;

const CliArgs = struct {
    filePath: []const u8 = undefined,
    encode: bool = false,
    decode: bool = false,
};

fn display_usage() void {
    std.debug.print(USAGE_FMT, .{PROGRAM_NAME});
}

const ArgParseError = error{ MissingArgs, InvalidArgs };

fn parseArgs(argv: [][:0]u8) ArgParseError!CliArgs {
    PROGRAM_NAME = std.fs.path.basename(argv[0]);
    var args = CliArgs{};

    var optind: usize = 1;
    if (argv.len - optind < 2) {
        display_usage();
        return error.MissingArgs;
    }
    args.filePath = argv[optind];
    optind += 1;

    while (optind < argv.len and argv[optind][0] == '-') {
        if (std.mem.eql(u8, argv[optind], "--encode") or
            std.mem.eql(u8, argv[optind], "-E")) {
            args.encode = true;
        } else if (std.mem.eql(u8, argv[optind], "--decode") or
                    std.mem.eql(u8, argv[optind], "-D")) {
            if (args.encode) {
                display_usage();
                std.debug.print("Choose either encode or decode\n", .{});
                return error.InvalidArgs;
            }

            args.decode = true;
        }
        optind += 1;
    }

    return args;
}

pub fn main() !u8 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const argv = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, argv);

    const args = parseArgs(argv) catch {
        return 1;
    };

    std.debug.print("Path: {s}\n", .{args.filePath});
    std.debug.print("Encode: {}\n", .{args.encode});
    std.debug.print("Decode: {}\n", .{args.decode});

    return 0;
}
