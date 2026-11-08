/*
 *  define estruturas e funcoes para criar a AST a partir do parser
 *  Representacao intermediaria usada para verificacao semantica, verificacoa de tipo e geracao de codigo
*/
#ifndef AST_H
#define AST_H

#include "tabela.h" //declaracao do Tipo


// #############################
//  structs  
// #############################


typedef enum {
  N_PROGRAMA,   /* lista de comandos */
  N_INTEIRO,    /* ival */
  N_REAL,       /* fval */
  N_VAR,        /* nome da varivavel*/
  N_BINOP,      /* operacao, a = esquerda, b = direita */
  N_ATRIB,      /* variavel, a = expressao*/
  N_SE,         /* a = condicao, b = entao, c = senao (NULL caso seja so um se)*/
  N_SWITCH,     /* a = condicao, b = lista de cases, c = caso padrao (NULL caso nao tenha)*/
  N_ENQUANTO,   /* a = condicao, b = lista de comandos*/
  N_FACA,       /* a = lista de comandos, b = condicao*/

} TipoNo;


typedef struct No {
  TipoNo tipo_no;    /* contem o tipo do no atual*/
    union {     /*cada No so vai ter uma das opcoes, usamos union anonima pra poupar espaco */
    int ival;   /* caso o no contenha um valor inteiro*/
    float fval; /* caso o no contenha um valor real*/
    char* nome; /* caso o no seja uma variavel (pegamos o tipo na tabela de simbolos)*/
    int op;    /* codigo da operacao binaria*/
    };
  int linha; /* linha do codigo, para mensagens de erro*/
 
  
  struct No *a,*b,*c; /*nos filhos*/

  struct No *prox;/*proximo no caso seja uma lista */

  Tipo tipo; /* tipo da operacao, parte da analise semantica*/
} No;

// #############################
//  funcoes 
// #############################

/*funcao base pra alocacao do No*/
No* criar_no(TipoNo t, int linha);

/*no raiz da ast */
No* no_programa(No* lista_comandos, int linha);

/*nos para valores*/
No* no_int(int valor, int linha);
No* no_real(float valor, int linha);

/*no para variavel*/
No* no_var(char* nome, int linha);

/*no para operacoes binarias como : a+b, a-b */
No* no_binop(int op, No* esq, No* dir, int linha);

/* no para atribucao de variavel*/
No* no_atrib(char* nome, No* exp, int linha);

/* no para se(exp) {cmd} ou se(exp) {cmd} (senao {}) ou ()*/
No* no_se(No* condicao, No* entao, No* senao,  int linha);

/* no para switch(exp) {case exp : {} ... (padrao: {}) ou ()}*/
No* no_switch(No* condicao, No* lista_casos, No* caso_padrao, int linha);

/* no para enquanto(exp) {cmd}*/
No* no_enquanto(No* condicao, No* lista_comandos, int linha);

/* no para faca {cmd} enquanto(exp)*/
No* no_faca(No* lista_comandos, No* condicao, int linha);

#endif
