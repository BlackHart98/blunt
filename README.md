# Avatre
**Avatre** is a general-purpose language that has (meta-programming language features for defining languages, code analysis, and code generation). The language will have the following:
- [Syntax Definition]()
- [Algebraic Data Types]()
- [Data Types]()
- [Functions]()
- [Variables]()
- [Gradual Typing]()
- [Type inference]()
- [Type checking]()
- [Type safety]()
- [Control structure]()
- [Visiting]()
- [Switch/Match]()
- [Language Bindings with Rust, C/C++, Java]()
- [Rewriting]()
- [Modularity]()
- [Extensibility/Mixins]()
- [Error as value]()
- [Closures]()
- [Generics]()
- [Pattern matching]()
- [String interpolation]()
- [STDLIB]()



# Code snippet(tentative)

```avatre
// proposed syntax (not yet refined)
@import(test/mod)
@import(prelude) 

data X = x(...) | y(...);

private fn foobar(x : int) -> int {
	return 0;
}

public fn foobar(x : (int) -> int) -> int {
	...
}

public fn foo(x : &T) -> int {
	...
}

// entrypoint
fn main() -> void {
	println("hello world");
}
```


# Reserved words
The following are the list of reserved words in Avatre

```avatre

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


```