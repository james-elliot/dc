const std = @import("std");

pub fn conv(s: []u8) u32 {
    return std.fmt.parseUnsigned(u32, s, 10) catch 0;
}

pub fn conv2(s: []const u8) u32 {
    return std.fmt.parseUnsigned(u32, s, 10) catch 0;
}

pub fn process(s_in: []u8, buf: []u8) []u8 {
    var j: u32 = 0;
    for (s_in) |c| {
        if ((c == 0x09) or (c == 0x0A) or (c == 0x0C) or (c == 0x0D) or (c == 0x22)) {
            buf[j] = ' ';
            j += 1;
        } else if ((c >= 0x61) and (c <= 0x7A)) {
            buf[j] = c - 0x20;
            j += 1;
        } else if ((c >= 0x1F) and (c < 0x7F)) {
            buf[j] = c;
            j += 1;
        }
    }
    while ((j > 0) and (buf[j - 1] == ' ')) {
        j -= 1;
    }
    const end = j;
    j = 0;
    while ((buf[j] == ' ') and (j < end)) {
        j += 1;
    }
    return buf[j..end];
}

pub fn process_utf8(s: []u8) []u8 {
    var j: u32 = 0;
    for (0..s.len()) |i| {
        if (s[i] >= 0) {
            s[j] = s[i];
            i += 1;
            j += 1;
        } else {
            const inc = std.unicode.utf8ByteSequenceLength(s[i]) catch 1;
            i += inc;
            s[j] = 255;
            j += 1;
        }
    }
    return s[0..(j - 1)];
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
