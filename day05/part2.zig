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

    var mergedRanges: std.ArrayList([2]u64) = .empty;
    defer mergedRanges.deinit(allocator);

    while (lines.next()) |line| {
        if (std.mem.indexOf(u8, line, "-")) |_| {
            var parts = std.mem.tokenizeScalar(u8, line, '-');

            const startStr = parts.next() orelse continue;
            const endStr = parts.next() orelse continue;

            const start = std.fmt.parseInt(u64, startStr, 10) catch continue;
            const end = std.fmt.parseInt(u64, endStr, 10) catch continue;
            try ranges.append(allocator, .{ start, end });
        }
    }

    // Sort ranges by start value
    std.mem.sort([2]u64, ranges.items, {}, rangeLessThan);

    var currentRange: ?[2]u64 = null;

    for (ranges.items) |range| {
        if (currentRange == null) {
            currentRange = range;
            continue;
        }

        if (range[0] <= currentRange.?[1]) {
            // Overlapping ranges, merge them
            if (range[1] > currentRange.?[1]) {
                currentRange.?[1] = range[1];
            }
        } else {
            // No overlap, push the current range and start a new one
            try mergedRanges.append(allocator, currentRange.?);
            currentRange = range;
        }
    }

    // Append the last range if exists
    if (currentRange != null) {
        try mergedRanges.append(allocator, currentRange.?);
    }

    var totalIngredients: u64 = 0;
    for (mergedRanges.items) |range| {
        totalIngredients += range[1] - range[0] + 1;
    }
    std.debug.print("Total ingredients: {}\n", .{totalIngredients});
}

fn rangeLessThan(_: void, a: [2]u64, b: [2]u64) bool {
    return a[0] < b[0];
}
