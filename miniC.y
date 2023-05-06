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

%type <stack> liste_declarations
%type <node> declarateur liste_declarateurs declaration
%type <str> binary_rel binary_comp binary_op type liste_parms l_parms parm liste_instructions instruction iteration selection saut affectation bloc appel variable expression liste_expressions condition liste_fonctions fonction

%%
programme	:	
 		liste_declarations liste_fonctions { printStack(top); freeStack(top); }
;
liste_declarations	:	
		liste_declarations declaration {
			//Ajoute la/les node(s) à la table de symboles 
			$1->node = addNode($1->node, $2);
			$$ = $1;
		}
 	|	{
			//Initialise une table de symboles
			$$ = initTable();
			//Ajoute la table à la pile
			push($$);
		}
;
liste_fonctions	:	
 		liste_fonctions fonction
 	|   fonction	
;
declaration	:	
 		type liste_declarateurs ';' {
			if(!strcmp($1, "VOID")){
				yyerror("Error! bad type for variable : VOID");
			}else{
				$$ = $2;
			}
		}
;
liste_declarateurs	:	
 		liste_declarateurs ',' declarateur {
			//ajoute une node à la liste
			$$ = addNode($1, $3);
		}
 	|	declarateur { $$ = $1; }
;
declarateur		:	
 		IDENTIFICATEUR { $$ = createNode($1); }
 	|	declarateur '[' CONSTANTE ']'
;
fonction		:	
 		type IDENTIFICATEUR '(' liste_parms ')' '{' liste_declarations liste_instructions '}' 
 	|	EXTERN type IDENTIFICATEUR '(' liste_parms ')' ';' 
;
type	:	
 		VOID { $$ = "VOID"; }
 	|	INT { $$ = "INT"; }
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

Node* createNode(char* name){
	Node* node = (Node*) malloc(sizeof(Node));
	node->name = name;
	node->type = TYPE_VAR;
	node->s_struct = NULL;
	node->next = NULL;
	return node;
}

void freeStack(){
	while(top != NULL){
		freeNodes(top->node);
		top = top->next;
	}
}

void freeNodes(Node* node1) {
    while(node1 != NULL) {
        Node* temp = node1;
        node1 = node1->next;
        printf("free de : %s\n", temp->name);
        free(temp->name);
		
        if(temp->s_struct := NULL) { 
			printf("type : %d\n", temp->type);
            switch(temp->type) {
                case TYPE_ARR:
                    free(temp->s_struct->array->dimensions); 
                    free(temp->s_struct->array); 
                    break;
                case TYPE_FUN:
                    free(temp->s_struct->function);
                    break;
                default:
					printf("Erreur de type !\n")
                    break;
            }
            free(temp->s_struct);
        }
        
        free(temp);
    }
}


Node* addNode(Node* node1, Node* node2){
	if (node1 == NULL){
		return node2;
	}
	else{
		Node* temp_node = node1;
		Node* curr_node = node1;
		while(curr_node != NULL){
			temp_node = curr_node;
			curr_node = temp_node->next;
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

//-------------FONCTIONS POUR DEBUG------------

void printNode(Node* node){
	if (node){
		char* s = "NULL";
		if (node->s_struct){
			//changer s
		}
		printf("node : {name: %s, type: %d, s_struct: %s next: ", node->name, node->type, s);
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