#[derive(Debug, PartialEq)]
enum Lexeme<'a>{
    Keyword{token: &'a str, pos: u32, length: u32},
    SpecialChar{token: &'a str, pos: u32, length: u32},
    WhiteSpace{token: &'a str, pos: u32, length: u32},
    Number{token: &'a str, pos: u32, length: u32},
    BinOp{token: &'a str, pos: u32, length: u32},
    Comment{token: &'a str, pos: u32, length: u32},
    ForwardArrow{token: &'a str, pos: u32, length: u32},
    Yield{token: &'a str, pos: u32, length: u32},
    UnsupportedToken{token: &'a str, pos: u32, length: u32},
    Identifier{token: &'a str, pos: u32, length: u32}
}


fn scan_string<'a>(input : &'a str) -> Result<Vec<Lexeme>, &'static str>{
    let mut foo = String::from(input);
    println!("Scanning... {:?}", foo);
    return Err("scanner failed");
}


fn main() {
    // let foo = vec![Lexeme::Keyword{token: "fn", pos: 0, length: 2}];
    println!("Hello, world! {:?}", scan_string("input"));
}
