const std = @import("std");
const cmprs = @import("cmprs");

var PROGRAM_NAME: []const u8 = undefined;

const USAGE_FMT =
    \\Usage: {s} [option...] [file...]
    \\
    \\  -z, --compress    Force compression
    \\  -d, --decompress  Force decompression
    \\
    \\Arguments:
    \\  FILENAME          The file to be encoded/decoded
    \\
    \\
;

const CliArgs = struct {
    filePath: []const u8 = undefined,
    compress: bool = true,
};

fn displayUsage() void {
    std.debug.print(USAGE_FMT, .{PROGRAM_NAME});
}

const ArgParseError = error{ MissingArgs, InvalidArgs };

fn parseArgs(argv: [][:0]u8) ArgParseError!CliArgs {
    PROGRAM_NAME = std.fs.path.basename(argv[0]);
    var args = CliArgs{};

    var optind: usize = 1;
    while (optind < argv.len and argv[optind][0] == '-') {
        if (std.mem.eql(u8, argv[optind], "--compress") or
            std.mem.eql(u8, argv[optind], "-z")) {
            args.compress = true;
        } else if (std.mem.eql(u8, argv[optind], "--decompress") or
                    std.mem.eql(u8, argv[optind], "-d")) {
            args.compress = false;
        } else {
            displayUsage();
            std.debug.print("Unknown option: {s}\n", .{argv[optind]});
            return error.InvalidArgs;
        }
        optind += 1;
    }

    if (argv.len - optind < 1) {
        displayUsage();
        return error.MissingArgs;
    }

    args.filePath = argv[optind];
    optind += 1;

    if (argv.len - optind > 0) {
        displayUsage();
        return error.InvalidArgs;
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
    std.debug.print("Compress: {}\n", .{args.compress});

    const file = std.fs.cwd().openFile(args.filePath, .{}) catch |err| {
        std.log.err("Failed to open file: {s}", .{@errorName(err)});
        return 1;
    };
    defer file.close();
    const file_stat = try file.stat();
    const file_contents = try file.readToEndAlloc(allocator, file_stat.size);
    defer allocator.free(file_contents);

    if (args.compress) {
        cmprs.compress(file_contents) catch |err| {
            std.log.err("Error compressing file: {s}\n", .{@errorName(err)});
            return 1;
        };
    }

    return 0;
}
