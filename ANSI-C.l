D                       [0-9]
L                       [a-zA-Z_]
%option noyywrap
%{
#include <stdio.h>
#include <stdlib.h>
// #include "y.tab.h"
int yylval;
#define TOKEN_EOF 0
#define BREAK 1
#define CASE 2
#define DEFAULT 3
#define ELSE 4
#define EXTERN 5
#define FOR 6
#define IF 7
#define INT 8
#define SWITCH 9
#define THEN 10
#define VOID 11
#define WHILE 12
#define IDENTIFICATEUR 13
#define CONSTANTE 14
#define LEQ 15
#define GEQ 16
#define LT 17
#define GT 18
#define EQ 19
#define NEQ 20
#define NOT 21
#define BAND 22
#define BOR 23
#define PLUS 24
#define MOINS 25
#define MUL 26
#define DIV 27
#define LSHIFT 28
#define RSHIFT 29
#define LAND 30
#define LOR 31

/* Ne g�re pas les commentaires. A rajouter */
/* Supprimer les lignes dont vous n'avez pas besoin. */

%}

%%
"break"                 { return BREAK; }
"case"                  { return CASE; }
"default"               { return DEFAULT; }
"else"                  { return ELSE; }
"extern"                { return EXTERN; }
"for"                   { return FOR; }
"if"                    { return IF; }
"int"                   { return INT; }
"switch"                { return SWITCH; }
"then"                  { return THEN; }
"void"                  { return VOID; }
"while"                 { return WHILE; }

{L}({L}|{D})*           { return IDENTIFICATEUR; }
      
{D}+                    { yylval = atoi(yytext); return CONSTANTE; }

"<="                    { return LEQ; }
">="                    { return GEQ; }
"<"                     { return LT; }
">"                     { return GT; }
"=="                    { return EQ; }
"!="                    { return NEQ; }
"!"                     { return NOT; }
"&&"                    { return BAND; }
"||"                    { return BOR; }
"+"                     { return PLUS; }
"-"                     { return MOINS; }
"*"                     { return MUL; }
"/"                     { return DIV; }
"<<"                    { return LSHIFT; }
">>"                    { return RSHIFT; }
"&"                     { return LAND; }
"|"                     { return LOR; }

[ \t\v\n\f]             ;
.                       { return yytext[0]; }
%%
int main(){
    int token_courant=yylex();
    printf("Codes des tokens retournés par yylex: ");
    do {
        printf("%d ", token_courant);
        token_courant = yylex();
    }while (token_courant != TOKEN_EOF);
    return 0;
}
