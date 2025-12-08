const std = @import("std");

const Pair = struct {
    box1: usize,
    box2: usize,
    dist: i64,
};

pub fn main() !void {
    const input1 = @embedFile("input.txt");

    var lines = std.mem.tokenizeScalar(u8, input1, '\n');

    // allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var junctionBoxes: std.ArrayList([3]i64) = .empty;
    defer junctionBoxes.deinit(allocator);

    while (lines.next()) |line| {
        var point = std.mem.tokenizeSequence(u8, line, ",");
        try junctionBoxes.append(allocator, .{
            try std.fmt.parseInt(i64, point.next() orelse "0", 10),
            try std.fmt.parseInt(i64, point.next() orelse "0", 10),
            try std.fmt.parseInt(i64, point.next() orelse "0", 10),
        });
    }

    var distances: std.ArrayList(Pair) = .empty;
    defer distances.deinit(allocator);

    for (junctionBoxes.items, 0..) |box1, i| {
        for (junctionBoxes.items, 0..) |box2, j| {
            if (i >= j) continue;
            const dist = distance(box1, box2);
            try distances.append(allocator, .{ .box1 = i, .box2 = j, .dist = dist });
        }
    }

    std.mem.sort(Pair, distances.items, {}, distanceLessThan);

    var parents: [1000]usize = undefined;
    for (&parents, 0..) |*p, i| {
        p.* = i;
    }

    for (distances.items) |pair| {
        setParent(&parents, pair.box1, pair.box2);
        if (allConnected(&parents, junctionBoxes.items.len)) {
            std.debug.print("Max distance to connect all junction boxes: {d}\n", .{junctionBoxes.items[pair.box1][0] * junctionBoxes.items[pair.box2][0]});
            break;
        }
    }
}

fn distance(a: [3]i64, b: [3]i64) i64 {
    const xDiff = a[0] - b[0];
    const yDiff = a[1] - b[1];
    const zDiff = a[2] - b[2];
    return (xDiff * xDiff) + (yDiff * yDiff) + (zDiff * zDiff);
}

fn distanceLessThan(_: void, a: Pair, b: Pair) bool {
    return a.dist < b.dist;
}

fn findParent(parents: *[1000]usize, i: usize) usize {
    if (parents[i] != i) {
        // path compression optimization
        // set the parent to the root parent so when we look it up again later it's faster
        parents[i] = findParent(parents, parents[i]);
    }
    return parents[i];
}

fn setParent(parents: *[1000]usize, x: usize, y: usize) void {
    // set the parent of x to y this let's us track connected components
    const xset = findParent(parents, x);
    const yset = findParent(parents, y);
    parents[xset] = yset;
}

fn allConnected(parents: *[1000]usize, count: usize) bool {
    const root = findParent(parents, 0);
    for (1..count) |i| {
        if (findParent(parents, i) != root) {
            return false;
        }
    }
    return true;
}
