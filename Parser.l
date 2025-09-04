%{
#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <stdlib.h>

#include "ParserExport.h"

/* ---------- Global variables ---------- */
stack_t undo_stack = { .top = -1 };
char lex_buffer[MAX_STRING_SIZE];
char *curr_ptr = lex_buffer;
char *lex_curr_token;
int lex_curr_token_len;

/* ---------- Stack Helpers ---------- */
static void
lex_push(int token_code, const char *yytext, int yyleng) {
    assert(undo_stack.top < MAX_MEXPR_LEN - 1);
    lex_data_t lex_data;
    lex_data.token_code = token_code;
    lex_data.token_len = yyleng;
    lex_data.token_val = strdup(yytext);
    undo_stack.data[++undo_stack.top] = lex_data;
}

static lex_data_t
lex_pop() {
    assert(undo_stack.top > -1);
    lex_data_t res = undo_stack.data[undo_stack.top--];
    return res;
}

/* Whitespace processing */
static void process_white_space(int n) {
    lex_data_t lex_data; 
    curr_ptr += n; 
    lex_data.token_code = PARSER_WHITE_SPACE; 
    lex_data.token_len = n; 
    lex_data.token_val = NULL; 
    lex_push(lex_data.token_code, " ", n); 
}

/* Custom lex method */
int cyylex(){
   int token_code = yylex(); 
   if (token_code == 0) return 0; 

   lex_data_t lex_data; 
   lex_data.token_code = token_code; 
   lex_data.token_len = yyleng; 
   curr_ptr = curr_ptr + yyleng; 
   lex_data.token_val = (char *)calloc(1,yyleng + 1); 
   strncpy(lex_data.token_val, yytext, yyleng); 
   lex_data.token_val[yyleng] = '\0';
   undo_stack.data[++undo_stack.top] = lex_data;
   return token_code; 
}

/* yyrewind: opposite of cyylex */
void yyrewind(int n) {
    if(n <= 0 ) return; 
    if(curr_ptr == lex_buffer) return; 
    int data_len = 0; 
    lex_data_t lex_data; 
    while (n && undo_stack.top >= 0) {
        lex_data = lex_pop(); 
        data_len += lex_data.token_len; 
        if(lex_data.token_val) free(lex_data.token_val);
        if(lex_data.token_code == PARSER_WHITE_SPACE){
            continue; 
        }
        n--; 
    }
    curr_ptr -= data_len; 
    yy_scan_string(curr_ptr);
}

void Parser_stack_reset(void) {
    while (undo_stack.top >= 0) {
        if (undo_stack.data[undo_stack.top].token_val)
            free(undo_stack.data[undo_stack.top].token_val);
        undo_stack.top--;
    }
    undo_stack.top = -1;
    curr_ptr = lex_buffer;
}

void lex_set_scan_buffer(const char *buffer) {
    Parser_stack_reset();
    if (!buffer) return;
    strncpy(lex_buffer, buffer, MAX_STRING_SIZE - 1);
    lex_buffer[MAX_STRING_SIZE - 1] = '\0';
    curr_ptr = lex_buffer;
    yy_scan_string(lex_buffer);
}
%}

/* ---------- Rules Section ---------- */
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

/* ---------- Main Test Harness ---------- */
int main(int argc, char **argv) {
    while (1) {
        if (!fgets(lex_buffer, sizeof(lex_buffer), stdin)) break;

        if (lex_buffer[0] == '0') {
            lex_buffer[0] = 0;
            continue;
        }

        yy_scan_string(lex_buffer);

        int token_code = yylex();

        while (token_code != PARSER_EOL && token_code != 0) {
            printf("token_code = %d, token = %s, token_len = %d\n",
                   token_code, yytext, yyleng);
            token_code = yylex();
        }
    }
    return 0;
}

int yywrap(void) { return 1; }
