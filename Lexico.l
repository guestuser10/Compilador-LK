%{ 
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include "Parse.tab.h" // Archivo generado por Bison con los tokens
char    texto[];
%}
%option yylineno
//en este segmento agrupamos posibles casos de caracteres aceptados.
digit   [0-9]
INTnumber {digit}+
number  {digit}+(\.{digit}+)
letter  [a-zA-Z_]
Text 	[A-za-z]*
id      {letter}({letter}|{digit})*
flags   "true"|"false"
%%//aqui ya son los filtros que tokenizara el programa
[ \t\n]+    {}
"ready"		{ return READY;}
"end"		{ return END;}
"+"         { return PLUS; }
"-"         { return MINUS; }
"*"         { return MULTIPLY; }
"/"         { return DIVIDE; }
"("         { return LPAREN; }
")"         { return RPAREN; }
"="         { return ASSIGN; }
";"         { return SEMICOLON; }
"if"        { return IF; }
"else"      { return ELSE; }
"while"     { return WHILE; }
"for"       { return FOR; }
"INC"		{ return INC; }
"DEC"		{ return DEC; }
"int"       { yylval.TYPELK='a';return INT_TYPE; }
"float"     { yylval.TYPELK='b';return FLOAT_TYPE; }
"char"      { yylval.TYPELK='c';return CHAR_TYPE; }
"boolean"   { yylval.TYPELK='d';return BOOL_TYPE; }
"\""		{ return COMMILLA; }
"\'"		{ return SIMPLECOM; }
"["         { return LBRACKET; }
"]"         { return RBRACKET; }
","         { return COMMA; }
"{"         { return LBRACE; }
"}"         { return RBRACE; }
"=="        { return EQUAL; }
"!="        { return NOTEQUAL; }
"<"         { return LESS; }
">"         { return GREATER; }
"<="        { return LESSEQUAL; }
">="        { return GREATEREQUAL; }
"switch"    { return SWITCH; }
"case"      { return CASE; }
"default"   { return DEFAULT; }
"Write"		{ return WRITE; }
{flags}		{ return BOLEANVAL; }
{INTnumber}	{ yylval.numint = atoi(yytext); return INTNUM;}
{number}    { yylval.float_val = atof(yytext); return NUMBER; }
{Text}		{ sprintf(texto,"%s ",yytext);
			  yylval.txt= strdup(texto);return TEXT;}
{id}        { yylval.variable_name = strdup(yytext); return IDENTIFIER; printf("jala el ID");}
.           { /*printf("Error léxico en la línea %d: Caracter inesperado %s\n", yylineno, yytext); */}
%%