const std = @import("std");

pub fn main() !void {
    const input1 = @embedFile("input.txt");

    var lines = std.mem.tokenizeScalar(u8, input1, '\n');
    var position: i32 = 50;
    var password: i32 = 0;

    while (lines.next()) |line| {
        const direction = line[0];
        const distance = try std.fmt.parseInt(i32, line[1..], 10);

        switch (direction) {
            'R' => position += distance,
            'L' => position -= distance,
            else => unreachable,
        }

        position = @mod(position, 100);

        if (position == 0) {
            password += 1;
        }
    }

    std.debug.print("Final password: {d}\n", .{password});
}
