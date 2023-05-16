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
%type <str> binary_rel binary_comp binary_op iteration selection saut affectation bloc appel variable condition 
%type <str> expression liste_expressions liste_instructions instruction

%%
programme	:	
 		liste_declarations liste_fonctions { freeStack(); printStack(top); }
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
 		liste_fonctions fonction { }
 	|   fonction { }
;
declaration	:	
 		type liste_declarateurs ';' {
			if($1 == TYPE_VOID){
				yyerror("Error! Bad type for variable : VOID");
			}else{
				if(isAlreadyDefined(top, $2->name)){
					yyerror("Error! Variable already defined");
					}
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
			pop();//supprime la table de symbole en haut de la pile
			pop();//supprime le sommet de la pile (liste_parms)
			if(isFunctionDefined(top, $2)){
				yyerror("Error! Function already defined");
			} 
			top->node = addNode(createNode($2, TYPE_FUN, createFunStruct($1, $4->node)), top->node); //ajoute la fonction à la liste du bloc parent
		}
 	|	EXTERN type IDENTIFICATEUR '(' liste_parms ')' ';' { 
			pop();//supprime le sommet de la pile (liste_parms)
			if(isFunctionDefined(top, $3)){
				yyerror("Error! Extern function already defined");
			}
			top->node = addNode(createNode($3, TYPE_FUN, createFunStruct($2, $5->node)), top->node); //ajoute la node au sommet de la stack
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
 		IDENTIFICATEUR '(' liste_expressions ')' ';' {
			printf("liste_expressions : %s\n", $3);
			int flag = isCallable(top, $1);
			checkFlag(flag);
		}
;
variable	:	
 		IDENTIFICATEUR { if(!isAlreadyDefined(top, $1)){
				yyerror("Error! Variable not defined");
			}
		}
 	|	variable '[' expression ']' {
			if(!isAlreadyDefined(top, $1)){
				yyerror("Error! Variable not defined");
			}
			int flag = ARRAY_UNDEFINED;//checkArray($1, $3);
			checkFlag(flag);
			

		}
	
;
expression	:	
 		'(' expression ')' { $$ = $2; }
 	|	expression binary_op expression %prec OP
 	|	MOINS expression 
 	|	CONSTANTE 
 	|	variable { }
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
    fprintf(stderr, "\033[31;1m%s, line : %d\033[0m \n", s, yylineno);
	freeStack(top);
    exit(1); //le programme s'arrete lors d'une erreur
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

//Libère la mémoire attribuée a un node
void freeOneStack(TableStack* stack){
	freeNodes(stack->node);
	free(stack);
}

//libere toute la pile
void freeStack(){
	TableStack* temp;
	while(top != NULL){
		temp = top->next;//garde en memoire la table suivante
		freeOneStack(top);//supprime le sommet de la pile
		top = temp;
	}
}

int isCallable(TableStack* stack, char* name){
	int flag;
	Node* node = stack->node;
	while(node != NULL){
		if(strcmp(node->name, name) == 0 && node->type == TYPE_FUN){
			//if(node->s_struct->function->nb_param != ?){
			//	flag = 2;
			//} // A finir
			flag = FUNCTION_OK;
			
		}
		node = node->next;
		
	}
	if(stack->next != NULL)
		return isCallable(stack->next, name);
	return flag;
}

int isAlreadyDefined(TableStack* stack, char* name){
	Node* node = stack->node;
	while(node != NULL){
		if(strcmp(node->name, name) == 0){
			return 1;
		}
		node = node->next;
		if(node == NULL && stack->next != NULL){
			return isAlreadyDefined(stack->next, name);
		}
		
	}
	return 0;
}

int isFunctionDefined(TableStack* stack, char* name){
	Node* node = stack->node;
	while(node != NULL){
		if(strcmp(node->name, name) == 0 && node->type == TYPE_FUN){
			return 1;
		}
		node = node->next;
	}
	return 0;
}
/*
int checkArray(){
	int flag;

	if($3->type != TYPE_INT){
				return ARRAY_BAD_TYPE;
	}

	if($1->type != TYPE_ARR){
		return ARRAY_UNDEFINED;
	}

	if($1->s_struct->array->dimensions[0] < $3->val){
		return ARRAY_OUT_OF_RANGE;
	}
	return ARRAY_OK;

}*/

void checkFlag(int flag){
	switch(flag){
		case FUNCTION_UNDEFINED:
			yyerror("Error! Function not defined");
			break;
		case FUNCTION_BAD_NB_ARGS:
			yyerror("Error! Bad number of arguments");
			break;
		case VAR_UNDEFINED:
			yyerror("Error! Variable not defined");
			break;
		case ARRAY_BAD_INDEX:
			yyerror("Error! Bad type for array index");
			break;
		case ARRAY_UNDEFINED:
			yyerror("Error! Array not defined");
			break;
		case ARRAY_OUT_OF_RANGE:
			yyerror("Error! Index out of range");
			break;
		case ARRAY_BAD_TYPE:
			yyerror("Error! Bad type for array");
			break;
		default:
			//Tout est bon
			break;
	}
}
void freeNodes(Node* node1) {
    while(node1 != NULL) {
        Node* temp = node1;
        node1 = node1->next;
        printf("free de : %s\n", temp->name);
        free(temp->name);
		
        if(temp->s_struct != NULL) { 
			printf("type : %d\n", temp->type);
            switch(temp->type) {
                case TYPE_ARR:
					printf("Free du tableau\n");
                    free(temp->s_struct->array->dimensions); 
                    free(temp->s_struct->array); 
                    break;
                case TYPE_FUN:
					printf("Free de la fonction\n");
                    free(temp->s_struct->function);
                    break;
                default:
					printf("Erreur de type !\n");
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
	freeOneStack(temp_stack);
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

//-------------FONCTIONS POUR DEBUG--------------

void printStruct(symbol_struct* s_struct, type_s type){
	if(type == TYPE_FUN){
		printf("{nb_param: %d, type_t: %d} ", s_struct->function->nb_param, s_struct->function->type);
	}
}

void printNode(Node* node){
	if (node){
		printf("node : {name: %s, type_s: %d, s_struct: ", node->name, node->type);
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