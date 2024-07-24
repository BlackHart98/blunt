use std::collections::HashSet;
use crate::utils::is_identifier_substring;

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
    VerticalWhiteSpace{token: String, pos: usize, length: usize},
    HorizontalWhiteSpace{token: String, pos: usize, length: usize},
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
    let list_of_chars = input.chars().collect::<Vec<char>>();
    let input_len = list_of_chars.len();
    let mut counter: usize = 0;
    let mut token_lexeme:Lexeme;
    // TODO: Implement scanner (stub)
    while counter < input_len {
        (token_lexeme, counter,) = emit_token(counter, &list_of_chars, input_len);
        result.push(token_lexeme);   
    }
    if !has_unsupported_char(&result) {
        return Err("unsupported character");  
    }   else{
        return Ok(result);
    }
}

fn emit_token(pos : usize, list_of_chars : &Vec<char>, input_len : usize) -> (Lexeme, usize) {
    let mut lookahead = pos;
    let mut token_ = String::from("");
    let keywords = HashSet::from(RESERVED_WORDS);
    return match list_of_chars[pos] {
        'a'..='z' => {
            token_.push(list_of_chars[pos]);
            lookahead = pos + 1;
            while lookahead < input_len { 
                if is_identifier_substring(list_of_chars[lookahead]){
                    token_.push(list_of_chars[lookahead]);
                    lookahead += 1;
                }else{
                    break;
                }
            }
            if keywords.contains(token_.as_str()){
                (Lexeme::Keyword{token:token_.to_owned(), pos:pos, length:lookahead}, lookahead)
            } else{
                (Lexeme::Identifier{token:token_.to_owned(), pos:pos, length:lookahead}, lookahead)   
            }
        }
        'A'..='Z' => {
            token_.push(list_of_chars[pos]);
            lookahead = pos + 1;
            while lookahead < input_len { 
                if is_identifier_substring(list_of_chars[lookahead]){
                    token_.push(list_of_chars[lookahead]);
                    lookahead += 1;
                }else{
                    break;
                }
            }
            (Lexeme::Identifier{token:token_.to_owned(), pos:pos, length:lookahead}, lookahead)   
        }
        '+' => {
            lookahead += 1;
            (Lexeme::SpecialChar{token:list_of_chars[pos].to_string(), pos:pos, length:lookahead}, lookahead)
        }
        ' ' => {
            token_.push(list_of_chars[pos]);
            lookahead = pos + 1;
            while lookahead < input_len { 
                if list_of_chars[lookahead] == ' '{
                    token_.push(list_of_chars[lookahead]);
                    lookahead += 1;
                }else{
                    break;
                }
            }
            (Lexeme::HorizontalWhiteSpace{token:list_of_chars[pos].to_string(), pos:pos, length:lookahead}, lookahead)
        }
        _ => {
            lookahead += 1;
            (Lexeme::SpecialChar{token:list_of_chars[pos].to_string(), pos:pos, length:lookahead}, lookahead)
        }
    };
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