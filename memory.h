#ifndef MEMORY_H
#define MEMORY_H
#include <stdio.h>

typedef enum {NODE,ARR_NODE, FUN_NODE, RET_NODE, CASE_NODE, DEFAULT_NODE, BLOC_NODE, BREAK_NODE, FUN_CALL_NODE, IF_NODE, TEST_NODE} type_node;

typedef struct _node node;

typedef struct _children_list{
    node *child;
    struct _children_list *next_child;
} children_list;

/**
 * liste chaînée de nodes représentant un arbre abstrait
 * @param type type de la node
 * @param list liste des enfants de la node
 * @param id id de la node
 * @param name nom de la node
*/
struct _node{
    type_node type;
    children_list *list;
    int id;
    char *name;
};

/**
 * liste d'arbres abstraits (1 arbre = 1 fonction)
 * @param node arbre abstrait
 * @param next prochain arbre abstrait
*/
typedef struct _node_list{
    node *node;
    struct _node_list *next;
} node_list;

/**
 * Créer le fichier DOT
 * @param list liste de node (arbre abstrait)
*/
void createFile(node_list *list);

/**
 * Initialise une node et la renvoie
 * @param type type de la node
 * @param s_node structure de la node
*/
node* createNode(type_node type, char *name);

int len_children_list(children_list *list);

void addChildToNode(node *_node, node *child);
void addChildToList(children_list *list, children_list *child);
children_list* initChildrenList(node *child);

node_list* addNodeToList(node_list *list1, node_list *list2);
node_list* createNodeList(node *_node);

void checkSwitchSyntax(children_list *list);

void writeNode(node *_node, FILE *fd);
void writeNodeInfo(char *label, char *shape, char *color, int id, FILE *fd);
void writeLink(int id1, int id2, FILE *fd);

#endif