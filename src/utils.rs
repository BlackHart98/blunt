pub fn is_alphabet(c : char) -> bool{
    return match c {
        'a'..='z' => true,
        'A'..='Z' => true,
        _ => false
    };
}

pub fn is_number(c : char) -> bool{
    return match c {
        '0'..='9' => true,
        _ => false
    };
}

pub fn is_underscore(c : char) -> bool{
    return match c {
        '_' => true,
        _ => false
    };
}


pub fn is_identifier_substring(c : char) -> bool {c.is_alphanumeric() || is_underscore(c)} 
pub fn not_whitespace(c : char) -> bool {c == ' ' || c == '\t' || c == '\n'} 



pub fn finite_automaton(
    pos : usize, 
    list_of_chars : &Vec<char>, 
    input_len : usize,
    next_char_fn:fn(char) -> bool) -> (String, usize) {
    let mut token_ = String::from("");
    let mut lookahead = pos + 1;
    token_.push(list_of_chars[pos]);
    // lookahead = pos + 1;
    while lookahead < input_len { 
        if next_char_fn(list_of_chars[lookahead]){
            token_.push(list_of_chars[lookahead]);
            lookahead += 1;
        }else{
            break;
        }
    }
    (token_, lookahead)
}