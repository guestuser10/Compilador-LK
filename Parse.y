%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "Arbolzeinador.h"
#include "Split.h"
#include "variables.h"
//declaracion de variables y estructuras
void yyerror(const char *s);
extern FILE *yyin;
extern int yylineno;
char* lines = NULL;
char *values_cond = NULL;
char tipo;
int acum;
int *havepoint,IsaINt,conditionres,flagcondition,Else_res,acu,In_While,flag_While_condition;
//metodos de asignacion valores a las banderas
void setInsideWhile(int val){
	In_While = val;
}
void setWhileCondition(int val){
	flag_While_condition = val;
}
void setInsideIf(int val) {
    conditionres = val;
}
void setInsideElse(int val) {
    Else_res = val;
}
void setflagCondition(int value){
	flagcondition = value;
}
void setacu(int plus){
	acu = plus;
}

struct TreeNode* root = NULL;
ASTNode *ArbolWhile=NULL;
//tokens y algunas estructuras a utilizar
%}

%token PLUS MINUS MULTIPLY DIVIDE LPAREN RPAREN ASSIGN SEMICOLON COMMILLA SIMPLECOM
%token IF ELSE WHILE FOR INC DEC
%token LBRACKET RBRACKET COMMA LBRACE RBRACE
%token EQUAL NOTEQUAL LESS GREATER LESSEQUAL GREATEREQUAL
%token SWITCH CASE DEFAULT BOLEANVAL 
%token READY END
%token WRITE
%code requires{
	struct TypeV{
		int numb;
		float numbf;
		char caract;
		int flagcondition;
	};
	struct ConditionCORP{
		char *opcion1;
		char *condition_var;
		char *opcion2;
	};
}
%union {
		char TYPELK;
		float float_val;
		char* variable_name;
		int numint;
		struct TypeV TypesExp;
		struct ConditionCORP Cond;
}
%union {
	char char_value;
    char bool_value;
}
%union{
		char *txt;
		char *cadena;
}
%token <float_val> NUMBER
%token <numint> INTNUM
%token <variable_name> IDENTIFIER
%token <txt> TEXT
%type <txt> Output_text
%type <TYPELK> type
%type <TypesExp> expression
%type <ASTNode> while_statement 
%type <Cond>  conditions
%token <TYPELK> INT_TYPE FLOAT_TYPE CHAR_TYPE BOOL_TYPE
%start program
%%
//sintaxis de estructura base;
program : READY empty_block END
		| function_declaration READY empty_block END
		| /* empty */
        ;
//estructura del empty_block
empty_block: LBRACE RBRACE
	| LBRACE statementList RBRACE
	;

function_declaration:
		;
//statementList puede contener uno o muchos statement
statementList: statement
			| statementList statement
			;

//statement son las funciones del programa
statement : declaration SEMICOLON
          | condition SEMICOLON {setInsideIf(2);}
          | loop
          | switch_case
		  | function_declaration
		  | Assign_expression SEMICOLON
		  | Write_Statement SEMICOLON
          | error SEMICOLON
          ;
//estructura de las condiciones
Condition_content: {setInsideIf(1);} statement
				| Condition_content statement{setInsideIf(1);}
				;
				
Else_content:   statement
				| Else_content statement
				;
condition: IF LPAREN expression RPAREN LBRACE Condition_content RBRACE
		| IF LPAREN expression RPAREN LBRACE Condition_content RBRACE ELSE LBRACE Else_content RBRACE

//estructura de la declaracion de variables
declaration : type IDENTIFIER {
			root=insertNodeWithoutV(root,$2,$1);
			}
            | type IDENTIFIER LBRACKET NUMBER RBRACKET
            ;
//tipos de dato aceptados y los datos que manda cada uno
type : INT_TYPE {$$ = $1;}
	| FLOAT_TYPE {$$ = $1;}
	| CHAR_TYPE {tipo= $1;}
	| BOOL_TYPE{tipo= $1;}
    ;
// estructura del print
Write_Statement: WRITE Write_content
				|WRITE{/*Error message*/ yyerror("Error-Expression: Write content not found please asign content.");
				return -1;}
		;
//funcionamiento del print
Write_content: COMMILLA Output_text COMMILLA {
			if(In_While==1){
				char *text_string= $2;
				ArbolWhile= createBodyWhile_INAST(ArbolWhile,"PRNT",text_string);
			}else{
				
				if((conditionres==1) && (flagcondition == 1))
				{
					free($2);
					printf("%s\n",$2);
					
				}else{
					if (conditionres == 2){
						setflagCondition(0);
						printf("%s\n",$2);
					}
				}
			}
			}
			|IDENTIFIER {
				Find = Find_Val(root,$1);
				tipo = Find->data_type;
				switch(tipo){
				case 'a':
					printf("%d\n",Find->value.numint);
					break;
				case 'b':
					printf("%f\n",Find->value.float_value);
					break;
				}
			}
			;

Output_text: TEXT{strcpy(&lines,&$1);}
			|Output_text TEXT {$$ = strcat(lines, $2); free($2);}
			;
//funcionamiento de las condiciones del while
conditions: IDENTIFIER{
				char variable[100];
				sprintf(variable,"%s",$1);
				char cadena_Identificador[]= "IDNTF,";
				strcat(cadena_Identificador,variable);
				$<Cond.opcion1>$=strdup(cadena_Identificador);
		   }
		   | INTNUM {
				int number=$1;
				char var1[12];
				char cadena_Identificador1[]= "NUM,";
				sprintf(var1,"%d",number);
				strcat(cadena_Identificador1,var1);
				$<Cond.opcion1>$=strdup(cadena_Identificador1);
			}
           | NUMBER {
				float decimal=$1;
				char var2[12];
				char cadena_Identificador2[]= "DECIM,";
				sprintf(var2,"%f",decimal);
				strcat(cadena_Identificador2,var2);
				$<Cond.opcion1>$=strdup(cadena_Identificador2);
		   }
		   | BOLEANVAL
           | conditions EQUAL conditions {
			$<Cond.opcion2>$= $<Cond.opcion1>3;
			$<Cond.condition_var>$="==";
		   }
           | conditions NOTEQUAL conditions{}
           | conditions LESS conditions{}
           | conditions GREATER conditions{}
           | conditions LESSEQUAL conditions{}
           | conditions GREATEREQUAL conditions{}
;
//parte del funcionamiento del while
while_content: {setInsideWhile(1);}statement
			|while_content {setInsideWhile(1);} statement
;
while_statement: WHILE LPAREN conditions{
//First_Part
char **String_of_Condition1 = Split($<Cond.opcion1>3,",");
char *Type_of_data_1 = String_of_Condition1[0];
char *Value_of_data_1 = String_of_Condition1[1];
//Second_Part
char **String_of_Condition2 = Split($<Cond.opcion2>3,",");
char *Type_of_data_2 = String_of_Condition2[0];
char *Value_of_data_2 = String_of_Condition2[1];
//Condition
char *condition_type = $<Cond.condition_var>3;
ArbolWhile=createNode("While","while",createNode("condition", condition_type, createNode(Type_of_data_1,Value_of_data_1, NULL, NULL), createNode(Type_of_data_2,Value_of_data_2, NULL, NULL)),NULL);
} RPAREN LBRACE while_content RBRACE SEMICOLON
;
loop: while_statement {setInsideWhile(0);
	LIST *priority=NULL;
    priority=CreateLISTNEXT(priority,ArbolWhile);
	executeWhileLoop_variable(priority,root);
	}
;


switch_case:
//funcionamiento de asignacion de variables
Assign_expression: IDENTIFIER ASSIGN expression{ 
			if(In_While==1){
				Find = Find_Val(root,$1);
				tipo = Find->data_type;
				char *Value_of_Identif;
				char valor1[100];
				switch(tipo){
					case 'a':
						if(havepoint==1 | IsaINt==2){
							int value_Ident = (int)$<TypesExp.numbf>3;//Guardo el valor del entero
							sprintf(valor1,"%s",Find->variable_name);
							char temp_string[]="";
							strcat(temp_string,valor1);
							strcat(temp_string,",");
							sprintf(valor1,"%d",value_Ident);
							strcat(temp_string,valor1);
							Value_of_Identif= temp_string;
							ArbolWhile= createBodyWhile_INAST(ArbolWhile,"ASGN",strdup(Value_of_Identif));
						}else{
							yyerror("Error-Type: Not accept this type float(0.00).");
							return -1;
						}
						break;
					case 'b':
						if(havepoint==1){
							Find->value.float_value = $<TypesExp.numbf>3;
						}else{
							Find->value.float_value = $<TypesExp.numbf>3;
						}
						break;
				}
			}else{
			if(conditionres==1 && flagcondition ==1){
				Find = Find_Val(root,$1);
				tipo = Find->data_type;
				switch(tipo){
				case 'a':
					if(havepoint==1 | IsaINt==2){
						Find->value.numint = (int)$<TypesExp.numbf>3;
					}else{
						yyerror("Error-Type: Not accept this type float(0.00).");
						return -1;
					}
					break;
				case 'b':
					if(havepoint==1){
						Find->value.float_value = $<TypesExp.numbf>3;
					}else{
						Find->value.float_value = $<TypesExp.numbf>3;
					}
					break;
				}
			}
			if(conditionres==0 && flagcondition==0){
				Find = Find_Val(root,$1);
				tipo = Find->data_type;
				switch(tipo){
				case 'a':
					if(havepoint==1 | IsaINt==2){
						Find->value.numint = (int)$<TypesExp.numbf>3;
					}else{
						yyerror("Error-Type: Not accept this type float(0.00).");
						return -1;
					}
					break;
				case 'b':
					if(havepoint==1){
						Find->value.float_value = $<TypesExp.numbf>3;
					}else{
						Find->value.float_value = $<TypesExp.numbf>3;
					}
					break;
				}
			}
			}
			}
	;
//funcionamiento de las expresiones 
expression: INTNUM { havepoint = 1;$<TypesExp.numbf>$ = $1;}
           | NUMBER {
				havepoint = 0;
				$<TypesExp.numbf>$ = $1;
		   }
		   | IDENTIFIER{ Find = Find_Val(root,$1);
				tipo = Find->data_type;
				switch(tipo){
				case 'a':
					$<TypesExp.numbf>$ = (float)Find->value.numint;
					break;
				case 'b':
					$<TypesExp.numbf>$ = Find->value.float_value;
					break;
				}
		   }
		   | BOLEANVAL
           | expression PLUS expression { 
				if(havepoint==1){
					$<TypesExp.numbf>$ = $<TypesExp.numbf>1 + $<TypesExp.numbf>3;
				}else{
					$<TypesExp.numbf>$ = $<TypesExp.numbf>1 + $<TypesExp.numbf>3;
				}
			}
           | expression MINUS expression{
				if(havepoint == 1){
					$<TypesExp.numbf>$ = $<TypesExp.numbf>1 - $<TypesExp.numbf>3;
				}else{
					$<TypesExp.numbf>$ = $<TypesExp.numbf>1 - $<TypesExp.numbf>3;
				}
		   }
           | expression MULTIPLY expression{
				if(havepoint == 1){
					$<TypesExp.numbf>$ = $<TypesExp.numbf>1 * $<TypesExp.numbf>3;
				}else{
					$<TypesExp.numbf>$ = $<TypesExp.numbf>1 * $<TypesExp.numbf>3;
				}
		   }
           | expression DIVIDE expression{
				if(havepoint == 1){
					$<TypesExp.numbf>$ = $<TypesExp.numbf>1 / $<TypesExp.numbf>3;
				}else{
					$<TypesExp.numbf>$ = $<TypesExp.numbf>1 / $<TypesExp.numbf>3;
				}
		   }
           | expression EQUAL expression {if($<TypesExp.numbf>1 == $<TypesExp.numbf>3){
											if(acu == 0){
												setflagCondition(1);
												setacu(1);
											}else{
												if(flagcondition==1){
													setflagCondition(1);
													setacu(0);
												}else
												{
													setflagCondition(0);
												}
											}
										}else{
											
											if(acu == 0){				
												setflagCondition(0);
												setacu(1);
											}else{
												if(flagcondition==1){
													setflagCondition(0);
													setacu(1);
												}else
												{
													setflagCondition(0);
													setacu(1);
												}
											}} }
           | expression NOTEQUAL expression{if($<TypesExp.numbf>1 != $<TypesExp.numbf>3){
											setflagCondition(1);
										}else{setflagCondition(0);}}
           | expression LESS expression{if($<TypesExp.numbf>1 < $<TypesExp.numbf>3){
											setflagCondition(1);
										}else{setflagCondition(0);}}
           | expression GREATER expression{if($<TypesExp.numbf>1 > $<TypesExp.numbf>3){
											setflagCondition(1);
										}else{setflagCondition(0);}}
           | expression LESSEQUAL expression{if($<TypesExp.numbf>1 <= $<TypesExp.numbf>3){
											setflagCondition(1);
										}else{setflagCondition(0);}}
           | expression GREATEREQUAL expression{if($<TypesExp.numbf>1 >= $<TypesExp.numbf>3){
											setflagCondition(1);
										}else{setflagCondition(0);}}
           | LPAREN expression RPAREN{
				if(havepoint == 1){
					$<TypesExp.numbf>$ = $<TypesExp.numbf>2;
				}else{
					$<TypesExp.numbf>$ = $<TypesExp.numbf>2;
				}
		   }
           
           ;
			
//gestor de errores
%%
void yyerror(const char *s) {
    fprintf(stderr, "Syntax error at line %d: %s\n", yylineno, s);
}
//main
int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *file = fopen(argv[1], "r");
        if (!file) {
            fprintf(stderr, "Could not open %s\n", argv[1]);
            return 1;
        }
        yyin = file; // Set yyin to read from the opened file
    }
    yyparse(); // Call the lexer to start processing the input
    fclose(yyin); // Close the file when done
	
    return 0;
}