/* Analisador Sintatico - Esdruxula (versao final da dupla)            */
/* Referencia: BNF do C (cs.wmich.edu/~gupta/...)                       */
/*  - <compound-statement>  : bloco entre chaves                        */
/*  - <selection-statement> : se / se-senao / switch                   */
/*  - <labeled-statement>   : caso / padrao                             */
/*  - <iteration-statement> : enquanto / faca-enquanto                  */
/*  - <jump-statement>      : terminar (break) / pular (continue)       */
/*  - expressoes: precedencia e associatividade por %left / %nonassoc   */
/*  - <declaration>         : int / float, obrigatoria antes do uso     */
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tabela.h"
#include "ast.h"
int yylex(void);
void yyerror(const char* s);

/* raiz da AST, preenchida quando o parser reconhece o programa */
No* raiz = NULL;

extern FILE *yyin;
extern FILE *yyout;
extern int yylineno;
extern int erros_lexicos;

/* 1 quando o programa roda com -v: escreve o trace no arquivo de saida */
int verbose = 0;
int erros_sintaticos = 0;

int erros_semanticos = 0;

/* profundidade de lacos e switches abertos:
   pular (continue) so vale dentro de enquanto ou faca,
   terminar (break) vale dentro de laco ou switch */
int prof_laco = 0;
int prof_switch = 0;

static void erro_semantico(const char *msg)
{
	erros_semanticos++;
	fprintf(yyout, "Erro semantico (linha %d): %s\n", yylineno, msg);
}

/* tabela de simbolos: toda variavel precisa ser declarada antes do uso */
static void declarar(Tipo tipo, const char *nome)
{
	Simbolo *s = buscar(nome);
	if (s) {
		char msg[160];
		snprintf(msg, sizeof msg, "variavel '%s' ja declarada na linha %d", nome, s->linha);
		erro_semantico(msg);
		return;
	}
	inserir(nome, tipo, yylineno);
	if (verbose)
		fprintf(yyout, "[decl] linha %3d: %s %s\n", yylineno, nome_do_tipo(tipo), nome);
}

static void verificar_uso(const char *nome)
{
	if (!buscar(nome)) {
		char msg[128];
		snprintf(msg, sizeof msg, "variavel '%s' nao declarada", nome);
		erro_semantico(msg);
	}
}
%}

/* o tipo Tipo vem da tabela de simbolos e e usado no %union */
%code requires {
  #include "tabela.h"
  #include "ast.h"
}

%define parse.error detailed

%union{
 char* text;
 int ival;
 float fval;
 Tipo tipo;
 No* no;
}

%token <text> ID
%token <ival> INTEIRO
%token <fval> REAL

%token ENQUANTO FACA
%token PULAR TERMINAR
%token SE SENAO
%token IGUAL DIFERENTE MENOR_IGUAL MAIOR_IGUAL
%token SWITCH CASO PADRAO
%token TIPO_INT TIPO_FLOAT

%nonassoc '<' '>' IGUAL DIFERENTE MENOR_IGUAL MAIOR_IGUAL
%left '+' '-'
%left '*' '/'

%type <tipo> tipo

%type <no> programa lista_cmds cmd switch_inicio lista_casos caso caso_padrao exp bloco

%%
/* Um arquivo contem um unico programa */
programa:	bloco { raiz = $$ = no_programa($1,@1.first_line);}
;

bloco: '{' lista_cmds '}' {$$ = $2;}
;

lista_cmds:	cmd {$$ = $1; }
		| lista_cmds cmd {$$ = lista_append($1,$2);}
;

/* acoes no meio da regra tambem contam na numeracao dos $n */
cmd:		tipo ID ';'	{ declarar($1, $2); $$ = no_decl($1,$2,@1.first_line);}		/* declaracao */
        | ID '=' exp ';'	{ verificar_uso($1); $$ = no_atrib($1,$3,@1.first_line);}		/* atribuicao */
        | ENQUANTO '(' exp ')' { prof_laco++; } bloco { prof_laco--; $$ = no_enquanto($3,$6,@1.first_line);}
        /* faca-enquanto: o "do-while" do C ("faca" = "faça", sem cedilha) */
        | FACA { prof_laco++; } bloco { prof_laco--; } ENQUANTO '(' exp ')' ';' { $$ = no_faca($3,$7,@1.first_line);}
        | SE '(' exp ')' bloco  { $$ = no_se($3,$5,NULL, @1.first_line);}

        | SE '(' exp ')' bloco SENAO bloco { $$ = no_se($3,$5,$7, @1.first_line);}

        | PULAR ';'     { if (prof_laco == 0)
                            erro_semantico("'pular' fora de um laco");
                          $$ = no_pular(@1.first_line); }
        | TERMINAR ';'  { if (prof_laco == 0 && prof_switch == 0)
                            erro_semantico("'terminar' fora de um laco ou 'switch'");
                          $$ = no_terminar(@1.first_line); }
        | switch_inicio lista_casos '}' { prof_switch--; $$ = no_switch($1,$2,NULL,@1.first_line);}
        | switch_inicio lista_casos caso_padrao '}' { prof_switch--; $$ = no_switch($1,$2,$3,@1.first_line);}
;
tipo:     TIPO_INT        { $$ = TIPO_INTEIRO; }
        | TIPO_FLOAT      { $$ = TIPO_REAL; }
;

/* regra propria (em vez de acao no meio) para as duas formas de switch
   compartilharem o inicio sem conflito; devolve a variavel da condicao */
switch_inicio: SWITCH '(' ID ')' ':' '{' { verificar_uso($3); prof_switch++; $$ = no_var($3,@3.first_line);}
;

lista_casos : caso {$$ = $1;}
            | lista_casos caso {$$ = lista_append($1,$2);}
;

caso: CASO exp ':' bloco {$$ = no_caso($2,$4,@1.first_line);}
;

caso_padrao: PADRAO ':' bloco {$$ = $3;}
;

/* a linha de uma operacao binaria e a do operador */
exp:	ID		{ verificar_uso($1); $$ = no_var($1,@1.first_line);}
      | INTEIRO		{ $$ = no_int($1,@1.first_line);}
      | REAL		{ $$ = no_real($1,@1.first_line);}
      | exp '+' exp		{ $$ = no_binop(OP_SOMA,$1,$3,@2.first_line);}
      | exp '-' exp		{ $$ = no_binop(OP_SUB,$1,$3,@2.first_line);}
      | exp '*' exp		{ $$ = no_binop(OP_MUL,$1,$3,@2.first_line);}
      | exp '/' exp		{ $$ = no_binop(OP_DIV,$1,$3,@2.first_line);}
      | exp '<' exp		{ $$ = no_binop(OP_MENOR,$1,$3,@2.first_line);}
      | exp '>' exp		{ $$ = no_binop(OP_MAIOR,$1,$3,@2.first_line);}
      | exp IGUAL exp		{ $$ = no_binop(OP_IGUAL,$1,$3,@2.first_line);}
      | exp DIFERENTE exp	{ $$ = no_binop(OP_DIFERENTE,$1,$3,@2.first_line);}
      | exp MENOR_IGUAL exp	{ $$ = no_binop(OP_MENOR_IGUAL,$1,$3,@2.first_line);}
      | exp MAIOR_IGUAL exp	{ $$ = no_binop(OP_MAIOR_IGUAL,$1,$3,@2.first_line);}
      | '(' exp ')'		{ $$ = $2;}
;
%%
static void uso(const char *prog)
{
	fprintf(stderr, "Uso: %s [-v] <entrada> <saida>\n", prog);
	fprintf(stderr, "  -v  escreve no arquivo de saida cada token lido\n");
}

int main (int argc, char **argv)
{
	const char *entrada = NULL, *saida = NULL;

	for (int i = 1; i < argc; i++) {
		if (strcmp(argv[i], "-v") == 0)
			verbose = 1;
		else if (!entrada)
			entrada = argv[i];
		else if (!saida)
			saida = argv[i];
		else {
			uso(argv[0]);
			return 1;
		}
	}
	if (!entrada || !saida) {
		uso(argv[0]);
		return 1;
	}

	printf("Lendo entrada: %s\n", entrada);
	yyin = fopen(entrada, "r");
	if (!yyin) {
		perror(entrada);
		return 1;
	}

	printf("Criando saida: %s%s\n", saida, verbose ? " (com trace)" : "");
	yyout = fopen(saida, "w");
	if (!yyout) {
		perror(saida);
		fclose(yyin);
		return 1;
	}

	printf("Analise lexica e sintatica...\n");
	int resultado = yyparse();
	int ok = (resultado == 0 && erros_lexicos == 0 && erros_semanticos == 0);

	if (verbose)
		imprimir_tabela(yyout);

	if (ok)
		fprintf(yyout, "programa analisado com sucesso\n");
	else
		fprintf(yyout, "programa com erros\n");

	fclose(yyin);
	fclose(yyout);

	printf("  linhas lidas:     %d\n", yylineno);
	printf("  erros lexicos:    %d\n", erros_lexicos);
	printf("  erros sintaticos: %d\n", erros_sintaticos);
	printf("  erros semanticos: %d\n", erros_semanticos);
	printf("%s. Resultado escrito em %s\n", ok ? "Sucesso" : "Falhou", saida);
	return ok ? 0 : 1;
}
void yyerror (const char* s) /* Called by yyparse on error */
{
	erros_sintaticos++;
	fprintf(yyout, "Erro sintatico (linha %d): %s\n", yylineno, s);
}
