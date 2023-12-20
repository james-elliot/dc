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
    const n: usize = s.len;
    while (i < n) {
        if (s[i] < 128) {
            s[j] = s[i];
            i += 1;
            j += 1;
        } else {
            var inc: u32 = 0;
            if (((s[i] & 0b11100000) == 0b11000000) and (i < n - 1) and
                ((s[i + 1] & 0b11000000) == 0b10000000))
            {
                inc = 2;
            } else if (((s[i] & 0b11110000) == 0b11100000) and (i < n - 2) and
                ((s[i + 1] & 0b11000000) == 0b10000000) and
                ((s[i + 2] & 0b11000000) == 0b10000000))
            {
                inc = 3;
            } else if (((s[i] & 0b11111000) == 0b11110000) and (i < n - 3) and
                ((s[i + 1] & 0b11000000) == 0b10000000) and
                ((s[i + 2] & 0b11000000) == 0b10000000) and
                ((s[i + 3] & 0b11000000) == 0b10000000))
            {
                inc = 4;
            } else {
                inc = 1;
            }
            i += inc;
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
pub fn one(in_stream: *std.io.BufferedReader(buf_size, std.fs.File.Reader).Reader, out_stream: *std.io.BufferedWriter(buf_size, std.fs.File.Writer).Writer) !void {
    var buf: [1024]u8 = undefined;
    var buf_nom: [81]u8, var buf_prenom: [81]u8 = .{ undefined, undefined };
    var buf_commune_b: [80]u8, var buf_pays_b: [80]u8 = .{ undefined, undefined };
    var buf_acte: [80]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const s = process_utf8(line);
        const n1 = find(s[0..80], '*');
        const nom = process(s[0..n1], &buf_nom);
        var prenom: []u8 = undefined;
        if (n1 < 79) {
            const n2 = find(s[n1 + 1 .. 80], '/');
            if (n2 == (80 - n1)) {
                prenom = process(s[n1 + 1 .. 80], &buf_prenom);
            } else {
                prenom = process(s[n1 + 1 .. @min(n1 + 1 + n2, 80)], &buf_prenom);
            }
        } else {
            prenom = "";
        }
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
}

pub fn main() !void {
    var buffer_in = [_]u8{0} ** 256;
    var buffer_out = [_]u8{0} ** 256;
    var args = std.process.args();
    _ = args.next();
    var i: usize = 0;
    var start: usize = 0;
    var end: usize = 0;
    while (args.next()) |arg| {
        if (i == 0) {
            start = try std.fmt.parseUnsigned(u32, arg, 10);
        } else {
            end = try std.fmt.parseUnsigned(u32, arg, 10);
        }
        i += 1;
    }
    switch (i) {
        1 => {
            const name_out = try std.fmt.bufPrint(&buffer_out, "deces-{d}.csv", .{start});
            const name_in = try std.fmt.bufPrint(&buffer_in, "deces-{d}.txt", .{start});
            var file_in = try std.fs.cwd().openFile(name_in, .{});
            var buf_reader = std.io.bufferedReaderSize(buf_size, file_in.reader());
            var in_stream = buf_reader.reader();
            var file_out = try std.fs.cwd().createFile(name_out, .{});
            var buf_writer = std.io.bufferedWriter(file_out.writer());
            var out_stream = buf_writer.writer();
            std.debug.print("{d} {d} {s} {s}\n", .{ start, end, name_in, name_out });
            one(&in_stream, &out_stream) catch std.debug.print("Error in one\n", .{});
            try buf_writer.flush();
            file_in.close();
            file_out.close();
        },
        2 => {
            const name_out = try std.fmt.bufPrint(&buffer_out, "deces-{d}-{d}.csv", .{ start, end });
            var file_out = try std.fs.cwd().createFile(name_out, .{});
            var buf_writer = std.io.bufferedWriter(file_out.writer());
            var out_stream = buf_writer.writer();
            for (start..end + 1) |y| {
                const name_in = try std.fmt.bufPrint(&buffer_in, "deces-{d}.txt", .{y});
                var file_in = try std.fs.cwd().openFile(name_in, .{});
                var buf_reader = std.io.bufferedReaderSize(buf_size, file_in.reader());
                var in_stream = buf_reader.reader();
                std.debug.print("{d} {d} {s} {s}\n", .{ start, end, name_in, name_out });
                one(&in_stream, &out_stream) catch std.debug.print("Error in one\n", .{});
                file_in.close();
            }
            try buf_writer.flush();
            file_out.close();
        },
        else => {
            std.debug.print("Incorrect number of arguments\n", .{});
        },
    }
}
