const std = @import("std");

pub fn main() !void {
    const input1 = @embedFile("input.txt");

    var lines = std.mem.tokenizeScalar(u8, input1, '\n');

    var sum: u32 = 0;

    while (lines.next()) |line| {
        const result = largestJoltage(line);
        sum += @as(u32, result);
    }

    std.debug.print("Sum of largest joltages: {}\n", .{sum});
}

fn largestJoltage(digits: []const u8) u8 {
    var maxJoltage: u8 = 0;

    // Check all pairs where i < j
    for (0..digits.len) |i| {
        for (i + 1..digits.len) |j| {
            const tens = digits[i] - '0';
            const ones = digits[j] - '0';
            const joltage = tens * 10 + ones;
            maxJoltage = @max(maxJoltage, joltage);
        }
    }

    return maxJoltage;
}
