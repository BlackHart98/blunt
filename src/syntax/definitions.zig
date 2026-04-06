const lexer = @import("../lexer/definitions.zig");
const std = @import("std");

//------------------------------------------------------------------------------
// Core Language Constructs
//------------------------------------------------------------------------------

/// Top-level program structure
pub const CompilationUnit = struct {
    decls: ?[] Declaration,
    position: usize,
    offset: usize,
    line_no: usize,
};


pub const Declaration = union(enum) {
    const_decl: ConstDeclaration,
    // meta_decl: MetaDeclaration
};


pub const ConstDeclaration = struct {
    identifier: lexer.Token,
    type_: ?Type,
    rval: ExprOrBlock, 
    position: usize,
    offset: usize,
    line_no: usize,
};


pub const VarDeclaration = struct {
    identifier: lexer.Token,
    type_: ?Type,
    rval: ExprOrBlock, 
    position: usize,
    offset: usize,
    line_no: usize,
};


pub const ExprOrBlock = union(enum) {
    expr: Expr,
    bloc: Block,
    import: Import,
    proc_sig: ProcSignature,
};


pub const Import = struct {
    module: lexer.Token, 
    position: usize,
    offset: usize,
    line_no: usize,
};

//------------------------------------------------------------------------------
// Identifiers and Basic Types
//------------------------------------------------------------------------------

/// Basic type definition
pub const Type = union(enum) {
    primitive_type: PrimitiveType,
    // proc_type: ProcType,
    // list_type: ListType,
    // map_type: MapType,
    // set_type: SetType,
    // rel_type: RelType,
    // lrel_type: LrelType,
};


/// Primitive type
pub const PrimitiveType = struct {
    primitive_type: PrimitiveTypeEnum,
};


pub const PrimitiveTypeEnum = enum(u8){
    NumType,
    IntType,
    RealType,
    StringType,
    VoidType,
};


pub const Parameter = struct {
    parameter: lexer.Token,
    type_: Type,
    position: usize,
    offset: usize,
    line_no: usize,
};


pub const Constraints = struct {
    constraints: []Expr,
    type_: Type,
    position: usize,
    offset: usize,
    line_no: usize,
};


//------------------------------------------------------------------------------
// Block
//------------------------------------------------------------------------------

pub const Block = struct {
    sig: ?ProcSignature,
    stmts: ?[]Statement,
    position: usize,
    offset: usize,
    line_no: usize,
};

pub const ProcSignature = struct {
    param_list: ?[]Parameter,
    return_type: ?Type,
    param_constraints: ?Constraints,
    position: usize,
    offset: usize,
    line_no: usize,
};

/// Available statement types
pub const Statement = union(enum) {
    // function_def: FunctionDef,
    const_decl: ConstDeclaration,
    var_decl: VarDeclaration,
    assign_stmt : AssignmentStmt,
    // for_stmt: ForStmt,
    // if_stmt: IfStmt,
    // function_call: FunctionCall,
};

pub const AssignmentStmt = union(enum) {
    lval: Expr,
    rval: ExprOrBlock,
};


//------------------------------------------------------------------------------
// Expressions
//------------------------------------------------------------------------------

/// Available expression types
pub const Expr = union(enum) {
    binary_op: BinaryOp,
    unary_op: UnaryOp,
    bracket: *Bracket,
    identifier: lexer.Token,
    proc_call: ProcCall,
    number_expr: Number,
    string_expr: String,
    sstring_expr: String,
    generator: Generator,
};

pub const BinaryOp = struct {
    op: enum(u8){
        Add, 
        Sub, 
        Mul, 
        Div, 
        Pow, 
        And, 
        Or, 
        Dot, 
        Eq, 
        Neq, 
        Gt, 
        Lt, 
        Gte, 
        Lte, 
        Match,
        Pipe,
        Combine,},
    left: *Expr,
    right: *Expr,
    position: usize,
    offset: usize,
    line_no: usize,
};

pub const UnaryOp = struct {
    op: enum(u8) { UMin, UPlus, Not, },
    expr: *Expr,
    position: usize,
    offset: usize,
    line_no: usize,
};

/// Expression Grouping
pub const Bracket = struct {
    expr: *Expr,
    position: usize,
    offset: usize,
    line_no: usize,
};

// Number
pub const Number = struct {
    number: lexer.Token,
};

// String
pub const String = struct {
    string: lexer.Token,
};



//------------------------------------------------------------------------------
// Function Calls and Arguments
//------------------------------------------------------------------------------

/// Function invocation
pub const ProcCall = struct {
    function_id: *const Expr,
    args: []*const Expr,
    position: usize,
    offset: usize,
    line_no: usize,
};


/// Generator expression for iterations
pub const Generator = struct {
    result: *Expr,
    iterator: *Expr,
    position: usize,
    offset: usize,
    line_no: usize,
};