#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "table_symbole.h"

TableStack* top = NULL;//représente le sommet de la pile
extern int yyerror(char *s);

Symbol* createSymbol(char* name, type_s type, symbol_struct* s_struct){
	Symbol* symbol = (Symbol*) malloc(sizeof(Symbol));
	symbol->name = name;
	symbol->type = type;
	symbol->s_struct = s_struct;	
	symbol->next = NULL;
	return symbol;
}

symbol_struct* createFunStruct(type_t type, Symbol* symbol){
	symbol_struct* s_struct = (symbol_struct*) malloc(sizeof(symbol_struct));
	s_struct->function = (symbol_function*) malloc(sizeof(symbol_function));
	s_struct->function->nb_param = len(symbol);
	s_struct->function->type = type;
	return s_struct;
}

//Libère la mémoire attribuée a un symbol
void freeOneStack(TableStack* stack){
	freeSymbols(stack->symbol);
	free(stack);
}

//libère toute la pile
void freeStack(){
	TableStack* temp;
	while(top != NULL){
		temp = top->next;//garde en memoire la table suivante
		freeOneStack(top);//supprime le sommet de la pile
		top = temp;
	}
}

void freeSymbols(Symbol* symbol1) {
    while(symbol1 != NULL) {
        Symbol* temp = symbol1;
        symbol1 = symbol1->next;
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

Symbol* addSymbol(Symbol* symbol1, Symbol* symbol2){
	if (symbol1 == NULL){
		return symbol2;
	}
	else{
		Symbol* temp_symbol = symbol1;
		while(temp_symbol->next != NULL){
			temp_symbol = temp_symbol->next;
		}
		temp_symbol->next = symbol2;
		return symbol1;
	}
}

TableStack* initTable(){
	TableStack* stack = (TableStack*) malloc(sizeof(TableStack));
	stack->symbol = NULL;
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

int len(Symbol* symbol){
	int length = 0;
	Symbol* temp_symbol = symbol;
	while(temp_symbol != NULL){
		length++;
		temp_symbol = temp_symbol->next;
	}
	return length;
}

char* type_tToString(type_t type){
	if(type == TYPE_VOID){
		return "void";
	}
	return "int";
}

int isCallable(TableStack* stack, char* name){
    int flag;
    Symbol* symbol = stack->symbol;
    while(symbol != NULL){
        if(strcmp(symbol->name, name) == 0 && symbol->type == TYPE_FUN){
            //if(symbol->s_struct->function->nb_param != ?){
            //    flag = 2;
            //} // A finir
            flag = FUNCTION_OK;
            
        }
        symbol = symbol->next;
        
    }
    if(stack->next != NULL)
        return isCallable(stack->next, name);
    return flag;
}

int isAlreadyDefined(TableStack* stack, char* name){
    Symbol* symbol = stack->symbol;
    while(symbol != NULL){
        if(strcmp(symbol->name, name) == 0){
            return 1;
        }
        symbol = symbol->next;
        if(symbol == NULL && stack->next != NULL){
            return isAlreadyDefined(stack->next, name);
        }
    }
    return 0;
}

int isFunctionDefined(TableStack* stack, char* name){
    Symbol* symbol = stack->symbol;
    while(symbol != NULL){
        if(strcmp(symbol->name, name) == 0 && symbol->type == TYPE_FUN){
            return 1;
        }
        symbol = symbol->next;
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