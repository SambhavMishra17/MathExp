#ifndef MEXPR_ENUMS_H
#define MEXPR_ENUMS_H

// Data type tokens
typedef enum {
    MATH_CPP_INT,
    MATH_CPP_DOUBLE,
    MATH_CPP_VARIABLE,
    MATH_CPP_IPV4,
    MATH_CPP_DTYPE_MAX
} mexprcpp_dtypes_t;

// Extra parser tokens
typedef enum {
    PARSER_EOL = (int)MATH_CPP_DTYPE_MAX + 1
} parser_extra_tokens_t;

#endif // MEXPR_ENUMS_H
