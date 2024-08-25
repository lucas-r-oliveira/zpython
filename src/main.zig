const std = @import("std");
const token = @import("token.zig");
const lexer = @import("lexer.zig");

pub fn main() !void {
    const tok = token.Token{ .type = "sometype", .literal = "=" };
    std.debug.print("t: {s}, l: {s}\n", .{ tok.type, tok.literal });
}

//test "simple test" {
//    var list = std.ArrayList(i32).init(std.testing.allocator);
//    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
//    try list.append(42);
//    try std.testing.expectEqual(@as(i32, 42), list.pop());
//}
