/* Verificando a sintaxe de programas segundo nossa GLC-exemplo */
/* na verdade, uma parte dela */
%{
#include <stdio.h>
#include <stdlib.h>
int yylex(void);
void yyerror(const char* s);

%}


%union{
 char* text;
 float num;

}

%token <text> ID
%token <num> NUMERO
%token TERMINAR
%token ENQUANTO
%token PULAR 
%token SE
%token SENAO 
%token FIM
%token CASO
%token SWITCH




%left '<' '>'
%left '+' '-'
%left '*' '/'


%%
/* Regras definindo a GLC e acoes correspondentes */
/* neste nosso exemplo quase todas as acoes estao vazias */

programa:	'{' lista_cmds '}'	{printf("programa analiseido\n"); YYACCEPT;}
;
lista_cmds:	cmd			{;}
		| cmd  lista_cmds	{;}
;
cmd:		ID '=' exp ';'	|
        ENQUANTO '('exp')' '{' lista_cmds '}' |
        SE   '('exp')' '{' lista_cmds '}'|
        SE   '('exp')' '{' lista_cmds '}' SENAO '{' lista_cmds '}' |
        FIM |
        PULAR |
        TERMINAR |
        SWITCH '(' ID ')' ':'  '{' lista_casos '}'
{;}
;
lista_casos : caso |
              caso lista_casos
{;}
;

caso: CASO exp ':' '{' lista_cmds '}' 
        
{;}
;

exp:	ID			    |
      NUMERO      |
      exp '+' exp |
      exp '-' exp |
      exp '*' exp |
      exp '/' exp |
      exp '<' exp |
      exp '>' exp |
      '(' exp ')'
{;}
;
%%
int main (void) 
{
	printf("Informe um programa para eu verificar a sintaxe\n");
	yyparse ();
  return 0;
}
void yyerror (const char* s) /* Called by yyparse on error */
{
	printf ("Problema com a analise sintatica! %s\n", s);
}


