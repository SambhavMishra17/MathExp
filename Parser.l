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

// Input buffer for scanning
extern char lex_buffer[MAX_STRING_SIZE];

static void 
lex_push(int token_code, const char *yytext, int yyleng) {
    assert(undo_stack.top < MAX_MEXPR_LEN - 1);
    lex_data_t lex_data;
    lex_data.token_code = token_code;
    lex_data.token_len = yyleng;
    lex_data.token_val = strdup(yytext); // allocate copy
    undo_stack.data[++undo_stack.top] = lex_data;
}

static lex_data_t
lex_pop() {
    assert(undo_stack.top > -1);
    lex_data_t res = undo_stack.data[undo_stack.top--];
    return res;
}
