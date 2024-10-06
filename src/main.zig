const std = @import("std");
const token = @import("token.zig");
const lexer = @import("lexer.zig");
const Lexer = lexer.Lexer;

pub fn main() !void {
    //const tok = token.Token{ .type = "sometype", .literal = "=" };
    //std.debug.print("t: {s}, l: {s}\n", .{ tok.type, tok.literal });

    const input = "=+():,";
    //const Expected = struct { e_type: token.TokenType, literal: []const u8 };

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const l: *Lexer = try Lexer.init(allocator, input);
    defer allocator.destroy(l);

    //const tests = [_]Expected{
    //    .{ .e_type = token.EQUAL, .literal = "=" },
    //    .{ .e_type = token.PLUS, .literal = "+" },
    //    .{ .e_type = token.LPAR, .literal = "(" },
    //    .{ .e_type = token.RPAR, .literal = ")" },
    //    .{ .e_type = token.COLON, .literal = ":" },
    //    .{ .e_type = token.COMMA, .literal = "," },
    //    .{ .e_type = token.ENDMARKER, .literal = "0" },
    //};

    //for (tests) |t| {
    //    const tok = l.nextToken();
    //    //defer testing.allocator.free(tok);
    //    defer testing.allocator.destroy(tok);

    //    try testing.expectEqualSlices(u8, t.literal, tok.literal);
    //    try testing.expectEqualSlices(u8, t.e_type, tok.type);
    //}

    //TODO: error handling and capture error
    for (input) |_| {
        const tok = try l.nextToken();
        std.debug.print("main.zig:main: type of tok: {any}\n", .{@TypeOf(tok)});
        //std.debug.print("\ntok.type: {s} | tok.literal: {s}", .{ tok.type, tok.literal });

        // this is unreachable => eithr struct is deallocated or fields are not properly
        // initialized or smth
        //std.debug.print("\nmain: l.input: {s} | l.pos: {} | l.read_pos: {} | l.ch: {c}\n", .{ l.input, l.position, l.read_position, l.ch });

        //std.debug.assert(tok.literal == c);
    }
}

//test "simple test" {
//    var list = std.ArrayList(i32).init(std.testing.allocator);
//    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
//    try list.append(42);
//    try std.testing.expectEqual(@as(i32, 42), list.pop());
//}
