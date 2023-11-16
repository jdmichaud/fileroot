const std = @import("std");

pub fn main() !u8 {
  var arena_instance = std.heap.ArenaAllocator.init(std.heap.page_allocator);
  defer arena_instance.deinit();
  const arena = arena_instance.allocator();

  const args = try std.process.argsAlloc(arena); 

  const stdout = std.io.getStdOut();
  const stdout_w = stdout.writer();

  if (args.len <= 1 or std.mem.eql(u8, args[1], "--help") or std.mem.eql(u8, args[1], "-h")) {
    try stdout_w.writeAll("Usage: fileroot NAME ...\n");
    try stdout_w.writeAll("Print the path file root\n");
    try stdout_w.writeAll("\n");
    try stdout_w.writeAll("Options:\n");
    try stdout_w.writeAll("  -z, --zero   end each output line with NUL, not newline\n");
    try stdout_w.writeAll("\n");
    try stdout_w.writeAll("Examples:\n");
    try stdout_w.writeAll("  fileroot /usr/include/termios.h  -> termios\n");
    return 0;
  }

  var arg_i: usize = 1;
  var endofline = lbl: {
    if (std.mem.eql(u8, args[arg_i], "--zero") or std.mem.eql(u8, args[arg_i], "-z")) {
      arg_i += 1;
      break :lbl [1]u8 { 0 };
    } else {
      break :lbl [1]u8 { '\n' };
    }
  };

  while (arg_i < args.len) : (arg_i += 1) {
    const basename = std.fs.path.basename(args[arg_i]);
    var i = basename.len - 1;
    while (i > 0) : (i -= 1) {
      if (basename[i] == '.') {
        break;
      }
    }
    if (i > 0) {
      try stdout_w.writeAll(basename[0..i]);
    } else {
      try stdout_w.writeAll(basename);
    }
    try stdout_w.writeAll(&endofline);
  }

  return 0;
}

