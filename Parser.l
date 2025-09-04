%{
#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <stdlib.h>
#include "MexprEnums.h"

typedef struct lex_data_ {
    int token_code;
    int token_len;
    char* token_val;
} lex_data_t;

#define MAX_MEXPR_LEN 512
#define MAX_STRING_SIZE 512

typedef struct stack_ {
    int top;
    lex_data_t data[MAX_MEXPR_LEN];
} stack_t;

stack_t undo_stack = { .top = -1 };

#define PARSER_EOL                   300
#define PARSER_QUIT                  301
#define MATH_INTEGER_VALUE           302
#define MATH_DOUBLE_VALUE            303
#define MATH_IDENTIFIER              304
#define MATH_IDENTIFIER_IDENTIFIER   305
#define MATH_STRING_VALUE            306

char lex_buffer[MAX_STRING_SIZE];

static void
lex_push(int token_code, const char *yytext, int yyleng) {
    assert(undo_stack.top < MAX_MEXPR_LEN - 1);
    lex_data_t lex_data;
    lex_data.token_code = token_code;
    lex_data.token_len = yyleng;
    lex_data.token_val = strdup(yytext); // copy token text
    undo_stack.data[++undo_stack.top] = lex_data;
}

static lex_data_t
lex_pop() {
    assert(undo_stack.top > -1);
    lex_data_t res = undo_stack.data[undo_stack.top--];
    return res;
}

// Stub for whitespace processing
static void process_white_space(int count) {
    (void)count;
}
%}

%%
"("                 { lex_push(MATH_CPP_BRACKET_START, yytext, yyleng); return MATH_CPP_BRACKET_START; }
")"                 { lex_push(MATH_CPP_BRACKET_END, yytext, yyleng); return MATH_CPP_BRACKET_END; }
"<="                { lex_push(MATH_CPP_LESS_THAN_EQ, yytext, yyleng); return MATH_CPP_LESS_THAN_EQ; }
"<"                 { lex_push(MATH_CPP_LESS_THAN, yytext, yyleng); return MATH_CPP_LESS_THAN; }
">"                 { lex_push(MATH_CPP_GREATER_THAN, yytext, yyleng); return MATH_CPP_GREATER_THAN; }
"="                 { lex_push(MATH_CPP_EQ, yytext, yyleng); return MATH_CPP_EQ; }
"!="                { lex_push(MATH_CPP_NEQ, yytext, yyleng); return MATH_CPP_NEQ; }

"and"               { lex_push(MATH_CPP_AND, yytext, yyleng); return MATH_CPP_AND; }
"or"                { lex_push(MATH_CPP_OR, yytext, yyleng); return MATH_CPP_OR; }

"*"                 { lex_push(MATH_CPP_MUL, yytext, yyleng); return MATH_CPP_MUL; }
"+"                 { lex_push(MATH_CPP_PLUS, yytext, yyleng); return MATH_CPP_PLUS; }
"-"                 { lex_push(MATH_CPP_MINUS, yytext, yyleng); return MATH_CPP_MINUS; }
"/"                 { lex_push(MATH_CPP_DIV, yytext, yyleng); return MATH_CPP_DIV; }
","                 { lex_push(MATH_CPP_COMMA, yytext, yyleng); return MATH_CPP_COMMA; }

"sqrt"              { lex_push(MATH_CPP_SQRT, yytext, yyleng); return MATH_CPP_SQRT; }
"sqr"               { lex_push(MATH_CPP_SQR, yytext, yyleng); return MATH_CPP_SQR; }
"mmax"              { lex_push(MATH_CPP_MAX, yytext, yyleng); return MATH_CPP_MAX; }
"mmin"              { lex_push(MATH_CPP_MIN, yytext, yyleng); return MATH_CPP_MIN; }
"sin"               { lex_push(MATH_CPP_SIN, yytext, yyleng); return MATH_CPP_SIN; }
"cos"               { lex_push(MATH_CPP_COS, yytext, yyleng); return MATH_CPP_COS; }
"pow"               { lex_push(MATH_CPP_POW, yytext, yyleng); return MATH_CPP_POW; }

\n                  { return PARSER_EOL; }
"\\\n"              { /* line continuation */ }

[ ]                 { process_white_space(1); }
[\t]                { process_white_space(4); }

"\\q"               { return PARSER_QUIT; }

0|-?[1-9][0-9]*     { lex_push(MATH_INTEGER_VALUE, yytext, yyleng); return MATH_INTEGER_VALUE; }
-?[0-9]*\.[0-9]+    { lex_push(MATH_DOUBLE_VALUE, yytext, yyleng); return MATH_DOUBLE_VALUE; }

[a-zA-Z0-9_]+\.[a-zA-Z0-9_]+ { lex_push(MATH_IDENTIFIER_IDENTIFIER, yytext, yyleng); return MATH_IDENTIFIER_IDENTIFIER; }
[a-zA-Z0-9_]+       { lex_push(MATH_IDENTIFIER, yytext, yyleng); return MATH_IDENTIFIER; }

\'[^\']*\'          { lex_push(MATH_STRING_VALUE, yytext, yyleng); return MATH_STRING_VALUE; }
\"[^\"]*\"          { lex_push(MATH_STRING_VALUE, yytext, yyleng); return MATH_STRING_VALUE; }

.                   { /* ignore */ }
%%

int main(int argc, char **argv) {
    while (1) {
        if (!fgets(lex_buffer, sizeof(lex_buffer), stdin)) break;

        if (lex_buffer[0] == '0') {
            lex_buffer[0] = 0;
            continue;
        }

        yy_scan_string(lex_buffer);

        int token_code = yylex();

        while (token_code != PARSER_EOL) {
            printf("token_code = %d, token = %s, token_len = %zu\n",
                   token_code, yytext, yyleng);
            token_code = yylex();
        }
    }
    return 0;
}

int yywrap(void) { return 1; }
