use avatre::lexer;

fn main() {
    println!("avatre 0.1.0 \n {:?}", lexer::scan_input("return a + b;\n"));
}
