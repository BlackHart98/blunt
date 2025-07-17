const std = @import("std");
const lexer = @import("../lexer/definitions.zig");
const ast = @import("../syntax/definitions.zig");
const utils = @import("../utils.zig");
const io = std.debug;


pub fn _expect(comptime T: type, token: lexer.Token, token_target: ?T) bool {
    if (T == lexer.BluntSymbol) {
        switch (token) {
            .blunt_symbol => {
                return token.blunt_symbol.token_type == token_target.?;
            },
            else => return false,
        }
    } else if (T == lexer.Keyword) {
        switch (token) {
            .keyword_token => {
                return token.keyword_token.token_type == token_target.?;
            },
            else => return false,
        }
    } else if (T == utils.TokenCategory) {
        if (token_target.? == .sstr) {
            switch (token) {
                .str_lit_single => {
                    return true;
                },
                else => return false,
            }
        } else if (token_target.? == .str) {
            switch (token) {
                .str_lit_double => {
                    return true;
                },
                else => return false,
            }
        } else if (token_target.? == .id) {
            switch (token) {
                .identifier_token => {
                    return true;
                },
                .esc_identifier_token => {
                    return true;
                },
                else => return false,
            }
        } else if (token_target.? == .cmt) {
            switch (token) {
                .coment_multi_line => {
                    return true;
                },
                .coment_single_line => {
                    return true;
                },
                else => return false,
            }
        } else if (token_target.? == .num) {
            switch (token) {
                .number => {
                    return true;
                },
                else => return false,
            }
        }
    }
    return false;
}



pub fn deinitCompilationUnit(allocator: std.mem.Allocator, unit: ast.CompilationUnit) void {
    if (unit.import_decls) |imports| {
        for (imports) |import_node| {
            allocator.destroy(import_node);
        }
        allocator.free(imports);
    }

    if (unit.statements) |statements| {
        for (statements) |statement_node| {
            allocator.destroy(statement_node);
        }
        allocator.free(statements);
    }
}

pub inline fn getLineNumberExpr(node: ast.Expr) !struct{position: usize, length: usize, line_no: usize}{
    switch(node){
        .identifier => {
            return .{
                .position = node.identifier.position,
                .length = node.identifier.length,
                .line_no = node.identifier.line_no,};
        },
        .binary_op =>{
            return .{
                .position = node.binary_op.position,
                .length = node.binary_op.length,
                .line_no = node.binary_op.line_no,};
        },
        .unary_op =>{
            return .{
                .position = node.unary_op.position,
                .length = node.unary_op.length,
                .line_no = node.unary_op.line_no,};
        },
        .function_call =>{
            return .{
                .position = node.function_call.position,
                .length = node.function_call.length,
                .line_no = node.function_call.line_no,};
        },
        .generator =>{
            return .{
                .position = node.generator.position,
                .length = node.generator.length,
                .line_no = node.generator.line_no,};
        },
        else => {
            return error.InternalError;
        }
    }
}