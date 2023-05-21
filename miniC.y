%{
	#include <stdio.h>
    #include <stdlib.h>
	#include <string.h>
	#include "table_symbole.h"
	#include "memory.h"
    int yylex();
    int yyerror(char *s);
	extern int yylineno;
	extern TableStack* top;
%}

%union{
	char *str;
	Symbol *symbol;
	TableStack *stack;
	type_t type;
	node *node;
	children_list *chld_list;
	node_list *list;
}

%token <str> IDENTIFICATEUR CONSTANTE 
%token VOID INT BREAK RETURN EXTERN FOR WHILE IF ELSE SWITCH CASE DEFAULT
%token GEQ LEQ EQ NEQ NOT PLUS MOINS MUL DIV LSHIFT RSHIFT BAND BOR LAND LOR LT GT


%left PLUS MOINS
%left MUL DIV
%left LSHIFT RSHIFT
%left BOR BAND
%left LAND LOR
%nonassoc THEN
%nonassoc ELSE
%left REL

%start programme

%type <node> fonction bloc affectation variable expression condition saut appel iteration selection instruction
%type <list> liste_fonctions
%type <chld_list> l_expressions liste_expressions liste_instructions 
%type <type> type
%type <stack> liste_declarations liste_parms
%type <symbol> declarateur liste_declarateurs declaration parm l_parms 
%type <str> binary_rel binary_comp 

%%
programme	:	
 		liste_declarations liste_fonctions { createFile($2); freeNodeList($2); freeStack(); }
;
liste_declarations	:	
		liste_declarations declaration
 	|	{ push(initTable()); }
;
liste_fonctions	:	
 		liste_fonctions fonction { $$ = addNodeToList($1, createNodeList($2)); }
 	|   fonction { $$ = createNodeList($1); }
;
declaration	:	
 		type liste_declarateurs ';' { if($1 == TYPE_VOID) yyerror("Error! Bad type for variable : VOID"); }
;
liste_declarateurs	:	
 		liste_declarateurs ',' declarateur
 	|	declarateur
;
declarateur		:	
 		IDENTIFICATEUR { 
			if(isAlreadyDefined(top,$1) != NULL){
				char *label;
				label = (char*) malloc(28 + strlen($1) + 1);	 
				sprintf(label, "Error! Variable %s is already defined", $1);
				yyerror(label);
				free(label);
			}
			$$ = createSymbol($1, TYPE_VAR, NULL);
			top->symbol = addSymbol(top->symbol, $$);
		}
 	|	declarateur '[' CONSTANTE ']' {
			$$ = $1;
			if($$->s_struct == NULL){
				$$->type = TYPE_ARR;
				$$->s_struct = createArrStruct();
			}
			$$->s_struct->array->dimension++;
		}	
;
fonction		:	
 		type IDENTIFICATEUR '(' liste_parms ')' '{' liste_declarations { top->symbol = addSymbol(createSymbol($2, TYPE_FUN, createFunStruct($1, $4->symbol)), top->symbol); } liste_instructions '}' { 
			pop();//supprime la table de symbole en haut de la pile
			TableStack *liste_parms = pop();//supprime le sommet de la pile (liste_parms)

			if(isAlreadyDefined(top, $2) != NULL) yyerror("Error! name already used");

			top->symbol = addSymbol(createSymbol($2, TYPE_FUN, createFunStruct($1, liste_parms->symbol)), top->symbol); //ajoute la fonction à la liste du bloc parent
			char *label;
			label = (char*) malloc(strlen($2) + strlen(type_tToString($1)) + 3);	 
			sprintf(label, "%s, %s", $2, type_tToString($1));
			$$ = createNode(FUN_NODE, label);
			// free(label);
			if (len_children_list($9) > 1) {
				node *bloc = createNode(BLOC_NODE, "BLOC");
				bloc->list = $9;//la liste d'instruction est la liste des fils du bloc
				$$->list = initChildrenList(bloc);//le bloc est le fils de la fonction
			}else $$->list = $9; //si il y a qu'une seule ou 0 instruction alors pas de bloc
		}
 	|	EXTERN type IDENTIFICATEUR '(' liste_parms ')' ';' {
			TableStack *liste_parms = pop();//supprime le sommet de la pile (liste_parms)
			if(isAlreadyDefined(top, $3) != NULL) yyerror("Error! name already used");
			top->symbol = addSymbol(createSymbol($3, TYPE_FUN, createFunStruct($2, liste_parms->symbol)), top->symbol); //ajoute le symbole au sommet de la stack
			$$ = NULL;
		}
;
type	:	
 		VOID { $$ = TYPE_VOID; }
 	|	INT { $$ = TYPE_INT; }
;
liste_parms		:	
 		l_parms	{ 
			$$ = initTable();//Initialise une table de symboles
			$$->symbol = $1;
			push($$);//Ajoute la table à la pile
		}
 	|	{ 
			$$ = initTable(); 
			push($$);
		}
;
l_parms		:
		l_parms ',' parm { $$ = addSymbol($1, $3); }
	|	parm { $$ = $1; }
;
parm	:	
 		INT IDENTIFICATEUR { $$ = createSymbol($2, TYPE_VAR, NULL); }
;
liste_instructions :	
 		liste_instructions instruction {
			if($1 == NULL) $$ = initChildrenList($2);
			else {
				$$ = $1;
				addChildToList($$, initChildrenList($2));
			}
		}
 	|	{ $$ = NULL; }
;
instruction	:
 		iteration { $$ = $1; }
 	|	selection { $$ = $1; }
 	|	saut { $$ = $1; }
 	|	affectation ';' { $$ = $1; }
 	|	bloc { $$ = $1; }	
 	|	appel { $$ = $1; }
;
iteration	:	
 		FOR '(' affectation ';' condition ';' affectation ')' instruction {
			$$ = createNode(NODE, "FOR");
			addChildToNode($$, $3);
			addChildToNode($$, $5);
			addChildToNode($$, $7);
			addChildToNode($$, $9);
		}
 	|	WHILE '(' condition ')' instruction { 
			$$ = createNode(NODE, "WHILE");
			addChildToNode($$, $3);
			addChildToNode($$, $5);
	 	}
;
selection	:	
 		IF '(' condition ')' instruction %prec THEN {
			$$ = createNode(IF_NODE, "IF");
			addChildToNode($$, $3);
			addChildToNode($$, $5);
		}
 	|	IF '(' condition ')' instruction ELSE instruction {
			$$ = createNode(IF_NODE, "IF");
			addChildToNode($$, $3);
			addChildToNode($$, $5);
			addChildToNode($$, $7);
		}
 	|	SWITCH '(' expression ')' instruction {
			$$ = createNode(NODE, "SWITCH");
			addChildToNode($$, $3);
			if($5->type == BLOC_NODE){
				checkSwitchSyntax($5->list);
				addChildToList($$->list, $5->list);
			}
			else addChildToNode($$, $5);
		}
 	|	CASE CONSTANTE ':' instruction { 
			$$ = createNode(CASE_NODE, "CASE");
			addChildToNode($$, createNode(NODE, $2));
			addChildToNode($$, $4);
		}
 	|	DEFAULT ':' instruction { 
			$$ = createNode(DEFAULT_NODE, "DEFAULT");
			addChildToNode($$, $3);
	 	}
;
saut	:	
 		BREAK ';' { $$ = createNode(BREAK_NODE, "BREAK"); }
 	|	RETURN ';' { $$ = createNode(RET_NODE, "RETURN"); }
 	|	RETURN expression ';' {
			$$ = createNode(RET_NODE, "RETURN");
			addChildToNode($$, $2);
		}
;
affectation	:	
 		variable '=' expression {
			if($1->type == ARR_NODE){
				Symbol *_array = lookup(top, $1->list->child->name);
				if(len_children_list($1->list)-1 != _array->s_struct->array->dimension){
					checkFlag(ARRAY_WRONG_DIMENSION);
				}
			}
			$$ = createNode(NODE, ":=");
			addChildToNode($$, $1);
			addChildToNode($$, $3);
		}
;
bloc	:	
 		'{' liste_declarations liste_instructions '}' { 
			pop(); 
			if($3 == NULL) $$ = NULL;
			else if(len_children_list($3) == 1) $$ = $3->child;
			else{
				$$ = createNode(BLOC_NODE, "BLOC");
				$$->list = $3;
			}
		}
;
appel	:	
 		IDENTIFICATEUR '(' liste_expressions ')' ';' {
			int flag = isCallable(top, $1, $3, 1);
            checkFlag(flag);

			$$ = createNode(FUN_CALL_NODE, $1);
			$$->list = $3;
		}
;
variable	:	
 		IDENTIFICATEUR { 
			char *label;
			label = (char*) malloc(28 + strlen($1) + 1);	 
			sprintf(label, "Error! Variable %s is never defined", $1);

			Symbol *_symbol = lookup(top, $1);
			if(_symbol == NULL){
				yyerror(label);
				free(label);
			}
			else if (_symbol->type == TYPE_ARR){
				$$ = createNode(ARR_NODE, "TAB");
				addChildToNode($$, createNode(NODE, $1));
			}
			else if (_symbol->type == TYPE_FUN) yyerror("Error! bad syntax for function call");
			else $$ = createNode(NODE, $1); 
		}
 	|	variable '[' expression ']' { 
			if($1->type == NODE) yyerror("Error! this variable is not an array");
			$$ = $1;
			addChildToNode($$, $3);
		}
;
expression	:	
 		'(' expression ')' { $$ = $2; }

 	|	expression PLUS expression { 
			$$ = createNode(NODE, "+"); 
			addChildToNode($$, $1);
			addChildToNode($$, $3);
		}
	|	expression MOINS expression { 
			$$ = createNode(NODE, "-"); 
			addChildToNode($$, $1);
			addChildToNode($$, $3);
		}			
	|	expression MUL expression { 
			$$ = createNode(NODE, "*"); 
			addChildToNode($$, $1);
			addChildToNode($$, $3);
		}
	|	expression DIV expression { 
			$$ = createNode(NODE, "/"); 
			addChildToNode($$, $1);
			addChildToNode($$, $3);
		}
	|	expression LSHIFT expression { 
			$$ = createNode(NODE, "<<"); 
			addChildToNode($$, $1);
			addChildToNode($$, $3);
		}
	|	expression RSHIFT expression { 
			$$ = createNode(NODE, ">>"); 
			addChildToNode($$, $1);
			addChildToNode($$, $3);
		}
	|	expression BAND expression { 
			$$ = createNode(NODE, "&"); 
			addChildToNode($$, $1);
			addChildToNode($$, $3);
		}
	|	expression BOR expression { 
			$$ = createNode(NODE, "|"); 
			addChildToNode($$, $1);
			addChildToNode($$, $3);
		}

 	|	MOINS expression { 
			$$ = createNode(NODE, "-");
			addChildToNode($$, $2); 
		}
 	|	CONSTANTE { $$ = createNode(NODE, $1); }
 	|	variable { 
			if($1->type == ARR_NODE){
				Symbol *_array = lookup(top, $1->list->child->name);
				if(len_children_list($1->list)-1 != _array->s_struct->array->dimension){
					checkFlag(ARRAY_WRONG_DIMENSION);
				}
			}
			$$ = $1; 
		}
 	|	IDENTIFICATEUR '(' liste_expressions ')' {
			int flag = isCallable(top, $1, $3, 0);
            checkFlag(flag);

			$$ = createNode(FUN_CALL_NODE, $1);
			$$->list = $3;
		}
;
liste_expressions	:	
 		l_expressions { $$ = $1; }
 	|	{ $$ = NULL; }
;
l_expressions		:
		expression { $$ = initChildrenList($1); }
	|	l_expressions ',' expression { 
			$$ = $1;
			addChildToList($$, initChildrenList($3));
		}
;
condition	:	
 		NOT '(' condition ')' { 
			$$ = createNode(NODE, "NOT");
			addChildToNode($$, $3);
		}
 	|	condition binary_rel condition %prec REL {
			$$ = createNode(NODE, $2);
			addChildToNode($$, $1);
			addChildToNode($$, $3);
		}
 	|	'(' condition ')' { $$ = $2; }
 	|	expression binary_comp expression {
			$$ = createNode(NODE, $2);
			addChildToNode($$, $1);
			addChildToNode($$, $3);
		}
;
binary_rel	:	
 		LAND { $$ = "&&"; }
 	|	LOR { $$ = "||"; }
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

int yyerror(char *s){
    fprintf(stderr, "\033[31;1m%s, line : %d\033[0m \n", s, yylineno);
    freeStack(top);
    exit(1); //le programme s'arrete lors d'une erreur
}

int main(){
    yyparse();
    return 0;
}

//-------------FONCTIONS POUR DEBUG--------------

void printStruct(symbol_struct* s_struct, type_s type){
	if(type == TYPE_FUN){
		printf("{nb_param: %d, type: %d} ", s_struct->function->nb_param, s_struct->function->type);
	}else if(type == TYPE_ARR){
		printf("{dimension: %d} ", s_struct->array->dimension);
	}
}

void printSymbol(Symbol* symbol){
	if (symbol){
		printf("symbol : {name: %s, type: %d, s_struct: ", symbol->name, symbol->type);
		if (symbol->s_struct){
			printStruct(symbol->s_struct, symbol->type);
		}else{
			printf("NULL, ");
		}
		printf("next: ");
		if (symbol->next == NULL){
			printf("NULL}\n");
		}else{
			printf("\n-> ");
			printSymbol(symbol->next);
		}
	}else{
		printf("symbol : NULL\n");
	}
}

void printStack(TableStack* stack){
	printf("___________________________________________________________\n\n");
	if(stack){
		printSymbol(stack->symbol);
		printStack(stack->next);
	}else{
		printf("\t\tEND OF STACK\n");	
	}
}