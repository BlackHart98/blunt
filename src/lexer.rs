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
    let list_of_chars = input.chars().collect::<Vec<char>>();
    let input_len = list_of_chars.len();
    let mut counter: usize = 0;
    let mut lookahead = 0;
    // TODO: Implement scanner (stub)
    while counter < input_len {
        let mut token_ = String::from("");
        token_ = match list_of_chars[counter] {
            'a'..='z' => {
                token_.push(list_of_chars[counter]);
                lookahead = counter + 1;
                while lookahead < input_len { 
                    if is_identifier_substring(list_of_chars[lookahead]){
                        token_.push(list_of_chars[lookahead]);
                        lookahead += 1;
                    }else{
                        break;
                    }
                }
                token_
            }
            _ => {
                lookahead += 1;
                list_of_chars[counter].to_string()
                
            }
        };
        if keywords.contains(token_.as_str()){
            result.push(Lexeme::Keyword{token:token_.to_owned(),pos:counter,length:lookahead});
        } else{
            result.push(Lexeme::Identifier{token:token_.to_owned(),pos:counter,length:lookahead});   
        }
        counter = lookahead;
        lookahead = counter;
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


fn is_alphabet(c : char) -> bool{
    return match c {
        'a'..='z' => true,
        'A'..='Z' => true,
        _ => false
    };
}

fn is_number(c : char) -> bool{
    return match c {
        '0'..='9' => true,
        _ => false
    };
}

fn is_underscore(c : char) -> bool{
    return match c {
        '_' => true,
        _ => false
    };
}


fn is_identifier_substring(c : char) -> bool {is_alphabet(c) || is_number(c) || is_underscore(c)}  