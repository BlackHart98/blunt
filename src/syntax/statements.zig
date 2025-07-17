const std = @import("std");
const lexer = @import("../lexer/definitions.zig");
const ast = @import("../syntax/definitions.zig");
const utils = @import("../utils.zig");
const common = @import("common.zig");
const io = std.debug;
const expr = @import("expr.zig");


// Still trying to wrap my head around Zig
pub fn parseCompilationUnit(allocator: std.mem.Allocator, tokens: ?[]const lexer.Token) utils.ParseResult(ast.CompilationUnit) {
    var importList = std.ArrayList(*const ast.Import).init(allocator);
    errdefer importList.deinit();
    var statementList = std.ArrayList(*const ast.Statement).init(allocator);
    errdefer statementList.deinit();
    const N = tokens.?.len;
    var i: usize = 0;
    while (i < N) : (i += 1) {
        if (common._expect(lexer.Keyword, tokens.?[i], .import_)) {
            while (i < N and common._expect(lexer.Keyword, tokens.?[i], .import_)) {
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

pub fn parseImport(tokens: ?[]const lexer.Token, index: usize) utils.ParseResult(ast.Import) {
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
        return utils.ParseError.ParseError;
    }
    if (common._expect(lexer.BluntSymbol, tokens.?[i], .open_par_)) {
        i += 1;
    }
    if (i >= N) {
        return utils.ParseError.ParseError;
    }
    if (common._expect(utils.TokenCategory, tokens.?[i], .str)) {
        module = &tokens.?[i];
        i += 1;
    }
    if (i >= N) {
        return utils.ParseError.ParseError;
    }
    if (common._expect(lexer.BluntSymbol, tokens.?[i], .close_par_)) {
        i += 1;
    }
    if (i >= N) {
        return utils.ParseError.ParseError;
    }
    if (common._expect(lexer.Keyword, tokens.?[i], .as_)) {
        i += 1;
    }
    if (i >= N) {
        return utils.ParseError.ParseError;
    }
    if (common._expect(utils.TokenCategory, tokens.?[i], .id)) {
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
    return utils.ParseError.ParseError;
}

pub fn parseStatement(
    allocator: std.mem.Allocator, 
    tokens: ?[]const lexer.Token, 
    index: usize
) utils.ParseResult(ast.Statement) {
    if (common._expect(lexer.Keyword, tokens.?[index], .fn_)) {
        return try parseFunctionDef(allocator, tokens, index);
    } else if (common._expect(lexer.Keyword, tokens.?[index], .const_) or common._expect(lexer.Keyword, tokens.?[index], .var_)) {
        const declaration_desc = tokens.?[index].keyword_token.token_type;
        return try parseDeclarationStmt(declaration_desc, allocator, tokens, index);
    } else if (common._expect(lexer.Keyword, tokens.?[index], .if_)) {
        io.print("if statement\n", .{});
        return utils.ParseError.ParseError;
    } else if (common._expect(lexer.Keyword, tokens.?[index], .return_)) {
        io.print("return statement\n", .{});
        return utils.ParseError.ParseError;
    } else if (common._expect(lexer.Keyword, tokens.?[index], .for_)) {
        io.print("for statement\n", .{});
        return utils.ParseError.ParseError;
    }else {
        return utils.ParseError.ParseError;
    }
}

pub inline fn parseAlias(tokens: ?[]const lexer.Token, index: usize) utils.ParseResult(ast.Alias) {
    if (common._expect(utils.TokenCategory, tokens.?[index], .id)) {
        const temp_ = try expr.parseIdentifier(tokens, index);
        return .{ .node = ast.Alias{
            .alias = temp_.node,
            .position = temp_.node.position,
            .length = temp_.node.length,
            .line_no = temp_.node.line_no,
        }, .end = temp_.end };
    }
    return utils.ParseError.ParseError;
}

// pub fn parseIdentifier(tokens: ?[]const lexer.Token, index: usize) utils.ParseResult(ast.Identifier) {
//     if (common._expect(utils.TokenCategory, tokens.?[index], .id)) {
//         return .{ .node = ast.Identifier{
//             .identifier = &tokens.?[index],
//             .position = tokens.?[index].identifier_token.position,
//             .length = tokens.?[index].identifier_token.length,
//             .line_no = tokens.?[index].identifier_token.line_no,
//         }, .end = index + 1 };
//     } else {
//         return utils.ParseError.ParseError;
//     }
// }

pub fn parseFunctionDef(
    allocator: std.mem.Allocator, 
    tokens: ?[]const lexer.Token, 
    index: usize
) utils.ParseResult(ast.Statement) {
    var i: usize = index + 1;
    const N = tokens.?.len;
    var parameterList = std.ArrayList(*const ast.Parameter).init(allocator);
    errdefer parameterList.deinit();
    var statementList = std.ArrayList(*const ast.Statement).init(allocator);
    errdefer statementList.deinit();
    const identifier = try expr.parseIdentifier(tokens, i);
    i = identifier.end;
    if (i >= N) {
        return utils.ParseError.ParseError;
    }
    if (common._expect(lexer.BluntSymbol, tokens.?[i], .open_par_)) {
        i += 1;
        var j: usize = i;
        while (j < N) : (j += 1) {
            if (common._expect(lexer.BluntSymbol, tokens.?[j], .close_par_)) {
                j += 1;
                break;
            } else {
                const parameter = try allocator.create(ast.Parameter);
                errdefer allocator.destroy(parameter);
                const temp_ = try expr.parseParameter(allocator, tokens, j);
                parameter.* = temp_.node;
                try parameterList.append(parameter);
                j = temp_.end - 1;
            }
        }
        i = j;
    }
    if (i >= N) {
        return utils.ParseError.ParseError;
    }
    if (common._expect(lexer.BluntSymbol, tokens.?[i], .fwd_arr_)) {
        i += 1;
    }
    if (i >= N) {
        return utils.ParseError.ParseError;
    }

    const type_symbol = expr.parseType(allocator, tokens, i)
        catch |err| {
            std.debug.print("Got out! .... error\n", .{});
            return err;
        };
    i = type_symbol.end;
    // std.debug.print("Got out, You're broke, Mr. {?}\n", .{tokens.?[i]});

    if (common._expect(lexer.BluntSymbol, tokens.?[i], .open_curly_)) {
        i += 1;
        var j: usize = i;
        while (j < N) : (j += 1) {
            if (common._expect(lexer.BluntSymbol, tokens.?[j], .close_curly_)) {
                const function_statement = try allocator.create(ast.Statement);
                errdefer allocator.destroy(function_statement);
                function_statement.* = ast.Statement{ .function_def = .{
                    .function_id = identifier.node,
                    .parameters = null,
                    .return_type = type_symbol.node,
                    .statements = try statementList.toOwnedSlice(),
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
        return utils.ParseError.ParseError;
    } else {
        return utils.ParseError.ParseError;
    }
}

pub inline fn parseDeclarationStmt(
    declaration_desc: ?lexer.Keyword, 
    allocator: std.mem.Allocator, 
    tokens: ?[]const lexer.Token, 
    index: usize
) utils.ParseResult(ast.Statement) {
    var i: usize = index + 1;
    if (common._expect(utils.TokenCategory, tokens.?[i], .id)) {
        const variable_result = try expr.parseIdentifier(tokens, i);
        i += 1;
        if (!common._expect(lexer.BluntSymbol, tokens.?[i], .colon_)){
            return utils.ParseError.ParseError;
        }
        i += 1;
        const type_result = try expr.parseType(allocator, tokens, i);
        const type_annotation = try allocator.create(ast.Type);
        errdefer allocator.destroy(type_annotation);
        i = type_result.end;

        if (common._expect(lexer.BluntSymbol, tokens.?[i], .bind_)){
            const declaration_statement = try allocator.create(ast.Statement);
            errdefer allocator.destroy(declaration_statement);
            type_annotation.* = type_result.node;
            const expression = try allocator.create(ast.Expr);
            errdefer allocator.destroy(expression);
            i += 1;
            
            const expr_node = try expr.parseExpr(allocator, tokens, i);
            expression.* = expr_node.node;
            if (common._expect(lexer.BluntSymbol, tokens.?[expr_node.end], .semi_colon_)){
                io.print("expression seemed to parse correctly! `{?}`\n", .{expr_node.node});
            }
            io.print("exited function parsing.\n", .{});
            declaration_statement.* = ast.Statement{
                .declaration_stmt = .{
                    .declaration_desc = declaration_desc,
                    .variable = variable_result.node,
                    .type_ =  type_annotation,
                    .expr = expression,
                    .position = index,
                    .length = i,
                    .line_no = tokens.?[index].keyword_token.line_no,

                }
            };
            return .{ .node = declaration_statement.*, .end = expr_node.end + 1 };
        } else {
            const declaration_statement = try allocator.create(ast.Statement);
            errdefer allocator.destroy(declaration_statement);
            type_annotation.* = type_result.node;
            i = type_result.end;
            if (!common._expect(lexer.BluntSymbol, tokens.?[i], .semi_colon_)){
                return utils.ParseError.ParseError;
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
            // std.debug.print("my mind is fatigued, {any} ..........\n", .{declaration_statement});
            return .{ .node = declaration_statement.*, .end = i + 1 };
        }
    }
    return utils.ParseError.ParseError;
}

