const lexer = @import("lexer.zig");
const std = @import("std");

//------------------------------------------------------------------------------
// Core Language Constructs
//------------------------------------------------------------------------------

/// Top-level program structure
pub const CompilationUnit = struct {
    import_decls: ?[]*const Import,
    statements: ?[]*const Statement,
    position: usize,
    length: usize,
    line_no: usize,
};

/// Module imports
pub const Import = struct {
    import: ?*const lexer.Token,
    alias: ?Alias,
    position: usize,
    length: usize,
    line_no: usize,
};

/// Import aliases
pub const Alias = struct {
    alias: Identifier,
    position: usize,
    length: usize,
    line_no: usize,
};

//------------------------------------------------------------------------------
// Identifiers and Basic Types
//------------------------------------------------------------------------------

/// Variable/function identifiers
pub const Identifier = struct {
    identifier: *const lexer.Token,
    position: usize,
    length: usize,
    line_no: usize,
};

/// Basic type definition
pub const Type = union(enum) {
    primitive_type: PrimitiveType,
    function_type: FunctionType,
    list_type: ListType,
    map_type: MapType,
    set_type: SetType,
    rel_type: RelType,
    lrel_type: LrelType,
};


/// Primitive type
pub const PrimitiveType = struct {
    primitive_type: PrimitiveTypeEnum,
    position: usize,
    length: usize,
    line_no: usize,
};


pub const PrimitiveTypeEnum = enum(u8){
    NumType,
    IntType,
    RealType,
    StringType,
    VoidType,
};


/// Function parameter definition
pub const Parameter = struct {
    parameter: Identifier,
    type_: *Type,
    position: usize,
    length: usize,
    line_no: usize,
};

//------------------------------------------------------------------------------
// Complex Types
//------------------------------------------------------------------------------

/// Function type with parameters and return type
pub const FunctionType = struct {
    parameter_type_list: []*Type,
    return_type: *Type,
    position: usize,
    length: usize,
    line_no: usize,
};

/// Collection Types
pub const ListType = struct {
    list_type: *Type,
    position: usize,
    length: usize,
    line_no: usize,
};

pub const SetType = struct {
    set_type: *Type,
    position: usize,
    length: usize,
    line_no: usize,
};

pub const MapType = struct {
    key_type: *Type,
    value_type: *Type,
    position: usize,
    length: usize,
    line_no: usize,
};

/// Relation Types
pub const RelType = struct {
    rel_type: []*Type,
    position: usize,
    length: usize,
    line_no: usize,
};

pub const LrelType = struct {
    rel_type: []*Type,
    position: usize,
    length: usize,
    line_no: usize,
};

//------------------------------------------------------------------------------
// Statements
//------------------------------------------------------------------------------

/// Available statement types
pub const Statement = union(enum) {
    function_def: FunctionDef,
    declaration_stmt: DeclarationStmt,
    assignment_stmt : AssignmentStmt,
    for_stmt: ForStmt,
    function_call: FunctionCall,
};

/// Function definition
pub const FunctionDef = struct {
    function_id: Identifier,
    parameters: ?[]*Parameter,
    return_type: Type,
    statements: ?[]*Statement,
    position: usize,
    length: usize,
    line_no: usize,
};

/// Variable assignment
pub const AssignmentStmt = struct {
    variable: Identifier,
    expr: ?*Expr,
    position: usize,
    length: usize,
    line_no: usize,
};


/// Variable assignment
pub const DeclarationStmt = struct {
    declaration_desc: ?lexer.Keyword,
    variable: Identifier,
    type_: *Type,
    expr: ?*Expr,
    position: usize,
    length: usize,
    line_no: usize,
};


/// Loop statement
pub const ForStmt = struct {
    generator: []*Expr,
    statements: []*Statement,
    position: usize,
    length: usize,
    line_no: usize,
};

//------------------------------------------------------------------------------
// Expressions
//------------------------------------------------------------------------------

/// Available expression types
pub const Expr = union(enum) {
    binary_op: *BinaryOp,
    unary_op: *UnaryOp,
    bracket: *Bracket,
    identifier: *Identifier,
    function_call: *FunctionCall,
    generator: *Generator,
    dot: *Dot,
};

pub const BinaryOp = struct {
    op: enum(u8){ Add, Sub, Mul, Div, Pow, And, Or },
    left: *Expr,
    right: *Expr,
    position: usize,
    length: usize,
    line_no: usize,
};

pub const UnaryOp = struct {
    op: enum(u8) { UMin, UPlus, Not, },
    expr: *Expr,
    position: usize,
    length: usize,
    line_no: usize,
};

/// Expression Grouping
pub const Bracket = struct {
    expr: *Expr,
    position: usize,
    length: usize,
    line_no: usize,
};

/// Member Access
pub const Dot = struct {
    expr_1: *Expr,
    expr_2: *Expr,
    position: usize,
    length: usize,
    line_no: usize,
};

//------------------------------------------------------------------------------
// Function Calls and Arguments
//------------------------------------------------------------------------------

/// Function invocation
pub const FunctionCall = struct {
    function_id: *Expr,
    args: []*Argument,
    position: usize,
    length: usize,
    line_no: usize,
};

/// Function argument
pub const Argument = struct {
    arg: *Expr,
    position: usize,
    length: usize,
    line_no: usize,
};

/// Generator expression for iterations
pub const Generator = struct {
    result: *Expr,
    iterator: *Expr,
    position: usize,
    length: usize,
    line_no: usize,
};