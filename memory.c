#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "memory.h"

extern int yyerror(char *s);

int id = 0;
int* ptr_id = &id;

int checkCaseValue(int capacity, int size, char **array, char *name){
	for (int i = 0; i < size; i++){
		if(strcmp(array[i], name) == 0) yyerror("Error! Duplicate case value");
	}
	if(size == capacity){
		capacity = (capacity == 0) ? 1 : capacity * 2;
		array = realloc(array, capacity * sizeof(char*));
	}
	array[size] = name;
	return capacity;
}

void checkSwitchSyntax(children_list *list){
	char **array = malloc(sizeof(char*));
	int size = 0;
	int capacity = 0;

	children_list *curr_last_case = NULL;
	int isDefaultDefine = 0;
	while(list->next_child != NULL){
		//si c'est une node DEFAULT -> verifie que DEFAULT n'est pas déjà définie
		if(list->child->type == DEFAULT_NODE){
			if(isDefaultDefine == 1) yyerror("Error! Multiple default labels in one switch");
			else {
				isDefaultDefine = 1;
				curr_last_case = list;
				list = list->next_child;
			}
		}
		//si c'est une node CASE -> verifie que la valeur du CASE n'est pas déjà utilisée
		else if(list->child->type == CASE_NODE){
			capacity = checkCaseValue(capacity, size, array, list->child->list->child->name);
			size++;

			curr_last_case = list;
			list = list->next_child;
		} 
		//si c'est une autre node -> ajoute la node au dernier CASE
		else{
			if(curr_last_case != NULL){
				curr_last_case->next_child = list->next_child;
				list->next_child = NULL;
				addChildToList(curr_last_case->child->list, list);
				list = curr_last_case->next_child;
			}else{
				list = list->next_child;
			}
		}
	}
	//si c'est une node DEFAULT -> verifie que DEFAULT n'est pas déjà définie
	if(list->child->type == DEFAULT_NODE){
		if(isDefaultDefine == 1) yyerror("error: multiple default labels in one switch");
		else {
			isDefaultDefine = 1;
			curr_last_case = list;
			list = list->next_child;
		}
	}
	//si c'est une autre node -> ajoute la node au dernier CASE
	else if(list->child->type != CASE_NODE){
		curr_last_case->next_child = list->next_child;
		list->next_child = NULL;
		addChildToList(curr_last_case->child->list, list);
		list = curr_last_case->next_child;
	}
	//si c'est une node CASE -> verifie que la valeur du CASE n'est pas déjà utilisée
	else checkCaseValue(capacity, size, array, list->child->list->child->name);

	free(array);
	array = NULL;
}

node_list* addNodeToList(node_list* list1, node_list* list2){
	if(list1 == NULL) return list2;
	node_list* temp = list1;
	while(temp->next != NULL){
		temp = temp->next;
	}
	temp->next = list2;
	return list1;
}

node_list* createNodeList(node *_node){
	if (_node == NULL){
		return NULL;
	}
	node_list* list = (node_list*) malloc(sizeof(node_list));
	list->node = _node;
	list->next = NULL;
	return list;
}

node* createNode(type_node type, char *name){
	node* _node = (node*) malloc(sizeof(node));
	_node->type = type;
	_node->list = NULL;
	_node->id = *ptr_id;
	_node->name = name;
	(*ptr_id)++;
	return _node;
}

children_list* initChildrenList(node *child){
	if(child == NULL) return NULL;
	children_list* list = (children_list*) malloc(sizeof(children_list));
	list->child = child;
	list->next_child = NULL;
	return list;
}
void addChildToList(children_list *list, children_list *child){
	children_list* temp_list = list;
	while(temp_list->next_child != NULL) temp_list = temp_list->next_child;
	temp_list->next_child = child;
}

void addChildToNode(node *_node, node *child){
	if(_node->list == NULL) _node->list = initChildrenList(child);
	else addChildToList(_node->list, initChildrenList(child));
}

int len_children_list(children_list *list){
	int length = 0;
	if (list == NULL) return length;
	while(list->next_child != NULL){
		length++;
		list = list->next_child;
	}
	return length+1;
}

void createFile(node_list* list){
	node_list *temp_list = list;
	FILE* fd = fopen("ex.dot", "w");
	fprintf(fd, "digraph program {\n");
	while(temp_list != NULL){
		writeNode(temp_list->node, fd);
		temp_list = temp_list->next;
	}
	fprintf(fd, "}");
}

void writeNode(node *_node, FILE *fd){
	//affiche la node dans le fichier
	switch(_node->type){
		case FUN_NODE:
			writeNodeInfo(_node->name, "invtrapezium", "blue", _node->id, fd);
			break;
		case RET_NODE:
			writeNodeInfo(_node->name, "trapezium", "blue", _node->id, fd);
			break;
		case BREAK_NODE:
			writeNodeInfo(_node->name, "box", "black", _node->id, fd);
			break;
		case FUN_CALL_NODE:
			writeNodeInfo(_node->name, "septagon", "black", _node->id, fd);
			break;
		case IF_NODE:
			writeNodeInfo(_node->name, "diamond", "black", _node->id, fd);
			break;
		case TEST_NODE:
			writeNodeInfo(_node->name, "triangle", "black", _node->id, fd);
			break;
		default:
			writeNodeInfo(_node->name, "ellipse", "black", _node->id, fd);
			break;
	}
	//affiche les nodes fils dans le fichier
	children_list *temp_list = _node->list;
	if(temp_list != NULL){
		do{
			writeNode(temp_list->child, fd);
			writeLink(_node->id, temp_list->child->id, fd);
			temp_list = temp_list->next_child;
		}while(temp_list != NULL);
	}
}

void writeNodeInfo(char* label, char* shape, char* color, int id, FILE* fd){
	fprintf(fd, "\tnode_%d [label=\"%s\" shape=\"%s\" color=%s]\n", id, label, shape, color);
}

void writeLink(int id1, int id2, FILE*fd){
	fprintf(fd, "\tnode_%d -> node_%d\n", id1, id2);
}

void freeNode(node *_node){
	if(_node != NULL){
		freeChildList(_node->list);
		free(_node);
	}
}

void freeChildList(children_list *list){
	if(list != NULL){
		freeNode(list->child);
		freeChildList(list->next_child);
		free(list);
	}
}

void freeNodeList(node_list *list){
	if(list != NULL){
		freeNode(list->node);
		freeNodeList(list->next);
		free(list);
	}
}