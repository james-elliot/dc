const std = @import("std");

pub fn conv(s: []u8) u32 {
    return std.fmt.parseUnsigned(u32, s, 10) catch 0;
}

pub fn conv2(s: []const u8) u32 {
    return std.fmt.parseUnsigned(u32, s, 10) catch 0;
}

pub fn main() !void {
    var file = try std.fs.cwd().openFile("foo.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const s: []const u8 = line;
        std.debug.print("{d}\n", .{s});
        const i = conv2(s);
        std.debug.print("{d}\n", .{i});
    }
}
