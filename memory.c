#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "memory.h"

int id = 0;
int* ptr_id = &id;

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
	FILE* fd = fopen("ex.dot", "w");
	fprintf(fd, "digraph program {\n");
	while(list != NULL){
		writeNode(list->node, fd);
		list = list->next;
	}
	fprintf(fd, "}");
}

void writeNode(node *_node, FILE *fd){
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
	//affiche les nodes fils
	if(_node->list != NULL){
		do{
			writeNode(_node->list->child, fd);
			writeLink(_node->id, _node->list->child->id, fd);
			_node->list = _node->list->next_child;
		}while(_node->list != NULL);
	}
}

void writeNodeInfo(char* label, char* shape, char* color, int id, FILE* fd){
	fprintf(fd, "\tnode_%d [label=\"%s\" shape=\"%s\" color=%s]\n", id, label, shape, color);
}

void writeLink(int id1, int id2, FILE*fd){
	fprintf(fd, "\tnode_%d -> node_%d\n", id1, id2);
}