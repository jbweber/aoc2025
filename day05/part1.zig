const std = @import("std");

pub fn main() !void {
    const input1 = @embedFile("input.txt");

    var lines = std.mem.tokenizeScalar(u8, input1, '\n');

    // allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var ranges: std.ArrayList([2]u64) = .empty;
    defer ranges.deinit(allocator);

    var ingredients: std.ArrayList(u64) = .empty;
    defer ingredients.deinit(allocator);

    while (lines.next()) |line| {
        if (std.mem.indexOf(u8, line, "-")) |_| {
            var parts = std.mem.tokenizeScalar(u8, line, '-');

            const startStr = parts.next() orelse continue;
            const endStr = parts.next() orelse continue;

            const start = std.fmt.parseInt(u64, startStr, 10) catch continue;
            const end = std.fmt.parseInt(u64, endStr, 10) catch continue;
            try ranges.append(allocator, .{ start, end });
        } else {
            const num = std.fmt.parseInt(u64, line, 10) catch continue;
            try ingredients.append(allocator, num);
        }
    }

    var validCount: usize = 0;
    for (ingredients.items) |ingredient| {
        for (ranges.items) |range| {
            if (inRange(ingredient, range)) {
                validCount += 1;
                break;
            }
        }
    }

    std.debug.print("Valid Count: {d}\n", .{validCount});
}

fn inRange(value: u64, range: [2]u64) bool {
    return value >= range[0] and value <= range[1];
}
