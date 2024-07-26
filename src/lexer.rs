use std::collections::HashSet;
use crate::utils::{
    is_identifier_substring,
    finite_automaton,
    RESERVED_WORDS,
    TType
};

#[allow(dead_code)]


#[derive(Debug, PartialEq, Clone)]
pub struct Token{
    token_type : TType,
    position : usize,
    length : usize,
    line_no : usize,
}


pub fn scan_input<'a>(input : &str) -> Result<Vec<Token>, Token>{
    let mut result = Vec::<Token>::new();
    let list_of_chars = input.chars().collect::<Vec<char>>();
    let input_len = list_of_chars.len();
    let mut counter: usize = 0;
    let mut token_lexeme:Token;
    let mut newline_count = 1;

    while counter < input_len {
        (token_lexeme, counter, newline_count) = emit_token(
            counter, 
            &list_of_chars, 
            input_len, 
            newline_count);
        match token_lexeme {
            Token{
                token_type: TType::UnsupportedToken(_)
                , position:_
                , length:_
                , line_no:_} => return Err(token_lexeme),
            _ => ()
        }
        result.push(token_lexeme);   
    }

    return Ok(filter_whitespace(&result));
    
}


fn emit_token(
    pos : usize, 
    list_of_chars : &Vec<char>, 
    input_len : usize, 
    newline_count : usize) -> (Token, usize, usize) {

    let mut lookahead = pos;
    let mut token_ = String::from("");
    let keywords = HashSet::from(RESERVED_WORDS);
    let mut newline_count = newline_count;
    return match list_of_chars[pos] {
        'a'..='z' => {
            get_keyword_or_id(pos, list_of_chars, input_len, newline_count)
        }
        'A'..='Z' => {
            get_keyword_or_id(pos, list_of_chars, input_len, newline_count)
        }
        '0'..='9' => {
            token_.push(list_of_chars[pos]);
            lookahead = pos + 1;
            let mut found_dot = false;
            while lookahead < input_len { 
                if list_of_chars[lookahead].is_numeric() {
                    token_.push(list_of_chars[lookahead]);
                    lookahead += 1;
                }else if list_of_chars[lookahead] == '.' &&  !found_dot {
                    token_.push(list_of_chars[lookahead]);
                    found_dot = true;
                    lookahead += 1;
                } else if list_of_chars[lookahead].is_numeric() && found_dot {
                    token_.push(list_of_chars[lookahead]);
                    lookahead += 1;
                } else if list_of_chars[lookahead] == '.' &&  found_dot {
                    token_.push(list_of_chars[lookahead]);
                    return (
                        Token{
                            token_type: TType::UnsupportedToken(token_.to_owned()), 
                            position: pos, 
                            length: lookahead, 
                            line_no: newline_count
                        }
                        , lookahead, newline_count
                    );
                } else if list_of_chars[lookahead].is_alphabetic() {
                    token_.push(list_of_chars[lookahead]);
                    lookahead += 1;
                    return (
                        Token{
                            token_type: TType::UnsupportedToken(token_.to_owned()), 
                            position: pos, 
                            length: lookahead, 
                            line_no: newline_count
                        }
                        , lookahead, newline_count
                    );
                } else  {
                    break;
                }
            }
            (
                Token{
                    token_type: TType::Num(token_.to_owned()), 
                    position: pos, 
                    length: lookahead, 
                    line_no: newline_count
                }
                , lookahead, newline_count
            )
        }
        '$' => {
            token_.push(list_of_chars[pos]);
            lookahead = pos + 1;
            while lookahead < input_len { 
                if list_of_chars[lookahead].is_numeric() {
                    token_.push(list_of_chars[lookahead]);
                    lookahead += 1;
                } else if list_of_chars[lookahead].is_alphabetic() {
                    token_.push(list_of_chars[lookahead]);
                    lookahead += 1;
                    return (
                        Token{
                            token_type: TType::UnsupportedToken(token_.to_owned()), 
                            position: pos, 
                            length: lookahead, 
                            line_no: newline_count
                        }
                        , lookahead, newline_count
                    );
                } else {
                    break;
                }
            }
            if token_.len() > 1{
                (
                    Token{
                        token_type: TType::GenericSymbol, 
                        position: pos, 
                        length: lookahead, 
                        line_no: newline_count
                    }
                    , lookahead, newline_count
                )
            } else {
                (
                    Token{
                        token_type: TType::UnsupportedToken(token_.to_owned()), 
                        position: pos, 
                        length: lookahead, 
                        line_no: newline_count
                    }
                    , lookahead, newline_count
                )
            }
        }
        '@' => {
            token_.push(list_of_chars[pos]);
            lookahead = pos + 1;
            while lookahead < input_len { 
                if list_of_chars[lookahead].is_lowercase() {
                    token_.push(list_of_chars[lookahead]);
                    lookahead += 1;
                } else if list_of_chars[lookahead].is_numeric() {
                    token_.push(list_of_chars[lookahead]);
                    lookahead += 1;
                    return (
                        Token{
                            token_type: TType::UnsupportedToken(token_.to_owned()), 
                            position: pos, 
                            length: lookahead, 
                            line_no: newline_count
                        }
                        , lookahead, newline_count
                    );
                } else {
                    break;
                }
            }
            if keywords.contains(token_.as_str()){
                (
                    Token{
                        token_type: TType::Keyword(token_.to_owned()), 
                        position: pos, 
                        length: lookahead, 
                        line_no: newline_count
                    }
                    , lookahead, newline_count
                )
            } else {
                (
                    Token{
                        token_type: TType::UnsupportedToken(token_.to_owned()), 
                        position: pos, 
                        length: lookahead, 
                        line_no: newline_count
                    }
                    , lookahead, newline_count
                )
            }
        }
        '+' => {
            token_.push(list_of_chars[pos]);
            lookahead = pos + 1;
            if list_of_chars[lookahead] == '='{
                token_.push(list_of_chars[lookahead]);
                lookahead += 1;
                (
                    Token{
                        token_type: TType::Incr, 
                        position: pos, 
                        length: lookahead, 
                        line_no: newline_count
                    }
                    , lookahead, newline_count
                )
            } else{
                (
                    Token{
                        token_type: TType::Plus, 
                        position: pos, 
                        length: lookahead, 
                        line_no: newline_count
                    }
                    , lookahead, newline_count
                )
            }
        }
        '*' => {
            token_.push(list_of_chars[pos]);
            lookahead = pos + 1;
            if list_of_chars[lookahead] == '='{
                token_.push(list_of_chars[lookahead]);
                lookahead += 1;
                (
                    Token{
                        token_type: TType::Incr, 
                        position: pos, 
                        length: lookahead, 
                        line_no: newline_count
                    }
                    , lookahead, newline_count
                )
            } else{
                (
                    Token{
                        token_type: TType::Plus, 
                        position: pos, 
                        length: lookahead, 
                        line_no: newline_count
                    }
                    , lookahead, newline_count
                )
            }
        }
        '/' => {
            token_.push(list_of_chars[pos]);
            lookahead = pos + 1;
            if list_of_chars[lookahead] == '='{
                token_.push(list_of_chars[lookahead]);
                lookahead += 1;
                (
                    Token{
                        token_type: TType::Incr, 
                        position: pos, 
                        length: lookahead, 
                        line_no: newline_count
                    }
                    , lookahead, newline_count
                )
            } else{
                (
                    Token{
                        token_type: TType::Plus, 
                        position: pos, 
                        length: lookahead, 
                        line_no: newline_count
                    }
                    , lookahead, newline_count
                )
            }
        }
        '=' => {
            token_.push(list_of_chars[pos]);
            lookahead = pos + 1;
            if list_of_chars[lookahead] == '='{
                token_.push(list_of_chars[lookahead]);
                lookahead += 1;
                (
                    Token{
                        token_type: TType::Eq, 
                        position: pos, 
                        length: lookahead, 
                        line_no: newline_count
                    }
                    , lookahead, newline_count
                )
            } else{
                (
                    Token{
                        token_type: TType::Bind, 
                        position: pos, 
                        length: lookahead, 
                        line_no: newline_count
                    }
                    , lookahead, newline_count
                )
            }
        }
        ':' => {
            token_.push(list_of_chars[pos]);
            lookahead = pos + 1;
            if list_of_chars[lookahead] == '='{
                token_.push(list_of_chars[lookahead]);
                lookahead += 1;
                (
                    Token{
                        token_type: TType::Match, 
                        position: pos, 
                        length: lookahead, 
                        line_no: newline_count
                    }
                    , lookahead, newline_count
                )
            } else {
                (
                    Token{
                        token_type: TType::Colon, 
                        position: pos, 
                        length: lookahead, 
                        line_no: newline_count
                    }
                    , lookahead, newline_count
                )
            }
        }
        ';' => {
            lookahead += 1;
            (
                Token{
                    token_type: TType::SemiColon, 
                    position: pos, 
                    length: lookahead, 
                    line_no: newline_count
                }
                , lookahead, newline_count
            )
        }
        ',' => {
            lookahead += 1;
            (
                Token{
                    token_type: TType::Comma, 
                    position: pos, 
                    length: lookahead, 
                    line_no: newline_count
                }
                , lookahead, newline_count
            )
        }
        '>' => {
            lookahead += 1;
            if list_of_chars[lookahead] == '='{
                token_.push(list_of_chars[lookahead]);
                lookahead += 1;
                (
                    Token{
                        token_type: TType::Gte, 
                        position: pos, 
                        length: lookahead, 
                        line_no: newline_count
                    }
                    , lookahead, newline_count
                )
            } else {
                (
                    Token{
                        token_type: TType::Gt, 
                        position: pos, 
                        length: lookahead, 
                        line_no: newline_count
                    }
                    , lookahead, newline_count
                )
            }
        }
        '<' => {
            lookahead += 1;
            if list_of_chars[lookahead] == '='{
                token_.push(list_of_chars[lookahead]);
                lookahead += 1;
                (
                    Token{
                        token_type: TType::Lte, 
                        position: pos, 
                        length: lookahead, 
                        line_no: newline_count
                    }
                    , lookahead, newline_count
                )
            } else if list_of_chars[lookahead] == ':'{
                token_.push(list_of_chars[lookahead]);
                lookahead += 1;
                (
                    Token{
                        token_type: TType::UpperBound, 
                        position: pos, 
                        length: lookahead, 
                        line_no: newline_count
                    }
                    , lookahead, newline_count
                )
            } else if list_of_chars[lookahead] == '-'{
                token_.push(list_of_chars[lookahead]);
                lookahead += 1;
                (
                    Token{
                        token_type: TType::Yield, 
                        position: pos, 
                        length: lookahead, 
                        line_no: newline_count
                    }
                    , lookahead, newline_count
                )
            } else{
                (
                    Token{
                        token_type: TType::Lt, 
                        position: pos, 
                        length: lookahead, 
                        line_no: newline_count
                    }
                    , lookahead, newline_count
                )
            }
        }
        '-' => {
            token_.push(list_of_chars[pos]);
            lookahead = pos + 1;
            if list_of_chars[lookahead] == '='{
                token_.push(list_of_chars[lookahead]);
                lookahead += 1;
                (
                    Token{
                        token_type: TType::Decr, 
                        position: pos, 
                        length: lookahead, 
                        line_no: newline_count
                    }
                    , lookahead, newline_count
                )
            } else if list_of_chars[lookahead] == '>'{
                token_.push(list_of_chars[lookahead]);
                lookahead += 1;
                (
                    Token{
                        token_type: TType::FwdArr, 
                        position: pos, 
                        length: lookahead, 
                        line_no: newline_count
                    }
                    , lookahead, newline_count
                )
            } else {
                (
                    Token{
                        token_type: TType::Minus, 
                        position: pos, 
                        length: lookahead, 
                        line_no: newline_count
                    }
                    , lookahead, newline_count
                )
            }
        }
        '_' => {
            token_.push(list_of_chars[pos]);
            lookahead = pos + 1;
            if list_of_chars[lookahead] == ' '{
                (
                    Token{
                        token_type: TType::Wildcard, 
                        position: pos, 
                        length: lookahead, 
                        line_no: newline_count
                    }
                    , lookahead, newline_count
                )
            }else{ 
                while lookahead < input_len { 
                    if is_identifier_substring(list_of_chars[lookahead]){
                        token_.push(list_of_chars[lookahead]);
                        lookahead += 1;
                    }else{
                        break;
                    }
                }
                (
                    Token{
                        token_type: TType::Id(token_.to_owned()), 
                        position: pos, 
                        length: lookahead, 
                        line_no: newline_count
                    }
                    , lookahead, newline_count
                )
            } 
        }
        ' ' => {
            lookahead += 1;
            (
                Token{
                    token_type: TType::HorizontalWhtSpc, 
                    position: pos, 
                    length: lookahead, 
                    line_no: newline_count
                }
                , lookahead, newline_count
            )
        }
        '\n' => {
            lookahead += 1;
            newline_count += 1;
            (
                Token{
                    token_type: TType::NewLine, 
                    position: pos, 
                    length: lookahead, 
                    line_no: newline_count - 1
                }
                , lookahead, newline_count
            )
        }
        '\t' => {
            lookahead += 1;
            (
                Token{
                    token_type: TType::HorizontalWhtSpc, 
                    position: pos, 
                    length: lookahead, 
                    line_no: newline_count
                }
                , lookahead, newline_count
            )
        }
        '.' => {
            token_.push(list_of_chars[pos]);
            lookahead = pos + 1;
            let mut found_dot = true;
            while lookahead < input_len { 
                if list_of_chars[lookahead].is_numeric() {
                    token_.push(list_of_chars[lookahead]);
                    lookahead += 1;
                }else if list_of_chars[lookahead] == '.' &&  !found_dot{
                    token_.push(list_of_chars[lookahead]);
                    found_dot = true;
                    lookahead += 1;
                } else if list_of_chars[lookahead].is_numeric() && found_dot {
                    token_.push(list_of_chars[lookahead]);
                    lookahead += 1;
                } else if list_of_chars[lookahead] == '.' &&  found_dot {
                    token_.push(list_of_chars[lookahead]);
                    return (
                        Token{
                            token_type: TType::UnsupportedToken(token_.to_owned()), 
                            position: pos, 
                            length: lookahead, 
                            line_no: newline_count
                        }
                        , lookahead, newline_count
                    );
                } else if list_of_chars[lookahead].is_alphabetic() {
                    token_.push(list_of_chars[lookahead]);
                    lookahead += 1;
                    return (
                        Token{
                            token_type: TType::UnsupportedToken(token_.to_owned()), 
                            position: pos, 
                            length: lookahead, 
                            line_no: newline_count
                        }
                        , lookahead, newline_count
                    );
                } else {
                    break;
                }
            }
            if token_.len() > 1 {
                (
                    Token{
                        token_type: TType::Num(token_.to_owned()), 
                        position: pos, 
                        length: lookahead, 
                        line_no: newline_count
                    }
                    , lookahead, newline_count
                )
            } else {
                (
                    Token{
                        token_type: TType::Dot, 
                        position: pos, 
                        length: lookahead, 
                        line_no: newline_count
                    }
                    , lookahead, newline_count
                )
            }
        }
        '!' => {
            token_.push(list_of_chars[pos]);
            lookahead = pos + 1;
            if list_of_chars[lookahead] == '='{
                token_.push(list_of_chars[lookahead]);
                lookahead += 1;
                (
                    Token{
                        token_type: TType::Neq, 
                        position: pos, 
                        length: lookahead, 
                        line_no: newline_count
                    }
                    , lookahead, newline_count
                )
            } else{
                (
                    Token{
                        token_type: TType::Not, 
                        position: pos, 
                        length: lookahead, 
                        line_no: newline_count
                    }
                    , lookahead, newline_count
                )
            }
        }
        '[' => {
            lookahead += 1;
            (
                Token{
                    token_type: TType::OpenBracket, 
                    position: pos, 
                    length: lookahead, 
                    line_no: newline_count
                }
                , lookahead, newline_count
            )
        }
        ']' => {
            lookahead += 1;
            (
                Token{
                    token_type: TType::CloseBracket, 
                    position: pos, 
                    length: lookahead, 
                    line_no: newline_count
                }
                , lookahead, newline_count
            )
        }
        '(' => {
            lookahead += 1;
            (
                Token{
                    token_type: TType::OpenPar, 
                    position: pos, 
                    length: lookahead, 
                    line_no: newline_count
                }
                , lookahead, newline_count
            )
        }
        ')' => {
            lookahead += 1;
            (
                Token{
                    token_type: TType::ClosePar, 
                    position: pos, 
                    length: lookahead, 
                    line_no: newline_count
                }
                , lookahead, newline_count
            )
        } 
        '{' => {
            lookahead += 1;
            (
                Token{
                    token_type: TType::OpenCurly, 
                    position: pos, 
                    length: lookahead, 
                    line_no: newline_count
                }
                , lookahead, newline_count
            )
        }
        '}' => {
            lookahead += 1;
            (
                Token{
                    token_type: TType::CloseCurly, 
                    position: pos, 
                    length: lookahead, 
                    line_no: newline_count
                }
                , lookahead, newline_count
            )
        }
        '\'' => {
            get_sstring_lit(pos, list_of_chars, input_len, newline_count)
        }
        '\"' => {
            get_dstring_lit(pos, list_of_chars, input_len, newline_count)
        }
        '&' => {
            token_.push(list_of_chars[pos]);
            lookahead = pos + 1;
            if list_of_chars[lookahead] == '&'{
                token_.push(list_of_chars[lookahead]);
                lookahead += 1;
                (
                    Token{
                        token_type: TType::And, 
                        position: pos, 
                        length: lookahead, 
                        line_no: newline_count
                    }
                    , lookahead, newline_count
                )
            } else{
                (
                    Token{
                        token_type: TType::UnsupportedToken(token_.to_owned()), 
                        position: pos, 
                        length: lookahead, 
                        line_no: newline_count
                    }
                    , lookahead, newline_count
                )
            }
        }
        '|' => {
            token_.push(list_of_chars[pos]);
            lookahead = pos + 1;
            if list_of_chars[lookahead] == '|'{
                token_.push(list_of_chars[lookahead]);
                lookahead += 1;
                (
                    Token{
                        token_type: TType::And, 
                        position: pos, 
                        length: lookahead, 
                        line_no: newline_count
                    }
                    , lookahead, newline_count
                )
            } else if list_of_chars[lookahead] == '>' {
                token_.push(list_of_chars[lookahead]);
                lookahead += 1;
                (
                    Token{
                        token_type: TType::Combine, 
                        position: pos, 
                        length: lookahead, 
                        line_no: newline_count
                    }
                    , lookahead, newline_count
                )
            } else {
                (
                    Token{
                        token_type: TType::Pipe, 
                        position: pos, 
                        length: lookahead, 
                        line_no: newline_count
                    }
                    , lookahead, newline_count
                )
            }
        }
        
        _ => {
            lookahead += 1;
            (
                Token{
                    token_type: TType::UnsupportedToken(list_of_chars[pos].to_string()), 
                    position: pos, 
                    length: lookahead, 
                    line_no: newline_count
                }
                , lookahead, newline_count
            )
        }
    };
}


fn get_keyword_or_id(
    pos : usize, 
    list_of_chars : &Vec<char>, 
    input_len : usize, 
    newline_count : usize
) -> (Token, usize, usize){

    let keywords = HashSet::from(RESERVED_WORDS);
    let lookahead:usize;
    let token_: String;
    (token_, lookahead) = finite_automaton(pos, list_of_chars, input_len, is_identifier_substring);
    if keywords.contains(token_.as_str()) {
        (
            Token{
                token_type: TType::Keyword(token_.to_owned()), 
                position: pos, 
                length: lookahead, 
                line_no: newline_count
            }
            , lookahead, newline_count
        )
    } else {
        (
            Token{
                token_type: TType::Id(token_.to_owned()), 
                position: pos, 
                length: lookahead, 
                line_no: newline_count
            }
            , lookahead, newline_count

        )
    }
}


fn get_sstring_lit(
    pos : usize, 
    list_of_chars : &Vec<char>, 
    input_len : usize, 
    newline_count : usize,
) -> (Token, usize, usize){
    let mut token_ = String::from("\"");
    let mut lookahead = pos + 1;
    let temp_ = HashSet::from(['\\', 'n', 't', '\'']);
    while lookahead < input_len { 
        if list_of_chars[lookahead] == '\"' {
            token_.push(list_of_chars[lookahead]);
            lookahead += 1;
            return (
                Token{
                    token_type: TType::StrLitDouble(token_.to_owned()), 
                    position: pos, 
                    length: lookahead, 
                    line_no: newline_count
                }
                , lookahead, newline_count
        
            );
        } else if list_of_chars[lookahead] != '\'' && list_of_chars[lookahead] != '\\'{
            token_.push(list_of_chars[lookahead]);
            lookahead += 1;
        }
        else if list_of_chars[lookahead] == '\\' {
            let buffer = list_of_chars[lookahead];
            println!("Got here");
            lookahead += 1;
            if !temp_.contains(&list_of_chars[lookahead]) {
                return (
                    Token{
                        token_type: TType::UnsupportedToken(String::from("")), 
                        position: pos, 
                        length: lookahead, 
                        line_no: newline_count
                    }
                    , lookahead, newline_count
            
                );
            } 
            token_.push(buffer);
            token_.push(list_of_chars[lookahead]);
            lookahead += 1;
        } else {
            break;
        }
    }
    (
        Token{
            token_type: TType::UnsupportedToken(token_.to_owned()), 
            position: pos, 
            length: lookahead, 
            line_no: newline_count
        }
        , lookahead, newline_count
    )
}


fn get_dstring_lit(
    pos : usize, 
    list_of_chars : &Vec<char>, 
    input_len : usize, 
    newline_count : usize,
) -> (Token, usize, usize){
    let mut token_ = String::from("\"");
    let mut lookahead = pos + 1;
    let temp_ = HashSet::from(['\\', 'n', 't', '\"']);
    while lookahead < input_len { 
        if list_of_chars[lookahead] == '\"' {
            token_.push(list_of_chars[lookahead]);
            lookahead += 1;
            return (
                Token{
                    token_type: TType::StrLitDouble(token_.to_owned()), 
                    position: pos, 
                    length: lookahead, 
                    line_no: newline_count
                }
                , lookahead, newline_count
        
            );
        } else if list_of_chars[lookahead] != '\"' && list_of_chars[lookahead] != '\\'{
            token_.push(list_of_chars[lookahead]);
            lookahead += 1;
        }
        else if list_of_chars[lookahead] == '\\' {
            let buffer = list_of_chars[lookahead];
            // println!("Got here{}", list_of_chars[lookahead+]);
            lookahead += 1;
            if !temp_.contains(&list_of_chars[lookahead]) {
                return (
                    Token{
                        token_type: TType::UnsupportedToken(String::from("")), 
                        position: pos, 
                        length: lookahead, 
                        line_no: newline_count
                    }
                    , lookahead, newline_count
            
                );
            } 
            token_.push(buffer);
            token_.push(list_of_chars[lookahead]);
            lookahead += 1;
        } else {
            break;
        }
    }
    (
        Token{
            token_type: TType::UnsupportedToken(token_.to_owned()), 
            position: pos, 
            length: lookahead, 
            line_no: newline_count
        }
        , lookahead, newline_count
    )
}


fn filter_whitespace(tokens : &Vec<Token>) -> Vec<Token> {
    let mut result : Vec<Token> = vec![];
    for x in tokens {
        match x {
            Token{token_type:TType::NewLine, position:_, length:_, line_no:_} => continue,
            Token{token_type:TType::HorizontalWhtSpc, position:_, length:_, line_no:_} => continue,
            _ => result.push(x.to_owned())
        }
    }
    result
}

