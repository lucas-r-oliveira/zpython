const std = @import("std");
const ascii = std.ascii;
const testing = std.testing;
const token = @import("token.zig");
const util = @import("util.zig");
const TokenType = token.TokenType;
const Allocator = std.mem.Allocator;

pub const log_level: std.log.level = .info;

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
        // I forgot why I actually did this
        const input = self.input[0..];
        if (self.read_position >= input.len) {
            self.ch = 0;
        } else {
            self.ch = input[self.read_position];
        }
        self.position = self.read_position;
        self.read_position += 1;
    }

    pub fn readName(self: *Lexer) []const u8 {
        const position = self.position;
        while (util.isLetter(self.ch)) {
            self.readChar();
        }
        return self.input[position..self.position];
    }

    pub fn readNumber(self: *Lexer) []const u8 {
        const position = self.position;
        while (util.isDigit(self.ch)) {
            self.readChar();
        }
        return self.input[position..self.position];
    }

    pub fn skipWhitespace(self: *Lexer) void {
        // What the hell is this syntax? "Conditional operators cannot be chained error"
        // if I remove the parenthesis in each condition
        // TODO: confirm if \x0c == \014
        while ((self.ch == ' ') || (self.ch == '\t') || (self.ch == '\x0C')) {
            self.readChar();
        }
    }

    pub fn nextToken(self: *Lexer) !*token.Token {
        var tok: *token.Token = undefined;

        self.skipWhitespace();

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
            else => {
                if (util.isLetter(self.ch)) {
                    tok.literal = self.readName();
                    // I *think* we can safely assume name if it's here (vars, keywords, etc.)
                    tok.type = TokenType.NAME;
                    return tok;
                } else if (ascii.isDigit(self.ch)) {
                    tok.literal = self.readNumber();
                    tok.type = TokenType.NUMBER;
                } else {
                    tok = try newToken(self.allocator, TokenType.ERRORTOKEN, self.ch);
                }
            },
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

test "nextToken happy path - single tokens" {
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
test "nextToken happy path - actual program" {
    const Expected = struct { type: TokenType, literal: []const u8 };
    const input =
        \\five = 5
        \\ten = 10
        \\
        \\def add(x, y):
        \\  return x + y
        \\
        \\result = add(five, ten)
    ;
    const l: *Lexer = try Lexer.init(testing.allocator, input);
    defer testing.allocator.destroy(l);

    const tests = [_]Expected{
        .{ .type = TokenType.NAME, .literal = "five" },
        .{ .type = TokenType.EQUAL, .literal = "=" },
        .{ .type = TokenType.NUMBER, .literal = "5" },
        .{ .type = TokenType.NEWLINE, .literal = "\n" },
        .{ .type = TokenType.NAME, .literal = "ten" },
        .{ .type = TokenType.EQUAL, .literal = "=" },
        .{ .type = TokenType.NUMBER, .literal = "10" },
        .{ .type = TokenType.NEWLINE, .literal = "\n" },
        .{ .type = TokenType.NEWLINE, .literal = "\n" },
        .{ .type = TokenType.NAME, .literal = "def" },
        .{ .type = TokenType.NAME, .literal = "add" },
        .{ .type = TokenType.LPAR, .literal = "(" },
        .{ .type = TokenType.NAME, .literal = "x" },
        .{ .type = TokenType.COMMA, .literal = "," },
        // TODO: review: does the whitespace count for lexing purposes?
        .{ .type = TokenType.NAME, .literal = "y" },
        .{ .type = TokenType.RPAR, .literal = ")" },
        .{ .type = TokenType.COLON, .literal = ":" },
        .{ .type = TokenType.NEWLINE, .literal = "\n" },
        .{ .type = TokenType.INDENT, .literal = "\t" }, //this is a special one, because it can be spaces, tabs... Im going to assume tab
        .{ .type = TokenType.NAME, .literal = "return" },
        .{ .type = TokenType.NAME, .literal = "x" },
        .{ .type = TokenType.PLUS, .literal = "+" },
        .{ .type = TokenType.NAME, .literal = "y" },
        // TODO: review: newline and then dedent or the other way around?
        .{ .type = TokenType.NEWLINE, .literal = "\n" },
        // TODO: review: what is the literal for dedent?
        .{ .type = TokenType.NEWLINE, .literal = "\n" },
        .{ .type = TokenType.DEDENT, .literal = "" },
        .{ .type = TokenType.NAME, .literal = "result" },
        .{ .type = TokenType.EQUAL, .literal = "=" },
        .{ .type = TokenType.NAME, .literal = "add" },
        .{ .type = TokenType.LPAR, .literal = "(" },
        .{ .type = TokenType.NAME, .literal = "five" },
        .{ .type = TokenType.COMMA, .literal = "," },
        .{ .type = TokenType.NAME, .literal = "ten" },
        .{ .type = TokenType.RPAR, .literal = ")" },
        .{ .type = TokenType.ENDMARKER, .literal = "0" },
    };

    for (tests) |t| {
        std.log.info("\nt.type = {s}; t.literal = {s}\n", .{ @tagName(t.type), t.literal });
        const tok: *token.Token = try l.nextToken();
        defer testing.allocator.destroy(tok);
        defer testing.allocator.free(tok.literal);

        try testing.expectEqualSlices(u8, t.literal, tok.literal);
        try testing.expectEqual(t.type, tok.type);
    }
}
