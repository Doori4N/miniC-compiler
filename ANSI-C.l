D                       [0-9]
L                       [a-zA-Z_]
%option noyywrap
%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"
int yylval;

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
/* int main(){
    int token_courant;
    while (1){
        token_courant=yylex();
        if (token_courant == 13){
            printf("token: %d, valeur de la constante : %d", token_courant, yylval);
        }
        else{
            printf("%d ", token_courant);
        }
    };
    return 0;
} */
