
// Testar se funciona corretamente o empilhamento de par�metros
// passados por valor ou por refer�ncia.


%{
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include "compilador.h"

int numVars;
char dados[256];
%}

%token PROGRAM ABRE_PARENTESES FECHA_PARENTESES 
%token VIRGULA PONTO_E_VIRGULA DOIS_PONTOS PONTO
%token T_BEGIN T_END VAR IDENT ATRIBUICAO

%token MAIS MENOS MULT DIV ABRE_COLCHETES FECHA_COLCHETES LABEL
%token TYPE ARRAY OF GOTO IF THEN ELSE WHILE DO OR
%token AND NOT IGUAL MAIOR MENOR NUMERO

%%
/* -------------------------------------------------------------------
 *  PROGRAM
 * ------------------------------------------------------------------- */
programa    :{ 
             geraCodigo (NULL, "INPP");
             }
             PROGRAM IDENT 
             ABRE_PARENTESES lista_idents FECHA_PARENTESES PONTO_E_VIRGULA
             bloco PONTO {
			 sprintf ( dados, "DMEM %d", numVars); geraCodigo(NULL, dados);
             geraCodigo (NULL, "PARA");
             }
;

/* -------------------------------------------------------------------
 *  DECLARACAO DE VARIAVEIS
 * ------------------------------------------------------------------- */
bloco       : 
              parte_declara_vars
              { 
              }

              comando_composto 
              ;

parte_declara_vars: parte_declara_vars PONTO_E_VIRGULA declara_vars
 			| 		VAR {numVars = 0;} declara_vars { sprintf ( dados, "AMEM %d", numVars); geraCodigo(NULL, dados);  }
;

declara_vars: declara_vars declara_var 
            | declara_var 
;

declara_var : { }
              lista_id_var DOIS_PONTOS 
              tipo 
              { /* AMEM */

	          }
              PONTO_E_VIRGULA
;

tipo        : IDENT
;

lista_id_var: lista_id_var VIRGULA var_id
            | var_id
;

lista_idents: lista_idents VIRGULA IDENT  
            | IDENT
;

var_id: IDENT
			{ /* insere vars na tabela de s�mbolos */
				if (!buscaTS(token, 0, 0)){
					empilhaTS( token, "integer", "VS", 0, 0);
					numVars++;		
				}
				else{
					printf("A v�riavel %s j� foi declarada\n", token);
			 		exit(1);
				}
			}

;



;

/* -------------------------------------------------------------------
 *  COMANDOS
 * ------------------------------------------------------------------- */
comando_composto: {printf("aquiii\n");} T_BEGIN  comandos T_END 
;

comandos:
		 comando_sem_rotulo comandos
		| comando_composto
		| 
;

comando_sem_rotulo: atribuicao PONTO_E_VIRGULA
//					| chamada_de_procedimento
//					| desvio
//					| comando_composto
//					| comando_condicional
					| comando_repetitivo comandos  
					
;

atribuicao: variavel ATRIBUICAO expressao_simples { 
													//noAux = busca_simb_TS(token); 
													sprintf(dados, "ARMZ %d,%d",noAux->nivelLexico, noAux->deslocamento);
													geraCodigo(NULL, dados);
												  }
;

//chamada_de_procedimento:;
//desvio:;
//comando_condicional:;
comando_repetitivo: WHILE expressao DO comando_composto
;

//rotulo: numero DOIS_PONTOS
//;

variavel: IDENT {
					if (!buscaTS(token, 0, 0)){
						printf("A variavel %s nao foi declarada\n", token);
					}
				}
/* -------------------------------------------------------------------
 *  EXPRESSOES
 * ------------------------------------------------------------------- */
expressao:	//expressao_simples {printf("sss3\n");}
		  expressao_simples  relacao expressao_simples
;

expressao_simples:	  expressao_simples MAIS termo  { geraCodigo(NULL, "SOMA"); }
					| expressao_simples MENOS termo { geraCodigo(NULL, "SUBT"); }
					| expressao_simples OR termo    { geraCodigo(NULL, "DISJ"); }
					| termo

;

termo:  termo MULT fator { geraCodigo(NULL, "MULT"); }
	|	termo AND fator  { geraCodigo(NULL, "CONJ"); }
	|	termo DIV fator  { geraCodigo(NULL, "DIVI"); }
	|	fator
;

fator:	variavel { geraCodigo(NULL, "CRVL 0,0");}
	|	numero
	|	ABRE_PARENTESES expressao_simples FECHA_PARENTESES
;

relacao:  MAIOR 
		| MENOR
		| MENOR MAIOR
		| MAIOR IGUAL
		| MENOR IGUAL
		| IGUAL
;

numero: NUMERO { sprintf(dados, "CRCT %s",token); geraCodigo(NULL, dados);}
;

%%

main (int argc, char** argv) {
	FILE* fp;
	extern FILE* yyin;

	if (argc<2 || argc>2) {
		printf("usage compilador <arq>a %d\n", argc);
		return(-1);
	}

	fp=fopen (argv[1], "r");
	if (fp == NULL) {
		printf("usage compilador <arq>b\n");
		return(-1);
	}


/* -------------------------------------------------------------------
 *  Inicia a Tabela de S�mbolos
 * ------------------------------------------------------------------- */
	iniciaTS();
	yyin=fp;
	yyparse();

	return 0;
}

