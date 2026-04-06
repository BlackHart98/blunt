const std = @import("std");
const ast = @import("definitions.zig");
const lexer = @import("../lexer/definitions.zig");
const tokenizer = @import("../lexer/lexer.zig");


const ParseError = error{
    UnexpectedToken,
    UnexpectedEof,
    ExpectedIdentifier,
    ExpectedKeyword,
    ExpectedSymbol,
    ExpectedType,
};


pub fn parse(comptime T: type, allocator: std.mem.Allocator, input: []const u8) !T {
    const loc: lexer.Position = .{ .idx = 0, .line_no = 0 };
    const result, _ = try parseDispatch(T, allocator, input, loc);
    return result;
}


// internal entry — exposes loc threading to recursive callers
fn parseDispatch(comptime T: type, allocator: std.mem.Allocator, input: []const u8, loc: lexer.Position) !struct { T, lexer.Position } {
    return switch (T) {
        ast.CompilationUnit  => parseCompilationUnit(allocator, input, loc),
        ast.Declaration      => parseDeclaration(allocator, input, loc),
        ast.ConstOrVarDecl   => parseConstOrVarDecl(allocator, input, loc),
        ast.ImportVal        => parseImportVal(allocator, input, loc),
        ast.ExprOrBlock      => parseExprOrBlock(allocator, input, loc),
        ast.Expr             => parseExpr(allocator, input, loc),
        ast.Block            => parseBlock(allocator, input, loc, null),
        ast.ProcSignature    => parseProcSignature(allocator, input, loc),
        ast.Type             => parseType(allocator, input, loc),
        ast.PrimitiveType    => parsePrimitiveType(allocator, input, loc),
        ast.Statement        => parseStatement(allocator, input, loc),
        ast.AssignmentStmt   => parseAssignmentStmt(allocator, input, loc),
        ast.ProcCall         => parseProcCall(allocator, input, loc),
        ast.BinaryOp         => parseBinaryOp(allocator, input, loc),
        ast.UnaryOp          => parseUnaryOp(allocator, input, loc),
        else => @compileError("no parser registered for type: " ++ @typeName(T)),
    };
}


fn parseCompilationUnit(allocator: std.mem.Allocator, input: []const u8, loc: lexer.Position) !struct{ ast.CompilationUnit, lexer.Position } {
    var decls: std.ArrayList(ast.Declaration) = .empty;
    var cur = loc;
    while (peekToken(input, cur) != null) {
        const decl, const new_loc = try parseDeclaration(allocator, input, cur);
        try decls.append(allocator, decl);
        cur = new_loc;
    }
    return .{
        ast.CompilationUnit{
            .decls    = decls.items,
            .position = loc.idx,
            .offset   = cur.idx,
            .line_no  = loc.line_no,
        },
        cur,
    };
}


fn parseDeclaration(allocator: std.mem.Allocator, input: []const u8, loc: lexer.Position) !struct{ ast.Declaration, lexer.Position } {
    const peek = peekToken(input, loc) orelse return ParseError.UnexpectedEof;
    switch (peek) {
        .keyword_token => |k| switch (k.token_type.?) {
            .import_ => {
                const node, const new_loc = try parseImportVal(allocator, input, loc);
                const loc_2 = try expectSymbol(input, new_loc, .semi_colon_);
                return .{ ast.Declaration{ .import_decl = node }, loc_2 };
            },
            else => return ParseError.UnexpectedToken,
        },
        .identifier_token => |_| {
            const node, const new_loc = try parseConstOrVarDecl(allocator, input, loc);
            return .{ ast.Declaration{ .decl = node }, new_loc };
        },
        else => return ParseError.UnexpectedToken,
    }
}


fn parseConstOrVarDecl(allocator: std.mem.Allocator, input: []const u8, loc: lexer.Position) !struct { ast.ConstOrVarDecl, lexer.Position } {
    const id_tok, const loc1 = try expectIdentifier(input, loc);
    var type_: ?ast.Type = null;
    var loc2 = loc1;
    var is_const: bool = false;
    if (peekToken(input, loc1)) |peek| {
        switch (peek) {
            .blunt_symbol => |s| if (s.token_type == .colon_) {
                const loc_after_colon = try expectSymbol(input, loc2, .colon_);
                const loc_next_colon = expectSymbol(input, loc_after_colon, .colon_) catch null;
                if (loc_next_colon) |item| {
                    loc2 = item; is_const = true;
                } else {
                    const loc_bind = expectSymbol(input, loc_after_colon, .bind_) catch null;
                    if (loc_bind) |item| { loc2 = item; }
                    else {
                        const t, const loc_after_type = try parseType(allocator, input, loc_after_colon);
                        loc2 = loc_after_type;
                        type_ = t;
                    }
                }
            },
            else => {},
        }
    }
    var value: ?ast.Value = null;
    var loc4: ?lexer.Position = null;
    if (is_const) {
        const rval, loc4 = try parseExprOrBlock(allocator, input, loc2);
        value = .{ .const_val = ast.ConstValue{
            .type_      = type_,
            .rval       = rval,
            .position   = loc1.idx,
            .offset     = loc4.?.idx,
            .line_no    = loc1.line_no, }};
    } else {
        const rval, loc4 = try parseExprOrBlock(allocator, input, loc2);
        value = .{ .var_val = ast.VarValue{
            .type_      = type_,
            .rval       = rval,
            .position   = loc1.idx,
            .offset     = loc4.?.idx,
            .line_no    = loc1.line_no, }};
    }
    return .{
        ast.ConstOrVarDecl{
            .identifier = id_tok,
            .value      = value.?,
            .position   = loc.idx,
            .offset     = loc4.?.idx,
            .line_no    = loc1.line_no,
        }, loc4.?,};
}


fn parseImportVal(allocator: std.mem.Allocator, input: []const u8, loc: lexer.Position) !struct { ast.ImportVal, lexer.Position } {
    _ = allocator;
    const loc1 = try expectKeyword(input, loc, .import_);
    const loc2 = try expectSymbol(input, loc1, .open_par_);
    const peek = peekToken(input, loc2) orelse return ParseError.UnexpectedEof;
    switch (peek) {
        .str_lit_double => {
            const tok, const loc3 = try expectStringLiteral(input, loc2);
            const loc4 = try expectSymbol(input, loc3, .close_par_);
            return .{
                ast.ImportVal{
                    .module     = tok,
                    .position   = loc.idx,
                    .offset     = loc4.idx,
                    .line_no    = loc.line_no,
                },
                loc4,
            };
        },
        else => {},
    }
    return ParseError.ExpectedType;
}


fn parseExprOrBlock(allocator: std.mem.Allocator, input: []const u8, loc: lexer.Position) anyerror!struct { ast.ExprOrBlock, lexer.Position } {
    const peek = peekToken(input, loc) orelse return ParseError.UnexpectedEof;
    switch (peek) {
        .blunt_symbol => |s| if (s.token_type == .open_curly_) {
            const block, const new_loc = try parseBlock(allocator, input, loc, null);
            return .{ ast.ExprOrBlock{ .bloc = block }, new_loc };
        },
        .keyword_token => |k| switch (k.token_type.?) {
            .import_ => {
                const node, const new_loc = try parseImportVal(allocator, input, loc);
                const loc_2 = try expectSymbol(input, new_loc, .semi_colon_);
                return .{ ast.ExprOrBlock{ .import = node }, loc_2 };
            },
            .proc_ => {
                const node, const loc_1 = try parseProcSignature(allocator, input, loc);
                const loc_after_semicolon = expectSymbol(input, loc_1, .semi_colon_) catch null;
                if (loc_after_semicolon) |item| {
                    return .{ ast.ExprOrBlock{ .proc_sig = node }, item };
                } else {
                    const block, const loc_2 = try parseBlock(allocator, input, loc_1, node);
                    return .{ ast.ExprOrBlock{ .bloc = block }, loc_2 };
                }
            },
            else => return ParseError.UnexpectedToken,
        },
        else => {
            const node, const new_loc = try parseExpr(allocator, input, loc);
            const loc_2 = try expectSymbol(input, new_loc, .semi_colon_);
            return .{ ast.ExprOrBlock{ .expr = node }, loc_2 };
        },
    }
    return ParseError.ExpectedType;
}


fn parseExpr(allocator: std.mem.Allocator, input: []const u8, loc: lexer.Position) !struct { ast.Expr, lexer.Position } {
    _ = allocator;
    // base case: identifier or number literal — binary ops need Pratt on top of this
    const tok, const new_loc = try expectToken(input, loc);
    switch (tok) {
        .identifier_token => return .{ ast.Expr{ .identifier = tok }, new_loc },
        .number           => return .{ ast.Expr{ .number_expr = .{ .number = tok } }, new_loc },
        .str_lit_double,
        .str_lit_single   => return .{ ast.Expr{ .string_expr = .{ .string = tok } }, new_loc },
        else              => return ParseError.UnexpectedToken,
    }
}


fn parseBlock(allocator: std.mem.Allocator, input: []const u8, loc: lexer.Position, proc_sig: ?ast.ProcSignature) !struct { ast.Block, lexer.Position } {
    var stmt_list: ?[]ast.Statement = null;
    const peek = peekToken(input, loc) orelse return ParseError.UnexpectedEof;
    var cur = try expectSymbol(input, loc, .open_curly_);
    switch (peek) {
        .blunt_symbol => |s| if (s.token_type == .open_curly_) {
            var stmts: std.ArrayList(ast.Statement) = .empty;
            while (peekToken(input, cur) != null) {
                const loc_curly = expectSymbol(input, cur, .close_curly_) catch null;
                if (loc_curly) |item| {
                    cur = item;
                    break;
                } 
                const stmt, const new_loc = try parseStatement(allocator, input, cur);
                try stmts.append(allocator, stmt);
                cur = new_loc;
            }
            if (0 == stmts.items.len) stmt_list = stmts.items;
        },
        else => {},
    }
    return .{
        ast.Block{
            .sig      = proc_sig,
            .stmts    = stmt_list,
            .position = loc.idx,
            .offset   = cur.idx,
            .line_no  = loc.line_no,
        },
        cur,
    };
}


fn parseProcSignature(allocator: std.mem.Allocator, input: []const u8, loc: lexer.Position) !struct { ast.ProcSignature, lexer.Position } {
    var params: std.ArrayList(ast.Parameter) = .empty;
    var cur = try expectKeyword(input, loc, .proc_);
    cur = try expectSymbol(input, cur, .open_par_);
    
    while (peekToken(input, cur) != null) {
        const loc_1 = expectSymbol(input, cur, .close_par_) catch null;
        if (loc_1) |item| {cur = item; break;}
        const param, const new_loc = try parseParameter(allocator, input, cur);
        try params.append(allocator, param);
        cur = new_loc;
    }
    var type_tok: ?ast.Type = null;
    const loc_after_arrow = expectSymbol(input, cur, .fwd_arr_) catch null;
    if (loc_after_arrow) |item| {
        type_tok, cur = try parseType(allocator, input, item);
    }
    var constraint: ?ast.Constraints = null;
    const loc_after_where = expectKeyword(input, cur, .where_) catch null;
    if (loc_after_where) |item| {
        constraint, cur = try parseConstraints(allocator, input, item);
    }
    return .{
        ast.ProcSignature{
            .param_list         = params.items,
            .return_type        = type_tok,
            .param_constraints  = constraint,
            .position           = loc.idx,
            .offset             = cur.idx,
            .line_no            = loc.line_no,
        },
        cur,
    };
}


fn parseParameter(allocator: std.mem.Allocator, input: []const u8, loc: lexer.Position) !struct { ast.Parameter, lexer.Position } {
    _ = allocator; _ = input; _ = loc;
    @panic("parseParameter: not implemented");
}


fn parseConstraints(allocator: std.mem.Allocator, input: []const u8, loc: lexer.Position) !struct { ast.Constraints, lexer.Position } {
    _ = allocator; _ = input; _ = loc;
    @panic("parseConstraints: not implemented");
}




fn parseType(allocator: std.mem.Allocator, input: []const u8, loc: lexer.Position) !struct { ast.Type, lexer.Position } {
    const prim, const new_loc = try parsePrimitiveType(allocator, input, loc);
    return .{ ast.Type{ .primitive_type = prim }, new_loc };
}


fn parsePrimitiveType(allocator: std.mem.Allocator, input: []const u8, loc: lexer.Position) !struct { ast.PrimitiveType, lexer.Position } {
    _ = allocator;
    const tok, const new_loc = try expectToken(input, loc);
    switch (tok) {
        .keyword_token => |k| {
            const prim: ast.PrimitiveTypeEnum = switch (k.token_type.?) {
                .num_   => .NumType,
                .int_   => .IntType,
                .float_ => .RealType,
                .str_   => .StringType,
                .void_  => .VoidType,
                else    => return ParseError.ExpectedType,
            };
            return .{ ast.PrimitiveType{ .primitive_type = prim }, new_loc };
        },
        else => return ParseError.ExpectedType,
    }
}


fn parseStatement(allocator: std.mem.Allocator, input: []const u8, loc: lexer.Position) !struct { ast.Statement, lexer.Position } {
    const peek = peekToken(input, loc) orelse return ParseError.UnexpectedEof;
    switch (peek) {
        .identifier_token => |_| {
            const node, const new_loc = try parseConstOrVarDecl(allocator, input, loc);
            return .{ ast.Statement{ .const_or_decl = node }, new_loc };
        },
        else => return ParseError.UnexpectedToken,
    }
}

fn parseAssignmentStmt(allocator: std.mem.Allocator, input: []const u8, loc: lexer.Position) !ast.AssignmentStmt {
    _ = allocator; _ = input; _ = loc;
    @panic("parseAssignmentStmt: not implemented");
}


fn parseBinaryOp(allocator: std.mem.Allocator, input: []const u8, loc: lexer.Position) !struct { ast.BinaryOp, lexer.Position } {
    _ = allocator; _ = input; _ = loc;
    @panic("parseBinaryOp: not implemented — needs Pratt parser");
}


fn parseUnaryOp(allocator: std.mem.Allocator, input: []const u8, loc: lexer.Position) !struct { ast.UnaryOp, lexer.Position } {
    _ = allocator; _ = input; _ = loc;
    @panic("parseUnaryOp: not implemented");
}


fn parseProcCall(allocator: std.mem.Allocator, input: []const u8, loc: lexer.Position) !struct { ast.FunctionCall, lexer.Position } {
    _ = allocator; _ = input; _ = loc;
    @panic("parseProcCall: not implemented");
}


// --------------------------------------------------------
// Helpers
// --------------------------------------------------------

// Consume next token or return UnexpectedEof
fn expectToken(input: []const u8, loc: lexer.Position) !struct { lexer.Token, lexer.Position } {
    const tok, const new_loc = tokenizer.emitToken(loc, input);
    if (tok == null) return ParseError.UnexpectedEof;
    return .{ tok.?, new_loc };
}

// Peek without advancing
fn peekToken(input: []const u8, loc: lexer.Position) ?lexer.Token {
    const tok, _ = tokenizer.emitToken(loc, input);
    return tok;
}

fn tokenSlice(tok: lexer.Token, input: []const u8) []const u8 {
    return switch (tok) {
        inline else => |inner| input[inner.position..inner.offset],
    };
}

fn expectKeyword(input: []const u8, loc: lexer.Position, kw: lexer.Keyword) !lexer.Position {
    const tok, const new_loc = try expectToken(input, loc);
    switch (tok) {
        .keyword_token => |k| {
            if (k.token_type == kw) return new_loc;
            return ParseError.UnexpectedToken;
        },
        else => return ParseError.ExpectedKeyword,
    }
}

fn expectSymbol(input: []const u8, loc: lexer.Position, sym: lexer.BluntSymbol) !lexer.Position {
    const tok, const new_loc = try expectToken(input, loc);
    switch (tok) {
        .blunt_symbol => |s| {
            if (s.token_type == sym) return new_loc;
            return ParseError.UnexpectedToken;
        },
        else => return ParseError.ExpectedSymbol,
    }
}

fn expectIdentifier(input: []const u8, loc: lexer.Position) !struct { lexer.Token, lexer.Position } {
    const tok, const new_loc = try expectToken(input, loc);
    switch (tok) {
        .identifier_token => return .{ tok, new_loc },
        else => return ParseError.ExpectedIdentifier,
    }
}


fn expectStringLiteral(input: []const u8, loc: lexer.Position) !struct { lexer.Token, lexer.Position } {
    const tok, const new_loc = try expectToken(input, loc);
    switch (tok) {
        .str_lit_double => return .{ tok, new_loc },
        else => return ParseError.ExpectedIdentifier,
    }
}