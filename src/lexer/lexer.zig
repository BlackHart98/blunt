const mem = @import("std").mem; 
const std = @import("std");
const lexer_node = @import("definitions.zig");


inline fn isWhitespace(char: u8) bool {
    if (char == '\r' or char == '\t' or char == ' ' or char == '\n') return true;
    return false;
}

// TODO: Also skip comments
fn skipWhitespace(loc: lexer_node.Position, input: []const u8) lexer_node.Position {
    var new_loc: lexer_node.Position = loc;
    if (input.len <= new_loc.idx) return new_loc;
    switch (input[new_loc.idx]) {
        '\r', '\t', ' ', '\n' => {
            if ('\n' == input[new_loc.idx]) new_loc.line_no += 1;
            new_loc.idx += 1;
            while (isWhitespace(input[new_loc.idx]) and (input.len > new_loc.idx)) : (new_loc.idx += 1){
                if ('\n' == input[new_loc.idx]) new_loc.line_no += 1;
            }
            return new_loc;
        },
        else => return new_loc
    }
}


pub fn emitToken(loc: lexer_node.Position, input: []const u8) struct { ?lexer_node.Token, lexer_node.Position } {
    // if (loc.idx > input.len) return .{ null, loc };
    const new_loc = skipWhitespace(loc, input);
    if (input.len <= new_loc.idx) return .{ null, new_loc };
    switch (input[new_loc.idx]) {
        'a'...'z', 'A'...'Z' => {
            var len = new_loc.idx;
            while (input.len > len and !isWhitespace(input[len])) : (len += 1) {
                if (!isIdentifierSubstring(input[len])) break;
            }
            return getKeywordOrId(new_loc, len, input);
        },
        '0'...'9' => {
            var len = new_loc.idx;
            while (input.len > len and !isWhitespace(input[len])) : (len += 1) { 
                if (!isNumber(input[len])) break;
            }
            return .{
                lexer_node.Token{
                    .number = .{
                        .token_type = {}, 
                        .position = new_loc.idx, 
                        .offset = len, 
                        .line_no = new_loc.line_no
                    }
                },
                .{ .idx = len, .line_no = new_loc.line_no },
            };
        },
        '=' => {
            var len = new_loc.idx + 1;
            if ('=' == input[len]){
                len += 1;
                return .{
                    lexer_node.Token{
                        .blunt_symbol = .{ 
                            .token_type = lexer_node.BluntSymbol.eq_, 
                            .position = new_loc.idx, 
                            .offset = len, 
                            .line_no = new_loc.line_no
                        }
                    },
                    .{ .idx = len, .line_no = new_loc.line_no },
                };
            } else {
                return .{
                    lexer_node.Token{
                        .blunt_symbol = .{ 
                            .token_type = lexer_node.BluntSymbol.bind_, 
                            .position = new_loc.idx, 
                            .offset = len, 
                            .line_no = new_loc.line_no
                        }
                    },
                    .{ .idx = len, .line_no = new_loc.line_no },
                };
            }
        },
        ':' => {
            const len = new_loc.idx + 1;
            return .{
                lexer_node.Token{
                    .blunt_symbol = .{ 
                        .token_type = lexer_node.BluntSymbol.colon_, 
                        .position = new_loc.idx, 
                        .offset = len, 
                        .line_no = new_loc.line_no
                    }
                },
                .{ .idx = len, .line_no = new_loc.line_no },
            };
        },
        ';' => {
            const len = new_loc.idx + 1;
            return .{
                lexer_node.Token{
                    .blunt_symbol = .{ 
                        .token_type = lexer_node.BluntSymbol.semi_colon_, 
                        .position = new_loc.idx, 
                        .offset = len, 
                        .line_no = new_loc.line_no
                    }
                },
                .{ .idx = len, .line_no = new_loc.line_no },
            };
        },
        '(' => {
            const len = new_loc.idx + 1;
            return .{
                lexer_node.Token{
                    .blunt_symbol = .{ 
                        .token_type = lexer_node.BluntSymbol.open_par_, 
                        .position = new_loc.idx, 
                        .offset = len, 
                        .line_no = new_loc.line_no
                    }
                },
                .{ .idx = len, .line_no = new_loc.line_no },
            };
        },
        ')' => {
            const len = new_loc.idx + 1;
            return .{
                lexer_node.Token{
                    .blunt_symbol = .{ 
                        .token_type = lexer_node.BluntSymbol.close_par_, 
                        .position = new_loc.idx, 
                        .offset = len, 
                        .line_no = new_loc.line_no
                    }
                },
                .{ .idx = len, .line_no = new_loc.line_no },
            };
        },
        '{' => {
            const len = new_loc.idx + 1;
            return .{
                lexer_node.Token{
                    .blunt_symbol = .{ 
                        .token_type = lexer_node.BluntSymbol.open_curly_, 
                        .position = new_loc.idx, 
                        .offset = len, 
                        .line_no = new_loc.line_no
                    }
                },
                .{ .idx = len, .line_no = new_loc.line_no },
            };
        },
        '}' => {
            const len = new_loc.idx + 1;
            return .{
                lexer_node.Token{
                    .blunt_symbol = .{ 
                        .token_type = lexer_node.BluntSymbol.close_curly_, 
                        .position = new_loc.idx, 
                        .offset = len, 
                        .line_no = new_loc.line_no
                    }
                },
                .{ .idx = len, .line_no = new_loc.line_no },
            };
        },
        // Character
        '\'' => {
            return .{ null, new_loc };
        },
        // String literal
        '"' => {
            return getStringLiteral(new_loc, input);
        },
        '$' => {
            const len = new_loc.idx + 1;
            return .{
                lexer_node.Token{
                    .blunt_symbol = .{ 
                        .token_type = lexer_node.BluntSymbol.generic_symbol_, 
                        .position = new_loc.idx, 
                        .offset = len, 
                        .line_no = new_loc.line_no
                    }
                },
                .{ .idx = len, .line_no = new_loc.line_no },
            };
        },
        '-' => {
            var len = new_loc.idx + 1;
            if ('=' == input[len]) {
                len += 1;
                return .{
                    lexer_node.Token{
                        .blunt_symbol = .{ 
                            .token_type = lexer_node.BluntSymbol.decr_, 
                            .position = new_loc.idx, 
                            .offset = len, 
                            .line_no = new_loc.line_no
                        }
                    },
                    .{ .idx = len, .line_no = new_loc.line_no },
                };
            } else if ('>' == input[len]){
                len += 1;
                return .{
                    lexer_node.Token{
                        .blunt_symbol = .{ 
                            .token_type = lexer_node.BluntSymbol.fwd_arr_, 
                            .position = new_loc.idx, 
                            .offset = len, 
                            .line_no = new_loc.line_no
                        }
                    },
                    .{ .idx = len, .line_no = new_loc.line_no },
                };
            } else {
                return .{
                    lexer_node.Token{
                        .blunt_symbol = .{ 
                            .token_type = lexer_node.BluntSymbol.minus_, 
                            .position = new_loc.idx, 
                            .offset = len, 
                            .line_no = new_loc.line_no
                        }
                    },
                    .{ .idx = len, .line_no = new_loc.line_no },
                };
            }
        },
        else => return .{ null, new_loc },
    }
}


inline fn getKeywordOrId(loc: lexer_node.Position, end: usize, list_of_chars : []const u8) struct{?lexer_node.Token, lexer_node.Position} {
    const keyword = mapToKeyword(list_of_chars[loc.idx..end]);
    if (keyword) |item| {
        return .{
            lexer_node.Token{
                .keyword_token = .{
                    .token_type = item, 
                    .position = loc.idx, 
                    .offset = end, 
                    .line_no = loc.line_no
                }
            },
            .{ .idx = end, .line_no = loc.line_no },
        };
    } else {
        return .{
            lexer_node.Token{
                .identifier_token = .{
                    .token_type = {},
                    .position = loc.idx, 
                    .offset = end, 
                    .line_no = loc.line_no
                }
            },
            .{ .idx = end, .line_no = loc.line_no },
        };
    }
}


pub fn getTokenString(token: lexer_node.Token, list_of_chars: []const u8) []const u8 {
    switch (token) {
        inline else => |inner| {
            return list_of_chars[inner.position .. inner.offset];
        },
    }
}


pub inline fn isKeyword(token: lexer_node.Token) bool { return switch (token) { .keyword_token => |_| true, else => false };}


fn isAlphabet(c: u8) bool{return switch (c) {'a'...'z' => true, 'A'...'Z' => true, else => false};}


fn isNumber(c: u8) bool{return switch (c) {'0'...'9' => true, else => false};}


fn isUnderscore(c: u8) bool{return switch (c) {'_' => true, else => false};}


fn isIdentifierSubstring(c: u8) bool {return isAlphabet(c) or isUnderscore(c) or isNumber(c);} 


const keyword_map = std.StaticStringMap(lexer_node.Keyword).initComptime(.{
    // control flow
    .{ "proc",   .proc_   },
    .{ "if",     .if_     },
    .{ "else",   .else_   },
    .{ "for",    .for_    },
    .{ "in",     .in_     },
    .{ "return", .return_ },
    .{ "defer",  .defer_  },
    .{ "try",    .try_    },
    .{ "catch",  .catch_  },
    .{ "where",  .where_  },

    // declarations
    .{ "import",  .import_  },
    .{ "var",     .var_     },
    .{ "typedef", .typedef_ },
    .{ "struct",  .struct_  },
    .{ "enum",    .enum_    },
    .{ "union",   .union_   },

    // literals
    .{ "true",  .true_  },
    .{ "false", .false_ },

    // types
    .{ "any",   .any_   },
    .{ "num",   .num_   },
    .{ "int",   .int_   },
    .{ "str",   .str_   },
    .{ "float", .float_ },
    .{ "list",  .list_  },
    .{ "tuple", .tuple_ },
    .{ "map",   .map_   },
    .{ "void",  .void_  },
    .{ "itr",   .itr_   },
});

pub fn mapToKeyword(token: []const u8) ?lexer_node.Keyword {
    return keyword_map.get(token);
}


fn getStringLiteral(loc: lexer_node.Position, list_of_chars : []const u8) struct{?lexer_node.Token, lexer_node.Position}{
    const new_loc: lexer_node.Position = loc;
    var lookahead = new_loc.idx + 1;
    const temp_= [_]u8{'\\', 'n', 't', '\r'};
    while (list_of_chars.len > lookahead) { 
        if (list_of_chars[lookahead] == '\"') {
            lookahead += 1;
            return .{
                lexer_node.Token{
                    .str_lit_double =.{
                        .token_type = {},
                        .position = new_loc.idx, 
                        .offset = lookahead, 
                        .line_no = new_loc.line_no
                    }
                },
                .{ .idx = lookahead, .line_no = loc.line_no },
        
            };
        } else if (list_of_chars[lookahead] != '\\'){
            lookahead += 1;
        } else if (list_of_chars[lookahead] == '\\' ){
            lookahead += 1;
            if (contains(list_of_chars[lookahead], &temp_)) {
                return .{
                    lexer_node.Token{
                        .unsupported_token = .{
                            .token_type = list_of_chars[lookahead],
                            .position = new_loc.idx, 
                            .offset = lookahead, 
                            .line_no = new_loc.line_no
                        }
                    },
                    .{ .idx = lookahead, .line_no = loc.line_no },
                };
            } 
            lookahead += 1;
        } else {
            break;
        }
    }
    return .{
        lexer_node.Token{
            .unsupported_token = .{
                .token_type = list_of_chars[new_loc.idx], 
                .position = new_loc.idx, 
                .offset = lookahead, 
                .line_no = new_loc.line_no
            }
        },
        .{ .idx = lookahead, .line_no = loc.line_no },
    };
}

fn contains(c: u8, list: []const u8) bool {
    for (list) |x| {
        if (c == x) return true;
    }
    return false;
}