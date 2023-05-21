#ifndef MEMORY_H
#define MEMORY_H
#include <stdio.h>

/**
 * type d'une node
*/
typedef enum {NODE,ARR_NODE, FUN_NODE, RET_NODE, CASE_NODE, DEFAULT_NODE, BLOC_NODE, BREAK_NODE, FUN_CALL_NODE, IF_NODE, TEST_NODE} type_node;

typedef struct _node node;

/**
 * liste des enfants d'une node
 * @param child node enfant
 * @param next_child prochaine node enfant
*/
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
 * @param name nom de la node
*/
node* createNode(type_node type, char *name);
/**
 * calcule la longueur de la liste des fils d'une node
 * @param list liste des fils d'une node
*/
int len_children_list(children_list *list);
/**
 * ajoute une node enfant à une autre node
 * @param _node node parent
 * @param child node enfant
*/
void addChildToNode(node *_node, node *child);
/**
 * ajoute un enfant à la liste des enfants d'une node
 * @param list liste des enfants de la node
 * @param child structure d'un fils à ajouter à la liste
*/
void addChildToList(children_list *list, children_list *child);
/**
 * initialise un enfant d'une node
 * @param child node enfant
*/
children_list* initChildrenList(node *child);
/**
 * Concatene deux listes de nodes
 * @param list1 liste de node 1
 * @param list2 liste de node 2
*/
node_list* addNodeToList(node_list *list1, node_list *list2);
/**
 * Creer un element de la liste de node 
 * @param _node node correspondant à un arbre abstrait d'une fonction
*/
node_list* createNodeList(node *_node);

/**
 * Verifie la semantique d'un switch
 * @param list liste des instructions du switch
*/
void checkSwitchSyntax(children_list *list);
/**
 * Verifie que les valeurs des CASES sont différentes
 * @param capacity capacité totale du tableau
 * @param size taille actuelle du tableau
 * @param array tableau qui contient les valeurs des CASES
 * @param name nom correspondant à la valeur d'un CASE
*/
int checkCaseValue(int capacity, int size, char **array, char *name);
/**
 * Fonction qui gere la creation d'une node et de ses fils dans le fichier DOT
 * @param _node node à afficher
 * @param fd descripteur du fichier DOT
*/
void writeNode(node *_node, FILE *fd);
/**
 * Creer la node dans le fichier DOT
 * @param label nom de la node
 * @param shape forme de la node
 * @param color couleur de la node
 * @param id id de la node
 * @param fd descripteur du fichier DOT
*/
void writeNodeInfo(char *label, char *shape, char *color, int id, FILE *fd);
/**
 * Relie deux nodes dans le fichier DOT
 * @param id1 id de la node parent
 * @param id2 id de la node enfant
 * @param fd descripteur du fichier DOT
*/
void writeLink(int id1, int id2, FILE *fd);
/**
 * libere la structure d'une node
 * @param _node node à liberer
*/
void freeNode(node *_node);
/**
 * libere chaque élément d'une liste de fils
 * @param list structure de liste des fils
*/
void freeChildList(children_list *list);
/**
 * libere chaque élément d'une liste d'arbres abstraits
 * @param list liste d'arbres abstraits
*/
void freeNodeList(node_list *list);
#endif