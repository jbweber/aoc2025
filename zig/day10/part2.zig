const std = @import("std");

const N = 13;
const EPS = 1e-8;

const Linear = struct {
    a: [N]f64,
    b: f64,
};

const Variable = struct {
    expr: Linear,
    free: bool,
    val: i32,
    max: i32,
};

const Machine = struct {
    buttons: std.ArrayList(u16),
    jolt: [16]u32,
    numCounters: usize,
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

        _ = tokens.next(); // skip the [.##.] indicator light diagram
        const buttons: std.ArrayList(u16) = .empty;
        var machine = Machine{
            .buttons = buttons,
            .jolt = [_]u32{0} ** 16,
            .numCounters = 0,
        };

        while (tokens.next()) |token| {
            if (token[0] == '(') {
                try machine.buttons.append(allocator, parseButton(token));
            } else if (token[0] == '{') {
                const inner = token[1 .. token.len - 1];
                var nums = std.mem.tokenizeScalar(u8, inner, ',');
                var idx: usize = 0;
                while (nums.next()) |num| {
                    machine.jolt[idx] = std.fmt.parseInt(u32, num, 10) catch 0;
                    idx += 1;
                }
                machine.numCounters = idx;
            }
        }
        try machines.append(allocator, machine);
    }

    var total: u64 = 0;

    for (machines.items, 0..) |machine, machineIdx| {
        const result = count2(machine);
        std.debug.print("Machine {d}: {d} presses\n", .{ machineIdx + 1, result });
        total += result;
    }

    std.debug.print("Total minimum button presses: {d}\n", .{total});
}

fn extract(lin: Linear, index: usize) ?Linear {
    const a = -lin.a[index];
    if (@abs(a) < EPS) {
        return null;
    }

    var r = Linear{
        .a = [_]f64{0} ** N,
        .b = lin.b / a,
    };
    for (0..N) |i| {
        if (i != index) {
            r.a[i] = lin.a[i] / a;
        }
    }
    return r;
}

fn substitute(lin: Linear, index: usize, expr: Linear) Linear {
    var r = Linear{
        .a = [_]f64{0} ** N,
        .b = 0,
    };

    const a = lin.a[index];
    var lin2 = lin;
    lin2.a[index] = 0;

    for (0..N) |i| {
        r.a[i] = lin2.a[i] + a * expr.a[i];
    }
    r.b = lin2.b + a * expr.b;
    return r;
}

fn eval(v: Variable, vals: [N]i32) f64 {
    if (v.free) {
        return @floatFromInt(v.val);
    }

    var x = v.expr.b;
    for (0..N) |i| {
        x += v.expr.a[i] * @as(f64, @floatFromInt(vals[i]));
    }
    return x;
}

fn count2(m: Machine) u64 {
    var vars: [N]Variable = undefined;
    for (0..m.buttons.items.len) |i| {
        vars[i] = Variable{
            .expr = Linear{ .a = [_]f64{0} ** N, .b = 0 },
            .free = false,
            .val = 0,
            .max = std.math.maxInt(i32),
        };
    }

    var eqs: [16]Linear = undefined;
    for (0..m.numCounters) |i| {
        var eq = Linear{
            .a = [_]f64{0} ** N,
            .b = -@as(f64, @floatFromInt(m.jolt[i])),
        };
        for (m.buttons.items, 0..) |b, j| {
            if ((b & (@as(u16, 1) << @intCast(i))) != 0) {
                eq.a[j] = 1;
                vars[j].max = @min(vars[j].max, @as(i32, @intCast(m.jolt[i])));
            }
        }
        eqs[i] = eq;
    }

    // Gaussian elimination
    for (0..m.buttons.items.len) |i| {
        vars[i].free = true;

        for (0..m.numCounters) |eqIdx| {
            if (extract(eqs[eqIdx], i)) |expr| {
                vars[i].free = false;
                vars[i].expr = expr;

                for (0..m.numCounters) |j| {
                    eqs[j] = substitute(eqs[j], i, expr);
                }
                break;
            }
        }
    }

    // Collect free variables
    var free: [N]usize = undefined;
    var numFree: usize = 0;
    for (0..m.buttons.items.len) |i| {
        if (vars[i].free) {
            free[numFree] = i;
            numFree += 1;
        }
    }

    const result = evalRecursive(&vars, m.buttons.items.len, free[0..numFree], 0);
    return result orelse 0;
}

fn evalRecursive(vars: *[N]Variable, numVars: usize, free: []usize, index: usize) ?u64 {
    if (index == free.len) {
        var vals: [N]i32 = [_]i32{0} ** N;
        var total: u64 = 0;

        var i: usize = numVars;
        while (i > 0) {
            i -= 1;
            const x = eval(vars[i], vals);
            if (x < -EPS or @abs(x - @round(x)) > EPS) {
                return null;
            }
            const rounded: i32 = @intFromFloat(@round(x));
            if (rounded < 0) {
                return null;
            }
            vals[i] = rounded;
            total += @intCast(rounded);
        }

        return total;
    }

    var best: ?u64 = null;
    var x: i32 = 0;
    while (x <= vars[free[index]].max) : (x += 1) {
        vars[free[index]].val = x;
        if (evalRecursive(vars, numVars, free, index + 1)) |result| {
            if (best == null or result < best.?) {
                best = result;
            }
        }
    }

    return best;
}

fn parseButton(input: []const u8) u16 {
    var result: u16 = 0;

    var btns = std.mem.tokenizeScalar(u8, input[1 .. input.len - 1], ',');
    while (btns.next()) |button| {
        const buttonIndex = std.fmt.parseInt(u8, button, 10) catch continue;
        result |= @as(u16, 1) << @intCast(buttonIndex);
    }

    return result;
}
