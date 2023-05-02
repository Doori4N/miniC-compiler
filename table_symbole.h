typedef enum {VOID,INT} type_t;

typedef struct tableau{
    char* nom;
    int dimension;
};

typedef struct fonction {
    char* nom;
    int nb_param;
    type_t type;
};

typedef struct id {
    char* nom;
};

typedef union value{
    struct tableau tableau;
    struct fonction fonction;
    struct id id;
};

typedef struct Symbole{
    char* t_val;
    value val;
    Symbole* suivant;
};

typedef struct TableStack{
    Symbole* suivant;
    TableStack* precedent;
};

// TableStack createTableStack();

// Symbole* searchSymbole(TableStack* table, char* nom);
// Symbole* createSymbole(type_t type, value val);

// void addSymbole(char *nom, Symbole* suivant);
// void addTableStack(char* nom);
// void freeTableStack(TableStack* table);