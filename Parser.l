%{
#include <stdio.h>
#include <string.h>
#include "MexprEnums.h"

// Input buffer for scanning
char lex_buffer[512];
%}

%%
\n    { return PARSER_EOL; }
(0|-?[1-9][0-9]*)    { return MATH_CPP_INT; }
-?[0-9]+\.[0-9]+    { return MATH_CPP_DOUBLE; }
[a-zA-Z_][a-zA-Z0-9_]*    { return MATH_CPP_VARIABLE; }
((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[0-9]{1,2})\.){3}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[0-9]{1,2})    { return MATH_CPP_IPV4; }
[ \t\r]+    { /* ignore whitespace */ }
.    { printf("ignore non-parsable character '%s'\n", yytext); }
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
