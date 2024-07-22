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