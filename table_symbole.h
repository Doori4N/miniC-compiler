typedef enum {TYPE_VOID, TYPE_INT} type_t;
typedef enum {TYPE_FUN, TYPE_ARR, TYPE_VAR} type_s;

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

Node* createNode(char* nom);
Node* addNode(Node* node1, Node* node2);

TableStack* initTable();
void push(TableStack* stack);

// TableStack createTableStack();
// Symbole* searchSymbole(TableStack* table, char* nom);
// Symbole* createSymbole(type_t type, value val);

// void addSymbole(char *nom, Symbole* suivant);
// void addTableStack(char* nom);
// void freeTableStack(TableStack* table);

//FONCTIONS POUR DEBUG
void printNode(Node* node);
void printStack(TableStack* stack);
