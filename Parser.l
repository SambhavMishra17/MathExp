%{
#include <stdio.h>
#include <string.h>
#include "MexprEnums.h"

// Extra token codes not in MexprEnums.h
#define PARSER_EOL                   300
#define PARSER_QUIT                  301
#define MATH_INTEGER_VALUE           302
#define MATH_DOUBLE_VALUE            303
#define MATH_IDENTIFIER              304
#define MATH_IDENTIFIER_IDENTIFIER   305
#define MATH_STRING_VALUE            306

// Input buffer for scanning
char lex_buffer[512];

// Stub for whitespace processing
static void process_white_space(int count) {
    (void)count; // ignore for now
}
%}

%%

"("                 { return MATH_CPP_BRACKET_START; }
")"                 { return MATH_CPP_BRACKET_END; }

"<="                { return MATH_CPP_LESS_THAN_EQ; }
"<"                 { return MATH_CPP_LESS_THAN; }
">"                 { return MATH_CPP_GREATER_THAN; }
"="                 { return MATH_CPP_EQ; }
"!="                { return MATH_CPP_NEQ; }

"and"               { return MATH_CPP_AND; }
"or"                { return MATH_CPP_OR; }

"*"                 { return MATH_CPP_MUL; }
"+"                 { return MATH_CPP_PLUS; }
"-"                 { return MATH_CPP_MINUS; }
"/"                 { return MATH_CPP_DIV; }
","                 { return MATH_CPP_COMMA; }

"sqrt"              { return MATH_CPP_SQRT; }
"sqr"               { return MATH_CPP_SQR; }
"mmax"              { return MATH_CPP_MAX; }
"mmin"              { return MATH_CPP_MIN; }
"sin"               { return MATH_CPP_SIN; }
"cos"               { return MATH_CPP_COS; }
"pow"               { return MATH_CPP_POW; }

\n                  { return PARSER_EOL; }
"\\\n"              { /* line continuation, ignore */ }

[ ]                 { process_white_space(1); }
[\t]                { process_white_space(4); }

"\\q"               { return PARSER_QUIT; }

0|-?[1-9][0-9]*     { return MATH_INTEGER_VALUE; }
-?[0-9]*\.[0-9]+    { return MATH_DOUBLE_VALUE; }

[a-zA-Z0-9_]+\.[a-zA-Z0-9_]+ { return MATH_IDENTIFIER_IDENTIFIER; }
[a-zA-Z0-9_]+       { return MATH_IDENTIFIER; }

\'[^\']*\'          { return MATH_STRING_VALUE; }
\"[^\"]*\"          { return MATH_STRING_VALUE; }

.                   { /* ignore everything else */ }

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
