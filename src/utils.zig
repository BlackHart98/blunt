// Datatypes
pub fn Result(comptime T:type, comptime U:type) type {
    return union(enum){
        success: T,
        failure: U
    };
}


pub fn Maybe(comptime T:type) type {
    return union(enum){
        just: T,
        none
    };
}

// Right biased
pub fn Either(comptime T:type, comptime U:type) type {
    return union(enum){
        left: T,
        right: U
    };
}