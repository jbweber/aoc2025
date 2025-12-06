const std = @import("std");

pub fn main() !void {
    const input1 = @embedFile("input.txt");

    var lines = std.mem.tokenizeScalar(u8, input1, '\n');

    var grid: [5][1000][]const u8 = undefined;

    var rowIndex: usize = 0;
    var colCount: usize = 0;

    while (lines.next()) |line| {
        const trimmedLine = std.mem.trim(u8, line, " \r");
        var tokens = std.mem.tokenizeScalar(u8, trimmedLine, ' ');
        var colIndex: usize = 0;
        while (tokens.next()) |token| {
            grid[rowIndex][colIndex] = token;
            colIndex += 1;
        }
        colCount = colIndex;
        rowIndex += 1;
    }

    var result: u64 = 0;

    for (0..colCount) |col| {
        const op = grid[rowIndex - 1][col];
        const multiply: bool = switch (op[0]) {
            '*' => true, // multiply
            '+' => false, // add
            else => return error.InvalidOperation,
        };

        var accumulator: u64 = switch (multiply) {
            true => 1,
            false => 0,
        };

        for (0..rowIndex - 1) |row| {
            const token = try std.fmt.parseInt(u64, grid[row][col], 10);
            accumulator = switch (multiply) {
                true => accumulator * token,
                false => accumulator + token,
            };
        }
        result += accumulator;
    }

    std.debug.print("Result: {d}\n", .{result});
}
// we worked out a good size, but we don't need this really we'll just figure out the size ahead of time and cheat
//     var rowCount: usize = 0;

//     while (lines.next()) |line| {
//         rowCount += 1;
//         const trimmedLine = std.mem.trim(u8, line, " \r");
//         var tokens = std.mem.tokenizeScalar(u8, trimmedLine, ' ');
//         var tokenCount: usize = 0;
//         while (tokens.next()) |_| {
//             tokenCount += 1;
//         }

//         std.debug.print("Line {d} tokens: {d}\n", .{ rowCount, tokenCount });
//         //tokenCount += std.mem.tokenizeScalar(u8, line, ',').count();
//     }

//     std.debug.print("Row count: {d}\n", .{rowCount});
