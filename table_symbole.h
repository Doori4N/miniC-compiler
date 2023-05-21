#ifndef TABLE_SYMBOLE_H
#define TABLE_SYMBOLE_H

#include "memory.h"

typedef enum {TYPE_VOID, TYPE_INT} type_t;
typedef enum {TYPE_FUN, TYPE_ARR, TYPE_VAR} type_s;
typedef enum {FUNCTION_UNDEFINED,FUNCTION_BAD_NB_ARGS,FUNCTION_VOID,FUNCTION_OK,
              VAR_UNDEFINED,VAR_OK,
              ARRAY_BAD_INDEX,ARRAY_UNDEFINED,ARRAY_WRONG_DIMENSION,ARRAY_BAD_TYPE,ARRAY_OK,
}flag;

typedef struct{
    int dimension;
} symbol_array;

typedef struct{
    int nb_param;
    type_t type;
} symbol_function;

typedef union{
    symbol_array* array;
    symbol_function* function;
} symbol_struct;

typedef struct symbol{
    char* name;
    type_s type;
    symbol_struct* s_struct;
    struct symbol* next;
} Symbol;

typedef struct stack{
    Symbol* symbol;
    struct stack* next;
} TableStack;

Symbol* createSymbol(char* name, type_s type, symbol_struct* s_struct);
Symbol* addSymbol(Symbol* symbol1, Symbol* symbol2);

TableStack* initTable();
void push(TableStack* stack);
TableStack* pop();

symbol_struct* createFunStruct(type_t type, Symbol* symbol);
symbol_struct* createArrStruct();

int len(Symbol* symbol);
char* type_tToString(type_t type);

void freeSymbols(Symbol* symbol);
void freeStack();
void freeOneStack(TableStack* stack);

int isCallable(TableStack* stack, char* name,children_list* list,int canBeVoid);
Symbol* isAlreadyDefined(TableStack* stack, char* name);
Symbol* lookup(TableStack *stack, char *name);
void checkFlag(int flag);

//FONCTIONS POUR DEBUG
void printSymbol(Symbol* symbol);
void printStack(TableStack* stack);
void printStruct(symbol_struct* s_struct, type_s type);

#endif