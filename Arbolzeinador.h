//
// Created by khrisna on 05/01/2024.
//esta cosa explotara en un momento jejejejajjajasjjjejjej
//  Arbolzeinador.h se encarga de las tareas que hacen posible la ejecucion del while
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "variables.h"
#include "Split.h"
#ifndef PRUEBACOMPILADOR_ARBOLZEINADOR_H
#define PRUEBACOMPILADOR_ARBOLZEINADOR_H
//definicion de estructuras
typedef struct Statement_While {
    char* type;
    char* value;
    struct Statement *next;
} Statement_While;

typedef struct ASTNode {
    char* type;
    char* value;
    struct ASTNode* condition;
    Statement_While * body;
} ASTNode;
typedef struct LIST{
    ASTNode* while_body;
    struct LIST *next;
    struct LIST *before;
}LIST;
void executeWhileLoop(LIST * node);
void executeWhileLoop_variable(LIST * node,struct TreeNode *node_tree);
struct LIST *puntero=NULL;
struct LIST *NextWhile=NULL;
//typedef struct {
//    LIST *first;
//}Priority;
//void crearPila(Priority *priority,int pos){
//    if(pos==1){
//        priority->first=NULL;
//    }
//}
//int pilaVacia(Priority priority){
//    return (priority.first==NULL);
//}
//ASTNode cima(Priority *priority){
//    if(priority==NULL){
//        puts("Underflow");
//        exit(1);
//    }
//    return priority->first->while_body;
//}
ASTNode *createNode(char* type, char* value, ASTNode* condition, Statement_While* body) {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = strdup(type);
    node->value = strdup(value);
    node->condition = condition;
    node->body = body;
    return node;
}
//void CreateLIST(Priority *priority,ASTNode *stat){
//    LIST *new;
//    new=(LIST*) malloc(sizeof(LIST));
//    new->while_body=*stat;
//    new->next = priority->first;
//    priority->first=new;
//}
//void POPLIST(Priority *priority){
//    if(pilaVacia(*priority)==0){
//        LIST *f;
//        f=priority->first;
//        priority->first=f->next;
//        free(f);
//    }
//}
struct TreeNode* Find = NULL;
//validacion de la condicion
int evaluateCondition(ASTNode* node) {
    // Simulated condition evaluation - For simplicity, assuming conditions are of the form "variable == number"
    if (node && node->condition && node->condition->type && node->condition->value) {
        if (strcmp(node->condition->type, "condition") == 0 && strcmp(node->condition->value, "==") == 0) {
            int var = atoi(node->condition->condition->value);
            int num = atoi(node->condition->body->value);
            return var == num; // Simulated condition evaluation result
        }
    }
    return 0; // Default condition result (false)
}
// ejecucion del body
void executeBody(Statement_While* body,LIST *list) {
    if(body!=NULL){
        if(body->type=="PRNT"){
            printf("%s\n",body->value);
            body=body->next;
            executeBody(body,list);
        } else if(body->type=="ASGN"){

        }else if(body->type=="W"){
            list= list->next;
            executeWhileLoop(list);
            return;
        }
    }

//    while (body) {
//        // Execute each statement within the body
//        if(body->value=="while"){ return;}
//        printf("Executing statement type: %s, value: %s\n", body->type, body->value);
//        body = body->next;
//    }
}
void executeBody_var(Statement_While* body,LIST *list,struct TreeNode *root) {
    if (body != NULL) {
        if (body->type == "PRNT") {
            printf("%s\n", body->value);
            body = body->next;
            executeBody_var(body, list,root);
        } else if (body->type == "ASGN") {
            char *prueba=  body->value;
            char **res= Split(strdup(prueba),",");
            struct TreeNode *FINDS = NULL;
            FINDS= Find_Val(root,res[0]);
            FINDS->value.numint= atoi(res[1]);
            body = body->next;
			free(prueba);
			free(res);
            executeBody_var(body, list,root);
        } else if (body->type == "W") {
            list = list->next;
            executeWhileLoop_variable(list,root);
            return;
        }
    }
}
//liberador de memoria
void DestruirNodo(LIST* node){
    free(node);
}
//rejecucion del while
void executeWhileLoop(LIST * node) {
    ASTNode *NODO=NULL;
    NODO=node->while_body;
    while (evaluateCondition(NODO)) {
        executeBody(NODO->body,node);
        if(node->next!=NULL){
            node=NextWhile;
            NODO=node->while_body;
        }
    }
    if(evaluateCondition(NODO)==0){
        if(node->next==NULL){
            node=node->before;
        } else{
            exit(0);
        }
        executeWhileLoop( node);
    }
}

int evaluateCondition_whit_var(ASTNode* node,struct TreeNode *node_tree) {
    // Simulated condition evaluation - For simplicity, assuming conditions are of the form "variable == number"
    if (node && node->condition && node->condition->type && node->condition->value) {
        if (strcmp(node->condition->type, "condition") == 0 && strcmp(node->condition->value, "==") == 0) {
            struct TreeNode* Find_value = NULL;
            int var=0;
            char *type= strdup(node->condition->condition->type);
            int comp = strcmp(type,"IDNTF");
            if(comp==0){
                Find_value= Find_Val(node_tree,node->condition->condition->value);
                var= Find_value->value.numint;
            }else{
                var = atoi(node->condition->condition->value);
            }
            int num = atoi(node->condition->body->value);
            return var == num; // Simulated condition evaluation result
        }
    }
    return 0; // Default condition result (false)
}
// ejecucion del contenido del while cuando la condicion es verdadera
void executeWhileLoop_variable(LIST * node,struct TreeNode *node_tree) {
    ASTNode *NODO=NULL;
    NODO=node->while_body;
    while (evaluateCondition_whit_var(NODO,node_tree)) {
        executeBody_var(NODO->body,node,node_tree);
        if(node->next!=NULL){
            node=NextWhile;
            NODO=node->while_body;
        }
    }
    if(evaluateCondition_whit_var(NODO,node_tree)==0){
        if(node->next==NULL){
            if(node->before==NULL){
                return;
            } else{
                node=node->before;
            }
        } else{
            return;
        }
        executeWhileLoop_variable( node,node_tree);
    }
}
//orden de ejecucion de las instrucciones
LIST *CreateLISTNEXT(LIST *list,ASTNode *Corp){
    LIST *newNODE, *aux;
    newNODE= (LIST*) malloc(sizeof(LIST));
    newNODE->while_body= Corp;
    newNODE->next=NULL;
    newNODE->before=NULL;
    if(list==NULL){
        list= newNODE;
    }
    else{
        aux=list;
        while (aux->next!=NULL){
            aux=aux->next;
        }
        newNODE->before = puntero;
        aux->next=newNODE;
    }
    puntero = newNODE;
    return list;
}
//creacion de nodos de instrucciones
Statement_While *createBodyWhile(Statement_While *body,char* type, char* value){
    Statement_While *newNODE, *aux;
    newNODE= (Statement_While*) malloc(sizeof(Statement_While));

    newNODE->type=type;
    newNODE->value=value;
    newNODE->next=NULL;
    if(body==NULL){
        body= newNODE;
    }
    else{
        aux=body;
        while (aux->next!=NULL){
            aux=aux->next;
        }
        aux->next=newNODE;
    }
    return body;
}
//orden de ejecucion interno del while
ASTNode *createBodyWhile_INAST(ASTNode *body,char* type,char* value){
    Statement_While *newNODE, *aux;
    newNODE= (Statement_While*) malloc(sizeof(Statement_While));

    newNODE->type=type;
    newNODE->value=value;
    newNODE->next=NULL;
    if(body->body==NULL){
        body->body= newNODE;
    }
    else{
        aux=body->body;
        while (aux->next!=NULL){
            aux=aux->next;
        }
        aux->next=newNODE;
    }
    return body;
}
#endif //PRUEBACOMPILADOR_ARBOLZEINADOR_H