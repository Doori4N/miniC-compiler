D                       [0-9]
L                       [a-zA-Z_]
C                       \/\*(.|[\n\t\r])*\*\/

%option noyywrap
%option yylineno
%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "table_symbole.h"
    #include "y.tab.h"
%}

%%
"break"                 { return BREAK; }
"return"                { return RETURN; }
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

{L}({L}|{D})*           { yylval.str = strdup(yytext); return IDENTIFICATEUR; }
      
{D}+                    { yylval.val = atoi(yytext); return CONSTANTE; }

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

{C}                     ;
[ \t\v\n\f]             ;
.                       { return yytext[0]; }
%%
/* int main(){
    int token_courant=yylex();
    printf("Codes des tokens retournés par yylex: ");
    do {
        printf("%d ", token_courant);
        token_courant = yylex();
    }while (token_courant != TOKEN_EOF);
    return 0;
} */
