# MiniGo Parser and AST Generator

## Project Overview

This is Project 2 in the compiler design series - a parser and Abstract Syntax Tree (AST) generator for MiniGo, a minimal subset of the Go programming language. This project builds upon the lexical analyzer from Project 1 and implements a complete parser that constructs an AST representation of the source code.

## Language Features

MiniGo supports the following language constructs:

### Keywords and Literals
- Keywords: `package`, `func`, `var`, `if`, `else`, `for`, `return`, `break`, `continue`, `true`, `false`, `nil`
- Integer literals: `0`, `42`, `123`
- Float literals: `3.14`, `2.71828`, `1.0e-5`
- String literals: `"hello"`, `"world"`
- Boolean literals: `true`, `false`
- Nil literal: `nil`

### Operators
- Arithmetic: `+`, `-`, `*`, `/`, `%`
- Comparison: `==`, `!=`, `<`, `>`, `<=`, `>=`
- Logical: `&&`, `||`, `!`
- Assignment: `=`, `:=`

### Statements and Expressions
- Variable declarations: `var x = 10`, `y := 20`
- Assignments: `x = y + 5`
- Function declarations: `func name(param1 type1) returnType { ... }`
- Function calls: `functionName(arg1, arg2)`
- If-else statements (with nested else-if support)
- For loops (while-style): `for condition { ... }`
- Return statements: `return value`
- Break and continue statements
- Block statements: `{ ... }`

## Grammar (EBNF)

```ebnf
program ::= package_decl declaration_list

package_decl ::= 'package' IDENT

declaration_list ::= declaration_list declaration | declaration

declaration ::= function_decl

function_decl ::= 'func' IDENT '(' parameter_list_opt ')' block

parameter_list_opt ::= parameter_list | ε
parameter_list ::= parameter_list ',' parameter | parameter
parameter ::= IDENT IDENT | IDENT

block ::= '{' statement_list '}' | '{' '}'

statement_list ::= statement_list statement | statement

statement ::= var_decl | assignment_stmt | if_stmt | for_stmt | 
              return_stmt | break_stmt | continue_stmt | expr_stmt

var_decl ::= 'var' IDENT '=' expression | IDENT ':=' expression

assignment_stmt ::= IDENT '=' expression

if_stmt ::= 'if' expression block |
            'if' expression block 'else' block |
            'if' expression block 'else' if_stmt

for_stmt ::= 'for' expression block

return_stmt ::= 'return' expression ';' | 'return' ';'

expression ::= logical_or_expr

logical_or_expr ::= logical_or_expr '||' logical_and_expr | logical_and_expr
logical_and_expr ::= logical_and_expr '&&' equality_expr | equality_expr
equality_expr ::= equality_expr ('=='|'!=') relational_expr | relational_expr
relational_expr ::= relational_expr ('<'|'>'|'<='|'>=') additive_expr | additive_expr
additive_expr ::= additive_expr ('+'|'-') multiplicative_expr | multiplicative_expr
multiplicative_expr ::= multiplicative_expr ('*'|'/'|'%') unary_expr | unary_expr
unary_expr ::= ('!'|'-'|'+') unary_expr | postfix_expr
postfix_expr ::= postfix_expr '(' argument_list_opt ')' | primary_expr

primary_expr ::= IDENT | INT_LIT | FLOAT_LIT | STRING_LIT | 
                 'true' | 'false' | 'nil' | '(' expression ')'
```

## AST Node Structure

The AST is represented using the following node types:

```c
typedef enum {
    // Program structure
    AST_PROGRAM, AST_PACKAGE_DECL, AST_FUNCTION_DECL,
    AST_PARAMETER, AST_PARAMETER_LIST,
    
    // Statements
    AST_BLOCK, AST_VAR_DECL, AST_ASSIGNMENT, AST_DECL_ASSIGNMENT,
    AST_IF_STMT, AST_FOR_STMT, AST_RETURN_STMT,
    AST_BREAK_STMT, AST_CONTINUE_STMT, AST_EXPR_STMT,
    
    // Expressions
    AST_BINARY_OP, AST_UNARY_OP, AST_FUNCTION_CALL,
    AST_IDENTIFIER, AST_INT_LITERAL, AST_FLOAT_LITERAL,
    AST_STRING_LITERAL, AST_BOOL_LITERAL, AST_NIL_LITERAL,
    
    // Lists
    AST_ARG_LIST
} ASTNodeType;
```

Each AST node contains:
- Node type identifier
- Value (for literals and identifiers)
- Child pointers for tree structure
- Dynamic arrays for lists (statements, parameters, arguments)

## Build Instructions

### Prerequisites

Make sure you have the required tools installed:

```bash
# Ubuntu/Debian
sudo apt-get install flex bison build-essential

# Or use the provided make target
make install-deps
```

### Building the Parser

```bash
# Build the parser
make

# Or manually:
bison -d parser.y
flex lexer.l
gcc -Wall -Wextra -std=c99 -g -o minigo_parser parser.tab.c lex.yy.c ast.c -lm
```

### Running the Parser

```bash
# Parse a file and display the AST
./minigo_parser test1.mg

# Or use the test target
make test

# Clean generated files
make clean
```

## Test Cases

### Valid Programs

1. **test1.mg**: Basic program with variables and if-else statement
2. **test2.mg**: Function declaration with recursion and loops
3. **test3.mg**: Complex expressions and nested if-else statements

### Invalid Programs

1. **test_errors.mg**: Contains syntax errors for testing error handling

## Example Output

When parsing `test1.mg`, the parser outputs:

```
Parse successful!

AST:
Program
  PackageDecl: main
  Block
    FunctionDecl: main
      ParameterList
      Block
        VarDecl: x
          IntLiteral: 10
        VarDecl: y
          FloatLiteral: 3.140000
        IfStmt
          BinaryOp: >
            Identifier: x
            IntLiteral: 5
          Block
            Assignment
              Identifier: x
              BinaryOp: +
                Identifier: x
                IntLiteral: 1
          Block
            Assignment
              Identifier: x
              BinaryOp: -
                Identifier: x
                IntLiteral: 1
```

## Implementation Details

### Parser Generator
- **Tool**: GNU Bison (LALR(1) parser generator)
- **Grammar**: Context-free grammar with proper operator precedence
- **Error Handling**: Provides line number information for syntax errors

### Lexer Integration
- **Tool**: Flex (Fast Lexical Analyzer)
- **Integration**: Seamlessly integrated with Bison using YYSTYPE union
- **Token Values**: Properly transfers semantic values (strings, numbers) to parser

### AST Construction
- **Memory Management**: Dynamic allocation with proper cleanup functions
- **Tree Structure**: Flexible node structure supporting both fixed and dynamic children
- **Visualization**: Tree printing function for debugging and demonstration

### Error Recovery
- Parser reports syntax errors with line numbers
- Graceful handling of unexpected tokens
- Clear error messages for debugging

## Future Enhancements

This parser serves as the foundation for Project 3 (Code Generation). Potential extensions include:

1. **Type System**: Add type checking and inference
2. **Symbol Table**: Implement scope management and symbol resolution
3. **More Constructs**: Add arrays, structs, and more complex expressions
4. **Error Recovery**: Implement error recovery to continue parsing after errors
5. **Semantic Analysis**: Add semantic validation beyond syntax checking

## Files Description

- `ast.h` / `ast.c`: AST node definitions and manipulation functions
- `lexer.l`: Flex lexer specification (updated from Project 1)
- `parser.y`: Bison parser grammar and AST construction
- `Makefile`: Build system and automation
- `test*.mg`: Test programs demonstrating various language features
- `README.md`: This documentation file

## Testing and Validation

The parser has been tested with various MiniGo programs covering:
- ✅ Basic arithmetic and logical expressions
- ✅ Variable declarations and assignments
- ✅ Function declarations with parameters
- ✅ Control flow statements (if-else, for loops)
- ✅ Function calls with arguments
- ✅ Nested constructs and complex expressions
- ✅ Error detection and reporting

This implementation provides a solid foundation for the next phase of the compiler project.
