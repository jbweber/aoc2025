const std = @import("std");

// this is a super brute force solution
// but it works for the input size we have
//
// invalid number is now at least two repetitions of the same digits
// e.g. 1212 is invalid, but 1234 is valid
// so find all patterns that divide evenly
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

    // Try every possible pattern length that divides evenly
    for (1..len) |patternLen| {
        if (len % patternLen != 0) continue;

        // if the pattern size repeats less than twice, skip
        const repetitions = len / patternLen;
        if (repetitions < 2) continue;

        const pattern = str[0..patternLen];

        // check through all the repetitions for the size to see if we have a match
        var haveMatch = true;
        for (1..repetitions) |i| {
            const start = i * patternLen;
            const chunk = str[start .. start + patternLen];
            // quit early if we don't match because we only need one mismatch to fail on the size
            if (!std.mem.eql(u8, pattern, chunk)) {
                haveMatch = false;
                break;
            }
        }

        if (haveMatch) return true;
    }

    return false;
}
