%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"
#include "parser.tab.h"

int lineno = 1;
extern YYSTYPE yylval;

// External declaration of custom_strdup
extern char* custom_strdup(const char* str);
%}

%option noyywrap

DIGIT      [0-9]
LETTER     [A-Za-z_]
ID         {LETTER}({LETTER}|{DIGIT})*
INT        0|([1-9]{DIGIT}*)
FLOAT      {DIGIT}+"."{DIGIT}+([eE][+-]?{DIGIT}+)?
STRCHAR    ([^"\\]|\\["\\nrtb0])
STRING     \"{STRCHAR}*\"

%%

[ \t\r]+                  { /* ignore whitespace */ }
\n                        { lineno++; }

"//".*                    { /* single-line comment ignored */ }
"/*"([^*]|\*+[^*/])*\*+"/" { /* naive block comment (no nesting) */
                            /* count newlines inside comment */
                            const char *s = yytext;
                            for (int i=0; s[i]; ++i) if (s[i]=='\n') lineno++;
                          }

"package"                 { return PACKAGE; }
"import"                  { return IMPORT; }
"func"                    { return FUNC; }
"var"                     { return VAR; }
"const"                   { return CONST; }
"type"                    { return TYPE; }
"struct"                  { return STRUCT; }
"if"                      { return IF; }
"else"                    { return ELSE; }
"for"                     { return FOR; }
"return"                  { return RETURN; }
"break"                   { return BREAK; }
"continue"                { return CONTINUE; }
"true"                    { yylval.bool_val = 1; return TRUE; }
"false"                   { yylval.bool_val = 0; return FALSE; }
"nil"                     { return NIL; }

{ID}                      { yylval.string_val = custom_strdup(yytext); return IDENT; }

{FLOAT}                   { yylval.float_val = atof(yytext); return FLOAT_LIT; }
{INT}                     { yylval.int_val = atoi(yytext); return INT_LIT; }

{STRING}                  { yylval.string_val = custom_strdup(yytext); return STRING_LIT; }

":="                      { return DECL_ASSIGN; }
"=="                      { return EQ; }
"!="                      { return NEQ; }
"<="                      { return LE; }
">="                      { return GE; }
"&&"                      { return AND; }
"||"                      { return OR; }
"++"                      { return INC; }
"--"                      { return DEC; }

"+"                       { return PLUS; }
"-"                       { return MINUS; }
"*"                       { return MUL; }
"/"                       { return DIV; }
"%"                       { return MOD; }
"="                       { return ASSIGN; }
"<"                       { return LT; }
">"                       { return GT; }
"!"                       { return NOT; }

","                       { return COMMA; }
";"                       { return SEMICOLON; }
":"                       { return COLON; }
"."                       { return DOT; }
"("                       { return LPAREN; }
")"                       { return RPAREN; }
"{"                       { return LBRACE; }
"}"                       { return RBRACE; }
"["                       { return LBRACK; }
"]"                       { return RBRACK; }

.                         { 
                            printf("Unexpected character: %s at line %d\n", yytext, lineno);
                            return yytext[0];
                          }

%%
