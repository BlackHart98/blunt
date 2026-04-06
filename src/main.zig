const std = @import("std");
const lexer = @import("lexer/definitions.zig");
const tokenizer = @import("lexer/lexer.zig");
const ast = @import("syntax/definitions.zig");
const parser = @import("syntax/statements.zig");
const io = std.debug;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const code_snippet_1 =
        \\prelude :: import("prelude");
        \\main :: proc() -> int {
        // \\  csa: int = pi(1);
        // \\  tsa :: proc() -> int {return 0;}
        // \\  return 0;
        \\}
    ;
    var loc: lexer.Position = .{.idx = 0, .line_no = 0};
    var token: ?lexer.Token = undefined;
    token, loc = tokenizer.emitToken(loc, code_snippet_1);
    while (token) |item| {
        io.print("token: `{s}`  ???  {any}  ???  {any}\n", .{tokenizer.getTokenString(item, code_snippet_1), loc, item});
        token, loc = tokenizer.emitToken(loc, code_snippet_1);
    }

    const ast_node = try parser.parse(ast.CompilationUnit, allocator, code_snippet_1);
    io.print("AST: {any}\n", .{ast_node});
}
