const TokenType = []const u8;

pub const Token = struct {
    type: TokenType,
    literal: []const u8,
};
// -- let's try to see if an enum works well here

// TOKENS DEFINITION
const TokenDef = enum([]const u8) {
    ERRORTOKEN = "ERRORTOKEN",
    ENDMARKER = "",

    // Identifiers + literals
    NAME = "NAME", //includes vars and keywords
    NUMBER = "NUMBER",
    NEWLINE = "\n",
    INDENT = "  ",
    DEDENT = "",

    // Operators
    EQUAL = "=",
    PLUS = "+",

    // Delimiters
    LPAR = "(",
    RPAR = ")",
    COLON = ":",
    COMMA = ",",
};
