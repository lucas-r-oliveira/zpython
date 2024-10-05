const std = @import("std");
const testing = std.testing;
const token = @import("token.zig");
const Allocator = std.mem.Allocator;

pub const Lexer = struct {
    input: []const u8, // for ease of use we'll consider the input to be a string
    position: u8 = 0,
    read_position: u8 = 0,
    ch: u8 = undefined, // this is supposed to be a byte. However, consider the case where we're supporting UTF-8

    pub fn init(allocator: Allocator, input: []const u8) !*Lexer {
        const l: *Lexer = try allocator.create(Lexer);
        l.* = .{
            .input = input,
        };

        return l;
    }

    // Can I do this? -> EDIT: guess not
    pub fn deinit(self: Lexer, allocator: Allocator) void {
        allocator.destroy(self);
    }

    //DEPRECATED -> Dangling pointer
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
            self.ch = input[self.read_position];
        }
        self.position = self.read_position;
        self.read_position += 1;
    }

    pub fn nextToken(self: *Lexer) token.Token {
        var tok: token.Token = undefined;

        switch (self.ch) {
            '=' => tok = token.Token{ .type = token.EQUAL, .literal = &[_]u8{self.ch} }, //newToken(token.EQUAL, self.ch),
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
        std.log.warn("\npre-return tok.literal: {c}\n", .{tok.literal});
        // here .literal doesn't exist already
        return tok;
    }
};

fn newToken(token_type: token.TokenType, ch: u8) token.Token {
    // everything works fine here
    return token.Token{ .type = token_type, .literal = &[_]u8{ch} };
}

test "nextToken" {
    //const Expected = struct { e_type: token.TokenType, literal: []const u8 };

    const input = "=+():,";

    // this is how you would instantiate in main
    //var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    const l: *Lexer = try Lexer.init(testing.allocator, input);
    //defer l.deinit(); //doesn't quite work as intended
    //defer l.deinit(testing.allocator);
    defer testing.allocator.destroy(l);

    //const l = Lexer.init();
    // trouble line
    //const l = Lexer.new(input);
    // workaround
    //var l = Lexer{ .input = input };

    //l.readChar();

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

    //    std.log.warn("\nt.literal: {s}; tok.literal: {s}\n", .{ t.literal, tok.literal });

    //    //try testing.expectEqualSlices(u8, t.literal, tok.literal);
    //    try testing.expectEqualSlices(u8, t.e_type, tok.type);
    //}

    try testing.expectEqualStrings(input, l.input);
}
