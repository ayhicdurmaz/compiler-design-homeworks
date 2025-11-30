#ifndef AST_H
#define AST_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// AST Node types for MiniGo language
typedef enum {
    // Program structure
    AST_PROGRAM,
    AST_PACKAGE_DECL,
    AST_FUNCTION_DECL,
    AST_PARAMETER,
    AST_PARAMETER_LIST,
    
    // Statements
    AST_BLOCK,
    AST_VAR_DECL,
    AST_ASSIGNMENT,
    AST_DECL_ASSIGNMENT,
    AST_IF_STMT,
    AST_FOR_STMT,
    AST_RETURN_STMT,
    AST_BREAK_STMT,
    AST_CONTINUE_STMT,
    AST_EXPR_STMT,
    
    // Expressions
    AST_BINARY_OP,
    AST_UNARY_OP,
    AST_FUNCTION_CALL,
    AST_IDENTIFIER,
    AST_INT_LITERAL,
    AST_FLOAT_LITERAL,
    AST_STRING_LITERAL,
    AST_BOOL_LITERAL,
    AST_NIL_LITERAL,
    
    // Argument list
    AST_ARG_LIST
} ASTNodeType;

// Forward declaration
typedef struct ASTNode ASTNode;

// Union to store different types of values
typedef union {
    char *string_value;
    int int_value;
    double float_value;
    int bool_value;
} ASTValue;

// AST Node structure
struct ASTNode {
    ASTNodeType type;
    ASTValue value;
    
    // Children - flexible structure
    ASTNode *left;
    ASTNode *right;
    ASTNode *third;  // For ternary operations like if-else
    ASTNode *fourth; // For additional children
    
    // For lists (statements, parameters, arguments)
    ASTNode **children;
    int child_count;
    int child_capacity;
    
    // Source location info (for error reporting)
    int line_number;
};

// Function prototypes

// Constructor functions
ASTNode* ast_create_node(ASTNodeType type);
ASTNode* ast_create_program(ASTNode *package_decl, ASTNode *declarations);
ASTNode* ast_create_package_decl(char *name);
ASTNode* ast_create_function_decl(char *name, ASTNode *params, ASTNode *body);
ASTNode* ast_create_parameter(char *name, char *type);
ASTNode* ast_create_parameter_list();
ASTNode* ast_create_block();
ASTNode* ast_create_var_decl(char *name, char *type, ASTNode *init_expr);
ASTNode* ast_create_assignment(char *name, ASTNode *expr);
ASTNode* ast_create_decl_assignment(char *name, ASTNode *expr);
ASTNode* ast_create_if_stmt(ASTNode *condition, ASTNode *then_block, ASTNode *else_block);
ASTNode* ast_create_for_stmt(ASTNode *init, ASTNode *condition, ASTNode *update, ASTNode *body);
ASTNode* ast_create_return_stmt(ASTNode *expr);
ASTNode* ast_create_break_stmt();
ASTNode* ast_create_continue_stmt();
ASTNode* ast_create_expr_stmt(ASTNode *expr);
ASTNode* ast_create_binary_op(char *op, ASTNode *left, ASTNode *right);
ASTNode* ast_create_unary_op(char *op, ASTNode *operand);
ASTNode* ast_create_function_call(char *name, ASTNode *args);
ASTNode* ast_create_identifier(char *name);
ASTNode* ast_create_int_literal(int value);
ASTNode* ast_create_float_literal(double value);
ASTNode* ast_create_string_literal(char *value);
ASTNode* ast_create_bool_literal(int value);
ASTNode* ast_create_nil_literal();
ASTNode* ast_create_arg_list();

// List manipulation functions
void ast_add_child(ASTNode *parent, ASTNode *child);
void ast_add_statement(ASTNode *block, ASTNode *stmt);
void ast_add_parameter(ASTNode *param_list, ASTNode *param);
void ast_add_argument(ASTNode *arg_list, ASTNode *arg);

// Utility functions
void ast_print(ASTNode *node, int indent);
void ast_free(ASTNode *node);
const char* ast_node_type_to_string(ASTNodeType type);
char* custom_strdup(const char* str);

#endif // AST_H
