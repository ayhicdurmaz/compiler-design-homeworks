%{
#include <stdio.h>
#include <stdlib.h>

int lineno = 1;

void emit(const char *tname, const char *text) {
    printf("%4d: %-15s -> %s\n", lineno, tname, text);
}
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

[ \t\r]+                  { /* ignore */ }
\n                        { lineno++; }

"//".*                    { /* single-line comment ignored */ }
"/*"([^*]|\*+[^*/])*\*+"/" { /* naive block comment (no nesting) */
                            /* count newlines inside comment */
                            const char *s = yytext;
                            for (int i=0; s[i]; ++i) if (s[i]=='\n') lineno++;
                          }

"package"                 { emit("PACKAGE", yytext); }
"import"                  { emit("IMPORT", yytext); }
"func"                    { emit("FUNC", yytext); }
"var"                     { emit("VAR", yytext); }
"const"                   { emit("CONST", yytext); }
"type"                    { emit("TYPE", yytext); }
"struct"                  { emit("STRUCT", yytext); }
"if"                      { emit("IF", yytext); }
"else"                    { emit("ELSE", yytext); }
"for"                     { emit("FOR", yytext); }
"return"                  { emit("RETURN", yytext); }
"break"                   { emit("BREAK", yytext); }
"continue"                { emit("CONTINUE", yytext); }
"true"                    { emit("TRUE", yytext); }
"false"                   { emit("FALSE", yytext); }
"nil"                     { emit("NIL", yytext); }

{ID}                      { emit("IDENT", yytext); }

{FLOAT}                   { emit("FLOAT_LIT", yytext); }
{INT}                     { emit("INT_LIT", yytext); }

{STRING}                  { emit("STRING_LIT", yytext); }

":="                      { emit("DECL_ASSIGN", yytext); }
"=="                      { emit("EQ", yytext); }
"!="                      { emit("NEQ", yytext); }
"<="                      { emit("LE", yytext); }
">="                      { emit("GE", yytext); }
"&&"                      { emit("AND", yytext); }
"||"                      { emit("OR", yytext); }
"++"                      { emit("INC", yytext); }
"--"                      { emit("DEC", yytext); }

"+"                       { emit("PLUS", yytext); }
"-"                       { emit("MINUS", yytext); }
"*"                       { emit("MUL", yytext); }
"/"                       { emit("DIV", yytext); }
"%"                       { emit("MOD", yytext); }
"="                       { emit("ASSIGN", yytext); }
"<"                       { emit("LT", yytext); }
">"                       { emit("GT", yytext); }
"!"                       { emit("NOT", yytext); }

","                       { emit("COMMA", yytext); }
";"                       { emit("SEMICOLON", yytext); }
":"                       { emit("COLON", yytext); }
"."                       { emit("DOT", yytext); }
"("                       { emit("LPAREN", yytext); }
")"                       { emit("RPAREN", yytext); }
"{"                       { emit("LBRACE", yytext); }
"}"                       { emit("RBRACE", yytext); }
"["                       { emit("LBRACK", yytext); }
"]"                       { emit("RBRACK", yytext); }

.                         { 
                            char buf[64];
                            snprintf(buf, sizeof(buf), "UNKNOWN(%s)", yytext);
                            emit("UNKNOWN", yytext);
                          }

%%

int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *f = fopen(argv[1], "r");
        if (!f) { perror("fopen"); return 1; }
        yyin = f;
    }
    yylex();
    return 0;
}
