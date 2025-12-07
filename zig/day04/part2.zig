const std = @import("std");

pub fn main() !void {
    const input1 = @embedFile("input.txt");

    var lines = std.mem.tokenizeScalar(u8, input1, '\n');

    var grid: [150][150]u8 = undefined;

    var rowIndex: usize = 0;

    const cols = lines.peek().?.len;

    while (lines.next()) |line| {
        const trimmedLine = std.mem.trim(u8, line, " \r");
        @memcpy(grid[rowIndex][0..trimmedLine.len], trimmedLine);
        rowIndex += 1;
    }

    var totalMovable: usize = 0;

    while (true) {
        const moved = move(&grid, rowIndex, cols);
        if (moved == 0) {
            break;
        }
        totalMovable += moved;
    }

    std.debug.print("Total movable: {d}\n", .{totalMovable});
}

fn move(grid: *[150][150]u8, rowIndex: usize, cols: usize) usize {
    var totalMovable: usize = 0;
    for (0..rowIndex) |r| {
        for (0..cols) |c| {
            if (grid[r][c] != '@') {
                continue;
            }
            var around: usize = 0;
            // check up
            if (r > 0) {
                if (grid[r - 1][c] == '@' or grid[r - 1][c] == 'X') {
                    around += 1;
                }
            }
            // check down
            if (r < rowIndex - 1) {
                if (grid[r + 1][c] == '@' or grid[r + 1][c] == 'X') {
                    around += 1;
                }
            }
            // check left
            if (c > 0) {
                if (grid[r][c - 1] == '@' or grid[r][c - 1] == 'X') {
                    around += 1;
                }
            }
            // check right
            if (c < cols - 1) {
                if (grid[r][c + 1] == '@' or grid[r][c + 1] == 'X') {
                    around += 1;
                }
            }
            // check up diagonal left
            if (r > 0 and c > 0) {
                if (grid[r - 1][c - 1] == '@' or grid[r - 1][c - 1] == 'X') {
                    around += 1;
                }
            }
            // check up diagonal right
            if (r > 0 and c < cols - 1) {
                if (grid[r - 1][c + 1] == '@' or grid[r - 1][c + 1] == 'X') {
                    around += 1;
                }
            }
            // check down diagonal left
            if (r < rowIndex - 1 and c > 0) {
                if (grid[r + 1][c - 1] == '@' or grid[r + 1][c - 1] == 'X') {
                    around += 1;
                }
            }
            // check down diagonal right
            if (r < rowIndex - 1 and c < cols - 1) {
                if (grid[r + 1][c + 1] == '@' or grid[r + 1][c + 1] == 'X') {
                    around += 1;
                }
            }
            if (around <= 3) {
                totalMovable += 1;
                grid[r][c] = 'X';
            }
        }
    }

    for (0..rowIndex) |r| {
        for (0..cols) |c| {
            if (grid[r][c] == 'X') {
                grid[r][c] = '.';
            }
        }
    }

    return totalMovable;
}
