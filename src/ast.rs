use crate::utils::TType;
// Abstract syntax tree definition
#[derive(Debug, PartialEq, Clone)]
pub enum Blunt{
    Program{
        includes: Vec<Include>, 
        decls: Vec<Declaration>,
    }
}

#[derive(Debug, PartialEq, Clone)]
pub enum Include{
    Import{module: Vec<TType>},
    Extend{module: Vec<TType>}
}

#[derive(Debug, PartialEq, Clone)]
pub enum Declaration{
    FunctionDef{
        name: TType, 
        params: Vec<Param>, 
        return_type: Type, 
        body: Vec<Statement>
    },
    ConstDecl{
        const_id: TType,
        type_: Type,
        value: TType
    },
    TypeDef{alias: TType, typedef: Type},
    SumType{
        name: TType, 
        type_params: Vec<TypeParam>, 
        sum_types: Vec<Constructor>
    },
}

#[derive(Debug, PartialEq, Clone)]
pub enum Param{
    Param{identifier: TType, type_ : Type}
}

#[derive(Debug, PartialEq, Clone)]
pub enum Type{
    Int,
    Real,
    Num,
    Str,
    Void,
    Node,
    Map{key_type: Type, value_type: Type},
    List{list_type: Type},
    Tuple{tuple_types: Vec<Type>},
    Set{set_type: Type},
    Itr,
    Any,
    Node,
    Loc,
    GenericSym{sym: TType, constraint_sym: TType, constraint: Type},
    CustomType{type_id: TType}
}

#[derive(Debug, PartialEq, Clone)]
pub enum Expr{
    Add{left: Expr, right: Expr},
    Sub{left: Expr, right: Expr},
    Div{left: Expr, right: Expr},
    Mul{left: Expr, right: Expr},
    UAdd{value: Expr},
    USub{value: Expr},
    And{left: Expr, right: Expr},
    Or{left: Expr, right: Expr},
    Not{value: Expr},
    In{left: Expr, right: Expr},
    Eq{left: Expr, right: Expr},
    Neq{left: Expr, right: Expr},
    Gt{left: Expr, right: Expr},
    Lt{left: Expr, right: Expr},
    Gte{left: Expr, right: Expr},
    Lte{left: Expr, right: Expr}, 
    Combine{combination: Vec<Expr>},
    ClosureExpr{ 
        params: Vec<Param>, 
        return_type: Option<Type>, 
        body: Vec<Statement>
    },
    FunctionCall{func_id: TType, args: Vec<Expr>},
    ListLiteral{exprs : Vec<Expr>},
    SetLiteral{exprs : Vec<Expr>},  
    TupleLiteral{exprs : Vec<Expr>},
    MapLiteral{key_values : Vec<KeyParam>},
    ListComprehension{expr: Expr, gen_list: Vec<Expr>},    
    SetComprehension{expr: Expr, gen_list: Vec<Expr>}, 
    MapComprehension{key_param: KeyParam, gen_list: Vec<Expr>}, 
    TupleComprehension{expr: Expr, gen_list: Vec<Expr>},
    Enumerator{
        id: TType, 
        type_: Type, 
        iterable: Expr
    }  
}

#[derive(Debug, PartialEq, Clone)]
pub enum KeyParam{
    KeyParam{key: Expr, value: Expr}
}


#[derive(Debug, PartialEq, Clone)]
pub enum Statement{
    If{
        cond: Expr, 
        body: Vec<Statement>, 
        else_if: Option<If>,
        else_: Option<Vec<Statement>>
    },
    FunctionDef{
        name: TType, 
        params: Vec<Param>, 
        return_type: Option<Type>, 
        body: Vec<Statement>
    },
    Closure{ 
        params: Vec<Param>, 
        return_type: Type, 
        body: Vec<Statement>
    },
    For{
        yield_ : Expr, //Enumerator only
        body: Vec<Statement>
    },
    VarDecl{
        var: Expr, 
        type_: Option<Type>, 
        value: Expr
    },
    Return{value: Option<Expr>},
    Try{
        body: Vec<Statement>, 
        catches: Vec<Catch>, 
        finally: Option<Vec<Statement>>
    },

}

#[derive(Debug, PartialEq, Clone)]
pub enum Catch{
    Catch{pattern:Expr, body: Vec<Statement>} 
}

#[derive(Debug, PartialEq, Clone)]
pub enum Constructor{
    Constructor{
        constructor_name: TType,
        params: Vec<Param>
    },
}


#[derive(Debug, PartialEq, Clone)]
pub enum TypeParam{
    TypeParam{type_param: Type},
}


#[derive(Debug, PartialEq, Clone)]
pub struct Src {
    line_no: usize,
    start_pos: usize,
    end_pos: usize,
}