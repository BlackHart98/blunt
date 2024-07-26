pub const RESERVED_WORDS: [&'static str; 42] 
    = [
        // keywords
        "fn", "if", "@import", "@extend", "var",
        "const", "return", "visit", "top_down", "bottom_up",
        "innermost", "fail", "insert", "outermost", "top_down_break",
        "for", "elif", "else","@external","@sypnosis","typedef",
        "data", "in", "true", "false", "try", "catch",

         // data types
        "any","num","int","str","real",
        "list","tuple","rel","lrel","map",
        "void","set","node","loc", "itr"
    ];


    #[derive(Debug, PartialEq, Clone)]
    pub enum TType{
        Keyword(String),
        Annotation(String),
        Num(String),
        CmtSingleLine(String),
        CmtMultiLine(String),
        UnsupportedToken(String),
        Id(String),
        EscId(String),
        StrLitSingle(String),
        StrLitDouble(String),
        SpecialChar(String),
        Pipe,
        GenericSymbol,
        Yield,
        FwdArr,
        Wildcard,
        Plus,
        Minus,
        Incr,
        Decr,
        Eq,
        Neq,
        Gt,
        Lt,
        Gte,
        Lte,
        Bind,
        Colon,
        Match,
        SemiColon,
        NewLine,
        HorizontalWhtSpc,
        Comma,
        Dot,
        UpperBound,
        OpenPar,
        ClosePar,
        OpenCurly,
        CloseCurly,
        OpenBracket,
        CloseBracket,
        And,
        Or,
        Not,
        Combine,
    }








pub fn is_alphabet(c : char) -> bool{
    return match c {
        'a'..='z' => true,
        'A'..='Z' => true,
        _ => false
    };
}

pub fn is_number(c : char) -> bool{
    return match c {
        '0'..='9' => true,
        _ => false
    };
}

pub fn is_underscore(c : char) -> bool{
    return match c {
        '_' => true,
        _ => false
    };
}


pub fn is_identifier_substring(c : char) -> bool {c.is_alphanumeric() || is_underscore(c)} 
pub fn not_whitespace(c : char) -> bool {c == ' ' || c == '\t' || c == '\n'} 



pub fn finite_automaton(
    pos : usize, 
    list_of_chars : &Vec<char>, 
    input_len : usize,
    next_char_fn:fn(char) -> bool) -> (String, usize) {
    let mut token_ = String::from("");
    let mut lookahead = pos + 1;
    token_.push(list_of_chars[pos]);
    // lookahead = pos + 1;
    while lookahead < input_len { 
        if next_char_fn(list_of_chars[lookahead]){
            token_.push(list_of_chars[lookahead]);
            lookahead += 1;
        }else{
            break;
        }
    }
    (token_, lookahead)
}