const std = @import("std");

pub fn main() !void {
    // this embeds the file at compile time
    const input1 = @embedFile("input.txt");

    var lines = std.mem.tokenizeScalar(u8, input1, '\n');
    var position: i32 = 50; // starting position
    var password: u32 = 0;

    while (lines.next()) |line| {
        const direction = line[0];
        const distance = try std.fmt.parseInt(i32, line[1..], 10);

        switch (direction) {
            'R' => {
                const passes = calc(position, distance);
                position += distance;
                password += passes;
            },
            'L' => {
                const passes = calc(position, -distance);
                position -= distance;
                password += passes;
            },
            else => unreachable,
        }
    }

    std.debug.print("Final password: {d}\n", .{password});
}

fn calc(position: i32, distance: i32) u32 {
    if (distance < 0) {
        // count crossings over the 0/1 boundary
        const start = @divFloor(position - 1, 100);
        const end = @divFloor(position + distance - 1, 100);
        return @abs(end - start);
    } else {
        // count crossings over the 99/100 boundary
        const start = @divFloor(position, 100);
        const end = @divFloor(position + distance, 100);
        return @abs(end - start);
    }
}
