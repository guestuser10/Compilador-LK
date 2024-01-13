#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#ifndef COMPILERAURORA_VARIABLES_H
#define COMPILERAURORA_VARIABLES_H
//definicion de las estructuras de datos
struct TreeNode {
    char* variable_name;
    char data_type;
    union {
        int numint;
        float float_value;
        char char_value;
        char bool_value;
    } value;
    struct TreeNode* left;
    struct TreeNode* right;
};
struct TreeNode* createTreeNodeWithoutVal(char* name, char type) {
    struct TreeNode* newNode = (struct TreeNode*)malloc(sizeof(struct TreeNode));
    newNode->variable_name = strdup(name);
    newNode->data_type = type;

    switch (type) {
        case 'a':
            newNode->value.numint = 0; // Por ejemplo, asignar cero como valor por defecto para enteros
            break;
        case 'b':
            newNode->value.float_value = 0.0; // Por ejemplo, asignar cero como valor por defecto para flotantes
            break;
        case 'c':
            newNode->value.char_value = '\0'; // Por ejemplo, asignar '\0' (carácter nulo) como valor por defecto para caracteres
            break;
            // Otros casos para diferentes tipos de datos
    }

    newNode->left = NULL;
    newNode->right = NULL;
    return newNode;
}
struct TreeNode* createTreeNode(char* name, char type, void* value) {
    struct TreeNode* newNode = (struct TreeNode*)malloc(sizeof(struct TreeNode));
    newNode->variable_name = strdup(name);
    newNode->data_type = type;

    switch (type) {
        case 'a':
            newNode->value.numint = *((int*)value);
            break;
        case 'b':
            newNode->value.float_value = *((float*)value);
            break;
            // Otros casos para diferentes tipos de datos
    }

    newNode->left = NULL;
    newNode->right = NULL;
    return newNode;
}

//liberador de memoria por que si no a C le da ansiedad
void freeTreeNode(struct TreeNode* node) {
    free(node->variable_name);
    free(node);
}
//parte de la busqueda
int compareNames(const char* name1, const char* name2) {
    return strcmp(name1, name2);
}
//insertar nodos
struct TreeNode* insertNode(struct TreeNode* root, struct TreeNode* newNode) {
    if (root == NULL) {
        return newNode;
    }

    int compare = strcmp(newNode->variable_name,root->variable_name);
    if (compare < 0) {
        root->left = insertNode(root->left, newNode);
    } else if (compare > 0) {
        root->right = insertNode(root->right, newNode);
    }

    return root;
}
//creacion de los nodos sin valor
struct TreeNode* insertNodeWithoutV(struct TreeNode* root,char* name, char type) {
    if (root == NULL) {
        return createTreeNodeWithoutVal(name,type);
    }

    int compare = strcmp(name,root->variable_name);
    if (compare < 0) {
        root->left = insertNodeWithoutV(root->left, name,type);
    } else if (compare > 0) {
        root->right = insertNodeWithoutV(root->right, name,type);
    }

    return root;
}
//resto de la busqueda
struct TreeNode* Find_Val(struct TreeNode* root, char* Variable){
    int compare = strcmp(Variable,root->variable_name);
    if(root == NULL || compare==0){
        return root;
    }

    if( compare < 0){
        return Find_Val(root->left,Variable);
    }else{
        return Find_Val(root->right,Variable);
    }
}
#endif //COMPILERAURORA_VARIABLES_H