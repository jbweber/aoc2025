const std = @import("std");

// this is a super brute force solution
// but it works for the input size we have
//
// invalid number can only have even number of digits
// and first half must equal second half
pub fn main() !void {
    const input1 = @embedFile("input.txt");

    var ranges = std.mem.splitScalar(u8, input1, ',');

    var result: u64 = 0;

    while (ranges.next()) |range| {
        var parts = std.mem.splitScalar(u8, range, '-');
        const startStr = parts.next() orelse continue;
        const endStr = parts.next() orelse continue;
        const start = try std.fmt.parseInt(u64, startStr, 10);
        const end = try std.fmt.parseInt(u64, endStr, 10);

        var n = start;
        while (n <= end) : (n += 1) {
            if (isInvalid(n)) {
                result += n;
            }
        }
    }
    std.debug.print("Result: {d}\n", .{result});
}

fn isInvalid(n: u64) bool {
    // u64 at most 20 digits
    // convert to string. zig is strict about allocations so we do this ourselves
    var buf: [20]u8 = undefined;
    const str = std.fmt.bufPrint(&buf, "{d}", .{n}) catch return false;
    const len = str.len;

    if (len % 2 != 0) return false;

    const half = len / 2;
    return std.mem.eql(u8, str[0..half], str[half..len]);
}
