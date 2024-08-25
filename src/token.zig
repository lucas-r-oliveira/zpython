pub const TokenType = []const u8; // ideally, this would probably be a byte

pub const Token = struct {
    type: TokenType,
    literal: []const u8,
};

// -- let's try to see if an enum works well here
// -- EDIT: it didn't

//pub const TokenDef = enum([]const u8) {
//    ERRORTOKEN = "ERRORTOKEN",
//    ENDMARKER = "",
//
//    // Identifiers + literals
//    NAME = "NAME", //includes vars and keywords
//    NUMBER = "NUMBER",
//    NEWLINE = "\n",
//    INDENT = "  ",
//    DEDENT = "",
//
//    // Operators
//    EQUAL = "=",
//    PLUS = "+",
//
//    // Delimiters
//    LPAR = "(",
//    RPAR = ")",
//    COLON = ":",
//    COMMA = ",",
//};

// TOKENS DEFINITION
pub const ERRORTOKEN: []const u8 = "ERRORTOKEN";
pub const ENDMARKER: []const u8 = "";
//
// Identifiers + literals
pub const NAME: []const u8 = "NAME"; //includes vars and keywords
pub const NUMBER: []const u8 = "NUMBER";
pub const NEWLINE: []const u8 = "\n";
pub const INDENT: []const u8 = "  ";
pub const DEDENT: []const u8 = "";

// Operators
pub const EQUAL: []const u8 = "=";
pub const PLUS: []const u8 = "+";

// Delimiters
pub const LPAR: []const u8 = "(";
pub const RPAR: []const u8 = ")";
pub const COLON: []const u8 = ":";
pub const COMMA: []const u8 = ",";
