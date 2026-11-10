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

/* no para print(exp);*/
No* no_print(No* exp, int linha){
  No* n = criar_no(N_PRINT, linha);
  n->a = exp;
  return n;
}


No* lista_append(No* lista, No* comando){
  assert(lista != NULL);

  No* iterador = lista;

  while(iterador->prox) iterador = iterador->prox;

  iterador->prox = comando;

  return lista;
}



static const char* nome_op(OpBin op){
  switch(op){
    case OP_SOMA:        return "+";
    case OP_SUB:         return "-";
    case OP_MUL:         return "*";
    case OP_DIV:         return "/";
    case OP_MENOR:       return "<";
    case OP_MAIOR:       return ">";
    case OP_IGUAL:       return "==";
    case OP_DIFERENTE:   return "!=";
    case OP_MENOR_IGUAL: return "<=";
    case OP_MAIOR_IGUAL: return ">=";
  }
  return "?";
}

/* imprime um no e seus filhos; "nome" e o rotulo opcional do no no pai (ex: cond) */
static void imprimir_no(No* no, const char* pre, const char* nome, int ultimo){
  if(no == NULL) return;

  printf("%s%s", pre, ultimo ? "└── " : "├── ");

  if(nome) printf("%s: ", nome);

  char p[1024];
  snprintf(p, sizeof(p), "%s%s", pre, ultimo ? "    " : "│   "); //prefixo do no filho

  switch(no->tipo_no){
    case  N_INTEIRO:
      printf("Inteiro %d\n", no->ival);
      break;
    case  N_REAL:
      printf("Real %f\n", no->fval);
      break;
    case  N_VAR:
      printf("Var %s\n", no->nome);
      break;
    case  N_DECL:
      printf("Decl %s %s\n", nome_do_tipo(no->tipo), no->nome);
      break;
    case  N_BINOP:
      printf("BinOp %s\n", nome_op(no->op));
      imprimir_no(no->a, p, NULL, 0);
      imprimir_no(no->b, p, NULL, 1);
      break;
    case  N_ATRIB:
      printf("Atrib %s\n", no->nome);
      imprimir_no(no->a, p, NULL, 1);
      break;

    case  N_SE:
      printf("Se\n");
      imprimir_no(no->a, p, "cond", 0);
      imprimir_lista_ast(no->b, p, "entao", no->c == NULL);
      if(no->c) imprimir_lista_ast(no->c, p, "senao", 1);
      break;
    case  N_SWITCH:
      printf("Switch\n");
      imprimir_no(no->a, p, "cond", 0);
      imprimir_lista_ast(no->b, p, "casos", no->c == NULL);
      if(no->c) imprimir_lista_ast(no->c, p, "padrao", 1);
      break;
    case  N_CASO:
      printf("Caso\n");
      imprimir_no(no->a, p, "valor", 0);
      imprimir_lista_ast(no->b, p, "comandos", 1);
      break;
    case  N_ENQUANTO:
      printf("Enquanto\n");
      imprimir_no(no->a, p, "cond", 0);
      imprimir_lista_ast(no->b, p, "comandos", 1);
      break;
    case  N_FACA:
      printf("Faca\n");
      imprimir_lista_ast(no->a, p, "comandos", 0);
      imprimir_no(no->b, p, "cond", 1);
      break;
    case  N_PULAR:
      printf("Pular\n");
      break;
    case  N_TERMINAR:
      printf("Terminar\n");
      break;
    case  N_PRINT:
      printf("Print\n");
      imprimir_no(no->a, p, NULL, 1);
      break;
    default:
      printf("No Nao Implementado\n");
      break;
  }
}

void imprimir_ast(No* no){
  assert(no->tipo_no == N_PROGRAMA);

  printf("Programa\n");
  imprimir_lista_ast(no->a, "", "comandos", 1);
}

void imprimir_lista_ast(No* lista, const char* pre, const char* nome, int ultimo){
  printf("%s%s%s:\n", pre, ultimo ? "└── " : "├── ", nome);
  char p[1024];
  snprintf(p, sizeof p, "%s%s", pre, ultimo ? "    " : "│   ");

  for (No *c = lista; c; c = c->prox) imprimir_no(c, p, NULL, c->prox == NULL);
}
