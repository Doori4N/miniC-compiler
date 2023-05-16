#ifndef TABLE_SYMBOLE_H
#define TABLE_SYMBOLE_H

typedef enum {TYPE_VOID, TYPE_INT} type_t;
typedef enum {TYPE_FUN, TYPE_ARR, TYPE_VAR} type_s;
typedef enum {FUNCTION_UNDEFINED,FUNCTION_BAD_NB_ARGS,FUNCTION_OK,
			  VAR_UNDEFINED,VAR_OK,
			  ARRAY_BAD_INDEX,ARRAY_UNDEFINED,ARRAY_OUT_OF_RANGE,ARRAY_BAD_TYPE,ARRAY_OK,
};

typedef struct{
    int dimensions[1];
} symbol_array;

typedef struct{
    int nb_param;
    type_t type;
} symbol_function;

typedef union{
    symbol_array* array;
    symbol_function* function;
} symbol_struct;

typedef struct node{
    char* name;
    type_s type;
    symbol_struct* s_struct;
    struct node* next;
} Node;

typedef struct stack{
    Node* node;
    struct stack* next;
} TableStack;


Node* createNode(char* name, type_s type, symbol_struct* s_struct);
Node* addNode(Node* node1, Node* node2);

TableStack* initTable();
void push(TableStack* stack);
void pop();

symbol_struct* createFunStruct(type_t type, Node* node);

int len(Node* node);

void freeNodes(Node* node);
void freeStack();
void freeOneStack(TableStack* stack);
int isAlreadyDefined(TableStack* stack, char* name);
int isFunctionDefined(TableStack* stack, char* name);
void checkFlag(int flag);
// TableStack createTableStack();
// Symbole* searchSymbole(TableStack* table, char* nom);
// Symbole* createSymbole(type_t type, value val);

// void addSymbole(char *nom, Symbole* suivant);
// void addTableStack(char* nom);
// void freeTableStack(TableStack* table);

//FONCTIONS POUR DEBUG
void printNode(Node* node);
void printStack(TableStack* stack);
void printStruct(symbol_struct* s_struct, type_s type);
#endif
