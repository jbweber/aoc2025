const std = @import("std");

pub fn main() !void {
    const input1 = @embedFile("input.txt");

    var lines = std.mem.tokenizeScalar(u8, input1, '\n');

    // allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var tiles: std.ArrayList([2]i64) = .empty;
    defer tiles.deinit(allocator);

    while (lines.next()) |line| {
        var tile = std.mem.tokenizeSequence(u8, line, ",");
        try tiles.append(allocator, .{
            try std.fmt.parseInt(i64, tile.next() orelse "0", 10),
            try std.fmt.parseInt(i64, tile.next() orelse "0", 10),
        });
    }

    var maxArea: u64 = 0;

    for (tiles.items, 0..) |tile1, i| {
        for (tiles.items, 0..) |tile2, j| {
            if (i >= j) continue;

            // we're not checking for the area as we know it
            // since a straight line would give area 0 and this is actually counting tiles basically
            // so we add 1 to each dimension to account for the tiles themselves in that direction
            const area = (@abs(tile2[0] - tile1[0]) + 1) * (@abs(tile2[1] - tile1[1]) + 1);
            if (area > maxArea) {
                maxArea = area;
            }
        }
    }

    std.debug.print("Max area: {any}\n", .{maxArea});
}
