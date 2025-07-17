const std = @import("std");
const lexer = @import("../lexer/definitions.zig");
const ast = @import("../syntax/definitions.zig");
const utils = @import("../utils.zig");
const common = @import("common.zig");
const io = std.debug;



pub fn parseIdentifier(tokens: ?[]const lexer.Token, index: usize) utils.ParseResult(ast.Identifier) {
    if (common._expect(utils.TokenCategory, tokens.?[index], .id)) {
        return .{ .node = ast.Identifier{
            .identifier = &tokens.?[index],
            .position = tokens.?[index].identifier_token.position,
            .length = tokens.?[index].identifier_token.length,
            .line_no = tokens.?[index].identifier_token.line_no,
        }, .end = index + 1 };
    } else {
        return utils.ParseError.ParseError;
    }
}


pub inline fn parseParameter(_: std.mem.Allocator, _: ?[]const lexer.Token, _: usize) utils.ParseResult(ast.Parameter) {
    return utils.ParseError.ParseError;
}


// todo: revisit parsing types
pub fn parseType(allocator: std.mem.Allocator, tokens: ?[]const lexer.Token, index: usize) utils.ParseResult(ast.Type) {
    var i: usize = index;
    const N: usize = tokens.?.len;
    if (common._expect(lexer.Keyword, tokens.?[i], .void_)) {
        return .{ 
            .node = ast.Type{ 
                .primitive_type = .{ 
                    .primitive_type = ast.PrimitiveTypeEnum.VoidType, 
                    .position = tokens.?[i].keyword_token.position, 
                    .length = tokens.?[i].keyword_token.length, 
                    .line_no = tokens.?[i].keyword_token.line_no } }, .end = i + 1 };
    } else if (common._expect(lexer.Keyword, tokens.?[i], .int_)) {
        return .{ 
            .node = ast.Type{ 
                .primitive_type = .{ 
                    .primitive_type = ast.PrimitiveTypeEnum.IntType, 
                    .position = tokens.?[i].keyword_token.position, 
                    .length = tokens.?[i].keyword_token.length, 
                    .line_no = tokens.?[i].keyword_token.line_no } }, .end = i + 1 };
    } else if (common._expect(lexer.Keyword, tokens.?[i], .str_)) {
        return .{ 
            .node = ast.Type{ 
                .primitive_type = .{ 
                    .primitive_type = ast.PrimitiveTypeEnum.StringType, 
                    .position = tokens.?[i].keyword_token.position, 
                    .length = tokens.?[i].keyword_token.length, 
                    .line_no = tokens.?[i].keyword_token.line_no } }, .end = i + 1 };
    } else if (common._expect(lexer.Keyword, tokens.?[i], .real_)) {
        return .{ 
            .node = ast.Type{ 
                .primitive_type = .{ 
                    .primitive_type = ast.PrimitiveTypeEnum.RealType, 
                    .position = tokens.?[i].keyword_token.position, 
                    .length = tokens.?[i].keyword_token.length, 
                    .line_no = tokens.?[i].keyword_token.line_no } }, .end = i + 1 };
    } else if (common._expect(lexer.Keyword, tokens.?[i], .num_)) {
        return .{ 
            .node = ast.Type{ 
                .primitive_type = .{ 
                    .primitive_type = ast.PrimitiveTypeEnum.RealType, 
                    .position = tokens.?[i].keyword_token.position, 
                    .length = tokens.?[i].keyword_token.length, 
                    .line_no = tokens.?[i].keyword_token.line_no } }, .end = i + 1 };
    } else if (common._expect(lexer.Keyword, tokens.?[i], .list_)) {
        const type_posistion = tokens.?[i].keyword_token.position;
        const type_line_no = tokens.?[i].keyword_token.line_no;
        i += 1;
        // std.debug.print("You're broke, Mr. {?}\n", .{tokens.?[i]});
        if (i >= N) {
            return utils.ParseError.ParseError;
        } else if (common._expect(lexer.BluntSymbol, tokens.?[i], .open_bracket_)) {
            i += 1;
            // std.debug.print("Got here, You're broke, Mr. {?}\n", .{tokens.?[i]});
            const type_symbol = try parseType(allocator, tokens, i);
            i = type_symbol.end;
            // std.debug.print("Got here again, You're broke, Mr. {?}\n", .{tokens.?[i]});
            const list_type_ptr = try allocator.create(ast.Type);
            list_type_ptr.* = type_symbol.node;
            if (common._expect(lexer.BluntSymbol, tokens.?[i], .close_bracket_)) {
                // std.debug.print("Got here finally, You're broke, Mr. {?}\n", .{tokens.?[i]});
                return .{ .node = ast.Type{ .list_type = .{ 
                    .list_type = list_type_ptr, 
                    .position = type_posistion, 
                    .length = tokens.?[i].blunt_symbol.line_no, 
                    .line_no = type_line_no } }, .end = i + 1 };
            }
            return utils.ParseError.ParseError;
        }
        return utils.ParseError.ParseError;
    } else if (common._expect(lexer.Keyword, tokens.?[i], .real_)) {
        return .{ 
            .node = ast.Type{ 
                .primitive_type = .{ 
                    .primitive_type = ast.PrimitiveTypeEnum.RealType, 
                    .position = tokens.?[i].keyword_token.position, 
                    .length = tokens.?[i].keyword_token.length, 
                    .line_no = tokens.?[i].keyword_token.line_no } }, .end = i + 1 };
    } else if (common._expect(lexer.Keyword, tokens.?[i], .map_)) {
        return .{ 
            .node = ast.Type{ 
                .primitive_type = .{ 
                    .primitive_type = ast.PrimitiveTypeEnum.RealType, 
                    .position = tokens.?[i].keyword_token.position, 
                    .length = tokens.?[i].keyword_token.length, 
                    .line_no = tokens.?[i].keyword_token.line_no } }, .end = i + 1 };
    }
    return utils.ParseError.ParseError;
}



pub fn parseExpr(allocator: std.mem.Allocator, tokens: ?[]const lexer.Token, index: usize) utils.ParseResult(ast.Expr){
    io.print("parse expression, token_no: {}, cunrent_token: \n\t{}\n", .{index, tokens.?[index]});
    return try parseRelationalExpr(allocator, tokens, index);
}


pub fn parseRelationalExpr(allocator: std.mem.Allocator, tokens: ?[]const lexer.Token, index: usize) utils.ParseResult(ast.Expr) {
    io.print("parse relations expression, token_no: {}, cunrent_token: \n\t{}\n", .{index, tokens.?[index]});
    var i = index;
    const N = tokens.?.len;
    var factor_result = try parseAndOrOrExpr(allocator, tokens, i);
    const expr_node = try allocator.create(ast.Expr);
    errdefer allocator.destroy(expr_node);
    expr_node.* = factor_result.node;
    i = factor_result.end;
    while (i < N){
        if (i >= N) return utils.ParseError.ParseError;
        if (common._expect(lexer.BluntSymbol, tokens.?[i], .lte_) 
            or common._expect(lexer.BluntSymbol, tokens.?[i], .gte_)
            or common._expect(lexer.BluntSymbol, tokens.?[i], .lt_)
            or common._expect(lexer.BluntSymbol, tokens.?[i], .gt_)
            or common._expect(lexer.BluntSymbol, tokens.?[i], .neq_)
            or common._expect(lexer.BluntSymbol, tokens.?[i], .eq_)){
            const op = tokens.?[i];
            i += 1;
            if (i >= N) return utils.ParseError.ParseError;

            const right_node = try allocator.create(ast.Expr);
            errdefer allocator.destroy(right_node);
            factor_result = try parseAndOrOrExpr(allocator, tokens, i);
            right_node.* = factor_result.node;
            i = factor_result.end;
            if (i >= N) return utils.ParseError.ParseError;

            const new_node = try makeBinaryNode(allocator, op, right_node, expr_node);
            expr_node.* = new_node;
        } else {
            io.print("exiting add or sub expression {?}\n", .{tokens.?[i]});
            return .{.node = expr_node.*, .end = i}; 
        }
    }
    return utils.ParseError.InternalError;
}


pub fn parseAndOrOrExpr(allocator: std.mem.Allocator, tokens: ?[]const lexer.Token, index: usize) utils.ParseResult(ast.Expr) {
    io.print("parse and or or expression, token_no: {}, cunrent_token: \n\t{}\n", .{index, tokens.?[index]});
    var i = index;
    const N = tokens.?.len;
    var factor_result = try parseAddOrSubExpr(allocator, tokens, i);
    io.print("left expression: \n\t{?}\n", .{factor_result.node});
    const expr_node = try allocator.create(ast.Expr);
    errdefer allocator.destroy(expr_node);
    expr_node.* = factor_result.node;
    i = factor_result.end;
    while (i < N){
        if (i >= N) return utils.ParseError.ParseError;
        if (common._expect(lexer.BluntSymbol, tokens.?[i], .or_) or common._expect(lexer.BluntSymbol, tokens.?[i], .and_)){
            const op = tokens.?[i];
            i += 1;
            if (i >= N) return utils.ParseError.ParseError;

            const right_node = try allocator.create(ast.Expr);
            errdefer allocator.destroy(right_node);
            factor_result = try parseAddOrSubExpr(allocator, tokens, i);
            right_node.* = factor_result.node;
            i = factor_result.end;
            if (i >= N) return utils.ParseError.ParseError;

            // io.print("creating node...\n", .{});
            const new_node = try makeBinaryNode(allocator, op, right_node, expr_node);
            expr_node.* = new_node;
        } else {
            io.print("exiting add or sub expression {?}\n", .{tokens.?[i]});
            return .{.node = expr_node.*, .end = i}; 
        }
    }
    return .{.node = expr_node.*, .end = i};
}


// recursive parser arranged according to precendence
pub fn parseAddOrSubExpr(allocator: std.mem.Allocator, tokens: ?[]const lexer.Token, index: usize) utils.ParseResult(ast.Expr){
    io.print("parse add or sub expression, token_no: {}, cunrent_token: \n\t{}\n", .{index, tokens.?[index]});
    var i = index;
    const N = tokens.?.len;
    var factor_result = try parseMulOrDivExpr(allocator, tokens, i);
    io.print("left expression: \n\t{?}\n", .{factor_result.node});
    const expr_node = try allocator.create(ast.Expr);
    errdefer allocator.destroy(expr_node);
    expr_node.* = factor_result.node;
    i = factor_result.end;
    while (i < N){
        if (i >= N) return utils.ParseError.ParseError;
        if (common._expect(lexer.BluntSymbol, tokens.?[i], .minus_) or common._expect(lexer.BluntSymbol, tokens.?[i], .plus_)){
            // io.print("trying to pass the rest of the the add or sub expression {?}\n", .{tokens.?[i]});
            // io.print("found plus operator\n", .{});
            const op = tokens.?[i];
            i += 1;
            if (i >= N) return utils.ParseError.ParseError;

            const right_node = try allocator.create(ast.Expr);
            errdefer allocator.destroy(right_node);
            factor_result = try parseMulOrDivExpr(allocator, tokens, i);
            right_node.* = factor_result.node;
            i = factor_result.end;
            if (i >= N) return utils.ParseError.ParseError;

            // io.print("creating node...\n", .{});
            const new_node = try makeBinaryNode(allocator, op, right_node, expr_node);
            expr_node.* = new_node;
        } else {
            io.print("exiting add or sub expression {?}\n", .{tokens.?[i]});
            return .{.node = expr_node.*, .end = i}; 
        }
    }
    return .{.node = expr_node.*, .end = i}; 
}



pub fn parseMulOrDivExpr(allocator: std.mem.Allocator, tokens: ?[]const lexer.Token, index: usize) utils.ParseResult(ast.Expr){
    // io.print("my mind is fatigued, .......... parseMulOrDivExpr\n", .{});
    var i = index;
    const N = tokens.?.len;
    var factor_result = try parseCombineExpr(allocator, tokens, i);
    const expr_node = try allocator.create(ast.Expr);
    errdefer allocator.destroy(expr_node);
    expr_node.* = factor_result.node;
    i = factor_result.end;
    while (i < N){
        if (common._expect(lexer.BluntSymbol, tokens.?[i], .div_) or common._expect(lexer.BluntSymbol, tokens.?[i], .mul_)){
            const op = tokens.?[i];
            i += 1;
            if (i >= N) return utils.ParseError.ParseError;

            const right_node = try allocator.create(ast.Expr);
            errdefer allocator.destroy(right_node);
            factor_result = try parseCombineExpr(allocator, tokens, i);
            right_node.* = factor_result.node;
            i = factor_result.end;
            if (i >= N) return utils.ParseError.ParseError;

            const new_node = try makeBinaryNode(allocator, op, right_node, expr_node);
            expr_node.* = new_node;
        } else {
            return .{.node = expr_node.*, .end = i}; 
        }
    }
    return .{.node = expr_node.*, .end = i}; 
}


pub fn parseCombineExpr(allocator: std.mem.Allocator, tokens: ?[]const lexer.Token, index: usize) utils.ParseResult(ast.Expr){
    io.print("parse combine expression, token_no: {}, cunrent_token: \n\t{}\n", .{index, tokens.?[index]});
    var i = index;
    const N = tokens.?.len;
    var factor_result = try parseDotExpr(allocator, tokens, i);
    const expr_node = try allocator.create(ast.Expr);
    errdefer allocator.destroy(expr_node);
    expr_node.* = factor_result.node;
    i = factor_result.end;
    while (i < N){
        if (common._expect(lexer.BluntSymbol, tokens.?[i], .combine_)){
            const op = tokens.?[i];
            i += 1;
            if (i >= N) return utils.ParseError.ParseError;

            const right_node = try allocator.create(ast.Expr);
            errdefer allocator.destroy(right_node);
            factor_result = try parseDotExpr(allocator, tokens, i);
            right_node.* = factor_result.node;
            i = factor_result.end;
            if (i >= N) return utils.ParseError.ParseError;

            const new_node = try makeBinaryNode(allocator, op, right_node, expr_node);
            expr_node.* = new_node;
        } else {
            return .{.node = expr_node.*, .end = i}; 
        }
    }
    return .{.node = expr_node.*, .end = i}; 
}


pub fn parseDotExpr(allocator: std.mem.Allocator, tokens: ?[]const lexer.Token, index: usize) utils.ParseResult(ast.Expr){
    var i = index;
    const N = tokens.?.len;
    var factor_result = try parseFunctionCallPrime(allocator, tokens, i);
    const expr_node = try allocator.create(ast.Expr);
    errdefer allocator.destroy(expr_node);
    expr_node.* = factor_result.node;
    i = factor_result.end;
    while (i < N){
        if (common._expect(lexer.BluntSymbol, tokens.?[i], .dot_)){
            const op = tokens.?[i];
            i += 1;
            if (i >= N) return utils.ParseError.ParseError;

            const right_node = try allocator.create(ast.Expr);
            errdefer allocator.destroy(right_node);
            factor_result = try parseFunctionCallPrime(allocator, tokens, i);
            right_node.* = factor_result.node;
            i = factor_result.end;
            if (i >= N) return utils.ParseError.ParseError;

            const new_node = try makeBinaryNode(allocator, op, right_node, expr_node);
            expr_node.* = new_node;
        } else {
            return .{.node = expr_node.*, .end = i}; 
        }
    }
    return .{.node = expr_node.*, .end = i}; 
}


pub fn parseFunctionCallPrime(allocator: std.mem.Allocator, tokens: ?[]const lexer.Token, index: usize) utils.ParseResult(ast.Expr) {
    var i = index;
    const N = tokens.?.len;

    const factor_result = try parseFunctionCall(allocator, tokens, i);
    const expr_node = try allocator.create(ast.Expr);
    errdefer allocator.destroy(expr_node);
    expr_node.* = factor_result.node;
    i = factor_result.end;

    if (common._expect(lexer.BluntSymbol, tokens.?[i], .open_par_)) {
        i += 1;
        if (i >= N) return utils.ParseError.ParseError;

        var argumentList = std.ArrayList(*const ast.Expr).init(allocator);
        defer argumentList.deinit();

        while (i < N) {
            if (common._expect(lexer.BluntSymbol, tokens.?[i], .close_par_)) {
                const end_token = tokens.?[i];
                i += 1;

                return .{
                    .node = ast.Expr{
                        .function_call = .{
                            .function_id = expr_node,
                            .args = try argumentList.toOwnedSlice(),
                            .position = end_token.blunt_symbol.position,
                            .length = end_token.blunt_symbol.length,
                            .line_no = end_token.blunt_symbol.line_no,
                        },
                    },
                    .end = i,
                };
            }

            const argument_result = try parseExpr(allocator, tokens, i);
            i = argument_result.end;

            const argument_node = try allocator.create(ast.Expr);
            errdefer allocator.destroy(argument_node);
            argument_node.* = argument_result.node;
            try argumentList.append(argument_node);

            if (i < N and common._expect(lexer.BluntSymbol, tokens.?[i], .comma_)) {
                i += 1;
                continue;
            } else if (i < N and common._expect(lexer.BluntSymbol, tokens.?[i], .close_par_)) {
                continue;
            } else {
                return utils.ParseError.ParseError;
            }
        }

        return utils.ParseError.ParseError;
    }

    return .{ .node = expr_node.*, .end = i };
}

pub fn parseFunctionCall(allocator: std.mem.Allocator, tokens: ?[]const lexer.Token, index: usize) utils.ParseResult(ast.Expr) {
    var i = index;
    const N = tokens.?.len;

    const factor_result = try parseFactor(allocator, tokens, i);
    const expr_node = try allocator.create(ast.Expr);
    errdefer allocator.destroy(expr_node);
    expr_node.* = factor_result.node;
    i = factor_result.end;

    if (common._expect(lexer.BluntSymbol, tokens.?[i], .open_par_)) {
        i += 1;
        if (i >= N) return utils.ParseError.ParseError;

        var argumentList = std.ArrayList(*const ast.Expr).init(allocator);
        defer argumentList.deinit();

        while (i < N) {
            if (common._expect(lexer.BluntSymbol, tokens.?[i], .close_par_)) {
                const end_token = tokens.?[i];
                i += 1;

                return .{
                    .node = ast.Expr{
                        .function_call = .{
                            .function_id = expr_node,
                            .args = try argumentList.toOwnedSlice(),
                            .position = end_token.blunt_symbol.position,
                            .length = end_token.blunt_symbol.length,
                            .line_no = end_token.blunt_symbol.line_no,
                        },
                    },
                    .end = i,
                };
            }

            const argument_result = try parseExpr(allocator, tokens, i);
            i = argument_result.end;

            const argument_node = try allocator.create(ast.Expr);
            errdefer allocator.destroy(argument_node);
            argument_node.* = argument_result.node;
            try argumentList.append(argument_node);

            if (i < N and common._expect(lexer.BluntSymbol, tokens.?[i], .comma_)) {
                i += 1;
                continue;
            } else if (i < N and common._expect(lexer.BluntSymbol, tokens.?[i], .close_par_)) {
                continue;
            } else {
                return utils.ParseError.ParseError;
            }
        }

        return utils.ParseError.ParseError;
    }

    return .{ .node = expr_node.*, .end = i };
}


pub fn parseFactor(allocator: std.mem.Allocator, tokens: ?[]const lexer.Token, index: usize) utils.ParseResult(ast.Expr){
    // io.print("my mind is fatigued, .......... parseFactor========= {?}\n", .{tokens.?[index]});
    var i = index;
    const N = tokens.?.len;
    if (common._expect(lexer.BluntSymbol, tokens.?[i], .open_par_)){
        i += 1;
        if (i >= N) return utils.ParseError.ParseError;
        const expr_result = try parseExpr(allocator, tokens, i);
        // io.print("end of the expression {?}\n", .{expr_result});
        i = expr_result.end;
        if (i >= N) return utils.ParseError.ParseError;
        const node = try allocator.create(ast.Expr);
        errdefer allocator.destroy(node);
        node.* = expr_result.node;
        // io.print("my mind is fatigued, .......... almost closed parenthesis???????? {?}\n", .{tokens.?[i]});
        if (common._expect(lexer.BluntSymbol, tokens.?[i], .close_par_)){
            // io.print("my mind is fatigued, .......... closed parenthesis\n", .{});
            return .{.node = node.*, .end = i + 1}; 
        } else {
            return utils.ParseError.ParseError;
        }
        return utils.ParseError.ParseError;
    } else if (common._expect(utils.TokenCategory, tokens.?[i], .id)){
        const identifier = try parseIdentifier(tokens, i);
        return .{.node = .{ 
            .identifier = ast.Identifier{
                .identifier = identifier.node.identifier
                , .position = identifier.node.position
                , .length = identifier.node.length
                , .line_no = identifier.node.line_no}
            }
            , .end = identifier.end}; 
    } else if (common._expect(utils.TokenCategory, tokens.?[i], .num)){
        return .{.node = .{ 
            .number_expr = ast.Number{
                .number = tokens.?[i].number.token_type
                , .position = tokens.?[i].number.position
                , .length = tokens.?[i].number.length
                , .line_no = tokens.?[i].number.line_no}
            }
            , .end = i + 1}; 
    } else if (common._expect(utils.TokenCategory, tokens.?[i], .str)){
        return .{.node = .{ 
            .string_expr = ast.String{
                .string = tokens.?[i].str_lit_double.token_type
                , .position = tokens.?[i].str_lit_double.position
                , .length = tokens.?[i].str_lit_double.length
                , .line_no = tokens.?[i].str_lit_double.line_no}
            }
            , .end = i + 1}; 
    } else if (common._expect(utils.TokenCategory, tokens.?[i], .sstr)){
        return .{.node = .{ 
            .string_expr = ast.String{
                .string = tokens.?[i].str_lit_single.token_type
                , .position = tokens.?[i].str_lit_single.position
                , .length = tokens.?[i].str_lit_single.length
                , .line_no = tokens.?[i].str_lit_single.line_no}
            }
            , .end = i + 1}; 
    } else {
        return utils.ParseError.ParseError;
    }
} 


pub fn makeBinaryNode(allocator: std.mem.Allocator, operator: lexer.Token, right_node: *ast.Expr, node: *ast.Expr) !ast.Expr{
    const loc = try getLineNumberExpr(right_node.*);
    const left = try allocator.create(ast.Expr);
    errdefer allocator.destroy(left);
    const right = try allocator.create(ast.Expr);
    errdefer allocator.destroy(right);
    left.* = node.*;
    right.* = right_node.*;
    switch (operator.blunt_symbol.token_type){
        .dot_ =>{
            return ast.Expr{
                .binary_op = ast.BinaryOp{
                .op = .Dot,
                .left = left,
                .right = right,
                .position = loc.position,
                .length = loc.length,
                .line_no = loc.line_no
            }};
        },
        .minus_ =>{
            return ast.Expr{
                .binary_op = ast.BinaryOp{
                .op = .Sub,
                .left = left,
                .right = right,
                .position = loc.position,
                .length = loc.length,
                .line_no = loc.line_no
            }};
        },
        .plus_ =>{
            return ast.Expr{
                .binary_op = ast.BinaryOp{
                .op = .Add,
                .left = left,
                .right = right,
                .position = loc.position,
                .length = loc.length,
                .line_no = loc.line_no
            }};
        },
        .div_ =>{
            return ast.Expr{
                .binary_op = ast.BinaryOp{
                    .op = .Div,
                    .left = left,
                    .right = right,
                    .position = loc.position,
                    .length = loc.length,
                    .line_no = loc.line_no
                }};
        },
        .mul_ =>{
            return ast.Expr{
                .binary_op = ast.BinaryOp{
                .op = .Mul,
                .left = left,
                .right = right,
                .position = loc.position,
                .length = loc.length,
                .line_no = loc.line_no
            }};
        },
        .eq_ =>{
            return ast.Expr{
                .binary_op = ast.BinaryOp{
                .op = .Eq,
                .left = left,
                .right = right,
                .position = loc.position,
                .length = loc.length,
                .line_no = loc.line_no
            }};
        },
        .neq_ =>{
            return ast.Expr{
                .binary_op = ast.BinaryOp{
                .op = .Neq,
                .left = left,
                .right = right,
                .position = loc.position,
                .length = loc.length,
                .line_no = loc.line_no
            }};
        },
        .gt_ =>{
            return ast.Expr{
                .binary_op = ast.BinaryOp{
                .op = .Gt,
                .left = left,
                .right = right,
                .position = loc.position,
                .length = loc.length,
                .line_no = loc.line_no
            }};
        },
        .lt_ =>{
            return ast.Expr{
                .binary_op = ast.BinaryOp{
                .op = .Lt,
                .left = left,
                .right = right,
                .position = loc.position,
                .length = loc.length,
                .line_no = loc.line_no
            }};
        },
        .gte_ =>{
            return ast.Expr{
                .binary_op = ast.BinaryOp{
                .op = .Gte,
                .left = left,
                .right = right,
                .position = loc.position,
                .length = loc.length,
                .line_no = loc.line_no
            }};
        },
        .lte_ =>{
            return ast.Expr{
                .binary_op = ast.BinaryOp{
                .op = .Lte,
                .left = left,
                .right = right,
                .position = loc.position,
                .length = loc.length,
                .line_no = loc.line_no
            }};
        },
        .match_ =>{
            return ast.Expr{
                .binary_op = ast.BinaryOp{
                .op = .Match,
                .left = left,
                .right = right,
                .position = loc.position,
                .length = loc.length,
                .line_no = loc.line_no
            }};
        },
        .and_ =>{
            return ast.Expr{
                .binary_op = ast.BinaryOp{
                .op = .And,
                .left = left,
                .right = right,
                .position = loc.position,
                .length = loc.length,
                .line_no = loc.line_no
            }};
        },
        .or_ =>{
            return ast.Expr{
                .binary_op = ast.BinaryOp{
                .op = .Or,
                .left = left,
                .right = right,
                .position = loc.position,
                .length = loc.length,
                .line_no = loc.line_no
            }};
        },
        .pipe_ =>{
            return ast.Expr{
                .binary_op = ast.BinaryOp{
                .op = .Pipe,
                .left = left,
                .right = right,
                .position = loc.position,
                .length = loc.length,
                .line_no = loc.line_no
            }};
        },
        .combine_ =>{
            return ast.Expr{
                .binary_op = ast.BinaryOp{
                .op = .Combine,
                .left = left,
                .right = right,
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

pub fn makeUnaryNode(operator: lexer.Token, operand: lexer.Token, node: ast.Expr) !ast.Expr{
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
