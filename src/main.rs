use avatre::lexer;

fn main() {
    let mut foo = vec![lexer::Lexeme::Keyword{token: "fn", pos: 0, length: 2}];
    // println!("Hello, world! {:?}", lexer::scan_string("input"));
    println!("Hello, world! {:?}", foo);
}
