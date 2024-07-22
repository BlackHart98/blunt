#[derive(Debug, PartialEq)]
pub enum Lexeme<'a>{
    Keyword{token: &'a str, pos: u32, length: u32},
    SpecialChar{token: &'a str, pos: u32, length: u32},
    WhiteSpace{token: &'a str, pos: u32, length: u32},
    Number{token: &'a str, pos: u32, length: u32},
    BinOp{token: &'a str, pos: u32, length: u32},
    Comment{token: &'a str, pos: u32, length: u32},
    ForwardArrow{token: &'a str, pos: u32, length: u32},
    Yield{token: &'a str, pos: u32, length: u32},
    UnsupportedToken{token: &'a str, pos: u32, length: u32},
    Identifier{token: &'a str, pos: u32, length: u32},
    StringLiteralSingle{token: &'a str, pos: u32, length: u32},
    StringLiteralDouble{token: &'a str, pos: u32, length: u32},
}


pub fn scan_string<'a>(input : &'a str) -> Result<Vec<Lexeme>, &'static str>{
    let mut foo = String::from(input);
    println!("Scanning...\n {:?}", foo);
    for (i, c) in input.chars().enumerate(){
        println!("pos-char pair => {:?} : {:?}", i, c);
    }

    return Err("scanner failed");
}


// fn lookahead() -> 