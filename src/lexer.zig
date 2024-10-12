const std = @import("std");
const testing = std.testing;
const token = @import("token.zig");
const TokenType = token.TokenType;
const Allocator = std.mem.Allocator;

pub const Lexer = struct {
    input: []const u8, // for ease of use we'll consider the input to be a string
    position: u8 = 0,
    read_position: u8 = 0,
    ch: u8 = undefined, // this is supposed to be a byte. However, consider the case where we're supporting UTF-8
    allocator: Allocator,

    pub fn init(allocator: Allocator, input: []const u8) !*Lexer {
        const l: *Lexer = try allocator.create(Lexer);
        l.* = .{
            .input = input,
            .allocator = allocator,
        };

        l.readChar();

        return l;
    }

    // DEPRECATED
    // Can I do this? -> EDIT: guess not
    pub fn deinit(self: Lexer, allocator: Allocator) void {
        allocator.destroy(self);
    }

    //DEPRECATED -> Dangling pointer
    pub fn new(input: []const u8) *Lexer {
        var l: Lexer = Lexer{ .input = input, .position = 0, .read_position = 0 };
        l.readChar();
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

    pub fn nextToken(self: *Lexer) !*token.Token {
        var tok: *token.Token = undefined;

        switch (self.ch) {
            '=' => tok = try newToken(self.allocator, TokenType.EQUAL, self.ch),
            '(' => tok = try newToken(self.allocator, TokenType.LPAR, self.ch),
            ')' => tok = try newToken(self.allocator, TokenType.RPAR, self.ch),
            ',' => tok = try newToken(self.allocator, TokenType.COMMA, self.ch),
            '+' => tok = try newToken(self.allocator, TokenType.PLUS, self.ch),
            ':' => tok = try newToken(self.allocator, TokenType.COLON, self.ch),
            0 => {
                //it was supposed to be "", empty string, but
                // I haven't been able to figure it out yet
                // so for now I'll assume 0
                // Careful when actually dealing with the number 0
                const end_char: u8 = '0';
                tok = try newToken(self.allocator, TokenType.ENDMARKER, end_char);
            },
            else => tok = try newToken(self.allocator, TokenType.ERRORTOKEN, self.ch),
        }
        self.readChar();
        return tok;
    }
};

fn newToken(allocator: Allocator, token_type: TokenType, ch: u8) !*token.Token {
    // I need to allocate memory here
    // why?
    // I have a ch
    // And I want to transform it into a slice
    // A slice is comprised of a len and a POINTER
    // therefore we're allocating memory
    // At runtime, the amount of memory necessary
    // is not known

    // where do we free this memory though?
    // Perhaps ArenaAllocator?

    // []const u8 or []u8 here?
    const tok: *token.Token = try allocator.create(token.Token);
    const alloc_slice = try allocator.alloc(u8, 1);
    alloc_slice[0] = ch;

    tok.* = .{ .type = token_type, .literal = alloc_slice };
    return tok;
}

test "nextToken happy path" {
    const Expected = struct { type: TokenType, literal: []const u8 };

    const input = "=+():,";

    // this is how you would instantiate in main
    //var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    const l: *Lexer = try Lexer.init(testing.allocator, input);
    //defer l.deinit(); //doesn't quite work as intended
    //defer l.deinit(testing.allocator); // doesn't either
    defer testing.allocator.destroy(l);

    const tests = [_]Expected{
        .{ .type = TokenType.EQUAL, .literal = "=" },
        .{ .type = TokenType.PLUS, .literal = "+" },
        .{ .type = TokenType.LPAR, .literal = "(" },
        .{ .type = TokenType.RPAR, .literal = ")" },
        .{ .type = TokenType.COLON, .literal = ":" },
        .{ .type = TokenType.COMMA, .literal = "," },
        .{ .type = TokenType.ENDMARKER, .literal = "0" },
    };

    for (tests) |t| {
        const tok: *token.Token = try l.nextToken();
        defer testing.allocator.destroy(tok);
        defer testing.allocator.free(tok.literal);

        try testing.expectEqualSlices(u8, t.literal, tok.literal);
        try testing.expectEqual(t.type, tok.type);
    }
}
