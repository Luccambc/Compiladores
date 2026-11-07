/* Sintatico - repeticao, condicional e expressoes                     */
/* Referencias:                                                         */
/*  - BNF do slide 8 (revisao LLC): programa, lista de comandos e      */
/*    atribuicao                                                        */
/*  - BNF do C (cs.wmich.edu/~gupta/...): if/else, while,              */
/*    break/continue,                                                   */
/*    bloco e niveis de expressao (igualdade, relacional, aditiva,     */
/*    multiplicativa, primaria)                                         */
/* Adaptacao: o se/senao fecha com fim, evitando a    			*/
/* ambiguidade do senao (dangling else)                                */
%{
#include <stdio.h>
int yylex(void);
void yyerror(const char *s);
%}
%token ID NUMERO ENQUANTO TERMINAR PULAR SE SENAO FIM IGUAL DIFERENTE MENOR_IGUAL MAIOR_IGUAL

%%
input:	/* empty */
	| input line
;
line:	'\n'
	| programa '\n'		{ printf("O programa esta sintaticamente correto\n"); }
;
programa:	'{' lista_cmds '}'
;
lista_cmds:	cmd
		| cmd ';' lista_cmds
;
cmd:	ID '=' exp
	| condicional
	| repeticao
	| '{' lista_cmds '}'		/* bloco */
;
condicional:	SE '(' exp ')' lista_cmds FIM				/* if */
		| SE '(' exp ')' lista_cmds SENAO lista_cmds FIM	/* if-else */
;
repeticao:	ENQUANTO '(' exp ')' cmd	/* while */
		| TERMINAR			/* break */
		| PULAR				/* continue */
;
exp:	exp IGUAL comparacao
	| exp DIFERENTE comparacao
	| comparacao
;
comparacao:	comparacao '<' soma_sub
		| comparacao '>' soma_sub
		| comparacao MENOR_IGUAL soma_sub
		| comparacao MAIOR_IGUAL soma_sub
		| soma_sub
;
soma_sub:	soma_sub '+' termo
		| soma_sub '-' termo
		| termo
;
termo:	termo '*' fator
	| termo '/' fator
	| fator
;
fator:	ID
	| NUMERO
	| '(' exp ')'
;
%%
int main(void)
{
	printf("Informe um programa para verificar a sintaxe\n");
	return yyparse();
}
void yyerror(const char *s)
{
	printf("Problema com a analise sintatica\n");
}
