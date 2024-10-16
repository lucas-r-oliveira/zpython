const std = @import("std"); //deleteme
const ascii = @import("std").ascii;

pub fn isLetter(ch: u8) bool {
    //std.log.warn("\nch: {c}\n", .{ch});
    return (ascii.isAlphabetic(ch) || ch == '_');
}

pub fn isDigit(ch: u8) bool {
    // TODO: handle complex numbers
    return (ascii.isDigit(ch) || ch == '_' || (ch == 'e') || (ch == 'E') || (ch == '.'));
}
