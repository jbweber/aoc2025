const std = @import("std");

pub fn main() !void {
    const input1 = @embedFile("input.txt");

    var lines = std.mem.tokenizeScalar(u8, input1, '\n');

    var grid: [150][]const u8 = undefined;

    var rowIndex: usize = 0;

    while (lines.next()) |line| {
        const trimmedLine = std.mem.trim(u8, line, " \r");
        grid[rowIndex] = trimmedLine;
        rowIndex += 1;
    }

    const cols = grid[0].len;

    var totalMovable: usize = 0;

    for (0..rowIndex) |r| {
        for (0..cols) |c| {
            if (grid[r][c] != '@') {
                continue;
            }
            var around: usize = 0;
            // check up
            if (r > 0) {
                if (grid[r - 1][c] == '@') {
                    around += 1;
                }
            }
            // check down
            if (r < rowIndex - 1) {
                if (grid[r + 1][c] == '@') {
                    around += 1;
                }
            }
            // check left
            if (c > 0) {
                if (grid[r][c - 1] == '@') {
                    around += 1;
                }
            }
            // check right
            if (c < cols - 1) {
                if (grid[r][c + 1] == '@') {
                    around += 1;
                }
            }
            // check up diagonal left
            if (r > 0 and c > 0) {
                if (grid[r - 1][c - 1] == '@') {
                    around += 1;
                }
            }
            // check up diagonal right
            if (r > 0 and c < cols - 1) {
                if (grid[r - 1][c + 1] == '@') {
                    around += 1;
                }
            }
            // check down diagonal left
            if (r < rowIndex - 1 and c > 0) {
                if (grid[r + 1][c - 1] == '@') {
                    around += 1;
                }
            }
            // check down diagonal right
            if (r < rowIndex - 1 and c < cols - 1) {
                if (grid[r + 1][c + 1] == '@') {
                    around += 1;
                }
            }
            if (around <= 3) {
                totalMovable += 1;
            }
        }
    }
    std.debug.print("Total movable: {d}\n", .{totalMovable});
}
