%{
	#include <stdio.h>
    #include <stdlib.h>
	//#include "table_symbole.h"
    int yylex();
    int yyerror(char *s);
	extern int yylineno;
%}


%union {
	char* str;
}

%token <str> IDENTIFICATEUR FOR WHILE IF ELSE SWITCH CASE DEFAULT
%token <str> VOID INT
%token <str> CONSTANTE
%token <str> BREAK RETURN PLUS MOINS MUL DIV LSHIFT RSHIFT BAND BOR LAND LOR LT GT 
%token GEQ LEQ EQ NEQ NOT EXTERN
%left PLUS MOINS
%left MUL DIV
%left LSHIFT RSHIFT
%left BOR BAND
%left LAND LOR
%nonassoc THEN
%nonassoc ELSE
%left OP
%left REL
%start programme

%type <str> binary_rel declarateur binary_comp binary_op type liste_declarateurs liste_parms l_parms parm liste_instructions instruction iteration selection saut affectation bloc appel variable expression liste_expressions condition liste_fonctions liste_declarations declaration fonction
%%
programme	:	
 		liste_declarations liste_fonctions {printf("ici programme %s %s \n\n\n\n ",$1,$2);}
;
liste_declarations	:	
		liste_declarations declaration {printf("ici liste_declarations %s %s \n ",$1,$2);}
 	|	{$$ = "";}
;
liste_fonctions	:	
 		liste_fonctions fonction {printf("ici liste_fonctions %s %s \n ",$1,$2);}
 	|   fonction {printf("ici liste_fonctions %s \n ",$1);}
;
declaration	:	
 		type liste_declarateurs ';' {if($1 == "void"){
										yyerror("Impossible de declarer une variable de type void");
										}
										printf("ici declaration %s %s \n ",$1,$2);
									}
;
liste_declarateurs	:	
 		liste_declarateurs ',' declarateur 
 	|	declarateur 
;
declarateur		:	
 		IDENTIFICATEUR {$$ = $1;}
 	|	declarateur '[' CONSTANTE ']' {$$ = $3;}
;
fonction		:	
 		type IDENTIFICATEUR '(' liste_parms ')' '{' liste_declarations liste_instructions '}' 
 	|	EXTERN type IDENTIFICATEUR '(' liste_parms ')' ';' 
;
type	:		
 		VOID { $$ = "void"; }
 	|	INT { $$= "int"; }
;
liste_parms		:	
 		l_parms 
 	|	
;
l_parms		:
		parm
	|	l_parms ',' parm
;
parm	:	
 		INT IDENTIFICATEUR
;
liste_instructions :	
 		liste_instructions instruction
 	|
;
instruction	:	
 		iteration
 	|	selection
 	|	saut
 	|	affectation ';'
 	|	bloc
 	|	appel
;
iteration	:	
 		FOR '(' affectation ';' condition ';' affectation ')' instruction
 	|	WHILE '(' condition ')' instruction
;
selection	:	
 		IF '(' condition ')' instruction %prec THEN
 	|	IF '(' condition ')' instruction ELSE instruction
 	|	SWITCH '(' expression ')' instruction
 	|	CASE CONSTANTE ':' instruction
 	|	DEFAULT ':' instruction
;
saut	:	
 		BREAK ';'
 	|	RETURN ';'
 	|	RETURN expression ';'
;
affectation	:	
 		variable '=' expression 
;
bloc	:	
 		'{' liste_declarations liste_instructions '}'
;
appel	:	
 		IDENTIFICATEUR '(' liste_expressions ')' ';'
;
variable	:	
 		IDENTIFICATEUR { $$ = $1;}
 	|	variable '[' expression ']'
;
expression	:	
 		'(' expression ')'
 	|	expression binary_op expression %prec OP
 	|	MOINS expression 
 	|	CONSTANTE { $$ = $1;}
 	|	variable
 	|	IDENTIFICATEUR '(' liste_expressions ')'
;
liste_expressions	:	
 		l_expressions
 	|	
;
l_expressions		:
		expression
	|	l_expressions ',' expression
;
condition	:	
 		NOT '(' condition ')'
 	|	condition binary_rel condition %prec REL
 	|	'(' condition ')'
 	|	expression binary_comp expression
;
binary_op	:	
 		PLUS { $$ = "+";}
 	|       MOINS { $$ = "-";}
 	|	MUL { $$ = "*";}
 	|	DIV { $$ = "/";}
 	|       LSHIFT { $$ = "<<";}
 	|       RSHIFT { $$ = ">>";}
 	|	BAND { $$ = "&";}
 	|	BOR { $$ = "|";}
;
binary_rel	:	
 		LAND { $$ = "&&";}
 	|	LOR { $$ = "||";}
;
binary_comp	:	
 		LT { $$ = "<"; }
 	|	GT { $$ = ">"; }
 	|	GEQ { $$ = ">="; }
 	|	LEQ { $$ = "<="; }
 	|	EQ { $$ = "=="; }
 	|	NEQ { $$ = "!="; }
;
%%

/*value* init(type t, struct tableau* tab, struct fonction* fnct, struct id* id){
	value val = malloc(sizeof(value));

}

Symbole* searchSymbole(TableStack* table, char* nom){

}
typedef struct test {
	char* type_valeur;
	union {
		struct tableau tableau;
		struct fonction fonction;
		struct id id;
	}
}
Symbole* createSymbole(type_t type, value val){
	 Symbole* symbole = malloc(sizeof(Symbole));
	 symbole->type = type;
	 symbole->val = val;
	 symbole->suivant = NULL;
	 return symbole;
}

void addSymbole(char *nom, Symbole* suivant){

}
// void addTableStack(char* nom);
// void freeTableStack(TableStack* table);


*/
int yyerror(char *s){
    fprintf(stderr, "\033[1;31m%s ligne :  %d\033[0m \n", s, yylineno);
    exit(1); //le programme s'arrete lors d'une erreur de syntaxe
}
int main(){
    yyparse();
    return 0;
}