const std = @import("std");
const lexer_node = @import("lexer/definitions.zig");
const tokenizer = @import("lexer/lexer.zig");
const ast = @import("syntax/definitions.zig");
const parser = @import("syntax/statements.zig");
const common = @import("syntax/common.zig");
const io = std.debug;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var allocator = arena.allocator();
    const code_snippet_1 =
        \\@import("prelude") as prelude
        \\@import("prelude") as prelude2
        \\fn main() -> int {
        \\  const csa : int = pi()(1);
        \\  const tsa : int = 5 |>foo |>some_func;
        // \\  return 0;
        \\}
    ;
    const tokens = try tokenizer.scanInput(allocator, code_snippet_1);
    defer allocator.free(tokens);
    // std.debug.print("You're broke, Mr. {?}\n", .{foobar[1]});
    for (tokens) |x|{
        io.print("token: {?}\n", .{x});
    }

    const ast_node = try parser.parseCompilationUnit(allocator, tokens);
    defer common.deinitCompilationUnit(allocator, ast_node.node);
    // defer allocator.free(foofoo.node);
    // io.print("imports: {any}\n", .{foofoo.node.import_decls});
    // var i : usize = 0;
    // for (foofoo.node.statements.?) |x| {
    //     io.print("statement #{} {any}\n", .{i + 1, x});
    //     i += 1;
    // }
    var import_count : usize = 0;
    var statement_count : usize = 0;
    if (ast_node.node.import_decls != null){
        for(ast_node.node.import_decls.?) |_|{
            import_count += 1;
        }
    }
    if (ast_node.node.statements != null){
        for(ast_node.node.statements.?) |_|{
            statement_count += 1;
        }
    }
    io.print("summary: \n\tnumner of imports: {} \n\tnumber of statements: {}\n", .{import_count, statement_count});
}
