#include "ast.h"
#include <stdlib.h>
#include <assert.h>


/*funcao base pra alocacao do No*/
No* criar_no(TipoNo t, int linha) {
  No* no = calloc(1, sizeof(No));
  assert(no != NULL);
  no->tipo_no = t;
  no->linha = linha;
  return no;
}

No* no_programa(No* lista_comandos, int linha){

  No* n = criar_no(N_PROGRAMA, linha);
  n->a = lista_comandos;
  return n;
}

/*nos para valores*/
No* no_int(int valor, int linha){
  No* n = criar_no(N_INTEIRO, linha);
  n->ival = valor;

  return n;
}
No* no_real(float valor, int linha){
  No* n = criar_no(N_REAL, linha);
  n->fval = valor;

  return n;
}

/*no para variavel*/
No* no_var(char* nome, int linha){
  No* n = criar_no(N_VAR, linha);
  n->nome = nome;

  return n;
}


/*no para declaracao de variavel: int a; */
No* no_decl(Tipo tipo, char* nome, int linha){
  No* n = criar_no(N_DECL, linha);
  n->nome = nome;
  n->tipo = tipo;

  return n;
}


/*no para operacoes binarias como : a+b, a-b */
No* no_binop(OpBin op, No* esq, No* dir, int linha){
  No* n = criar_no(N_BINOP, linha);
  n->op = op;
  n->a = esq;
  n->b = dir;

  return n;
}


/* no para atribucao de variavel*/
No* no_atrib(char* nome, No* exp, int linha){
  No* n = criar_no(N_ATRIB, linha);
  n->nome = nome;
  n->a = exp;

  return n;
}

/* no para se(exp) {cmd} ou se(exp) {cmd} (senao {}) ou ()*/
No* no_se(No* condicao, No* entao, No* senao,  int linha){
  No* n = criar_no(N_SE, linha);
  n->a = condicao;
  n->b = entao;
  n->c = senao;
  return n;
}

/* no para switch(exp) {case exp : {} ... (padrao: {}) ou ()}*/
No* no_switch(No* condicao, No* lista_casos, No* caso_padrao, int linha){
  No* n = criar_no(N_SWITCH , linha);
  n->a = condicao;
  n->b = lista_casos;
  n->c = caso_padrao;
  return n;
}

/* no para caso exp : {cmd}, encadeado em lista pelo campo "prox"*/
No* no_caso(No* expressao, No* lista_comandos, int linha){
  No* n = criar_no(N_CASO, linha);
  n->a = expressao;
  n->b = lista_comandos;
  return n;
}


/* no para enquanto(exp) {cmd}*/
No* no_enquanto(No* condicao, No* lista_comandos, int linha){
  No* n = criar_no(N_ENQUANTO, linha);
  n->a = condicao;
  n->b = lista_comandos;
  return n;
}



/* no para faca {cmd} enquanto(exp)*/
No* no_faca(No* lista_comandos, No* condicao, int linha){
  No* n = criar_no(N_FACA, linha);
  n->a = lista_comandos;
  n->b = condicao;
  return n;
}

/* nos para pular; e terminar;*/
No* no_pular(int linha){
  return criar_no(N_PULAR, linha);
}

No* no_terminar(int linha){
  return criar_no(N_TERMINAR, linha);
}


No* lista_append(No* lista, No* comando){
  assert(lista != NULL);

  No* iterador = lista;

  while(iterador->prox) iterador = iterador->prox;

  iterador->prox = comando;

  return lista;
}
