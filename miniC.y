%{
	#include <stdio.h>
    #include <stdlib.h>
	#include <string.h>
	#include "table_symbole.h"
    int yylex();
    int yyerror(char *s);
	extern int yylineno;
	TableStack* top = NULL;
%}

%union{
	char* str;
	int val;
	Node* node;
	TableStack* stack;
	type_t type;
}

%token <str> IDENTIFICATEUR CONSTANTE VOID INT FOR WHILE IF ELSE SWITCH CASE DEFAULT
%token <str> BREAK RETURN PLUS MOINS MUL DIV LSHIFT RSHIFT BAND BOR LAND LOR LT GT 
%token <str> GEQ LEQ EQ NEQ NOT EXTERN

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

%type <type> type
%type <stack> liste_declarations liste_parms
%type <node> declarateur liste_declarateurs declaration fonction parm l_parms liste_fonctions
%type <str> binary_rel binary_comp binary_op liste_instructions instruction iteration selection saut affectation bloc appel variable expression liste_expressions condition 

%%
programme	:	
 		liste_declarations liste_fonctions { $1->node = addNode($1->node, $2); printStack(top);}
;
liste_declarations	:	
		liste_declarations declaration {
			$1->node = addNode($1->node, $2);//Ajoute la/les node(s) à la table de symboles 
			$$ = $1;
		}
 	|	{
			$$ = initTable();//Initialise une table de symboles
			push($$);//Ajoute la table à la pile
		}
;
liste_fonctions	:	
 		liste_fonctions fonction { $$ = addNode($1, $2); }
 	|   fonction { $$ = $1; }
;
declaration	:	
 		type liste_declarateurs ';' {
			if($1 == TYPE_VOID){
				yyerror("Error! bad type for variable : VOID");
			}else{
				$$ = $2;
			}
		}
;
liste_declarateurs	:	
 		liste_declarateurs ',' declarateur {
			$$ = addNode($1, $3); //ajoute une node à la liste
		}
 	|	declarateur { $$ = $1; }
;
declarateur		:	
 		IDENTIFICATEUR { $$ = createNode($1, TYPE_VAR, NULL); }
 	|	declarateur '[' CONSTANTE ']' 
;
fonction		:	
 		type IDENTIFICATEUR '(' liste_parms ')' '{' liste_declarations liste_instructions '}' { 
			$$ = createNode($2, TYPE_FUN, createFunStruct($1, $4->node)); //ajoute la fonction à la liste du bloc parent
			pop();//supprime la table de symbole en haut de la pile
			pop();
		}
 	|	EXTERN type IDENTIFICATEUR '(' liste_parms ')' ';' { 
			$$ = createNode($3, TYPE_FUN, createFunStruct($2, $5->node)); 
			pop();
		}
;
type	:	
 		VOID { $$ = TYPE_VOID; }
 	|	INT { $$ = TYPE_INT; }
;
liste_parms		:	
 		l_parms	{ 
			$$ = initTable();//Initialise une table de symboles
			$$->node = $1;
			push($$);//Ajoute la table à la pile
		}
 	|	{ 
			$$ = initTable(); 
			push($$);
		}
;
l_parms		:
		l_parms ',' parm { $$ = addNode($1, $3); }
	|	parm { $$ = $1; }
;
parm	:	
 		INT IDENTIFICATEUR { $$ = createNode($2, TYPE_VAR, NULL); }
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
 		'{' liste_declarations liste_instructions '}' { pop(); }
;
appel	:	
 		IDENTIFICATEUR '(' liste_expressions ')' ';'
;
variable	:	
 		IDENTIFICATEUR
 	|	variable '[' expression ']'
;
expression	:	
 		'(' expression ')'
 	|	expression binary_op expression %prec OP
 	|	MOINS expression
 	|	CONSTANTE
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
 	|   MOINS { $$ = "-";}
 	|	MUL { $$ = "*";}
 	|	DIV { $$ = "/";}
 	|   LSHIFT { $$ = "<<";}
 	|   RSHIFT { $$ = ">>";}
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

int yyerror(char *s){
    fprintf(stderr, "%s, ligne : %d \n", s, yylineno);
    exit(1); //le programme s'arrete lors d'une erreur de syntaxe
}
int main(){
    yyparse();
    return 0;
}

Node* createNode(char* name, type_s type, symbol_struct* s_struct){
	Node* node = (Node*) malloc(sizeof(Node));
	node->name = name;
	node->type = type;
	node->s_struct = s_struct;	
	node->next = NULL;
	return node;
}

symbol_struct* createFunStruct(type_t type, Node* node){
	symbol_struct* s_struct = (symbol_struct*) malloc(sizeof(symbol_struct));
	s_struct->function = (symbol_function*) malloc(sizeof(symbol_function));
	s_struct->function->nb_param = len(node);
	s_struct->function->type = type;
	return s_struct;
}

Node* addNode(Node* node1, Node* node2){
	if (node1 == NULL){
		return node2;
	}
	else{
		Node* temp_node = node1;
		while(temp_node->next != NULL){
			temp_node = temp_node->next;
		}
		temp_node->next = node2;
		return node1;
	}
}

TableStack* initTable(){
	TableStack* stack = (TableStack*) malloc(sizeof(TableStack));
	stack->node = NULL;
	stack->next = NULL;
	return stack;
}

void push(TableStack* stack){
	if(top){
		stack->next = top;
	}
	top = stack;
}

void pop(){
	TableStack* temp_stack = top;
	if(top){
		top = top->next;
	}
	free(temp_stack);
}

int len(Node* node){
	int length = 0;
	Node* temp_node = node;
	while(temp_node != NULL){
		length++;
		temp_node = temp_node->next;
	}
	return length;
}

//-------------FONCTIONS POUR DEBUG------------

void printStruct(symbol_struct* s_struct, type_s type){
	if(type == TYPE_FUN){
		printf("{nb_param: %d, type: %d} ", s_struct->function->nb_param, s_struct->function->type);
	}
}

void printNode(Node* node){
	if (node){
		printf("node : {name: %s, type: %d, s_struct: ", node->name, node->type);
		if (node->s_struct){
			printStruct(node->s_struct, node->type);
		}else{
			printf("NULL, ");
		}
		printf("next: ");
		if (node->next == NULL){
			printf("NULL}\n");
		}else{
			printf("\n-> ");
			printNode(node->next);
		}
	}else{
		printf("node : NULL\n");
	}
}

void printStack(TableStack* stack){
	printf("___________________________________________________________\n\n");
	if(stack){
		printNode(stack->node);
		printStack(stack->next);
	}else{
		printf("\t\tEND OF STACK\n");	
	}
}