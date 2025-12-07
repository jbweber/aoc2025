const std = @import("std");

pub fn main() !void {
    const input1 = @embedFile("input.txt");

    var lines = std.mem.tokenizeScalar(u8, input1, '\n');

    var sum: u64 = 0;

    while (lines.next()) |line| {
        const result = largestJoltage(line);
        sum += result;
    }

    std.debug.print("Sum of largest joltages: {}\n", .{sum});
}

fn largestJoltage(digits: []const u8) u64 {
    var result: u64 = 0;
    var start: usize = 0;

    for (0..12) |outPos| {
        // how many digits are left to pick
        const remainingToPick = 12 - outPos;
        // limit for the search. We need to leave enough digits for the remaining picks
        const end = digits.len - remainingToPick;

        // greatest digit in digits[start..end]
        var bestIdx = start;
        for (start..end) |i| {
            if (digits[i] > digits[bestIdx]) {
                bestIdx = i;
            }
        }

        // append best digit to result
        result = result * 10 + (digits[bestIdx] - '0');
        start = bestIdx + 1;
    }

    return result;
}
