#include <stdio.h>

//dot -Tpdf ex.dot -o ex.pdf

typedef enum {NODE_FUN, NODE_BLOC, NODE_RET} type_node;

typedef union{
    function* fun;
    ret* ret;
    bloc* bloc;
} node;

typedef struct _function{
    char* name;
    char* type;
} function;

typedef struct _ret{
    
} ret;

typedef struct _bloc{

} bloc;

typedef struct _node{
    
} node;

int main(){
    FILE *fp;
    fp = fopen ("ex.dot", "w");
}
