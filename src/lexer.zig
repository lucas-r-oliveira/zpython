const std = @import("std");
const testing = std.testing;
const token = @import("token.zig");

test nextToken {
    const Expected = struct { e_type: token.TokenType, literal: []const u8 };

    _ = "=+():,";

    const tests = [_]Expected{
        .{ .e_type = token.EQUAL, .literal = "=" },
        .{ .e_type = token.PLUS, .literal = "+" },
        .{ .e_type = token.LPAR, .literal = "(" },
        .{ .e_type = token.RPAR, .literal = ")" },
        .{ .e_type = token.COLON, .literal = ":" },
        .{ .e_type = token.COMMA, .literal = "," },
        .{ .e_type = token.ENDMARKER, .literal = "" },
    };

    for (tests) |expected| {
        const tok = nextToken();

        try testing.expect(tok.Type == expected.e_type);
        try testing.expect(tok.Literal == expected.literal);
    }
}

pub fn nextToken() !void {}
