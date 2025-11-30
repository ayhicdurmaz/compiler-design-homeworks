#include "ast.h"

// Custom string duplication function to avoid strdup issues
char* custom_strdup(const char* str) {
    if (str == NULL) return NULL;
    size_t len = strlen(str) + 1;
    char* dup = malloc(len);
    if (dup != NULL) {
        memcpy(dup, str, len);
    }
    return dup;
}

// Helper function to create a basic AST node
ASTNode* ast_create_node(ASTNodeType type) {
    ASTNode *node = (ASTNode*)malloc(sizeof(ASTNode));
    if (!node) {
        fprintf(stderr, "Error: Memory allocation failed\n");
        exit(1);
    }
    
    node->type = type;
    node->left = NULL;
    node->right = NULL;
    node->third = NULL;
    node->fourth = NULL;
    node->children = NULL;
    node->child_count = 0;
    node->child_capacity = 0;
    node->line_number = 0;
    
    // Initialize union to zero
    memset(&node->value, 0, sizeof(ASTValue));
    
    return node;
}

// Program structure constructors
ASTNode* ast_create_program(ASTNode *package_decl, ASTNode *declarations) {
    ASTNode *node = ast_create_node(AST_PROGRAM);
    node->left = package_decl;
    node->right = declarations;
    return node;
}

ASTNode* ast_create_package_decl(char *name) {
    ASTNode *node = ast_create_node(AST_PACKAGE_DECL);
    node->value.string_value = custom_strdup(name);
    return node;
}

ASTNode* ast_create_function_decl(char *name, ASTNode *params, ASTNode *body) {
    ASTNode *node = ast_create_node(AST_FUNCTION_DECL);
    node->value.string_value = custom_strdup(name);
    node->left = params;
    node->right = body;
    return node;
}

ASTNode* ast_create_parameter(char *name, char *type) {
    ASTNode *node = ast_create_node(AST_PARAMETER);
    // Store parameter name in string_value, type information can be added later
    node->value.string_value = custom_strdup(name);
    // For now, we'll store type in left child as a string identifier
    if (type) {
        node->left = ast_create_identifier(type);
    }
    return node;
}

ASTNode* ast_create_parameter_list() {
    ASTNode *node = ast_create_node(AST_PARAMETER_LIST);
    node->child_capacity = 4; // Initial capacity
    node->children = (ASTNode**)malloc(sizeof(ASTNode*) * node->child_capacity);
    return node;
}

// Statement constructors
ASTNode* ast_create_block() {
    ASTNode *node = ast_create_node(AST_BLOCK);
    node->child_capacity = 8; // Initial capacity for statements
    node->children = (ASTNode**)malloc(sizeof(ASTNode*) * node->child_capacity);
    return node;
}

ASTNode* ast_create_var_decl(char *name, char *type, ASTNode *init_expr) {
    ASTNode *node = ast_create_node(AST_VAR_DECL);
    node->value.string_value = custom_strdup(name);
    node->left = init_expr;
    // Type information can be stored in right child if needed
    if (type) {
        node->right = ast_create_identifier(type);
    }
    return node;
}

ASTNode* ast_create_assignment(char *name, ASTNode *expr) {
    ASTNode *node = ast_create_node(AST_ASSIGNMENT);
    node->left = ast_create_identifier(name);
    node->right = expr;
    return node;
}

ASTNode* ast_create_decl_assignment(char *name, ASTNode *expr) {
    ASTNode *node = ast_create_node(AST_DECL_ASSIGNMENT);
    node->left = ast_create_identifier(name);
    node->right = expr;
    return node;
}

ASTNode* ast_create_if_stmt(ASTNode *condition, ASTNode *then_block, ASTNode *else_block) {
    ASTNode *node = ast_create_node(AST_IF_STMT);
    node->left = condition;
    node->right = then_block;
    node->third = else_block; // Can be NULL for if without else
    return node;
}

ASTNode* ast_create_for_stmt(ASTNode *init, ASTNode *condition, ASTNode *update, ASTNode *body) {
    ASTNode *node = ast_create_node(AST_FOR_STMT);
    node->left = init;
    node->right = condition;
    node->third = update;
    node->fourth = body;
    return node;
}

ASTNode* ast_create_return_stmt(ASTNode *expr) {
    ASTNode *node = ast_create_node(AST_RETURN_STMT);
    node->left = expr; // Can be NULL for empty return
    return node;
}

ASTNode* ast_create_break_stmt() {
    return ast_create_node(AST_BREAK_STMT);
}

ASTNode* ast_create_continue_stmt() {
    return ast_create_node(AST_CONTINUE_STMT);
}

ASTNode* ast_create_expr_stmt(ASTNode *expr) {
    ASTNode *node = ast_create_node(AST_EXPR_STMT);
    node->left = expr;
    return node;
}

// Expression constructors
ASTNode* ast_create_binary_op(char *op, ASTNode *left, ASTNode *right) {
    ASTNode *node = ast_create_node(AST_BINARY_OP);
    node->value.string_value = custom_strdup(op);
    node->left = left;
    node->right = right;
    return node;
}

ASTNode* ast_create_unary_op(char *op, ASTNode *operand) {
    ASTNode *node = ast_create_node(AST_UNARY_OP);
    node->value.string_value = custom_strdup(op);
    node->left = operand;
    return node;
}

ASTNode* ast_create_function_call(char *name, ASTNode *args) {
    ASTNode *node = ast_create_node(AST_FUNCTION_CALL);
    node->value.string_value = custom_strdup(name);
    node->left = args;
    return node;
}

ASTNode* ast_create_identifier(char *name) {
    ASTNode *node = ast_create_node(AST_IDENTIFIER);
    node->value.string_value = custom_strdup(name);
    return node;
}

ASTNode* ast_create_int_literal(int value) {
    ASTNode *node = ast_create_node(AST_INT_LITERAL);
    node->value.int_value = value;
    return node;
}

ASTNode* ast_create_float_literal(double value) {
    ASTNode *node = ast_create_node(AST_FLOAT_LITERAL);
    node->value.float_value = value;
    return node;
}

ASTNode* ast_create_string_literal(char *value) {
    ASTNode *node = ast_create_node(AST_STRING_LITERAL);
    node->value.string_value = custom_strdup(value);
    return node;
}

ASTNode* ast_create_bool_literal(int value) {
    ASTNode *node = ast_create_node(AST_BOOL_LITERAL);
    node->value.bool_value = value;
    return node;
}

ASTNode* ast_create_nil_literal() {
    return ast_create_node(AST_NIL_LITERAL);
}

ASTNode* ast_create_arg_list() {
    ASTNode *node = ast_create_node(AST_ARG_LIST);
    node->child_capacity = 4; // Initial capacity
    node->children = (ASTNode**)malloc(sizeof(ASTNode*) * node->child_capacity);
    return node;
}

// List manipulation functions
void ast_add_child(ASTNode *parent, ASTNode *child) {
    if (!parent || !child) return;
    
    // Ensure children array is allocated
    if (!parent->children) {
        parent->child_capacity = 4;
        parent->children = (ASTNode**)malloc(sizeof(ASTNode*) * parent->child_capacity);
        parent->child_count = 0;
    }
    
    // Resize if needed
    if (parent->child_count >= parent->child_capacity) {
        parent->child_capacity *= 2;
        parent->children = (ASTNode**)realloc(parent->children, 
                                             sizeof(ASTNode*) * parent->child_capacity);
    }
    
    parent->children[parent->child_count++] = child;
}

void ast_add_statement(ASTNode *block, ASTNode *stmt) {
    ast_add_child(block, stmt);
}

void ast_add_parameter(ASTNode *param_list, ASTNode *param) {
    ast_add_child(param_list, param);
}

void ast_add_argument(ASTNode *arg_list, ASTNode *arg) {
    ast_add_child(arg_list, arg);
}

// Utility functions
const char* ast_node_type_to_string(ASTNodeType type) {
    switch (type) {
        case AST_PROGRAM: return "Program";
        case AST_PACKAGE_DECL: return "PackageDecl";
        case AST_FUNCTION_DECL: return "FunctionDecl";
        case AST_PARAMETER: return "Parameter";
        case AST_PARAMETER_LIST: return "ParameterList";
        case AST_BLOCK: return "Block";
        case AST_VAR_DECL: return "VarDecl";
        case AST_ASSIGNMENT: return "Assignment";
        case AST_DECL_ASSIGNMENT: return "DeclAssignment";
        case AST_IF_STMT: return "IfStmt";
        case AST_FOR_STMT: return "ForStmt";
        case AST_RETURN_STMT: return "ReturnStmt";
        case AST_BREAK_STMT: return "BreakStmt";
        case AST_CONTINUE_STMT: return "ContinueStmt";
        case AST_EXPR_STMT: return "ExprStmt";
        case AST_BINARY_OP: return "BinaryOp";
        case AST_UNARY_OP: return "UnaryOp";
        case AST_FUNCTION_CALL: return "FunctionCall";
        case AST_IDENTIFIER: return "Identifier";
        case AST_INT_LITERAL: return "IntLiteral";
        case AST_FLOAT_LITERAL: return "FloatLiteral";
        case AST_STRING_LITERAL: return "StringLiteral";
        case AST_BOOL_LITERAL: return "BoolLiteral";
        case AST_NIL_LITERAL: return "NilLiteral";
        case AST_ARG_LIST: return "ArgList";
        default: return "Unknown";
    }
}

void ast_print(ASTNode *node, int indent) {
    if (!node) return;
    
    // Print indentation
    for (int i = 0; i < indent; i++) {
        printf("  ");
    }
    
    printf("%s", ast_node_type_to_string(node->type));
    
    // Print node-specific information
    switch (node->type) {
        case AST_PACKAGE_DECL:
        case AST_FUNCTION_DECL:
        case AST_VAR_DECL:
        case AST_BINARY_OP:
        case AST_UNARY_OP:
        case AST_FUNCTION_CALL:
        case AST_IDENTIFIER:
        case AST_STRING_LITERAL:
            if (node->value.string_value) {
                printf(": %s", node->value.string_value);
            }
            break;
        case AST_INT_LITERAL:
            printf(": %d", node->value.int_value);
            break;
        case AST_FLOAT_LITERAL:
            printf(": %f", node->value.float_value);
            break;
        case AST_BOOL_LITERAL:
            printf(": %s", node->value.bool_value ? "true" : "false");
            break;
        default:
            break;
    }
    
    printf("\n");
    
    // Print children
    if (node->children && node->child_count > 0) {
        for (int i = 0; i < node->child_count; i++) {
            ast_print(node->children[i], indent + 1);
        }
    } else {
        // Print direct children
        if (node->left) {
            ast_print(node->left, indent + 1);
        }
        if (node->right) {
            ast_print(node->right, indent + 1);
        }
        if (node->third) {
            ast_print(node->third, indent + 1);
        }
        if (node->fourth) {
            ast_print(node->fourth, indent + 1);
        }
    }
}

void ast_free(ASTNode *node) {
    if (!node) return;
    
    // Free string values only for node types that actually use strings
    switch (node->type) {
        case AST_PACKAGE_DECL:
        case AST_FUNCTION_DECL:
        case AST_VAR_DECL:
        case AST_BINARY_OP:
        case AST_UNARY_OP:
        case AST_FUNCTION_CALL:
        case AST_IDENTIFIER:
        case AST_STRING_LITERAL:
            if (node->value.string_value) {
                free(node->value.string_value);
            }
            break;
        default:
            // For literal types (INT_LITERAL, FLOAT_LITERAL, BOOL_LITERAL, etc.)
            // don't try to free the value as it's not a dynamically allocated string
            break;
    }
    
    // Free children
    if (node->children) {
        for (int i = 0; i < node->child_count; i++) {
            ast_free(node->children[i]);
        }
        free(node->children);
    } else {
        // Free direct children
        ast_free(node->left);
        ast_free(node->right);
        ast_free(node->third);
        ast_free(node->fourth);
    }
    
    free(node);
}
