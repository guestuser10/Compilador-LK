//
// Created by khrisna on 05/01/2024.
//
#ifndef PRUEBACOMPILADOR_SPLIT_H
#define PRUEBACOMPILADOR_SPLIT_H
#include <stdlib.h>
#include <string.h>
//funcion para separar una cadena de caracteres.
char **Split(char *cadena, char *delim) {
    char **tokens = NULL;
    int contador = 0;

    char *token = strtok(cadena, delim);

    tokens = (char **)malloc(sizeof(char *));
    while (token != NULL) {
        tokens = (char **)realloc(tokens, (contador + 1) * sizeof(char *));
        tokens[contador] = token;
        contador++;
        token = strtok(NULL, delim);
    }

    // Agregamos un token nulo al final para indicar el fin de los tokens
    tokens = (char **)realloc(tokens, (contador + 1) * sizeof(char *));
    tokens[contador] = NULL;

    return tokens;
}
#endif //PRUEBACOMPILADOR_SPLIT_H
