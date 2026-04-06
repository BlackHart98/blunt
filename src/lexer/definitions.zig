const mem = @import("std").mem; 
const std = @import("std");


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


pub fn TokenComptime(comptime T : type) type {
    return struct {
        token_type : T,
        position : usize,
        offset : usize,
        line_no : usize,
    };
}


pub const Keyword = enum(u8) { 
    // keywords
    proc_,      if_,        import_,    var_,   return_,    for_,   else_,
    typedef_,   struct_,    enum_,      union_, in_,        true_,  false_,     try_,   
    catch_,     where_,     defer_,

    // data types
    any_, num_,  int_, str_,  float_, list_, tuple_, map_, void_, itr_
};


pub const Token = union(enum) {
    keyword_token: TokenComptime(?Keyword),
    identifier_token: TokenComptime(void),
    coment_single_line: TokenComptime([]const u8),
    coment_multi_line: TokenComptime([]const u8),
    esc_identifier_token: TokenComptime([]const u8),
    str_lit_single: TokenComptime([]const u8),
    str_lit_double: TokenComptime(void),
    special_char: TokenComptime([]const u8),
    blunt_symbol: TokenComptime(BluntSymbol),
    number: TokenComptime(void),
    unsupported_token: TokenComptime(u8),
};

pub const Position = struct{idx: usize, line_no: usize};