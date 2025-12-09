const std = @import("std");

const Point = [2]u32;
const GRID_SIZE = 1000; // Enough for ~500 unique coords + padding

pub fn main() !void {
    const input1 = @embedFile("input.txt");

    var lines = std.mem.tokenizeScalar(u8, input1, '\n');

    // allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var tiles: std.ArrayList(Point) = .empty;
    defer tiles.deinit(allocator);

    // Collect unique x and y coordinates
    var xCoords: std.ArrayList(u32) = .empty;
    defer xCoords.deinit(allocator);
    var yCoords: std.ArrayList(u32) = .empty;
    defer yCoords.deinit(allocator);

    while (lines.next()) |line| {
        var tile = std.mem.tokenizeSequence(u8, line, ",");
        const x = try std.fmt.parseInt(u32, tile.next() orelse "0", 10);
        const y = try std.fmt.parseInt(u32, tile.next() orelse "0", 10);
        try tiles.append(allocator, .{ x, y });
        try xCoords.append(allocator, x);
        try yCoords.append(allocator, y);
    }

    // Step 1: Coordinate Compression
    // Map ~500 unique x/y values to indices 0-500, shrinking 98k×98k to ~500×500
    std.mem.sort(u32, xCoords.items, {}, std.sort.asc(u32));
    std.mem.sort(u32, yCoords.items, {}, std.sort.asc(u32));
    var xToIdx: std.AutoHashMapUnmanaged(u32, usize) = .{};
    defer xToIdx.deinit(allocator);
    var yToIdx: std.AutoHashMapUnmanaged(u32, usize) = .{};
    defer yToIdx.deinit(allocator);

    var xIdx: usize = 1; // Start at 1 to leave border for flood fill
    var lastX: ?u32 = null;
    for (xCoords.items) |x| {
        if (lastX == null or lastX.? != x) {
            _ = try xToIdx.put(allocator, x, xIdx);
            xIdx += 1;
            lastX = x;
        }
    }

    var yIdx: usize = 1;
    var lastY: ?u32 = null;
    for (yCoords.items) |y| {
        if (lastY == null or lastY.? != y) {
            _ = try yToIdx.put(allocator, y, yIdx);
            yIdx += 1;
            lastY = y;
        }
    }

    const gridW = xIdx + 1; // +1 for border
    const gridH = yIdx + 1;

    // Create grid: 0 = unknown, 1 = boundary, 2 = outside
    var grid: [GRID_SIZE][GRID_SIZE]u8 = undefined;
    for (0..gridH) |gy| {
        for (0..gridW) |gx| {
            grid[gy][gx] = 0;
        }
    }

    // Step 2: Draw polygon boundary in compressed space
    for (0..tiles.items.len) |i| {
        const current = tiles.items[i];
        const next = tiles.items[(i + 1) % tiles.items.len];

        const cx = xToIdx.get(current[0]).?;
        const cy = yToIdx.get(current[1]).?;
        const nx = xToIdx.get(next[0]).?;
        const ny = yToIdx.get(next[1]).?;

        if (cx == nx) {
            // Vertical line
            const startY = @min(cy, ny);
            const endY = @max(cy, ny);
            for (startY..endY + 1) |y| {
                grid[y][cx] = 1;
            }
        } else {
            // Horizontal line
            const startX = @min(cx, nx);
            const endX = @max(cx, nx);
            for (startX..endX + 1) |x| {
                grid[cy][x] = 1;
            }
        }
    }

    // Step 3: Flood fill from edges to mark "outside" cells
    var queue: std.ArrayList([2]usize) = .empty;
    defer queue.deinit(allocator);

    // Add all border cells to queue
    for (0..gridW) |x| {
        if (grid[0][x] == 0) {
            grid[0][x] = 2;
            try queue.append(allocator, .{ x, 0 });
        }
        if (grid[gridH - 1][x] == 0) {
            grid[gridH - 1][x] = 2;
            try queue.append(allocator, .{ x, gridH - 1 });
        }
    }
    for (1..gridH - 1) |y| {
        if (grid[y][0] == 0) {
            grid[y][0] = 2;
            try queue.append(allocator, .{ 0, y });
        }
        if (grid[y][gridW - 1] == 0) {
            grid[y][gridW - 1] = 2;
            try queue.append(allocator, .{ gridW - 1, y });
        }
    }

    // BFS flood fill
    var qIdx: usize = 0;
    while (qIdx < queue.items.len) {
        const pos = queue.items[qIdx];
        qIdx += 1;
        const x = pos[0];
        const y = pos[1];

        const neighbors = [_][2]i64{ .{ -1, 0 }, .{ 1, 0 }, .{ 0, -1 }, .{ 0, 1 } };
        for (neighbors) |d| {
            const nx_i = @as(i64, @intCast(x)) + d[0];
            const ny_i = @as(i64, @intCast(y)) + d[1];
            if (nx_i >= 0 and nx_i < gridW and ny_i >= 0 and ny_i < gridH) {
                const nx_u: usize = @intCast(nx_i);
                const ny_u: usize = @intCast(ny_i);
                if (grid[ny_u][nx_u] == 0) {
                    grid[ny_u][nx_u] = 2;
                    try queue.append(allocator, .{ nx_u, ny_u });
                }
            }
        }
    }

    // Step 4: Build 2D prefix sum for O(1) rectangle queries
    var prefix: [GRID_SIZE][GRID_SIZE]u32 = undefined;
    for (0..gridH) |y| {
        for (0..gridW) |x| {
            const isOutside: u32 = if (grid[y][x] == 2) 1 else 0;
            const left: u32 = if (x > 0) prefix[y][x - 1] else 0;
            const up: u32 = if (y > 0) prefix[y - 1][x] else 0;
            const diag: u32 = if (x > 0 and y > 0) prefix[y - 1][x - 1] else 0;
            prefix[y][x] = isOutside + left + up - diag;
        }
    }

    // Step 5: Check all tile pairs - valid if rectangle has no outside cells
    var maxArea: u64 = 0;
    for (tiles.items) |tile1| {
        for (tiles.items) |tile2| {
            const x1 = xToIdx.get(tile1[0]).?;
            const y1 = yToIdx.get(tile1[1]).?;
            const x2 = xToIdx.get(tile2[0]).?;
            const y2 = yToIdx.get(tile2[1]).?;

            const minX = @min(x1, x2);
            const maxX = @max(x1, x2);
            const minY = @min(y1, y2);
            const maxY = @max(y1, y2);

            // Query prefix sum for outside cells in rectangle
            const total: i64 = prefix[maxY][maxX];
            const left: i64 = if (minX > 0) prefix[maxY][minX - 1] else 0;
            const up: i64 = if (minY > 0) prefix[minY - 1][maxX] else 0;
            const diag: i64 = if (minX > 0 and minY > 0) prefix[minY - 1][minX - 1] else 0;
            const outsideCount = total - left - up + diag;

            if (outsideCount == 0) {
                // Valid rectangle - calculate actual area
                const dx = @abs(@as(i64, tile2[0]) - @as(i64, tile1[0])) + 1;
                const dy = @abs(@as(i64, tile2[1]) - @as(i64, tile1[1])) + 1;
                const area: u64 = @intCast(dx * dy);
                if (area > maxArea) {
                    maxArea = area;
                }
            }
        }
    }

    std.debug.print("Max area: {d}\n", .{maxArea});
}
