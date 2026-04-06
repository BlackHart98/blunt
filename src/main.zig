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
        \\prelude::import("prelude");
        \\main::proc() -> int {
        \\  csa := 0;
        \\}
    ;

    const ast_node = try parser.parse(ast.CompilationUnit, allocator, code_snippet_1);
    for (ast_node.decls.?) |item| {
        io.print("Declaration: {any}\n", .{item});
    }
}
