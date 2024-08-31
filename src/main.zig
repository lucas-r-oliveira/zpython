const std = @import("std");
const token = @import("token.zig");
const lexer = @import("lexer.zig");

pub fn main() !void {
    //const tok = token.Token{ .type = "sometype", .literal = "=" };
    //std.debug.print("t: {s}, l: {s}\n", .{ tok.type, tok.literal });

    const input = "=+():,";
    //const l = lexer.Lexer.new(&input);
    var l = lexer.Lexer{ .input = input };
    //std.debug.print("\nmain: l.input: {s} | l.pos: {d} | l.read_pos: {d} | l.ch: {c}\n", .{ l.input, l.position, l.read_position, l.ch });
    l.readChar();
    //l.readChar();
    //std.debug.print("\nmain: l.input: {s} | l.pos: {d} | l.read_pos: {d} | l.ch: {c}\n", .{ l.input, l.position, l.read_position, l.ch });

    //TODO: error handling and capture error
    for (input) |_| {
        const tok = l.nextToken();
        std.debug.print("\ntok.type: {s} | tok.literal: {s}", .{ tok.type, tok.literal });

        // this is unreachable => eithr struct is deallocated or fields are not properly
        // initialized or smth
        std.debug.print("\nmain: l.input: {s} | l.pos: {} | l.read_pos: {} | l.ch: {c}\n", .{ l.input, l.position, l.read_position, l.ch });

        //std.debug.assert(tok.literal == c);
    }
}

//test "simple test" {
//    var list = std.ArrayList(i32).init(std.testing.allocator);
//    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
//    try list.append(42);
//    try std.testing.expectEqual(@as(i32, 42), list.pop());
//}
