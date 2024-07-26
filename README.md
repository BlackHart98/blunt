# Blunt Language
**Blunt** is a general-purpose language that has (meta-programming language features for defining languages, code analysis, and code generation). The language will have the following:
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

```blunt
@import(prelude)


data Maybe[$1] = just(content:$1) | none();

fn map(x_fn : fn($1) -> $2) -> fn(list[$1]) -> list[$2]{
    return |x_list:list[$1]| -> list[$2] {
        return [x_fn(x) | x:$1 <- x_list];
    }
}

fn add1(x:int) -> int {
    return x + 1;
}

fn main(args : list[str]) -> void {
	print("hello world\n");
    var result = map(add1)([1,2,3,4]);
    print(result);
}
```


# Reserved words
The following are the list of reserved words in Avatre

```blunt

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