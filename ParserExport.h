#ifndef PARSER_EXPORT_H
#define PARSER_EXPORT_H

#include "MexprEnums.h"

/* ---------- Constants ---------- */
#define MAX_MEXPR_LEN   512
#define MAX_STRING_SIZE 512

#define PARSER_EOL                   300
#define PARSER_QUIT                  301
#define MATH_INTEGER_VALUE           302
#define MATH_DOUBLE_VALUE            303
#define MATH_IDENTIFIER              304
#define MATH_IDENTIFIER_IDENTIFIER   305
#define MATH_STRING_VALUE            306
#define PARSER_WHITE_SPACE           307

/* ---------- Types ---------- */
typedef struct lex_data_ {
    int token_code;
    int token_len;
    char* token_val;
} lex_data_t;

typedef struct stack_ {
    int top;
    lex_data_t data[MAX_MEXPR_LEN];
} stack_t;

/* ---------- Extern Declarations ---------- */
#ifdef __cplusplus
extern "C" {
#endif

extern char lex_buffer[MAX_STRING_SIZE];
extern stack_t undo_stack;
extern char *curr_ptr;

/* Exported functions */
int yylex(void);
int cyylex(void);
void yyrewind(int n);
void Parser_stack_reset(void);
void lex_set_scan_buffer(const char *buffer);

#ifdef __cplusplus
}
#endif

/* ---------- Macros for checkpointing ---------- */
#define CHECKPOINT(a)    a = undo_stack.top
#define RESTORE_CHKP(a)  yyrewind(undo_stack.top - a)

#endif 
