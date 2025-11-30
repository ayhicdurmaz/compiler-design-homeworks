%{
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"

extern int yylex();
extern int lineno;
void yyerror(const char *msg);

// Global variable to hold the root of the AST
ASTNode *ast_root = NULL;
%}

%union {
    int int_val;
    double float_val;
    char *string_val;
    int bool_val;
    ASTNode *node;
}

// Token declarations
%token <string_val> IDENT STRING_LIT
%token <int_val> INT_LIT
%token <float_val> FLOAT_LIT
%token <bool_val> TRUE FALSE
%token PACKAGE IMPORT FUNC VAR CONST TYPE STRUCT
%token IF ELSE FOR RETURN BREAK CONTINUE NIL
%token DECL_ASSIGN EQ NEQ LE GE AND OR INC DEC
%token PLUS MINUS MUL DIV MOD ASSIGN LT GT NOT
%token COMMA SEMICOLON COLON DOT
%token LPAREN RPAREN LBRACE RBRACE LBRACK RBRACK

// Non-terminal type declarations
%type <node> program package_decl declaration_list declaration
%type <node> function_decl parameter_list parameter_list_opt parameter
%type <node> block statement_list statement
%type <node> var_decl assignment_stmt if_stmt for_stmt return_stmt
%type <node> break_stmt continue_stmt expr_stmt
%type <node> expression primary_expr postfix_expr unary_expr
%type <node> multiplicative_expr additive_expr relational_expr
%type <node> equality_expr logical_and_expr logical_or_expr
%type <node> argument_list argument_list_opt

// Operator precedence and associativity
%left OR
%left AND
%left EQ NEQ
%left LT GT LE GE
%left PLUS MINUS
%left MUL DIV MOD
%right NOT UNARY_MINUS UNARY_PLUS
%left LPAREN RPAREN
%nonassoc IF
%nonassoc ELSE

%start program

%%

program:
    package_decl declaration_list
    {
        $$ = ast_create_program($1, $2);
        ast_root = $$;
    }
    ;

package_decl:
    PACKAGE IDENT
    {
        $$ = ast_create_package_decl($2);
        // Don't free $2 here, it's freed by ast_create_package_decl
    }
    ;

declaration_list:
    declaration_list declaration
    {
        if ($1->type == AST_BLOCK) {
            ast_add_statement($1, $2);
            $$ = $1;
        } else {
            ASTNode *list = ast_create_block();
            ast_add_statement(list, $1);
            ast_add_statement(list, $2);
            $$ = list;
        }
    }
    | declaration
    {
        $$ = $1;
    }
    ;

declaration:
    function_decl
    {
        $$ = $1;
    }
    ;

function_decl:
    FUNC IDENT LPAREN parameter_list_opt RPAREN block
    {
        $$ = ast_create_function_decl($2, $4, $6);
        // Don't free $2 here, it's handled by ast_create_function_decl
    }
    ;

parameter_list_opt:
    parameter_list
    {
        $$ = $1;
    }
    | /* empty */
    {
        $$ = ast_create_parameter_list();
    }
    ;

parameter_list:
    parameter_list COMMA parameter
    {
        ast_add_parameter($1, $3);
        $$ = $1;
    }
    | parameter
    {
        ASTNode *list = ast_create_parameter_list();
        ast_add_parameter(list, $1);
        $$ = list;
    }
    ;

parameter:
    IDENT IDENT
    {
        $$ = ast_create_parameter($1, $2);
        // Strings are handled by ast_create_parameter
    }
    | IDENT
    {
        $$ = ast_create_parameter($1, NULL);
        // String is handled by ast_create_parameter
    }
    ;

block:
    LBRACE statement_list RBRACE
    {
        $$ = $2;
    }
    | LBRACE RBRACE
    {
        $$ = ast_create_block();
    }
    ;

statement_list:
    statement_list statement
    {
        ast_add_statement($1, $2);
        $$ = $1;
    }
    | statement
    {
        ASTNode *block = ast_create_block();
        ast_add_statement(block, $1);
        $$ = block;
    }
    ;

statement:
    var_decl
    {
        $$ = $1;
    }
    | assignment_stmt
    {
        $$ = $1;
    }
    | if_stmt
    {
        $$ = $1;
    }
    | for_stmt
    {
        $$ = $1;
    }
    | return_stmt
    {
        $$ = $1;
    }
    | break_stmt
    {
        $$ = $1;
    }
    | continue_stmt
    {
        $$ = $1;
    }
    | expr_stmt
    {
        $$ = $1;
    }
    ;

var_decl:
    VAR IDENT ASSIGN expression
    {
        $$ = ast_create_var_decl($2, NULL, $4);
    }
    | IDENT DECL_ASSIGN expression
    {
        $$ = ast_create_decl_assignment($1, $3);
    }
    ;

assignment_stmt:
    IDENT ASSIGN expression
    {
        $$ = ast_create_assignment($1, $3);
    }
    ;

if_stmt:
    IF expression block %prec IF
    {
        $$ = ast_create_if_stmt($2, $3, NULL);
    }
    | IF expression block ELSE block
    {
        $$ = ast_create_if_stmt($2, $3, $5);
    }
    | IF expression block ELSE if_stmt
    {
        $$ = ast_create_if_stmt($2, $3, $5);
    }
    ;

for_stmt:
    FOR expression block
    {
        $$ = ast_create_for_stmt(NULL, $2, NULL, $3);
    }
    ;

return_stmt:
    RETURN expression SEMICOLON
    {
        $$ = ast_create_return_stmt($2);
    }
    | RETURN SEMICOLON
    {
        $$ = ast_create_return_stmt(NULL);
    }
    ;

break_stmt:
    BREAK SEMICOLON
    {
        $$ = ast_create_break_stmt();
    }
    ;

continue_stmt:
    CONTINUE SEMICOLON
    {
        $$ = ast_create_continue_stmt();
    }
    ;

expr_stmt:
    expression SEMICOLON
    {
        $$ = ast_create_expr_stmt($1);
    }
    ;

expression:
    logical_or_expr
    {
        $$ = $1;
    }
    ;

logical_or_expr:
    logical_or_expr OR logical_and_expr
    {
        $$ = ast_create_binary_op("||", $1, $3);
    }
    | logical_and_expr
    {
        $$ = $1;
    }
    ;

logical_and_expr:
    logical_and_expr AND equality_expr
    {
        $$ = ast_create_binary_op("&&", $1, $3);
    }
    | equality_expr
    {
        $$ = $1;
    }
    ;

equality_expr:
    equality_expr EQ relational_expr
    {
        $$ = ast_create_binary_op("==", $1, $3);
    }
    | equality_expr NEQ relational_expr
    {
        $$ = ast_create_binary_op("!=", $1, $3);
    }
    | relational_expr
    {
        $$ = $1;
    }
    ;

relational_expr:
    relational_expr LT additive_expr
    {
        $$ = ast_create_binary_op("<", $1, $3);
    }
    | relational_expr GT additive_expr
    {
        $$ = ast_create_binary_op(">", $1, $3);
    }
    | relational_expr LE additive_expr
    {
        $$ = ast_create_binary_op("<=", $1, $3);
    }
    | relational_expr GE additive_expr
    {
        $$ = ast_create_binary_op(">=", $1, $3);
    }
    | additive_expr
    {
        $$ = $1;
    }
    ;

additive_expr:
    additive_expr PLUS multiplicative_expr
    {
        $$ = ast_create_binary_op("+", $1, $3);
    }
    | additive_expr MINUS multiplicative_expr
    {
        $$ = ast_create_binary_op("-", $1, $3);
    }
    | multiplicative_expr
    {
        $$ = $1;
    }
    ;

multiplicative_expr:
    multiplicative_expr MUL unary_expr
    {
        $$ = ast_create_binary_op("*", $1, $3);
    }
    | multiplicative_expr DIV unary_expr
    {
        $$ = ast_create_binary_op("/", $1, $3);
    }
    | multiplicative_expr MOD unary_expr
    {
        $$ = ast_create_binary_op("%", $1, $3);
    }
    | unary_expr
    {
        $$ = $1;
    }
    ;

unary_expr:
    NOT unary_expr %prec NOT
    {
        $$ = ast_create_unary_op("!", $2);
    }
    | MINUS unary_expr %prec UNARY_MINUS
    {
        $$ = ast_create_unary_op("-", $2);
    }
    | PLUS unary_expr %prec UNARY_PLUS
    {
        $$ = ast_create_unary_op("+", $2);
    }
    | postfix_expr
    {
        $$ = $1;
    }
    ;

postfix_expr:
    postfix_expr LPAREN argument_list_opt RPAREN
    {
        ASTNode *call = ast_create_function_call("", $3);
        call->left = $1;  // Function expression (usually identifier)
        $$ = call;
    }
    | primary_expr
    {
        $$ = $1;
    }
    ;

primary_expr:
    IDENT
    {
        $$ = ast_create_identifier($1);
    }
    | INT_LIT
    {
        $$ = ast_create_int_literal($1);
    }
    | FLOAT_LIT
    {
        $$ = ast_create_float_literal($1);
    }
    | STRING_LIT
    {
        $$ = ast_create_string_literal($1);
    }
    | TRUE
    {
        $$ = ast_create_bool_literal(1);
    }
    | FALSE
    {
        $$ = ast_create_bool_literal(0);
    }
    | NIL
    {
        $$ = ast_create_nil_literal();
    }
    | LPAREN expression RPAREN
    {
        $$ = $2;
    }
    ;

argument_list_opt:
    argument_list
    {
        $$ = $1;
    }
    | /* empty */
    {
        $$ = ast_create_arg_list();
    }
    ;

argument_list:
    argument_list COMMA expression
    {
        ast_add_argument($1, $3);
        $$ = $1;
    }
    | expression
    {
        ASTNode *list = ast_create_arg_list();
        ast_add_argument(list, $1);
        $$ = list;
    }
    ;

%%

void yyerror(const char *msg) {
    fprintf(stderr, "Parse error at line %d: %s\n", lineno, msg);
}

int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *f = fopen(argv[1], "r");
        if (!f) {
            perror("fopen");
            return 1;
        }
        extern FILE *yyin;
        yyin = f;
    }

    if (yyparse() == 0) {
        printf("Parse successful!\n");
        printf("\nAST:\n");
        ast_print(ast_root, 0);
        ast_free(ast_root);
    } else {
        printf("Parse failed!\n");
        return 1;
    }

    return 0;
}
