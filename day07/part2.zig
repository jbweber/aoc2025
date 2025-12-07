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
    var beams: [150]usize = [_]usize{0} ** 150;

    for (0..colCount) |colIndex| {
        if (grid[0][colIndex] == 'S') {
            beams[colIndex] = 1;
            break;
        }
    }

    while (currentRow < rowCount) : (currentRow += 1) {
        // check each column for beams, then look down for splitters
        // if we find a splitter we set the beams in the next row accordingly
        var nextBeams: [150]usize = beams;

        for (0..colCount) |colIndex| {
            // if there's a beam here, check for splitters
            // we're counting the number of beams that reach the bottom row and following splits down their timeline
            if (beams[colIndex] > 0) {
                const cell = grid[currentRow][colIndex];
                if (cell == '^') {
                    // split left
                    if (colIndex > 0) {
                        nextBeams[colIndex - 1] += beams[colIndex];
                    }
                    // split right
                    if (colIndex + 1 < colCount) {
                        nextBeams[colIndex + 1] += beams[colIndex];
                    }
                    // turn off current beam
                    nextBeams[colIndex] = 0;
                }
            }
        }
        beams = nextBeams;
    }

    var total: usize = 0;
    for (beams[0..colCount]) |v| {
        total += v;
    }

    std.debug.print("Number of timelines: {any}\n", .{total});
}
