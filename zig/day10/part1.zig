const std = @import("std");

const Machine = struct {
    expected: u16,
    buttons: std.ArrayList(u16),
};

pub fn main() !void {
    const input1 = @embedFile("input.txt");

    var lines = std.mem.tokenizeScalar(u8, input1, '\n');

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var machines: std.ArrayList(Machine) = .empty;
    defer {
        for (machines.items) |*machine| {
            machine.buttons.deinit(allocator);
        }
        machines.deinit(allocator);
    }

    while (lines.next()) |line| {
        var tokens = std.mem.tokenizeScalar(u8, line, ' ');

        const machineDef = tokens.next().?;
        const buttons: std.ArrayList(u16) = .empty;
        var machine = Machine{
            .expected = parseMachine(machineDef),
            .buttons = buttons,
        };

        while (tokens.next()) |token| {
            if (token[0] == '(') {
                try machine.buttons.append(allocator, parseButton(token));
            } else if (token[0] == '{') {
                // this is an output
                // we don't need to do anything with it for part 1
            }
        }
        try machines.append(allocator, machine);
    }

    var count: u64 = 0;

    for (machines.items) |machine| {
        var minPresses: u64 = 0;
        const numButtons = machine.buttons.items.len;

        var combo: usize = 0;
        while (combo < (@as(usize, 1) << @intCast(numButtons))) : (combo += 1) {
            var toggled: u16 = 0;
            for (0..numButtons) |i| {
                if ((combo & (@as(usize, 1) << @intCast(i))) != 0) {
                    toggled ^= machine.buttons.items[i];
                }
            }
            if (toggled == machine.expected) {
                const presses = @popCount(combo);
                if (minPresses == 0 or presses < minPresses) {
                    minPresses = presses;
                }
            }
        }

        count += minPresses;
    }

    std.debug.print("Total minimum button presses: {d}\n", .{count});
}

// this represents the expected state of the machine's lights
// we use a u16 to hold the state of up to 10 lights and will
// use it as a bit mask
// in theory this is stored backwards (i.e. light 0 is the least significant bit)
// but it doesn't really matter for our purposes if we align everything the same way
fn parseMachine(input: []const u8) u16 {
    var expected: u16 = 0;
    const lights = input[1 .. input.len - 1];

    for (lights, 0..) |c, i| {
        if (c == '#') {
            expected |= @as(u16, 1) << @intCast(i);
        }
    }

    return expected;
}

// this represents the buttons that were pressed
// we use a u16 to hold the state of up to 10 buttons and will
// use it as a bit mask
// can xor with the machine state to determine which lights should toggle
fn parseButton(input: []const u8) u16 {
    var expected: u16 = 0;

    var buttons = std.mem.tokenizeScalar(u8, input[1 .. input.len - 1], ',');
    while (buttons.next()) |button| {
        const buttonIndex = std.fmt.parseInt(u8, button, 10) catch continue;
        expected |= @as(u16, 1) << @intCast(buttonIndex);
    }

    return expected;
}

// {}
