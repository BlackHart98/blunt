// recursive descent parser
const std = @import("std");
const lexer = @import("lexer.zig");
const ast = @import("ast.zig");
const _utils = @import("../utils.zig");

const ParseError = error{ ParseError, OutOfMemory, UnsupportedToken };
const TokenCategory = enum { str, id, num, cmt };
pub fn ParseResult(comptime T: type) type {
    return ParseError!struct {
        node: T,
        end: usize,
    };
}

// Still trying to wrap my head around Zig
pub fn parseCompilationUnit(allocator: std.mem.Allocator, tokens: ?[]const lexer.Token) ParseResult(ast.CompilationUnit) {
    var importList = std.ArrayList(*const ast.Import).init(allocator);
    errdefer importList.deinit();
    var statementList = std.ArrayList(*const ast.Statement).init(allocator);
    errdefer statementList.deinit();
    const N = tokens.?.len;
    var i: usize = 0;
    while (i < N) : (i += 1) {
        if (_expect(lexer.Keyword, tokens.?[i], .import_)) {
            while (i < N and _expect(lexer.Keyword, tokens.?[i], .import_)) {
                const import = try allocator.create(ast.Import);
                errdefer allocator.destroy(import);
                const temp_ = try parseImport(tokens, i);
                import.* = temp_.node;
                try importList.append(import);
                i = temp_.end - 1;
            }
        } else {
            const statement = try allocator.create(ast.Statement);
            errdefer allocator.destroy(statement);
            const temp_ = try parseStatement(allocator, tokens, i);
            statement.* = temp_.node;
            try statementList.append(statement);
            i = temp_.end - 1;
        }
    }
    var imports: ?[]*const ast.Import = null;
    var statements: ?[]*const ast.Statement = null;

    if (importList.items.len > 0) {
        imports = try importList.toOwnedSlice();
    }
    if (statementList.items.len > 0) {
        statements = try statementList.toOwnedSlice();
    }
    return .{ .node = ast.CompilationUnit{
        .import_decls = imports,
        .statements = statements,
        .position = 0,
        .length = 0,
        .line_no = 1,
    }, .end = i };
}

pub inline fn parseImport(tokens: ?[]const lexer.Token, index: usize) ParseResult(ast.Import) {
    var i: usize = index + 1;
    const N = tokens.?.len;
    var importNode: ast.Import = ast.Import{
        .import = null,
        .alias = null,
        .position = 0,
        .length = 0,
        .line_no = 0,
    };
    var aliasNode: ast.Alias = undefined;
    var module: *const lexer.Token = undefined;
    if (i >= N) {
        return ParseError.ParseError;
    }
    if (_expect(lexer.BluntSymbol, tokens.?[i], .open_par_)) {
        i += 1;
    }
    if (i >= N) {
        return ParseError.ParseError;
    }
    if (_expect(TokenCategory, tokens.?[i], .str)) {
        module = &tokens.?[i];
        i += 1;
    }
    if (i >= N) {
        return ParseError.ParseError;
    }
    if (_expect(lexer.BluntSymbol, tokens.?[i], .close_par_)) {
        i += 1;
    }
    if (i >= N) {
        return ParseError.ParseError;
    }
    if (_expect(lexer.Keyword, tokens.?[i], .as_)) {
        i += 1;
    }
    if (i >= N) {
        return ParseError.ParseError;
    }
    if (_expect(TokenCategory, tokens.?[i], .id)) {
        const temp_ = try parseAlias(tokens, i);
        aliasNode = temp_.node;
        i = temp_.end;
        importNode = ast.Import{
            .import = module,
            .alias = aliasNode,
            .position = temp_.node.position,
            .length = temp_.node.length,
            .line_no = temp_.node.line_no,
        };
        return .{ .node = importNode, .end = i };
    }
    return ParseError.ParseError;
}

pub fn parseStatement(allocator: std.mem.Allocator, tokens: ?[]const lexer.Token, index: usize) ParseResult(ast.Statement) {
    if (_expect(lexer.Keyword, tokens.?[index], .fn_)) {
        return try parseFunctionDef(allocator, tokens, index);
    } else if (_expect(lexer.Keyword, tokens.?[index], .const_) or _expect(lexer.Keyword, tokens.?[index], .var_)) {
        const declaration_desc = tokens.?[index].keyword_token.token_type;
        return try parseDeclarationStmt(declaration_desc, allocator, tokens, index);
    } else {
        return ParseError.ParseError;
    }
}

pub inline fn parseAlias(tokens: ?[]const lexer.Token, index: usize) ParseResult(ast.Alias) {
    if (_expect(TokenCategory, tokens.?[index], .id)) {
        const temp_ = try parseIdentifier(tokens, index);
        return .{ .node = ast.Alias{
            .alias = temp_.node,
            .position = temp_.node.position,
            .length = temp_.node.length,
            .line_no = temp_.node.line_no,
        }, .end = temp_.end };
    }
    return ParseError.ParseError;
}

pub inline fn parseIdentifier(tokens: ?[]const lexer.Token, index: usize) ParseResult(ast.Identifier) {
    if (_expect(TokenCategory, tokens.?[index], .id)) {
        return .{ .node = ast.Identifier{
            .identifier = &tokens.?[index],
            .position = tokens.?[index].identifier_token.position,
            .length = tokens.?[index].identifier_token.length,
            .line_no = tokens.?[index].identifier_token.line_no,
        }, .end = index + 1 };
    } else {
        return ParseError.ParseError;
    }
}

pub fn parseFunctionDef(allocator: std.mem.Allocator, tokens: ?[]const lexer.Token, index: usize) ParseResult(ast.Statement) {
    var i: usize = index + 1;
    const N = tokens.?.len;
    var parameterList = std.ArrayList(*const ast.Parameter).init(allocator);
    errdefer parameterList.deinit();
    var statementList = std.ArrayList(*const ast.Statement).init(allocator);
    errdefer statementList.deinit();
    const identifier = try parseIdentifier(tokens, i);
    i = identifier.end;
    if (i >= N) {
        return ParseError.ParseError;
    }
    if (_expect(lexer.BluntSymbol, tokens.?[i], .open_par_)) {
        i += 1;
        var j: usize = i;
        while (j < N) : (j += 1) {
            if (_expect(lexer.BluntSymbol, tokens.?[j], .close_par_)) {
                j += 1;
                break;
            } else {
                const parameter = try allocator.create(ast.Parameter);
                errdefer allocator.destroy(parameter);
                const temp_ = try parseParameter(allocator, tokens, j);
                parameter.* = temp_.node;
                try parameterList.append(parameter);
                j = temp_.end - 1;
            }
        }
        i = j;
    }
    if (i >= N) {
        return ParseError.ParseError;
    }
    if (_expect(lexer.BluntSymbol, tokens.?[i], .fwd_arr_)) {
        i += 1;
    }
    if (i >= N) {
        return ParseError.ParseError;
    }

    const type_symbol = parseType(allocator, tokens, i)
        catch |err| {
            std.debug.print("Got out! .... error\n", .{});
            return err;
        };
    i = type_symbol.end;
    // std.debug.print("Got out, You're broke, Mr. {?}\n", .{tokens.?[i]});

    if (_expect(lexer.BluntSymbol, tokens.?[i], .open_curly_)) {
        i += 1;
        var j: usize = i;
        while (j < N) : (j += 1) {
            if (_expect(lexer.BluntSymbol, tokens.?[j], .close_curly_)) {
                const function_statement = try allocator.create(ast.Statement);
                errdefer allocator.destroy(function_statement);
                function_statement.* = ast.Statement{ .function_def = .{
                    .function_id = identifier.node,
                    .parameters = null,
                    .return_type = type_symbol.node,
                    .statements = null,
                    .position = tokens.?[j].blunt_symbol.position,
                    .length = tokens.?[j].blunt_symbol.length,
                    .line_no = tokens.?[j].blunt_symbol.line_no,
                } };
                return .{ .node = function_statement.*, .end = j + 1 };
            } else {
                const statement = try allocator.create(ast.Statement);
                errdefer allocator.destroy(statement);
                const temp_ = try parseStatement(allocator, tokens, j);
                statement.* = temp_.node;
                try statementList.append(statement);
                j = temp_.end - 1;
            }
        }
        i = j;
        return ParseError.ParseError;
    } else {
        return ParseError.ParseError;
    }
}

pub inline fn parseDeclarationStmt(declaration_desc: ?lexer.Keyword, allocator: std.mem.Allocator, tokens: ?[]const lexer.Token, index: usize) ParseResult(ast.Statement) {
    var i: usize = index;
    i += 1;
    if (_expect(TokenCategory, tokens.?[i], .id)) {
        const variable_result = try parseIdentifier(tokens, i);
        i += 1;
        if (!_expect(lexer.BluntSymbol, tokens.?[i], .colon_)){
            return ParseError.ParseError;
        }
        i += 1;
        const type_result = try parseType(allocator, tokens, i);

        i = type_result.end;

        if (_expect(lexer.BluntSymbol, tokens.?[i], .bind_)){
            const declaration_statement = try allocator.create(ast.Statement);
            errdefer allocator.destroy(declaration_statement);
            i += 1;
            
            _ = try parseExpr(allocator, tokens, i);

            // declaration_statement.* = ast.Statement{
            //     .declaration_stmt = .{
            //         .declaration_desc = declaration_desc,
            //         .variable = variable_result.node,
            //         .expr = null,
            //         .position = 0,
            //         .length = 0,
            //         .line_no = 0,
            //     }
            // };
        } else {
            const declaration_statement = try allocator.create(ast.Statement);
            errdefer allocator.destroy(declaration_statement);
            const type_annotation = try allocator.create(ast.Type);
            errdefer allocator.destroy(type_annotation);
            type_annotation.* = type_result.node;
            i = type_result.end;
            if (!_expect(lexer.BluntSymbol, tokens.?[i], .semi_colon_)){
                return ParseError.ParseError;
            }

            declaration_statement.* = ast.Statement{
                .declaration_stmt = .{
                    .declaration_desc = declaration_desc,
                    .variable = variable_result.node,
                    .type_ =  type_annotation,
                    .expr = null,
                    .position = index,
                    .length = i,
                    .line_no = tokens.?[index].keyword_token.line_no,

                }
            };
            std.debug.print("my mind is fatigued, {any} ..........\n", .{declaration_statement});
            return .{ .node = declaration_statement.*, .end = i + 1 };
        }
    }
    return ParseError.ParseError;
}


pub inline fn parseParameter(_: std.mem.Allocator, _: ?[]const lexer.Token, _: usize) ParseResult(ast.Parameter) {
    return ParseError.ParseError;
}


// prefix notation
pub inline fn parseExpr(allocator: std.mem.Allocator, tokens: ?[]const lexer.Token, index: usize) ParseResult(ast.Expr){
    const i: usize = index;
    const N = tokens.?.len;
    const expr_stack = _utils.Stack(ast.Expr, 500).init(allocator);
    // errdefer expr_node.deinit();
    std.debug.print("info: trying to parse expression!{any}_________{?} current stack size {?}\n", .{tokens.?[i], N, expr_stack.top});
    // while (i < )
    return ParseError.ParseError;
}


pub fn parseType(allocator: std.mem.Allocator, tokens: ?[]const lexer.Token, index: usize) ParseResult(ast.Type) {
    var i: usize = index;
    const N: usize = tokens.?.len;
    if (_expect(lexer.Keyword, tokens.?[i], .void_)) {
        return .{ .node = ast.Type{ .primitive_type = .{ .primitive_type = ast.PrimitiveTypeEnum.VoidType, .position = tokens.?[i].keyword_token.position, .length = tokens.?[i].keyword_token.length, .line_no = tokens.?[i].keyword_token.line_no } }, .end = i + 1 };
    } else if (_expect(lexer.Keyword, tokens.?[i], .int_)) {
        return .{ .node = ast.Type{ .primitive_type = .{ .primitive_type = ast.PrimitiveTypeEnum.IntType, .position = tokens.?[i].keyword_token.position, .length = tokens.?[i].keyword_token.length, .line_no = tokens.?[i].keyword_token.line_no } }, .end = i + 1 };
    } else if (_expect(lexer.Keyword, tokens.?[i], .str_)) {
        return .{ .node = ast.Type{ .primitive_type = .{ .primitive_type = ast.PrimitiveTypeEnum.StringType, .position = tokens.?[i].keyword_token.position, .length = tokens.?[i].keyword_token.length, .line_no = tokens.?[i].keyword_token.line_no } }, .end = i + 1 };
    } else if (_expect(lexer.Keyword, tokens.?[i], .real_)) {
        return .{ .node = ast.Type{ .primitive_type = .{ .primitive_type = ast.PrimitiveTypeEnum.RealType, .position = tokens.?[i].keyword_token.position, .length = tokens.?[i].keyword_token.length, .line_no = tokens.?[i].keyword_token.line_no } }, .end = i + 1 };
    } else if (_expect(lexer.Keyword, tokens.?[i], .num_)) {
        return .{ .node = ast.Type{ .primitive_type = .{ .primitive_type = ast.PrimitiveTypeEnum.RealType, .position = tokens.?[i].keyword_token.position, .length = tokens.?[i].keyword_token.length, .line_no = tokens.?[i].keyword_token.line_no } }, .end = i + 1 };
    } else if (_expect(lexer.Keyword, tokens.?[i], .list_)) {
        const type_posistion = tokens.?[i].keyword_token.position;
        const type_line_no = tokens.?[i].keyword_token.line_no;
        i += 1;
        // std.debug.print("You're broke, Mr. {?}\n", .{tokens.?[i]});
        if (i >= N) {
            return ParseError.ParseError;
        } else if (_expect(lexer.BluntSymbol, tokens.?[i], .open_bracket_)) {
            i += 1;
            // std.debug.print("Got here, You're broke, Mr. {?}\n", .{tokens.?[i]});
            const type_symbol = try parseType(allocator, tokens, i);
            i = type_symbol.end;
            // std.debug.print("Got here again, You're broke, Mr. {?}\n", .{tokens.?[i]});
            const list_type_ptr = try allocator.create(ast.Type);
            list_type_ptr.* = type_symbol.node;
            if (_expect(lexer.BluntSymbol, tokens.?[i], .close_bracket_)) {
                // std.debug.print("Got here finally, You're broke, Mr. {?}\n", .{tokens.?[i]});
                return .{ .node = ast.Type{ .list_type = .{ .list_type = list_type_ptr, .position = type_posistion, .length = tokens.?[i].blunt_symbol.line_no, .line_no = type_line_no } }, .end = i + 1 };
            }
            return ParseError.ParseError;
        }
        return ParseError.ParseError;
    } else if (_expect(lexer.Keyword, tokens.?[i], .real_)) {
        return .{ .node = ast.Type{ .primitive_type = .{ .primitive_type = ast.PrimitiveTypeEnum.RealType, .position = tokens.?[i].keyword_token.position, .length = tokens.?[i].keyword_token.length, .line_no = tokens.?[i].keyword_token.line_no } }, .end = i + 1 };
    } else if (_expect(lexer.Keyword, tokens.?[i], .map_)) {
        return .{ .node = ast.Type{ .primitive_type = .{ .primitive_type = ast.PrimitiveTypeEnum.RealType, .position = tokens.?[i].keyword_token.position, .length = tokens.?[i].keyword_token.length, .line_no = tokens.?[i].keyword_token.line_no } }, .end = i + 1 };
    }
    return ParseError.ParseError;
}

// --------------- utils

fn _expect(comptime T: type, token: lexer.Token, token_target: ?T) bool {
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
    } else if (T == TokenCategory) {
        if (token_target.? == .str) {
            switch (token) {
                .str_lit_single => {
                    return true;
                },
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


fn precedence() u8{
    return 0;
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