#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "table_symbole.h"
#include "memory.h" 
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

symbol_struct* createArrStruct(){
	symbol_struct* s_struct = (symbol_struct*) malloc(sizeof(symbol_struct));
	s_struct->array = (symbol_array*) malloc(sizeof(symbol_array));
	s_struct->array->dimension = 0;
	return s_struct;
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
        free(temp->name);
		
        if(temp->s_struct != NULL) { 
            switch(temp->type) {
                case TYPE_ARR:
                    free(temp->s_struct->array); 
                    break;
                case TYPE_FUN:
                    free(temp->s_struct->function);
                    break;
                default:
                    break;
            }
            free(temp->s_struct);
        }
        
        free(temp);
    }
}

Symbol* addSymbol(Symbol *symbol1, Symbol *symbol2){
	if (symbol1 == NULL){
		return symbol2;
	}
	else{
		Symbol *temp_symbol = symbol1;
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

TableStack* pop(){
	TableStack* temp_stack = top;
	if(top){
		top = top->next;
	}
	return temp_stack;
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

int isCallable(TableStack* stack, char* name,children_list* list, int canBeVoid){
    int flag = FUNCTION_UNDEFINED;
    Symbol* symbol = stack->symbol;
    while(symbol != NULL){
        if(strcmp(symbol->name, name) == 0 && symbol->type == TYPE_FUN){
            if(symbol->s_struct->function->type == TYPE_VOID && canBeVoid == 0){
                return FUNCTION_VOID;
            }
            if(symbol->s_struct->function->nb_param == len_children_list(list)){
                return FUNCTION_OK;
            }
            else{
                return FUNCTION_BAD_NB_ARGS;
            }
            return FUNCTION_OK;
        }
        symbol = symbol->next;
    }
    if(stack->next != NULL)
        return isCallable(stack->next, name,list, canBeVoid);
    return flag;
}

Symbol* isAlreadyDefined(TableStack *stack, char *name){
    Symbol *symbol = stack->symbol;
    while(symbol != NULL){
        if(strcmp(symbol->name, name) == 0){
            return symbol;
        }
        symbol = symbol->next;
    }
    return NULL;
}

Symbol* lookup(TableStack *stack, char *name){
	Symbol *symbol = isAlreadyDefined(stack,name);
    if(symbol != NULL) return symbol;
    if(stack->next != NULL) return lookup(stack->next, name);
    return NULL;
}

int checkArray(TableStack* stack, node *var, node *expr){
    int flag = ARRAY_UNDEFINED;
    Symbol* symbol = stack->symbol;

    while(symbol !=NULL){
        if (strcmp(symbol->name,var->name)==0 && symbol->type == TYPE_ARR){
            printf("big test\n");
            return ARRAY_OK;
        } 
    }

    return flag;
}

void checkFlag(int flag){
    switch(flag){
        case FUNCTION_UNDEFINED:
            yyerror("Error! Function not defined");
            break;
        case FUNCTION_BAD_NB_ARGS:
            yyerror("Error! Bad number of arguments");
            break;
        case FUNCTION_VOID:
            yyerror("Error! Invalid use of void expression");
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
        case ARRAY_WRONG_DIMENSION:
            yyerror("Error! Wrong dimension for array");
            break;
        case ARRAY_BAD_TYPE:
            yyerror("Error! Bad type for array");
            break;
        default:
            //Tout est bon
            break;
    }
}