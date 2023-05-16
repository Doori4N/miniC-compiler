#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "table_symbole.h"

TableStack* top = NULL;//représente le sommet de la pile

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