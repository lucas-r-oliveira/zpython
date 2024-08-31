const std = @import("std");
const testing = std.testing;
const token = @import("token.zig");

pub const Lexer = struct {
    input: []const u8, // for ease of use we'll consider the input to be a string
    position: u8 = 0,
    read_position: u8 = 0,
    ch: u8 = undefined, // this is supposed to be a byte. However, consider the case where we're supporting UTF-8

    pub fn new(input: []const u8) *Lexer {
        var l: Lexer = Lexer{ .input = input, .position = 0, .read_position = 0 };
        l.readChar();
        // print here crashes the program???
        return &l;
    }

    pub fn readChar(self: *Lexer) void {
        const input = self.input[0..];
        if (self.read_position >= input.len) {
            self.ch = 0;
        } else {
            // this works
            self.ch = input[self.read_position];
        }
        // the problem has to be here
        // when i comment this my
        // terminal turns into demon mode
        self.position = self.read_position;
        self.read_position += 1;
        // print here works just fine
    }

    pub fn nextToken(self: *Lexer) token.Token {
        // this one already doesn't work
        // it looks like pos and read pos have garbage

        var tok: token.Token = undefined;

        //this prints the wrong value
        //std.debug.print("\nself.ch (nextToken): {c}\n", .{self.ch});
        switch (self.ch) {
            '=' => tok = newToken(token.EQUAL, self.ch),
            '(' => tok = newToken(token.LPAR, self.ch),
            ')' => tok = newToken(token.RPAR, self.ch),
            ',' => tok = newToken(token.COMMA, self.ch),
            '+' => tok = newToken(token.PLUS, self.ch),
            ':' => tok = newToken(token.COLON, self.ch),
            //it was supposed to be "", empty string, but
            // I haven't been able to figure it out yet
            // so for now I'll assume 0
            // Careful when actually dealing with the number 0
            0 => tok = newToken(token.ENDMARKER, self.ch), //""),
            else => tok = newToken(token.ERRORTOKEN, self.ch),
        }
        self.readChar();
        return tok;
    }
};

fn newToken(token_type: token.TokenType, ch: u8) token.Token {
    return token.Token{ .type = token_type, .literal = &[1:0]u8{ch} }; // the .literal part might fail
}

//test "nextToken" {
//    const Expected = struct { e_type: token.TokenType, literal: []const u8 };
//
//    const input = "=+():,";
//
//    const l = Lexer.new(input);
//    // print here works just fine
//
//    const tests = [_]Expected{
//        .{ .e_type = token.EQUAL, .literal = "=" },
//        .{ .e_type = token.PLUS, .literal = "+" },
//        .{ .e_type = token.LPAR, .literal = "(" },
//        .{ .e_type = token.RPAR, .literal = ")" },
//        .{ .e_type = token.COLON, .literal = ":" },
//        .{ .e_type = token.COMMA, .literal = "," },
//        .{ .e_type = token.ENDMARKER, .literal = "0" },
//    };
//
//    for (tests) |t| {
//        std.log.warn("---- NEW TEST ----", .{});
//        // print here crashes the program???
//
//        const tok = l.nextToken();
//        // also here
//
//        // std.mem.eql is how you compare two strings in zig
//        //try testing.expectEqual(t.e_type, tok.type);
//        //try testing.expectEqual(t.literal, tok.literal);
//        //try testing.expectEqua(std.mem.eql(u8, tok.literal, t.literal));
//
//        std.log.warn("\nt_literal: {s} | t.e_type: {s} | tok.literal: {s} | tok.type: {s}\n", .{ t.literal, t.e_type, tok.literal, tok.type });
//
//        try testing.expectEqualSlices(u8, t.literal, tok.literal);
//        try testing.expectEqualSlices(u8, t.e_type, tok.type);
//    }
//}
