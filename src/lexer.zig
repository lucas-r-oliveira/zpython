const std = @import("std");
const testing = std.testing;
const token = @import("token.zig");

const Lexer = struct {
    input: []const u8, // for ease of use we'll consider the input to be a string
    position: u16 = 0,
    read_position: u16 = 0,
    ch: u8 = undefined, // this is supposed to be a byte. However, consider the case where we're supporting UTF-8

    pub fn readChar(self: *Lexer) void {
        if (self.read_position >= self.input.len) {
            self.ch = 0;
        } else {
            self.ch = self.input[self.read_position];
        }
        self.position = self.read_position;
        self.read_position += 1;
    }

    pub fn nextToken(self: *Lexer) token.Token {
        var tok: token.Token = undefined;

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
        return tok;
    }

    pub fn new(input: []const u8) *Lexer {
        var l: Lexer = Lexer{ .input = input };
        l.readChar(); // how does this init l with the right params?
        return &l;
    }
};

fn newToken(token_type: token.TokenType, ch: u8) token.Token {
    return token.Token{ .type = token_type, .literal = &[1:0]u8{ch} }; // the .literal part might fail
}

test "nextToken" {
    const Expected = struct { e_type: token.TokenType, literal: []const u8 };

    const input = "=+():,";

    const l = Lexer.new(input);

    const tests = [_]Expected{
        .{ .e_type = token.EQUAL, .literal = "=" },
        .{ .e_type = token.PLUS, .literal = "+" },
        .{ .e_type = token.LPAR, .literal = "(" },
        .{ .e_type = token.RPAR, .literal = ")" },
        .{ .e_type = token.COLON, .literal = ":" },
        .{ .e_type = token.COMMA, .literal = "," },
        .{ .e_type = token.ENDMARKER, .literal = "0" },
    };

    for (tests) |t| {
        const tok = l.nextToken();

        // std.mem.eql is how you compare two strings in zig
        try testing.expect(std.mem.eql(u8, tok.type, t.e_type));
        try testing.expect(std.mem.eql(u8, tok.literal, t.literal));
    }
}
