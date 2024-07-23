#[derive(Debug, PartialEq)]
pub enum Lexeme{
    Keyword{token: String, pos: usize, length: usize},
    SpecialChar{token: String, pos: usize, length: usize},
    WhiteSpace{token: String, pos: usize, length: usize},
    Number{token: String, pos: usize, length: usize},
    BinOp{token: String, pos: usize, length: usize},
    Comment{token: String, pos: usize, length: usize},
    ForwardArrow{token: String, pos: usize, length: usize},
    Yield{token: String, pos: usize, length: usize},
    UnsupportedChar{token: String, pos: usize, length: usize},
    Identifier{token: String, pos: usize, length: usize},
    StringLiteralSingle{token: String, pos: usize, length: usize},
    StringLiteralDouble{token: String, pos: usize, length: usize},
}


pub fn scan_input<'a>(input : &str) -> Result<Vec<Lexeme>, &'static str>{
    let mut result = Vec::<Lexeme>::new();
    for (i, c) in input.chars().enumerate(){
        match c {
            ';' => result.push(Lexeme::SpecialChar{token: c.to_string(), pos: i, length: 1}),
            _ => result.push(Lexeme::UnsupportedChar{token: c.to_string(), pos: i, length: 1}),
        }
    }
    let foo = has_unsupported_char(&result);
    if foo {
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