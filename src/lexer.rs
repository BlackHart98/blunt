use std::collections::HashSet;

#[allow(dead_code)]



const RESERVED_WORDS: [&'static str; 36] 
    = [
        // keywords
        "fn", "if", "@import", "@extend", "let",
        "const", "return", "visit", "top_down", "bottom_up",
        "innermost", "fail", "insert", "outermost", "top_down_break",
        "for", "elif", "else","@external","@sypnosis","typedef",
        "data",

         // data types
        "any","num","int","str","real",
        "list","tuple","rel","lrel","map",
        "void","set","node","loc",
    ];


#[derive(Debug, PartialEq)]
pub enum Lexeme{
    Keyword{token: String, pos: usize, length: usize},
    SpecialChar{token: String, pos: usize, length: usize},
    WhiteSpace{token: String, pos: usize, length: usize},
    Number{token: String, pos: usize, length: usize},
    BinOp{token: String, pos: usize, length: usize},
    CommentSingleLine{token: String, pos: usize, length: usize},
    CommentMultiLine{token: String, pos: usize, length: usize},
    ForwardArrow{token: String, pos: usize, length: usize},
    Yield{token: String, pos: usize, length: usize},
    UnsupportedChar{token: String, pos: usize, length: usize},
    Identifier{token: String, pos: usize, length: usize},
    StringLiteralSingle{token: String, pos: usize, length: usize},
    StringLiteralDouble{token: String, pos: usize, length: usize},
}

pub fn scan_input<'a>(input : &str) -> Result<Vec<Lexeme>, &'static str>{
    let mut result = Vec::<Lexeme>::new();
    let keywords = HashSet::from(RESERVED_WORDS);

    // TODO: Implement scanner (stub)
    for (i, c) in input.chars().enumerate(){
        match c {
            ';' => result.push(Lexeme::SpecialChar{token: c.to_string(), pos: i, length: 1}),
            '+' => result.push(Lexeme::SpecialChar{token: c.to_string(), pos: i, length: 1}),
            '-' => result.push(Lexeme::SpecialChar{token: c.to_string(), pos: i, length: 1}),
            '*' => result.push(Lexeme::SpecialChar{token: c.to_string(), pos: i, length: 1}),
            '^' => result.push(Lexeme::SpecialChar{token: c.to_string(), pos: i, length: 1}),
            '`' => result.push(Lexeme::SpecialChar{token: c.to_string(), pos: i, length: 1}),
            '=' => result.push(Lexeme::SpecialChar{token: c.to_string(), pos: i, length: 1}),
            '/' => result.push(Lexeme::SpecialChar{token: c.to_string(), pos: i, length: 1}),
            ' ' => result.push(Lexeme::WhiteSpace{token: c.to_string(), pos: i, length: 1}),
            '\n' => result.push(Lexeme::WhiteSpace{token: c.to_string(), pos: i, length: 1}),
            '\t' => result.push(Lexeme::WhiteSpace{token: c.to_string(), pos: i, length: 1}),
            _ => result.push(Lexeme::UnsupportedChar{token: c.to_string(), pos: i, length: 1}),
        }
    }
    
    if !has_unsupported_char(&result) {
      return Err("unsupported character");  
    }   else{
        return Ok(result);
    }
}

fn has_unsupported_char(lexemes : &Vec<Lexeme>) -> bool{
    for x in lexemes{
        match x{
            Lexeme::UnsupportedChar{token:_,pos:_,length:_} => return false,
            _ => continue
        }
    }
    return true
}

// fn lookahead() -> 