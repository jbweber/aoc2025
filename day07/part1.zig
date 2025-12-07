const std = @import("std");

pub fn main() !void {
    const input1 = @embedFile("input.txt");

    var lines = std.mem.tokenizeScalar(u8, input1, '\n');

    var grid: [150][150]u8 = undefined;

    var rowCount: usize = 0;
    var colCount: usize = 0;

    while (lines.next()) |line| {
        const trimmedLine = std.mem.trim(u8, line, " \r");
        @memcpy(grid[rowCount][0..trimmedLine.len], trimmedLine);
        rowCount += 1;
        colCount = trimmedLine.len;
    }

    // S is in the middle of the first row
    var currentRow: usize = 1; // start just below the first row
    var beams: [150]bool = [_]bool{false} ** 150;

    for (0..colCount) |colIndex| {
        if (grid[0][colIndex] == 'S') {
            beams[colIndex] = true;
            break;
        }
    }

    var splitCount: usize = 0;

    while (currentRow < rowCount - 1) : (currentRow += 1) {
        // check each column for beams, then look down for splitters
        // if we find a splitter we set the beams in the next row accordingly
        var nextBeams: [150]bool = beams;

        for (0..colCount) |colIndex| {
            // if there's a beam here, check for splitters
            if (beams[colIndex]) {
                const cell = grid[currentRow][colIndex];
                if (cell == '^') {
                    // split left
                    if (colIndex > 0) {
                        nextBeams[colIndex - 1] = true;
                    }
                    // split right
                    if (colIndex + 1 < colCount) {
                        nextBeams[colIndex + 1] = true;
                    }
                    // turn off current beam
                    nextBeams[colIndex] = false;
                    splitCount += 1;
                }
            }
        }
        beams = nextBeams;
    }

    std.debug.print("Number of splits: {}\n", .{splitCount});
}
