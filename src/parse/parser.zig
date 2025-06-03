// recursive descent parser
const std = @import("std");
const lexer = @import("lexer.zig");
const ast = @import("ast.zig");
const _utils = @import("../utils.zig");
const io = std.debug;

const ParseError = error{ ParseError, OutOfMemory, UnsupportedToken, InternalError };
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

pub fn parseIdentifier(tokens: ?[]const lexer.Token, index: usize) ParseResult(ast.Identifier) {
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
    var i: usize = index + 1;
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
            io.print("foo bar, finally ... so I can rest {?}\n", .{try parseExpr(allocator, tokens, i)});
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


pub fn parseExpr(allocator: std.mem.Allocator, tokens: ?[]const lexer.Token, index: usize) ParseResult(ast.Expr){
    io.print("my mind is fatigued, ..........\n", .{});
    return try parseAddOrSubExpr(allocator, tokens, index);
}


// recursive parser arranged according to precendence
pub fn parseAddOrSubExpr(allocator: std.mem.Allocator, tokens: ?[]const lexer.Token, index: usize) ParseResult(ast.Expr){
    io.print("my mind is fatigued, .......... parseAddOrSubExpr\n", .{});
    var i = index;
    const N = tokens.?.len;
    var factor_result = try parseMulOrDivExpr(allocator, tokens, index);
    io.print("my mind is end parsing mul or div, .......... parseAddOrSubExpr {?} ============ \n\t{?}\n", .{factor_result.node, tokens.?[factor_result.end]});
    const expr_node = try allocator.create(ast.Expr);
    errdefer allocator.destroy(expr_node);
    expr_node.* = factor_result.node;
    i = factor_result.end;
    while (i < N) : (i += 1){
        io.print("trying to pass the rest of the the addition expression {?}\n", .{tokens.?[i]});
        if (_expect(lexer.BluntSymbol, tokens.?[i], .minus_) or _expect(lexer.BluntSymbol, tokens.?[i], .plus_)){
            io.print("found plus operator\n", .{});
            const op = tokens.?[i];
            i += 1;
            if (i >= N) return ParseError.ParseError;

            const right_node = try allocator.create(ast.Expr);
            errdefer allocator.destroy(right_node);
            factor_result = try parseMulOrDivExpr(allocator, tokens, i);
            right_node.* = factor_result.node;
            i = factor_result.end;
            if (i >= N) return ParseError.ParseError;

            io.print("creating node...", .{});
            expr_node.* = try makeBinaryNode(allocator, op, right_node.*, expr_node.*);
        } else {
            return .{.node = expr_node.*, .end = i}; 
        }
    }
    return .{.node = expr_node.*, .end = i}; 
}



pub fn parseMulOrDivExpr(allocator: std.mem.Allocator, tokens: ?[]const lexer.Token, index: usize) ParseResult(ast.Expr){
    io.print("my mind is fatigued, .......... parseMulOrDivExpr\n", .{});
    var i = index;
    const N = tokens.?.len;
    var factor_result = try parseDotExpr(allocator, tokens, index);
    const expr_node = try allocator.create(ast.Expr);
    errdefer allocator.destroy(expr_node);
    expr_node.* = factor_result.node;
    i = factor_result.end;
    while (i < N) : (i += 1){
        if (_expect(lexer.BluntSymbol, tokens.?[i], .div_) or _expect(lexer.BluntSymbol, tokens.?[i], .mul_)){
            const op = tokens.?[i];
            i += 1;
            if (i >= N) return ParseError.ParseError;

            const right_node = try allocator.create(ast.Expr);
            errdefer allocator.destroy(right_node);
            factor_result = try parseDotExpr(allocator, tokens, i);
            right_node.* = factor_result.node;
            i = factor_result.end;
            if (i >= N) return ParseError.ParseError;

            expr_node.* = try makeBinaryNode(allocator, op, right_node.*, expr_node.*);
        } else {
            return .{.node = expr_node.*, .end = i}; 
        }
    }
    return .{.node = expr_node.*, .end = i}; 
}


pub fn parseDotExpr(allocator: std.mem.Allocator, tokens: ?[]const lexer.Token, index: usize) ParseResult(ast.Expr){
    io.print("my mind is fatigued, .......... parseDotExpr\n", .{});
    var i = index;
    const N = tokens.?.len;
    var factor_result = try parseFactor(allocator, tokens, i);
    const expr_node = try allocator.create(ast.Expr);
    errdefer allocator.destroy(expr_node);
    expr_node.* = factor_result.node;
    i = factor_result.end;
    while (i < N) : (i += 1){
        if (_expect(lexer.BluntSymbol, tokens.?[i], .dot_)){
            const op = tokens.?[i];
            i += 1;
            if (i >= N) return ParseError.ParseError;

            const right_node = try allocator.create(ast.Expr);
            errdefer allocator.destroy(right_node);
            factor_result = try parseFactor(allocator, tokens, i);
            right_node.* = factor_result.node;
            i = factor_result.end;
            if (i >= N) return ParseError.ParseError;

            expr_node.* = try makeBinaryNode(allocator, op, right_node.*, expr_node.*);
        } else {
            return .{.node = expr_node.*, .end = i}; 
        }
    }
    return .{.node = expr_node.*, .end = i}; 
}

pub fn parseFactor(allocator: std.mem.Allocator, tokens: ?[]const lexer.Token, index: usize) ParseResult(ast.Expr){
    io.print("my mind is fatigued, .......... parseFactor>>>>>>>>> {?}\n", .{tokens.?[index]});
    var i = index;
    const N = tokens.?.len;
    if (_expect(lexer.BluntSymbol, tokens.?[i], .open_par_)){
        i += 1;
        if (i >= N) return ParseError.ParseError;
        const expr_result = try parseExpr(allocator, tokens, i);
        const node = try allocator.create(ast.Expr);
        errdefer allocator.destroy(node);
        node.* = expr_result.node;
        i = expr_result.end;
        if (i >= N) return ParseError.ParseError;
        // io.print("my mind is fatigued, .......... almost closed parenthesis {?}\n", .{expr_result});
        io.print("my mind is fatigued, .......... almost closed parenthesis {?}\n", .{tokens.?[i - 1]});
        if (_expect(lexer.BluntSymbol, tokens.?[i - 1], .close_par_)){
            io.print("my mind is fatigued, .......... closed parenthesis\n", .{});
            return .{.node = node.*, .end = i + 1}; 
        } else {
            return ParseError.ParseError;
        }
    } else if (_expect(TokenCategory, tokens.?[i], .id)){
        const identifier = try parseIdentifier(tokens, i);
        io.print("my mind is fatigued, .......... parseIdentifier {?}\n", .{tokens.?[identifier.end]});
        return .{.node = .{ 
            .identifier = ast.Identifier{
                .identifier = identifier.node.identifier
                , .position = identifier.node.position
                , .length = identifier.node.length
                , .line_no = identifier.node.line_no}
            }
            , .end = identifier.end}; 
    }
    return ParseError.ParseError;
} 


pub fn makeBinaryNode(_: std.mem.Allocator, operator: lexer.Token, right_node: ast.Expr, node: ast.Expr) !ast.Expr{
    const loc = try getLineNumberExpr(right_node);
    switch (operator.blunt_symbol.token_type){
        .dot_ =>{
            return ast.Expr{
                .binary_op = ast.BinaryOp{
                .op = .Dot,
                .left = &node,
                .right = &right_node,
                .position = loc.position,
                .length = loc.length,
                .line_no = loc.line_no
            }};
        },
        .minus_ =>{
            return ast.Expr{
                .binary_op = ast.BinaryOp{
                .op = .Sub,
                .left = &node,
                .right = &right_node,
                .position = loc.position,
                .length = loc.length,
                .line_no = loc.line_no
            }};
        },
        .plus_ =>{
            return ast.Expr{
                .binary_op = ast.BinaryOp{
                .op = .Add,
                .left = &node,
                .right = &right_node,
                .position = loc.position,
                .length = loc.length,
                .line_no = loc.line_no
            }};
        },
        .div_ =>{
            return ast.Expr{
                .binary_op = ast.BinaryOp{
                    .op = .Div,
                    .left = &node,
                    .right = &right_node,
                    .position = loc.position,
                    .length = loc.length,
                    .line_no = loc.line_no
                }};
        },
        .mul_ =>{
            return ast.Expr{
                .binary_op = ast.BinaryOp{
                .op = .Mul,
                .left = &node,
                .right = &right_node,
                .position = loc.position,
                .length = loc.length,
                .line_no = loc.line_no
            }};
        },
        .eq_ =>{
            return ast.Expr{
                .binary_op = ast.BinaryOp{
                .op = .Eq,
                .left = &node,
                .right = &right_node,
                .position = loc.position,
                .length = loc.length,
                .line_no = loc.line_no
            }};
        },
        .neq_ =>{
            return ast.Expr{
                .binary_op = ast.BinaryOp{
                .op = .Neq,
                .left = &node,
                .right = &right_node,
                .position = loc.position,
                .length = loc.length,
                .line_no = loc.line_no
            }};
        },
        .gt_ =>{
            return ast.Expr{
                .binary_op = ast.BinaryOp{
                .op = .Gt,
                .left = &node,
                .right = &right_node,
                .position = loc.position,
                .length = loc.length,
                .line_no = loc.line_no
            }};
        },
        .lt_ =>{
            return ast.Expr{
                .binary_op = ast.BinaryOp{
                .op = .Lt,
                .left = &node,
                .right = &right_node,
                .position = loc.position,
                .length = loc.length,
                .line_no = loc.line_no
            }};
        },
        .gte_ =>{
            return ast.Expr{
                .binary_op = ast.BinaryOp{
                .op = .Gte,
                .left = &node,
                .right = &right_node,
                .position = loc.position,
                .length = loc.length,
                .line_no = loc.line_no
            }};
        },
        .lte_ =>{
            return ast.Expr{
                .binary_op = ast.BinaryOp{
                .op = .Lte,
                .left = &node,
                .right = &right_node,
                .position = loc.position,
                .length = loc.length,
                .line_no = loc.line_no
            }};
        },
        .match_ =>{
            return ast.Expr{
                .binary_op = ast.BinaryOp{
                .op = .Match,
                .left = &node,
                .right = &right_node,
                .position = loc.position,
                .length = loc.length,
                .line_no = loc.line_no
            }};
        },
        .and_ =>{
            return ast.Expr{
                .binary_op = ast.BinaryOp{
                .op = .And,
                .left = &node,
                .right = &right_node,
                .position = loc.position,
                .length = loc.length,
                .line_no = loc.line_no
            }};
        },
        .or_ =>{
            return ast.Expr{
                .binary_op = ast.BinaryOp{
                .op = .Or,
                .left = &node,
                .right = &right_node,
                .position = loc.position,
                .length = loc.length,
                .line_no = loc.line_no
            }};
        },
        .pipe_ =>{
            return ast.Expr{
                .binary_op = ast.BinaryOp{
                .op = .Pipe,
                .left = &node,
                .right = &right_node,
                .position = loc.position,
                .length = loc.length,
                .line_no = loc.line_no
            }};
        },
        else => {
            return error.InternalError;
        }
    }
}

pub fn makeUnaryNode(_: std.mem.Allocator, operator: lexer.Token, operand: lexer.Token, node: ast.Expr) !ast.Expr{
    switch (operator.blunt_symbol.token_type){
        .minus_ =>{
            return ast.UnaryOp{
                .op = .UMin,
                .left = &node,
                .length = operand.length,
                .line_no = operand.line_no
            };
        },
        .plus_ =>{
            return ast.UnaryOp{
                .op = .UPlus,
                .left = &node,
                .length = operand.length,
                .line_no = operand.line_no
            };
        },
        .not_ =>{
            return ast.UnaryOp{
                .op = .Not,
                .left = &node,
                .length = operand.length,
                .line_no = operand.line_no
            };
        },
        else => {
            return error.InternalError;
        }
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
        else => {
            return error.InternalError;
        }
    }
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