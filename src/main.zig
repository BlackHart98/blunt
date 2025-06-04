const std = @import("std");
const lexer = @import("parse/lexer.zig");
const ast = @import("parse/ast.zig");
const parser = @import("parse/parser.zig");
const io = std.debug;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var allocator = arena.allocator();
    // const code_snippet =
    //     \\@import("prelude") as prelude
    //     \\
    //     \\
    //     \\data Maybe[$1] = just(content:$1) | none();
    //     \\
    //     \\fn map(x_fn : fn($1) -> $2) -> fn(list[$1]) -> list[$2]{
    //     \\    return |x_list:list[$1]| -> list[$2] {
    //     \\        return [x_fn(x) | x:$1 <- x_list];
    //     \\    }
    //     \\}
    //     \\
    //     \\fn add1(x:int) -> int {
    //     \\    return x + 1;
    //     \\}
    //     \\
    //     \\fn add2(x:int) {
    //     \\
    //     \\}
    //     \\
    //     \\fn main(args : list[str]) -> void {
    //     \\	// print("hello world\n");
    //     \\    var result = map(add1)([1,2,3,4]);
    //     \\    print(result);
    //     \\}
    // ;
    const code_snippet_1 =
        \\@import("prelude") as prelude
        \\@import("prelude") as prelude2
        // \\fn main() -> list[real] {fn main() -> int {} fn main() -> int {}}
        \\fn main() -> list[int] {
        \\  const csa : int = pi() * r * (r + h);
        \\}
    ;
    const tokens = try lexer.scanInput(allocator, code_snippet_1);
    defer allocator.free(tokens);
    // std.debug.print("You're broke, Mr. {?}\n", .{foobar[1]});
    for (tokens) |x|{
        io.print("token: {?}\n", .{x});
    }

    const ast_node = try parser.parseCompilationUnit(allocator, tokens);
    defer parser.deinitCompilationUnit(allocator, ast_node.node);
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
