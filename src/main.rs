use blunt::lexer;
use std::fs::File;
use std::io::prelude::*;

fn main() -> std::io::Result<()> {
    let mut file = File::open("examples/hello.blunt")?;
    let mut file_content = String::new();
    file.read_to_string(&mut file_content)?;
    println!("blunt 0.1.0 \n {:?}", lexer::scan_input(&file_content));
    Ok(())
}
