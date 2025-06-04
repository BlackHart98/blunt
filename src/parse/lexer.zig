const mem = @import("std").mem; 
const std = @import("std");

pub const Keyword = enum(u8) { 
    // keywords
    fn_,        if_,     import_, extend_,   var_,
    const_,     return_, visit_,   top_down_,  bottom_up_,
    innermost_, fail_,   insert_,  outermost_, top_down_break_,
    for_,       elif_,   else_,    external_, sypnosis_,
    typedef_,   data_,   in_,      true_,      false_,
    try_,       catch_,  as_,

    // data types
    any_,       num_,    int_,
    str_,       real_,   list_,    tuple_,     rel_,
    lrel_,      map_,    void_,    set_,       node_,
    loc_,       itr_,
};


pub const BluntSymbol = enum(u8) { 
    // symbols
    pipe_,          generic_symbol_,   yield_,          fwd_arr_,    wildcard_,
    plus_,          minus_,            div_,            mul_,        incr_,
    decr_,          rmul_,             rdiv_,           eq_,         neq_,
    gt_,            lt_,               gte_,            lte_,        bind_,
    colon_,         match_,            semi_colon_,     new_line_,   horizontal_wht_spc_,
    comma_,         dot_,              upper_bound_,    open_par_,  close_par_,
    open_curly_,    close_curly_,      open_bracket_,   close_bracket_,
    and_,           or_,               not_,            combine_,
};



pub const Token = union(enum) {
    keyword_token: TokenComptime(?Keyword),
    identifier_token: TokenComptime([]const u8),
    coment_single_line: TokenComptime([]const u8),
    coment_multi_line: TokenComptime([]const u8),
    esc_identifier_token: TokenComptime([]const u8),
    str_lit_single: TokenComptime([]const u8),
    str_lit_double: TokenComptime([]const u8),
    special_char: TokenComptime([]const u8),
    blunt_symbol: TokenComptime(BluntSymbol),
    number: TokenComptime([]const u8),
    unsupported_token: TokenComptime(u8),
};


pub fn TokenComptime(comptime T : type) type {
    return struct {
        token_type : T,
        position : usize,
        length : usize,
        line_no : usize,
    };
}


pub inline fn partialEqToken(token_1: Token, token_2: Token) bool{
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


fn _mapToKeyword(token: *const []const u8) ?Keyword {
    const ptr_token = token.*;
    if (mem.eql(u8, ptr_token, "fn")) {
        return Keyword.fn_;
    } else if (mem.eql(u8, ptr_token, "if")) {
        return Keyword.if_;
    } else if (mem.eql(u8, ptr_token, "@import")) {
        return Keyword.import_;
    } else if (mem.eql(u8, ptr_token, "@import")) {
        return Keyword.import_;
    }else if (mem.eql(u8, ptr_token, "as")) {
        return Keyword.as_;
    } else if (mem.eql(u8, ptr_token, "var")) {
        return Keyword.var_;
    } else if (mem.eql(u8, ptr_token, "const")) {
        return Keyword.const_;
    } else if (mem.eql(u8, ptr_token, "return")) {
        return Keyword.return_;
    } else if (mem.eql(u8, ptr_token, "visit")) {
        return Keyword.visit_;
    } else if (mem.eql(u8, ptr_token, "top_down")) {
        return Keyword.top_down_;
    } else if (mem.eql(u8, ptr_token, "bottom_up")) {
        return Keyword.bottom_up_;
    } else if (mem.eql(u8, ptr_token, "innermost")) {
        return Keyword.innermost_;
    } else if (mem.eql(u8, ptr_token, "fail")) {
        return Keyword.fail_;
    } else if (mem.eql(u8, ptr_token, "insert")) {
        return Keyword.insert_;
    } else if (mem.eql(u8, ptr_token, "outermost")) {
        return Keyword.outermost_;
    } else if (mem.eql(u8, ptr_token, "top_down_break")) {
        return Keyword.top_down_break_;
    } else if (mem.eql(u8, ptr_token, "for")) {
        return Keyword.for_;
    } else if (mem.eql(u8, ptr_token, "elif")) {
        return Keyword.elif_;
    } else if (mem.eql(u8, ptr_token, "else")) {
        return Keyword.else_;
    } else if (mem.eql(u8, ptr_token, "@external")) {
        return Keyword.external_;
    } else if (mem.eql(u8, ptr_token, "@sypnosis")) {
        return Keyword.sypnosis_;
    } else if (mem.eql(u8, ptr_token, "typedef")) {
        return Keyword.typedef_;
    } else if (mem.eql(u8, ptr_token, "data")) {
        return Keyword.data_;
    } else if (mem.eql(u8, ptr_token, "in")) {
        return Keyword.in_;
    } else if (mem.eql(u8, ptr_token, "true")) {
        return Keyword.true_;
    } else if (mem.eql(u8, ptr_token, "false")) {
        return Keyword.false_;
    } else if (mem.eql(u8, ptr_token, "try")) {
        return Keyword.try_;
    } else if (mem.eql(u8, ptr_token, "catch")) {
        return Keyword.catch_;
    } else if (mem.eql(u8, ptr_token, "any")) {
        return Keyword.any_;
    } else if (mem.eql(u8, ptr_token, "num")) {
        return Keyword.num_;
    } else if (mem.eql(u8, ptr_token, "int")) {
        return Keyword.int_;
    } else if (mem.eql(u8, ptr_token, "str")) {
        return Keyword.str_;
    } else if (mem.eql(u8, ptr_token, "real")) {
        return Keyword.real_;
    } else if (mem.eql(u8, ptr_token, "list")) {
        return Keyword.list_;
    } else if (mem.eql(u8, ptr_token, "tuple")) {
        return Keyword.tuple_;
    } else if (mem.eql(u8, ptr_token, "rel")) {
        return Keyword.rel_;
    } else if (mem.eql(u8, ptr_token, "lrel")) {
        return Keyword.lrel_;
    } else if (mem.eql(u8, ptr_token, "map")) {
        return Keyword.map_;
    } else if (mem.eql(u8, ptr_token, "void")) {
        return Keyword.void_;
    } else if (mem.eql(u8, ptr_token, "set")) {
        return Keyword.set_;
    } else if (mem.eql(u8, ptr_token, "node")) {
        return Keyword.node_;
    } else if (mem.eql(u8, ptr_token, "loc")) {
        return Keyword.loc_;
    } else if (mem.eql(u8, ptr_token, "itr")) {
        return Keyword.itr_;
    } else {
        return null;
    }
}


const LexerError = error{LexerError, OutOfMemory};


pub fn scanInput(allocator: std.mem.Allocator, input: []const u8) LexerError![]Token {
    var result = std.ArrayList(Token).init(allocator);
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


inline fn _emitToken(allocator: std.mem.Allocator, pos: usize, list_of_chars: []const u8, input_len: usize, newline_count_: usize) !struct{?Token, usize, usize} {
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
                    Token{
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
                            Token{
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
                        Token{
                            .blunt_symbol = .{
                                .token_type = BluntSymbol.generic_symbol_, 
                                .position = pos, 
                                .length = lookahead, 
                                .line_no = newline_count
                            }
                        }
                        , lookahead, newline_count
                    };
                } else {
                    return .{
                        Token{
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
                            Token{
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
                        Token{
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
                        Token{
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
                        Token{
                            .blunt_symbol = .{ 
                                .token_type = BluntSymbol.incr_, 
                                .position = pos, 
                                .length = lookahead, 
                                .line_no = newline_count
                            }
                        }
                        , lookahead, newline_count
                    };
                } else{
                    return .{
                        Token{
                            .blunt_symbol = .{ 
                                .token_type = BluntSymbol.plus_, 
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
                        Token{
                            .blunt_symbol = .{ 
                                .token_type = BluntSymbol.rmul_, 
                                .position = pos, 
                                .length = lookahead, 
                                .line_no = newline_count
                            }
                        }
                        , lookahead, newline_count
                    };
                } else {
                    return .{
                        Token{
                            .blunt_symbol = .{ 
                                .token_type = BluntSymbol.mul_, 
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
                        Token{
                            .blunt_symbol = .{ 
                                .token_type = BluntSymbol.rdiv_, 
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
                        Token{
                            .blunt_symbol = .{ 
                                .token_type = BluntSymbol.div_, 
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
                        Token{
                            .blunt_symbol = .{ 
                                .token_type = BluntSymbol.eq_, 
                                .position = pos, 
                                .length = lookahead, 
                                .line_no = newline_count
                            }
                        }
                        , lookahead, newline_count
                    };
                } else {
                    return .{
                        Token{
                            .blunt_symbol = .{ 
                                .token_type = BluntSymbol.bind_, 
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
                        Token{
                            .blunt_symbol = .{ 
                                .token_type = BluntSymbol.match_, 
                                .position = pos, 
                                .length = lookahead, 
                                .line_no = newline_count
                            }
                        }
                        , lookahead, newline_count
                    };
                } else {
                    return .{
                        Token{
                            .blunt_symbol = .{ 
                                .token_type = BluntSymbol.colon_, 
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
                    Token{
                        .blunt_symbol = .{ 
                            .token_type = BluntSymbol.semi_colon_, 
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
                    Token{
                        .blunt_symbol = .{ 
                            .token_type = BluntSymbol.comma_, 
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
                        Token{
                            .blunt_symbol = .{ 
                                .token_type = BluntSymbol.gte_, 
                                .position = pos, 
                                .length = lookahead, 
                                .line_no = newline_count
                            }
                        }
                        , lookahead, newline_count
                    };
                } else {
                    return .{
                        Token{
                            .blunt_symbol = .{ 
                                .token_type = BluntSymbol.gt_, 
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
                        Token{
                            .blunt_symbol = .{ 
                                .token_type = BluntSymbol.lte_, 
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
                        Token{
                            .blunt_symbol = .{ 
                                .token_type = BluntSymbol.upper_bound_, 
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
                        Token{
                            .blunt_symbol = .{ 
                                .token_type = BluntSymbol.yield_, 
                                .position = pos, 
                                .length = lookahead, 
                                .line_no = newline_count
                            }
                        }
                        , lookahead, newline_count
                    };
                } else{
                    return .{
                        Token{
                            .blunt_symbol = .{ 
                                .token_type = BluntSymbol.lt_, 
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
                        Token{
                            .blunt_symbol = .{ 
                                .token_type = BluntSymbol.decr_, 
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
                        Token{
                            .blunt_symbol = .{ 
                                .token_type = BluntSymbol.fwd_arr_, 
                                .position = pos, 
                                .length = lookahead, 
                                .line_no = newline_count
                            }
                        }
                        , lookahead, newline_count
                    };
                } else {
                    return .{
                        Token{
                            .blunt_symbol = .{ 
                                .token_type = BluntSymbol.minus_, 
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
                        Token{
                            .blunt_symbol = .{ 
                                .token_type = BluntSymbol.wildcard_, 
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
                        Token{
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
                    Token{
                        .blunt_symbol = .{ 
                            .token_type = BluntSymbol.dot_, 
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
                        Token{
                            .blunt_symbol = .{
                                .token_type = BluntSymbol.neq_, 
                                .position = pos, 
                                .length = lookahead, 
                                .line_no = newline_count
                            }
                        }
                        , lookahead, newline_count
                    };
                } else {
                    return .{
                        Token{
                            .blunt_symbol = .{
                                .token_type = BluntSymbol.not_, 
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
                    Token{
                        .blunt_symbol = .{
                            .token_type = BluntSymbol.open_bracket_, 
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
                    Token{
                        .blunt_symbol = .{
                            .token_type = BluntSymbol.close_bracket_, 
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
                    Token{
                        .blunt_symbol = .{
                            .token_type = BluntSymbol.open_par_, 
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
                    Token{
                        .blunt_symbol = .{
                            .token_type = BluntSymbol.close_par_, 
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
                    Token{
                        .blunt_symbol = .{
                            .token_type = BluntSymbol.open_curly_, 
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
                    Token{
                        .blunt_symbol = .{
                            .token_type = BluntSymbol.close_curly_, 
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
                        Token{
                            .blunt_symbol = .{
                                .token_type = BluntSymbol.and_, 
                                .position = pos, 
                                .length = lookahead, 
                                .line_no = newline_count
                            }
                        }
                        , lookahead, newline_count
                    };
                } else {
                    return .{
                        Token{
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
                        Token{
                            .blunt_symbol = .{
                                .token_type = BluntSymbol.or_, 
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
                        Token{
                            .blunt_symbol = .{
                                .token_type = BluntSymbol.combine_, 
                                .position = pos, 
                                .length = lookahead, 
                                .line_no = newline_count
                            }
                        }
                        , lookahead, newline_count
                    };
                } else {
                    return .{
                        Token{
                            .blunt_symbol = .{
                                .token_type = BluntSymbol.pipe_, 
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
                    Token{
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



inline fn _getKeywordOrId(allocator: std.mem.Allocator, pos : usize, list_of_chars : []const u8, input_len: usize, newline_count: usize) !struct{?Token, usize, usize} {
    const temp_ = try _finiteAutomaton(allocator, pos, list_of_chars, input_len);
    const token_ = temp_.@"0"; const lookahead = temp_.@"1";
    // std.debug.print("hello world ____ {s}\n", .{token_});
    const keyword = _mapToKeyword(&token_);
    
    if (keyword != null) {
        return .{
            Token{
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
            Token{
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

fn getDstringLit(allocator: std.mem.Allocator, pos : usize, list_of_chars : []const u8, input_len: usize, newline_count: usize) !struct{?Token, usize, usize}{
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
                Token{
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
                    Token{
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
        Token{
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
