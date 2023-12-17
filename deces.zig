const std = @import("std");

pub fn conv(s: []u8) u32 {
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
    while ((j > 0) and (buf[j - 1] == ' ')) j -= 1;
    const end = j;
    j = 0;
    while ((buf[j] == ' ') and (j < end)) j += 1;
    return buf[j..end];
}

pub fn process_utf8(s: []u8) []u8 {
    var i: u32, var j: u32 = .{ 0, 0 };
    while (i < s.len) {
        if (s[i] < 128) {
            s[j] = s[i];
            i += 1;
            j += 1;
        } else {
            i += std.unicode.utf8ByteSequenceLength(s[i]) catch 1;
            s[j] = 255;
            j += 1;
        }
    }
    return s[0..j];
}

pub fn find(s: []u8, f: u8) usize {
    for (s, 0..) |c, i| {
        if (c == f) return i;
    }
    return s.len;
}

const buf_size: usize = 4096;
pub fn one(buf_reader: *std.io.BufferedReader(buf_size, std.fs.File.Reader), buf_writer: *std.io.BufferedWriter(buf_size, std.fs.File.Writer)) !void {
    var in_stream = buf_reader.reader();
    var out_stream = buf_writer.writer();
    var buf: [1024]u8 = undefined;
    var buf_nom: [80]u8, var buf_prenom: [80]u8 = .{ undefined, undefined };
    var buf_commune_b: [80]u8, var buf_pays_b: [80]u8 = .{ undefined, undefined };
    var buf_acte: [80]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const s = process_utf8(line);
        const n1 = find(s[0..81], '*');
        const nom = process(s[0..n1], &buf_nom);
        const n2 = find(s[n1 + 1 .. 81], '/');
        const prenom = process(s[n1 + 1 .. n1 + 1 + n2], &buf_prenom);
        var sexe: u8 = undefined;
        if (s[80] == '1') sexe = 'H' else sexe = 'F';
        const year_b = conv(s[81..85]);
        const month_b = conv(s[85..87]);
        const day_b = conv(s[87..89]);
        const insee_b = s[89..94];
        const commune_b = process(s[94..124], &buf_commune_b);
        const pays_b = process(s[124..154], &buf_pays_b);
        const year_d = conv(s[154..158]);
        const month_d = conv(s[158..160]);
        const day_d = conv(s[160..162]);
        const insee_d = s[162..167];
        const num_acte = process(s[167..176], &buf_acte);
        try out_stream.print("\"{s}\",\"{s}\",\"{c}\",\"{d}\",\"{d}\",\"{d}\",\"{s}\",\"{s}\",\"{s}\",\"{d}\",\"{d}\",\"{d}\",\"{s}\",\"{s}\"\n", .{ nom, prenom, sexe, year_b, month_b, day_b, insee_b, commune_b, pays_b, year_d, month_d, day_d, insee_d, num_acte });
    }
    try buf_writer.flush();
}

pub fn main() !void {
    var buffer = [_]u8{0} ** 256;

    var args = std.process.args();
    _ = args.next();
    var i: usize = 0;
    var start: usize = 0;
    var end: usize = 0;
    while (args.next()) |arg| {
        //        const printed = try std.fmt.bufPrint(&buffer, "https://github.com/{s}/reponame", .{arg});
        if (i == 0) {
            start = try std.fmt.parseUnsigned(u32, arg, 10);
        } else {
            end = try std.fmt.parseUnsigned(u32, arg, 10);
        }
        i += 1;
        std.debug.print("{d} {d}\n", .{ start, end });
    }
    var file = try std.fs.cwd().openFile("deces-1970.txt", .{});
    defer file.close();
    var buf_reader = std.io.bufferedReaderSize(buf_size, file.reader());

    var file2 = try std.fs.cwd().createFile("deces-1970.csv", .{});
    defer file2.close();
    var buf_writer = std.io.bufferedWriter(file2.writer());

    try one(&buf_reader, &buf_writer);
    std.debug.print("coucou\n", .{});
}
