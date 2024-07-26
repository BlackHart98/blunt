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

# Type Hierarchy
Below is the hierarchy of types in the avatre language from lowest to highest

```text

                  ┌────────────┐
                  │   void     │
                  └────────────┘
                       ▲
                       │
                       │
    ┌──────────────────┴─────────────────────────────────────────────────────────────────────────────────────────────────┐
    │           │           │           │           │           │           │           │           │           │        │
    │           │           │           │           │           │           │           │           │           │        │
    │           │           │           │           │           │           │           │           │           │        │
   ┌─────┐   ┌────────┐   ┌────────┐   ┌────────┐   ┌───────┐   ┌────────┐   ┌────────┐   ┌────────┐   ┌────────┐   ┌────────┐
   │ int │   │  real  │   │  bool  │   │  str   │◄──│ list  │   │ tuple  │   │  set   │◄──│  rel   │   │  map   │   │  node  │
   └─────┘   └────────┘   └────────┘   └────────┘   └───────┘   └────────┘   └────────┘   └────────┘   └────────┘   └────────┘
    ▲           ▲           ▲           ▲           ▲           ▲           ▲           ▲           ▲           ▲           ▲
    │           │           │           │           │           │           │           │           │           │           │
    │           │           │           │           │           │           │           │           │           │           │
    └───────────┘           │           └─────────────────────────────────────────────────────────────────────────┐         │
        ▲                   │                                   ▲                                                 │         │
        │                   │                                   │                                                 │         │
        │                   │                                   │                                                 │         │
    ┌────────┐              |                                ┌────────┐                                           │         │
    │  num   │              |                                │  itr   │                                           │         │
    └────────┘              |                                └────────┘                                           │         │
        ▲                   |                                    ▲                                                │         │
        │                   |                                    │                                                │         │
        │                   |                                    │                                                │         │
        └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
                                                ▲
                                                │
                                                │
                                            ┌────────────┐
                                            │    any     │
                                            └────────────┘

```

# Code snippet(tentative)

```avatre
@import(prelude)

var result = a + aA + Ab - 2 && 3.0 + .04;

data Maybe[$1] = just($1 content) | none();


if n == 0 {
    println("debug");
}

fn foo(x: $1 <: int) -> fn($1) -> $2 {
    return x |> y |> z;
}


fn main(args : list[str]) -> void {
	print("hello world\n");
}
```


# Reserved words
The following are the list of reserved words in Avatre

```avatre

// keywords
"fn", "if", "@import", "@extend", "var",
"const", "return", "visit", "top_down", "bottom_up",
"innermost", "fail", "insert", "outermost", "top_down_break",
"for", "elif", "else","@external","@sypnosis","typedef",
"data", "in", "true", "false", "try", "catch",

// data types
"any","num","int","str","real",
"list","tuple","rel","lrel","map",
"void","set","node","loc","itr"


```