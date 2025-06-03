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
        // \\@import("prelude") as prelude
        // \\@import("prelude") as prelude2
        // \\fn main() -> list[real] {fn main() -> int {} fn main() -> int {}}
        \\fn main() -> list[int] {
        \\  const foo : int = (i + ig) + y;
        \\}
    ;
    const tokens = try lexer.scanInput(allocator, code_snippet_1);
    defer allocator.free(tokens);
    // std.debug.print("You're broke, Mr. {?}\n", .{foobar[1]});
    // for (tokens) |x|{
    //     std.debug.print("You're broke, Mr. {?}\n", .{x});
    // }

    const foofoo = try parser.parseCompilationUnit(allocator, tokens);
    defer parser.deinitCompilationUnit(allocator, foofoo.node);
    // defer allocator.free(foofoo.node);
    std.debug.print("astNode: {any}\n", .{foofoo.node.statements});
    for (foofoo.node.statements.?) |x| {
        std.debug.print("You're broke, Mr. {?}\n", .{x});
    }
}
