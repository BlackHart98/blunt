const mem = @import("std").mem; 
const std = @import("std");
const lexer_node = @import("definitions.zig");


pub inline fn partialEqToken(token_1: lexer_node.Token, token_2: lexer_node.Token) bool{
    if (@TypeOf(token_1) != @TypeOf(token_2)){
        return false;
    }
    return switch (token_1) {
        .keyword_token => switch (token_2) {
            .keyword_token => token_1.keyword_token.token_type == token_2.keyword_token.token_type,
            else => false,
        },
        .identifier_token => switch (token_2) {
            .identifier_token => mem.eql(u8, token_1.identifier_token.token_type, token_2.identifier_token.token_type),
            else => false,
        },
        .coment_single_line => switch (token_2) {
            .coment_single_line => mem.eql(u8, token_1.coment_single_line.token_type, token_2.coment_single_line.token_type),
            else => false,
        },
        .coment_multi_line => switch (token_2) {
            .coment_multi_line => mem.eql(u8, token_1.coment_multi_line.token_type, token_2.coment_multi_line.token_type),
            else => false,
        },
        .esc_identifier_token => switch (token_2) {
            .esc_identifier_token => mem.eql(u8, token_1.esc_identifier_token.token_type, token_2.esc_identifier_token.token_type),
            else => false,
        },
        .str_list_single => switch (token_2) {
            .str_list_single => mem.eql(u8, token_1.str_list_single.token_type, token_2.str_list_single.token_type),
            else => false,
        },
        .str_list_double => switch (token_2) {
            .str_list_double => mem.eql(u8, token_1.str_list_double.token_type, token_2.str_list_double.token_type),
            else => false,
        },
        .special_char => switch (token_2) {
            .special_char => mem.eql(u8, token_1.special_char.token_type, token_2.special_char.token_type),
            else => false,
        },
        .blunt_symbol => switch (token_2) {
            .blunt_symbol => token_1.blunt_symbol.token_type == token_2.blunt_symbol.token_type,
            else => false,
        },
        .number => switch (token_2) {
            .number => mem.eql(u8, token_1.number.token_type, token_2.number.token_type),
            else => false,
        },
        .unsupported_token => switch (token_2) {
            .unsupported_token => true,
            else => false,
        },
    };
}


fn _mapToKeyword(token: *const []const u8) ?lexer_node.Keyword {
    const ptr_token = token.*;
    if (mem.eql(u8, ptr_token, "fn")) {
        return lexer_node.Keyword.fn_;
    } else if (mem.eql(u8, ptr_token, "if")) {
        return lexer_node.Keyword.if_;
    } else if (mem.eql(u8, ptr_token, "@import")) {
        return lexer_node.Keyword.import_;
    } else if (mem.eql(u8, ptr_token, "@import")) {
        return lexer_node.Keyword.import_;
    }else if (mem.eql(u8, ptr_token, "as")) {
        return lexer_node.Keyword.as_;
    } else if (mem.eql(u8, ptr_token, "var")) {
        return lexer_node.Keyword.var_;
    } else if (mem.eql(u8, ptr_token, "const")) {
        return lexer_node.Keyword.const_;
    } else if (mem.eql(u8, ptr_token, "return")) {
        return lexer_node.Keyword.return_;
    } else if (mem.eql(u8, ptr_token, "visit")) {
        return lexer_node.Keyword.visit_;
    } else if (mem.eql(u8, ptr_token, "top_down")) {
        return lexer_node.Keyword.top_down_;
    } else if (mem.eql(u8, ptr_token, "bottom_up")) {
        return lexer_node.Keyword.bottom_up_;
    } else if (mem.eql(u8, ptr_token, "innermost")) {
        return lexer_node.Keyword.innermost_;
    } else if (mem.eql(u8, ptr_token, "fail")) {
        return lexer_node.Keyword.fail_;
    } else if (mem.eql(u8, ptr_token, "insert")) {
        return lexer_node.Keyword.insert_;
    } else if (mem.eql(u8, ptr_token, "outermost")) {
        return lexer_node.Keyword.outermost_;
    } else if (mem.eql(u8, ptr_token, "top_down_break")) {
        return lexer_node.Keyword.top_down_break_;
    } else if (mem.eql(u8, ptr_token, "for")) {
        return lexer_node.Keyword.for_;
    } else if (mem.eql(u8, ptr_token, "elif")) {
        return lexer_node.Keyword.elif_;
    } else if (mem.eql(u8, ptr_token, "else")) {
        return lexer_node.Keyword.else_;
    } else if (mem.eql(u8, ptr_token, "@external")) {
        return lexer_node.Keyword.external_;
    } else if (mem.eql(u8, ptr_token, "@sypnosis")) {
        return lexer_node.Keyword.sypnosis_;
    } else if (mem.eql(u8, ptr_token, "typedef")) {
        return lexer_node.Keyword.typedef_;
    } else if (mem.eql(u8, ptr_token, "data")) {
        return lexer_node.Keyword.data_;
    } else if (mem.eql(u8, ptr_token, "in")) {
        return lexer_node.Keyword.in_;
    } else if (mem.eql(u8, ptr_token, "true")) {
        return lexer_node.Keyword.true_;
    } else if (mem.eql(u8, ptr_token, "false")) {
        return lexer_node.Keyword.false_;
    } else if (mem.eql(u8, ptr_token, "try")) {
        return lexer_node.Keyword.try_;
    } else if (mem.eql(u8, ptr_token, "catch")) {
        return lexer_node.Keyword.catch_;
    } else if (mem.eql(u8, ptr_token, "any")) {
        return lexer_node.Keyword.any_;
    } else if (mem.eql(u8, ptr_token, "num")) {
        return lexer_node.Keyword.num_;
    } else if (mem.eql(u8, ptr_token, "int")) {
        return lexer_node.Keyword.int_;
    } else if (mem.eql(u8, ptr_token, "str")) {
        return lexer_node.Keyword.str_;
    } else if (mem.eql(u8, ptr_token, "real")) {
        return lexer_node.Keyword.real_;
    } else if (mem.eql(u8, ptr_token, "list")) {
        return lexer_node.Keyword.list_;
    } else if (mem.eql(u8, ptr_token, "tuple")) {
        return lexer_node.Keyword.tuple_;
    } else if (mem.eql(u8, ptr_token, "rel")) {
        return lexer_node.Keyword.rel_;
    } else if (mem.eql(u8, ptr_token, "lrel")) {
        return lexer_node.Keyword.lrel_;
    } else if (mem.eql(u8, ptr_token, "map")) {
        return lexer_node.Keyword.map_;
    } else if (mem.eql(u8, ptr_token, "void")) {
        return lexer_node.Keyword.void_;
    } else if (mem.eql(u8, ptr_token, "set")) {
        return lexer_node.Keyword.set_;
    } else if (mem.eql(u8, ptr_token, "node")) {
        return lexer_node.Keyword.node_;
    } else if (mem.eql(u8, ptr_token, "loc")) {
        return lexer_node.Keyword.loc_;
    } else if (mem.eql(u8, ptr_token, "itr")) {
        return lexer_node.Keyword.itr_;
    } else {
        return null;
    }
}


const LexerError = error{LexerError, OutOfMemory};


pub fn scanInput(allocator: std.mem.Allocator, input: []const u8) LexerError![]lexer_node.Token {
    var result = std.ArrayList(lexer_node.Token).init(allocator);
    errdefer result.deinit();
    
    var counter: usize = 0;
    var newline_count: usize = 1;
    
    while (counter < input.len) {
        const temp_ = try _emitToken(allocator, counter, input, input.len, newline_count);
        const token_lexeme = temp_.@"0";
        counter = temp_.@"1";
        newline_count = temp_.@"2";
        
        // Debug print the token before comparison
        // std.debug.print("Current token: {any}\n", .{token_lexeme});
        if (token_lexeme != null) try result.append(token_lexeme.?);
    }
    return result.toOwnedSlice();
}


inline fn _emitToken(allocator: std.mem.Allocator, pos: usize, list_of_chars: []const u8, input_len: usize, newline_count_: usize) !struct{?lexer_node.Token, usize, usize} {
        var lookahead: usize = pos;
        
        var token_ = std.ArrayList(u8).init(allocator);
        defer token_.deinit();
        var newline_count: usize = newline_count_;
        switch (list_of_chars[pos]) {
            'a'...'z', 'A'...'Z' => {
                return try _getKeywordOrId(allocator, pos, list_of_chars, input_len, newline_count);
            },
            '0'...'9' => {
                try token_.append(list_of_chars[pos]);
                lookahead = pos + 1;
                while (lookahead < input_len) { 
                    if (_isNumber(list_of_chars[lookahead])) {
                        try token_.append(list_of_chars[lookahead]);
                        lookahead += 1;
                    } else {
                        break;
                    }
                }
                return .{
                    lexer_node.Token{
                        .number = .{
                            .token_type = try token_.toOwnedSlice(), 
                            .position = pos, 
                            .length = lookahead, 
                            .line_no = newline_count
                        }
                    }
                    , lookahead, newline_count
                };
            },
            '$' => {
                try token_.append(list_of_chars[pos]);
                lookahead = pos + 1;
                while (lookahead < input_len) { 
                    if (_isNumber(list_of_chars[lookahead])) {
                        try token_.append(list_of_chars[lookahead]);
                        lookahead += 1;
                    } else if (_isAlphabet(list_of_chars[lookahead])) {
                        try token_.append(list_of_chars[lookahead]);
                        lookahead += 1;
                        return .{
                            lexer_node.Token{
                                .unsupported_token = .{
                                    .token_type = list_of_chars[pos], 
                                    .position = pos, 
                                    .length = lookahead, 
                                    .line_no = newline_count
                                }
                            }
                            , lookahead, newline_count
                        };
                    } else {
                        break;
                    }
                }
                if (token_.items.len > 1){
                    return .{
                        lexer_node.Token{
                            .blunt_symbol = .{
                                .token_type = lexer_node.BluntSymbol.generic_symbol_, 
                                .position = pos, 
                                .length = lookahead, 
                                .line_no = newline_count
                            }
                        }
                        , lookahead, newline_count
                    };
                } else {
                    return .{
                        lexer_node.Token{
                            .unsupported_token = .{
                                    .token_type = list_of_chars[pos], 
                                    .position = pos, 
                                    .length = lookahead, 
                                    .line_no = newline_count
                                }
                        }
                        , lookahead, newline_count
                    };
                }
            },
            '@' => {
                try token_.append(list_of_chars[pos]);
                lookahead = pos + 1;
                while (lookahead < input_len) { 
                    if (std.ascii.isLower(list_of_chars[lookahead])) {
                        try token_.append(list_of_chars[lookahead]);
                        lookahead += 1;
                    } else if (_isNumber(list_of_chars[lookahead])) {
                        try token_.append(list_of_chars[lookahead]);
                        lookahead += 1;
                        return .{
                            lexer_node.Token{
                                .unsupported_token = .{
                                    .token_type = list_of_chars[pos], 
                                    .position = pos, 
                                    .length = lookahead, 
                                    .line_no = newline_count
                                }
                            }
                            , lookahead, newline_count
                        };
                    } else {
                        break;
                    }
                }
                const keyword = _mapToKeyword(&(token_.items));

                if (keyword != null){
                    return .{
                        lexer_node.Token{
                            .keyword_token = .{
                                .token_type = keyword, 
                                .position = pos, 
                                .length = lookahead, 
                                .line_no = newline_count
                            }
                        }
                        , lookahead, newline_count
                    };
                } else {
                    return .{
                        lexer_node.Token{
                            .unsupported_token = .{
                                .token_type = list_of_chars[pos], 
                                .position = pos, 
                                .length = lookahead, 
                                .line_no = newline_count
                            }
                        }
                        , lookahead, newline_count
                    };
                }
            },
            '+' => {
                try token_.append(list_of_chars[pos]);
                lookahead = pos + 1;
                if (list_of_chars[lookahead] == '='){
                    try token_.append(list_of_chars[lookahead]);
                    lookahead += 1;
                    return .{
                        lexer_node.Token{
                            .blunt_symbol = .{ 
                                .token_type = lexer_node.BluntSymbol.incr_, 
                                .position = pos, 
                                .length = lookahead, 
                                .line_no = newline_count
                            }
                        }
                        , lookahead, newline_count
                    };
                } else{
                    return .{
                        lexer_node.Token{
                            .blunt_symbol = .{ 
                                .token_type = lexer_node.BluntSymbol.plus_, 
                                .position = pos, 
                                .length = lookahead, 
                                .line_no = newline_count
                            }
                        }
                        , lookahead, newline_count
                    };
                }
            },
            '*' => {
                try token_.append(list_of_chars[pos]);
                lookahead = pos + 1;
                if (list_of_chars[lookahead] == '=') {
                    try token_.append(list_of_chars[lookahead]);
                    lookahead += 1;
                    return .{
                        lexer_node.Token{
                            .blunt_symbol = .{ 
                                .token_type = lexer_node.BluntSymbol.rmul_, 
                                .position = pos, 
                                .length = lookahead, 
                                .line_no = newline_count
                            }
                        }
                        , lookahead, newline_count
                    };
                } else {
                    return .{
                        lexer_node.Token{
                            .blunt_symbol = .{ 
                                .token_type = lexer_node.BluntSymbol.mul_, 
                                .position = pos, 
                                .length = lookahead, 
                                .line_no = newline_count
                            }
                        }
                        , lookahead, newline_count
                    };
                }
            },
            '/' => {
                try token_.append(list_of_chars[pos]);
                lookahead = pos + 1;
                if (list_of_chars[lookahead] == '=') {
                    try token_.append(list_of_chars[lookahead]);
                    lookahead += 1;
                    return .{
                        lexer_node.Token{
                            .blunt_symbol = .{ 
                                .token_type = lexer_node.BluntSymbol.rdiv_, 
                                .position = pos, 
                                .length = lookahead, 
                                .line_no = newline_count
                            }
                        }
                        , lookahead, newline_count
                    };
                } else if (list_of_chars[lookahead] == '/'){
                    try token_.append(list_of_chars[lookahead]);
                    lookahead = pos + 1;
                    while (lookahead < input_len) {
                        if (list_of_chars[lookahead] == '\n'){
                            break;
                        } else {
                            try token_.append(list_of_chars[lookahead]);
                            lookahead += 1;
                        }
                    }
                    // return .{
                    //     Token{
                    //         .coment_single_line = .{
                    //             .token_type = try token_.toOwnedSlice(), 
                    //             .position = pos, 
                    //             .length = lookahead, 
                    //             .line_no = newline_count
                    //         }
                    //     }
                    //     , lookahead, newline_count
                    // };
                    return .{null, lookahead, newline_count};
                } else {
                    return .{
                        lexer_node.Token{
                            .blunt_symbol = .{ 
                                .token_type = lexer_node.BluntSymbol.div_, 
                                .position = pos, 
                                .length = lookahead, 
                                .line_no = newline_count
                            }
                        }
                        , lookahead, newline_count
                    };
                }
            },
            '=' => {
                try token_.append(list_of_chars[pos]);
                lookahead = pos + 1;
                if (list_of_chars[lookahead] == '='){
                    try token_.append(list_of_chars[lookahead]);
                    lookahead += 1;
                    return .{
                        lexer_node.Token{
                            .blunt_symbol = .{ 
                                .token_type = lexer_node.BluntSymbol.eq_, 
                                .position = pos, 
                                .length = lookahead, 
                                .line_no = newline_count
                            }
                        }
                        , lookahead, newline_count
                    };
                } else {
                    return .{
                        lexer_node.Token{
                            .blunt_symbol = .{ 
                                .token_type = lexer_node.BluntSymbol.bind_, 
                                .position = pos, 
                                .length = lookahead, 
                                .line_no = newline_count
                            }
                        }
                        , lookahead, newline_count
                    };
                }
            },
            ':' => {
                try token_.append(list_of_chars[pos]);
                lookahead = pos + 1;
                if (list_of_chars[lookahead] == '=') {
                    try token_.append(list_of_chars[lookahead]);
                    lookahead += 1;
                    return .{
                        lexer_node.Token{
                            .blunt_symbol = .{ 
                                .token_type = lexer_node.BluntSymbol.match_, 
                                .position = pos, 
                                .length = lookahead, 
                                .line_no = newline_count
                            }
                        }
                        , lookahead, newline_count
                    };
                } else {
                    return .{
                        lexer_node.Token{
                            .blunt_symbol = .{ 
                                .token_type = lexer_node.BluntSymbol.colon_, 
                                .position = pos, 
                                .length = lookahead, 
                                .line_no = newline_count
                            }
                        }
                        , lookahead, newline_count
                    };
                }
            },
            ';' => {
                lookahead += 1;
                return .{
                    lexer_node.Token{
                        .blunt_symbol = .{ 
                            .token_type = lexer_node.BluntSymbol.semi_colon_, 
                            .position = pos, 
                            .length = lookahead, 
                            .line_no = newline_count
                        }
                    }
                    , lookahead, newline_count
                };
            },
            ',' => {
                lookahead += 1;
                return .{
                    lexer_node.Token{
                        .blunt_symbol = .{ 
                            .token_type = lexer_node.BluntSymbol.comma_, 
                            .position = pos, 
                            .length = lookahead, 
                            .line_no = newline_count
                        }
                    }
                    , lookahead, newline_count
                };
            },
            '>' => {
                lookahead += 1;
                if (list_of_chars[lookahead] == '=') {
                    try token_.append(list_of_chars[lookahead]);
                    lookahead += 1;
                    return .{
                        lexer_node.Token{
                            .blunt_symbol = .{ 
                                .token_type = lexer_node.BluntSymbol.gte_, 
                                .position = pos, 
                                .length = lookahead, 
                                .line_no = newline_count
                            }
                        }
                        , lookahead, newline_count
                    };
                } else {
                    return .{
                        lexer_node.Token{
                            .blunt_symbol = .{ 
                                .token_type = lexer_node.BluntSymbol.gt_, 
                                .position = pos, 
                                .length = lookahead, 
                                .line_no = newline_count
                            }
                        }
                        , lookahead, newline_count
                    };
                }
            },
            '<' => {
                lookahead += 1;
                if (list_of_chars[lookahead] == '='){
                    try token_.append(list_of_chars[lookahead]);
                    lookahead += 1;
                    return .{
                        lexer_node.Token{
                            .blunt_symbol = .{ 
                                .token_type = lexer_node.BluntSymbol.lte_, 
                                .position = pos, 
                                .length = lookahead, 
                                .line_no = newline_count
                            }
                        }
                        , lookahead, newline_count
                    };
                } else if (list_of_chars[lookahead] == ':'){
                    try token_.append(list_of_chars[lookahead]);
                    lookahead += 1;
                    return .{
                        lexer_node.Token{
                            .blunt_symbol = .{ 
                                .token_type = lexer_node.BluntSymbol.upper_bound_, 
                                .position = pos, 
                                .length = lookahead, 
                                .line_no = newline_count
                            }
                        }
                        , lookahead, newline_count
                    };
                } else if (list_of_chars[lookahead] == '-') {
                    try token_.append(list_of_chars[lookahead]);
                    lookahead += 1;
                    return .{
                        lexer_node.Token{
                            .blunt_symbol = .{ 
                                .token_type = lexer_node.BluntSymbol.yield_, 
                                .position = pos, 
                                .length = lookahead, 
                                .line_no = newline_count
                            }
                        }
                        , lookahead, newline_count
                    };
                } else{
                    return .{
                        lexer_node.Token{
                            .blunt_symbol = .{ 
                                .token_type = lexer_node.BluntSymbol.lt_, 
                                .position = pos, 
                                .length = lookahead, 
                                .line_no = newline_count
                            }
                        }
                        , lookahead, newline_count
                    };
                }
            },
            '-' => {
                try token_.append(list_of_chars[pos]);
                lookahead = pos + 1;
                if (list_of_chars[lookahead] == '='){
                    try token_.append(list_of_chars[lookahead]);
                    lookahead += 1;
                    return .{
                        lexer_node.Token{
                            .blunt_symbol = .{ 
                                .token_type = lexer_node.BluntSymbol.decr_, 
                                .position = pos, 
                                .length = lookahead, 
                                .line_no = newline_count
                            }
                        }
                        , lookahead, newline_count
                    };
                } else if (list_of_chars[lookahead] == '>'){
                    try token_.append(list_of_chars[lookahead]);
                    lookahead += 1;
                    return .{
                        lexer_node.Token{
                            .blunt_symbol = .{ 
                                .token_type = lexer_node.BluntSymbol.fwd_arr_, 
                                .position = pos, 
                                .length = lookahead, 
                                .line_no = newline_count
                            }
                        }
                        , lookahead, newline_count
                    };
                } else {
                    return .{
                        lexer_node.Token{
                            .blunt_symbol = .{ 
                                .token_type = lexer_node.BluntSymbol.minus_, 
                                .position = pos, 
                                .length = lookahead, 
                                .line_no = newline_count
                            }
                        }
                        , lookahead, newline_count
                    };
                }
            },
            '_' => {
                try token_.append(list_of_chars[pos]);
                lookahead = pos + 1;
                if (list_of_chars[lookahead] == ' '){
                    return .{
                        lexer_node.Token{
                            .blunt_symbol = .{ 
                                .token_type = lexer_node.BluntSymbol.wildcard_, 
                                .position = pos, 
                                .length = lookahead, 
                                .line_no = newline_count
                            }
                        }
                        , lookahead, newline_count
                    };
                } else { 
                    while (lookahead < input_len) { 
                        if (_isIdentifierSubstring(list_of_chars[lookahead])){
                            try token_.append(list_of_chars[lookahead]);
                            lookahead += 1;
                        } else {
                            break;
                        }
                    }
                    return .{
                        lexer_node.Token{
                            .identifier_token = .{ 
                                .token_type = try token_.toOwnedSlice(), 
                                .position = pos, 
                                .length = lookahead, 
                                .line_no = newline_count
                            }
                        }
                        , lookahead, newline_count
                    };
                } 
            },
            ' ' => {
                lookahead += 1;
                return .{null, lookahead, newline_count};
            },
            '\n' => {
                lookahead += 1;
                newline_count += 1;
                return .{null, lookahead, newline_count};
            },
            '\t' => {
                lookahead += 1;
                return .{null, lookahead, newline_count};
            },
            '.' => {
                try token_.append(list_of_chars[pos]);
                lookahead = pos + 1;
                return .{
                    lexer_node.Token{
                        .blunt_symbol = .{ 
                            .token_type = lexer_node.BluntSymbol.dot_, 
                            .position = pos, 
                            .length = lookahead, 
                            .line_no = newline_count
                        }
                    }
                    , lookahead, newline_count
                };
            },
            '!' => {
                try token_.append(list_of_chars[pos]);
                lookahead = pos + 1;
                if (list_of_chars[lookahead] == '=') {
                    try token_.append(list_of_chars[lookahead]);
                    lookahead += 1;
                    return .{
                        lexer_node.Token{
                            .blunt_symbol = .{
                                .token_type = lexer_node.BluntSymbol.neq_, 
                                .position = pos, 
                                .length = lookahead, 
                                .line_no = newline_count
                            }
                        }
                        , lookahead, newline_count
                    };
                } else {
                    return .{
                        lexer_node.Token{
                            .blunt_symbol = .{
                                .token_type = lexer_node.BluntSymbol.not_, 
                                .position = pos, 
                                .length = lookahead, 
                                .line_no = newline_count
                            }
                        }
                        , lookahead, newline_count
                    };
                }
            },
            '[' => {
                lookahead += 1;
                return .{
                    lexer_node.Token{
                        .blunt_symbol = .{
                            .token_type = lexer_node.BluntSymbol.open_bracket_, 
                            .position = pos, 
                            .length = lookahead, 
                            .line_no = newline_count
                        }
                    }
                    , lookahead, newline_count
                };
            },
            ']' => {
                lookahead += 1;
                return .{
                    lexer_node.Token{
                        .blunt_symbol = .{
                            .token_type = lexer_node.BluntSymbol.close_bracket_, 
                            .position = pos, 
                            .length = lookahead, 
                            .line_no = newline_count
                        }
                    }
                    , lookahead, newline_count
                };
            },
            '(' => {
                lookahead += 1;
                return .{
                    lexer_node.Token{
                        .blunt_symbol = .{
                            .token_type = lexer_node.BluntSymbol.open_par_, 
                            .position = pos, 
                            .length = lookahead, 
                            .line_no = newline_count
                        }
                    }
                    , lookahead, newline_count
                };
            },
            ')' => {
                lookahead += 1;
                return .{
                    lexer_node.Token{
                        .blunt_symbol = .{
                            .token_type = lexer_node.BluntSymbol.close_par_, 
                            .position = pos, 
                            .length = lookahead, 
                            .line_no = newline_count
                        }
                    }
                    , lookahead, newline_count
                };
            }, 
            '{' => {
                lookahead += 1;
                return .{
                    lexer_node.Token{
                        .blunt_symbol = .{
                            .token_type = lexer_node.BluntSymbol.open_curly_, 
                            .position = pos, 
                            .length = lookahead, 
                            .line_no = newline_count
                        }
                    }
                    , lookahead, newline_count
                };
            },
            '}' => {
                lookahead += 1;
                return .{
                    lexer_node.Token{
                        .blunt_symbol = .{
                            .token_type = lexer_node.BluntSymbol.close_curly_, 
                            .position = pos, 
                            .length = lookahead, 
                            .line_no = newline_count
                        }
                    }
                    , lookahead, newline_count
                };
            },
            // '\'' => {
            //     return getSstringLit(pos, list_of_chars, input_len, newline_count);
            // },
            '\"' => {
                return getDstringLit(allocator, pos, list_of_chars, input_len, newline_count);
            },
            '&' => {
                try token_.append(list_of_chars[pos]);
                lookahead = pos + 1;
                if (list_of_chars[lookahead] == '&'){
                    try token_.append(list_of_chars[lookahead]);
                    lookahead += 1;
                    return .{
                        lexer_node.Token{
                            .blunt_symbol = .{
                                .token_type = lexer_node.BluntSymbol.and_, 
                                .position = pos, 
                                .length = lookahead, 
                                .line_no = newline_count
                            }
                        }
                        , lookahead, newline_count
                    };
                } else {
                    return .{
                        lexer_node.Token{
                            .unsupported_token = .{
                                .token_type = list_of_chars[pos], 
                                .position = pos, 
                                .length = lookahead, 
                                .line_no = newline_count
                            }
                        }
                        , lookahead, newline_count
                    };
                }
            },
            '|' => {
                try token_.append(list_of_chars[pos]);
                lookahead = pos + 1;
                if (list_of_chars[lookahead] == '|'){
                    try token_.append(list_of_chars[lookahead]);
                    lookahead += 1;
                    return .{
                        lexer_node.Token{
                            .blunt_symbol = .{
                                .token_type = lexer_node.BluntSymbol.or_, 
                                .position = pos, 
                                .length = lookahead, 
                                .line_no = newline_count
                            }
                        }
                        , lookahead, newline_count
                    };
                } else if (list_of_chars[lookahead] == '>') {
                    try token_.append(list_of_chars[lookahead]);
                    lookahead += 1;
                    return .{
                        lexer_node.Token{
                            .blunt_symbol = .{
                                .token_type = lexer_node.BluntSymbol.combine_, 
                                .position = pos, 
                                .length = lookahead, 
                                .line_no = newline_count
                            }
                        }
                        , lookahead, newline_count
                    };
                } else {
                    return .{
                        lexer_node.Token{
                            .blunt_symbol = .{
                                .token_type = lexer_node.BluntSymbol.pipe_, 
                                .position = pos, 
                                .length = lookahead, 
                                .line_no = newline_count
                            }
                        }
                        , lookahead, newline_count
                    };
                }
            },
            else => {
                lookahead += 1;
                return .{
                    lexer_node.Token{
                        .unsupported_token = .{
                            .token_type = list_of_chars[pos], 
                            .position = pos, 
                            .length = lookahead, 
                            .line_no = newline_count
                        }
                    }
                    , lookahead, newline_count
                };
            },
        }
}



inline fn _getKeywordOrId(allocator: std.mem.Allocator, pos : usize, list_of_chars : []const u8, input_len: usize, newline_count: usize) !struct{?lexer_node.Token, usize, usize} {
    const temp_ = try _finiteAutomaton(allocator, pos, list_of_chars, input_len);
    const token_ = temp_.@"0"; const lookahead = temp_.@"1";
    // std.debug.print("hello world ____ {s}\n", .{token_});
    const keyword = _mapToKeyword(&token_);
    
    if (keyword != null) {
        return .{
            lexer_node.Token{
                .keyword_token = .{
                    .token_type = keyword, 
                    .position = pos, 
                    .length = lookahead, 
                    .line_no = newline_count
                }
            }
            , lookahead, newline_count
        };
    } else {
        return .{
            lexer_node.Token{
                .identifier_token = .{
                    .token_type = token_, 
                    .position = pos, 
                    .length = lookahead, 
                    .line_no = newline_count
                }
            }
            , lookahead, newline_count
        };
    }
}


inline fn _finiteAutomaton(allocator: std.mem.Allocator, pos: usize, list_of_chars: []const u8, input_len: usize) !struct { []const u8, usize } {
    var token_ = std.ArrayList(u8).init(allocator);
    defer token_.deinit();
    
    var lookahead = pos + 1;
    try token_.append(list_of_chars[pos]);
    while (lookahead < input_len) { 
        if (_isIdentifierSubstring(list_of_chars[lookahead])) {
            try token_.append(list_of_chars[lookahead]);
            lookahead += 1;
        } else {
            break;
        }
    }
    return .{ try token_.toOwnedSlice(), lookahead };
}

fn getDstringLit(allocator: std.mem.Allocator, pos : usize, list_of_chars : []const u8, input_len: usize, newline_count: usize) !struct{?lexer_node.Token, usize, usize}{
    var token_ = std.ArrayList(u8).init(allocator);
    defer token_.deinit();
    try token_.append('\"');
    var lookahead = pos + 1;
    const temp_= [4]u8{'\\', 'n', 't', '\''};
    while (lookahead < input_len) { 
        if (list_of_chars[lookahead] == '\"') {
            try token_.append(list_of_chars[lookahead]);
            lookahead += 1;
            return .{
                lexer_node.Token{
                    .str_lit_double =.{
                        .token_type = try token_.toOwnedSlice(), 
                        .position = pos, 
                        .length = lookahead, 
                        .line_no = newline_count
                    }
                }
                , lookahead, newline_count
        
            };
        } else if (list_of_chars[lookahead] != '\'' and list_of_chars[lookahead] != '\\'){
            try token_.append(list_of_chars[lookahead]);
            lookahead += 1;
        } else if (list_of_chars[lookahead] == '\\' ){
            const buffer = list_of_chars[lookahead];
            lookahead += 1;
            if (_contains(list_of_chars[lookahead], &temp_)) {
                return .{
                    lexer_node.Token{
                        .unsupported_token = .{
                            .token_type = list_of_chars[pos], 
                            .position = pos, 
                            .length = lookahead, 
                            .line_no = newline_count
                        }
                    }
                    , lookahead, newline_count
                };
            } 
            try token_.append(buffer);
            try token_.append(list_of_chars[lookahead]);
            lookahead += 1;
        } else {
            break;
        }
    }
    return .{
        lexer_node.Token{
            .unsupported_token = .{
                .token_type = list_of_chars[pos], 
                .position = pos, 
                .length = lookahead, 
                .line_no = newline_count
            }
        }
        , lookahead, newline_count
    };
}

// fn getSstringLit(allocator: *std.mem.Allocator, pos : usize, list_of_chars : []const u8, input_len: usize, newline_count: usize) !struct{Token, usize, usize}{
    
// }





//--------------------- UTIL FUNCTIONS -----------------------------------


fn _isAlphabet(c: u8) bool{return switch (c) {'a'...'z' => true, 'A'...'Z' => true, else => false};}


fn _isNumber(c: u8) bool{return switch (c) {'0'...'9' => true, else => false};}


fn _isUnderscore(c: u8) bool{return switch (c) {'_' => true, else => false};}


fn _isIdentifierSubstring(c: u8) bool {return _isAlphabet(c) or _isUnderscore(c) or _isNumber(c);} 


fn _isWhitespace(c: u8) bool {return (c == ' ') or (c == '\t') or (c == '\n');} 

fn _contains(c: u8, list : *const [4]u8) bool {
    for (list) |x| {
        if (c == x) return true;
    }
    return false;
}


// pub fn filterWhitespace(allocator: *std.mem.Allocator, tokens : *const []Token) []Token {
//     var result = std.ArrayList(u8).init(allocator.*);
//     defer result.deinit();
//     for (tokens) |_|{
//         // match x {
//         //     Token{token_type:TType::NewLine, position:_, length:_, line_no:_} => continue,
//         //     Token{token_type:TType::HorizontalWhtSpc, position:_, length:_, line_no:_} => continue,
//         //     Token{token_type:TType::CmtSingleLine(_), position:_, length:_, line_no:_} => continue,
//         //     _ => result.push(x.to_owned())
//         // }
//         // if (partialEqToken(x, ))
//     }
//     return result.toOwnedSlice();
// }
