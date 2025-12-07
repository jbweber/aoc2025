const std = @import("std");

pub fn main() !void {
    const input1 = @embedFile("input.txt");

    var lines = std.mem.tokenizeScalar(u8, input1, '\n');

    var grid: [5][]const u8 = undefined;

    var rowSize: usize = 0;

    while (lines.next()) |line| {
        grid[rowSize] = line;
        rowSize += 1;
    }

    const trimmedLastLine = std.mem.trim(u8, grid[rowSize - 1], " \r");
    var operators = std.mem.tokenizeScalar(u8, trimmedLastLine, ' ');

    var ops: [1500]u8 = undefined;
    var opCount: usize = 0;

    while (operators.next()) |op| {
        ops[opCount] = op[0];
        opCount += 1;
    }

    std.debug.print("Parsed {d} operators\n", .{opCount});

    var result: u64 = 0;
    var colCount = grid[0].len - 1;

    var opIndex = opCount - 1;
    var accumulator: u64 = 0;
    var multiply = switch (ops[opIndex]) {
        '*' => true,
        '+' => false,
        else => unreachable,
    };

    if (multiply) {
        accumulator = 1;
    }

    while (colCount >= 0) {
        var number: u64 = 0;
        for (0..rowSize - 1) |row| {
            switch (grid[row][colCount]) {
                ' ' => {
                    // skip whitespace
                },
                else => {
                    // Build number digit by digit: multiply shifts existing digits left,
                    // then add new digit. E.g., for "431": 0->4->43->431
                    // The - '0' converts ASCII char to numeric value ('4' -> 4)
                    number = number * 10 + grid[row][colCount] - '0';
                },
            }
        }

        if (number == 0 and colCount > 0) {
            // reset for next grouping
            result += accumulator;
            opIndex -= 1;
            multiply = switch (ops[opIndex]) {
                '*' => true,
                '+' => false,
                else => unreachable,
            };
            if (multiply) {
                accumulator = 1;
            } else {
                accumulator = 0;
            }
            colCount -= 1;
            continue;
        }

        if (multiply) {
            accumulator *= number;
        } else {
            accumulator += number;
        }
        std.debug.print("Processed column {d}\n", .{colCount});

        if (colCount == 0) {
            break;
        } else {
            colCount -= 1;
        }
    }

    result += accumulator;
    std.debug.print("Result: {d}\n", .{result});
}
