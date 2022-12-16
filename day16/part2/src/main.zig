// This is a straight port of my part 2 code from SLANG to Zig.
//
// On my PC, compiled in release-fast mode:
// sample input: 2ms (vs 30 mins on SCAMP, which is ~900000x slower)
// real input: 2m20s (so we expect about 4 years on SCAMP)
//
// (To run on the sample input, you need to edit the sample input text so that all lines are plural)

const std = @import("std");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
var valvenumber = std.ArrayList(usize).init(gpa.allocator());
var nvalves: usize = 0;

fn valveid(s: []const u8) usize {
    var key = @intCast(usize, s[0] - 'A') * 26 + s[1] - 'A';
    var i: usize = 0;
    while (i < valvenumber.items.len) : (i += 1) {
        if (valvenumber.items[i] == key) return i;
    }
    valvenumber.append(key) catch unreachable;
    nvalves += 1;
    return nvalves - 1;
}

fn skipover(ss: []const u8, ch: u8) ?[]const u8 {
    var s = ss;
    while (s.len > 0) {
        if (s[0] == ch) return s[1..];
        s = s[1..];
    }
    return null;
}

var flowrate: [66]usize = undefined;
var neighbours: [66]std.ArrayList(usize) = undefined;
var valves = std.ArrayList(usize).init(gpa.allocator());

const NeighbourNode = struct {
    v: usize,
    len: usize,
};

var visited = std.mem.zeroes([66:false]bool);
var realneighbours: [66]std.ArrayList(NeighbourNode) = undefined;

fn computeneighbours(ffrom: usize) void {
    var idx = ffrom;
    var q = std.ArrayList(NeighbourNode).init(gpa.allocator());
    var qidx: usize = 0;
    q.append(NeighbourNode{ .v = ffrom, .len = 0 }) catch unreachable;

    while (qidx < q.items.len) {
        var vl = q.items[qidx];
        qidx += 1;
        var from = vl.v;
        var len = vl.len;
        var i: usize = 0;
        while (i < neighbours[from].items.len) {
            var v = neighbours[from].items[i];
            if (!visited[v]) {
                visited[v] = true;
                if (flowrate[v] != 0) {
                    realneighbours[idx].append(NeighbourNode{ .v = v, .len = len + 1 }) catch unreachable;
                }
                q.append(NeighbourNode{ .v = v, .len = len + 1 }) catch unreachable;
            }
            i += 1;
        }
    }
}

var vopen = std.mem.zeroes([66:false]bool);

fn dfs(from: usize, elephant: bool, levels: usize) usize {
    if (levels == 0) return 0;

    var i: usize = 0;
    var flow: usize = 0;
    var bestflow: usize = 0;
    while (i < realneighbours[from].items.len) {
        var vl = realneighbours[from].items[i];
        var v = vl.v;
        var l = vl.len;
        if (!vopen[v] and levels > l) {
            vopen[v] = true;

            flow = flowrate[v] * (levels - (l + 1)) + dfs(v, elephant, levels - (l + 1));
            if (flow > bestflow) bestflow = flow;

            vopen[v] = false;
        }
        if (!elephant) {
            flow = dfs(valveid("AA"), true, 26);
            if (flow > bestflow) bestflow = flow;
        }
        i += 1;
    }
    return bestflow;
}

pub fn main() void {
    std.debug.print("reading input...\n", .{});

    var i: usize = 0;
    while (i < 66) : (i += 1) {
        neighbours[i] = std.ArrayList(usize).init(gpa.allocator());
        realneighbours[i] = std.ArrayList(NeighbourNode).init(gpa.allocator());
    }

    var id: usize = 0;
    var p: []const u8 = undefined;

    var stream = std.io.getStdIn().reader();
    var buffer: [1000]u8 = undefined;

    while (true) {
        var line = stream.readUntilDelimiter(buffer[0..], '\n') catch break;
        id = valveid(line[6..]);
        valves.append(id) catch unreachable;
        flowrate[id] = std.fmt.parseInt(usize, line[23..25], 10) catch std.fmt.parseInt(usize, line[23..24], 10) catch unreachable;
        std.debug.print("flowrate={}\n", .{flowrate[id]});
        p = skipover(line, 'd').?;
        p = skipover(p, 's').?;
        p = p[1..];
        while (true) {
            neighbours[id].append(valveid(p)) catch unreachable;
            var r = skipover(p, ' ');
            if (r) |v| p = v else break;
        }
    }

    std.debug.print("{} valves\n", .{nvalves});

    std.debug.print("computing neighbours...\n", .{});

    i = 0;
    while (i < valves.items.len) {
        var v = valves.items[i];
        std.mem.set(bool, &visited, false);
        computeneighbours(v);
        i += 1;
    }

    std.debug.print("running dfs...\n", .{});

    std.debug.print("{}\n", .{dfs(valveid("AA"), false, 26)});
}
