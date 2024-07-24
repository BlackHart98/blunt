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


pub fn is_identifier_substring(c : char) -> bool {is_alphabet(c) || is_number(c) || is_underscore(c)}  