/*
 *  Analise semantica - type check
 *
 *  Regras (seguindo o C):
 *   - INTEIRO e int, REAL e float, uma variavel tem o tipo da declaracao
 *   - int com int da int, qualquer conta com float da float
 *   - comparacoes (<, >, ==, !=, <=, >=) dao int
 *   - float recebendo int e aceito (o inteiro vira real)
 *   - int recebendo float e erro (a parte decimal seria perdida)
 *   - no switch, a variavel e os valores dos casos precisam ser int
 *   - divisao por zero constante (a / 0, a / 0.0) e erro
 */
#include <stdio.h>
#include "semantico.h"
#include "tabela.h"

/* contador e arquivo de saida definidos no sintatico.y */
extern int erros_semanticos;
extern FILE *yyout;

static void erro_tipo(int linha, const char *msg)
{
	erros_semanticos++;
	fprintf(yyout, "Erro semantico (linha %d): %s\n", linha, msg);
}

/* 1 se o no for o numero zero escrito no programa (0 ou 0.0) */
static int eh_zero_constante(No* e)
{
	return e && ((e->tipo_no == N_INTEIRO && e->ival == 0) ||
	             (e->tipo_no == N_REAL && e->fval == 0.0f));
}

static int eh_comparacao(OpBin op)
{
	return op == OP_MENOR || op == OP_MAIOR || op == OP_IGUAL ||
	       op == OP_DIFERENTE || op == OP_MENOR_IGUAL || op == OP_MAIOR_IGUAL;
}

/* calcula o tipo de uma expressao, guarda no no e devolve */
static Tipo tipo_exp(No* e)
{
	if (e == NULL)
		return TIPO_INDEFINIDO;

	Tipo t = TIPO_INDEFINIDO;
	switch (e->tipo_no) {
	case N_INTEIRO:
		t = TIPO_INTEIRO;
		break;
	case N_REAL:
		t = TIPO_REAL;
		break;
	case N_VAR: {
		/* variavel nao declarada ja foi acusada pelo parser */
		Simbolo *s = buscar(e->nome);
		t = s ? s->tipo : TIPO_INDEFINIDO;
		break;
	}
	case N_BINOP: {
		Tipo ta = tipo_exp(e->a);
		Tipo tb = tipo_exp(e->b);
		if (e->op == OP_DIV && eh_zero_constante(e->b))
			erro_tipo(e->linha, "divisao por zero");
		if (ta == TIPO_INDEFINIDO || tb == TIPO_INDEFINIDO)
			t = TIPO_INDEFINIDO;	/* evita erros em cascata */
		else if (eh_comparacao(e->op))
			t = TIPO_INTEIRO;
		else if (ta == TIPO_REAL || tb == TIPO_REAL)
			t = TIPO_REAL;
		else
			t = TIPO_INTEIRO;
		break;
	}
	default:
		break;
	}
	e->tipo = t;
	return t;
}

static void verificar_lista(No* lista);

static void verificar_cmd(No* c)
{
	char msg[200];

	switch (c->tipo_no) {
	case N_ATRIB: {
		Tipo te = tipo_exp(c->a);
		Simbolo *s = buscar(c->nome);
		if (s && s->tipo == TIPO_INTEIRO && te == TIPO_REAL) {
			snprintf(msg, sizeof msg,
			         "atribuicao de valor float a variavel int '%s' (a parte decimal seria perdida)",
			         c->nome);
			erro_tipo(c->linha, msg);
		}
		c->tipo = s ? s->tipo : TIPO_INDEFINIDO;
		break;
	}
	case N_SE:
		tipo_exp(c->a);
		verificar_lista(c->b);
		verificar_lista(c->c);
		break;
	case N_ENQUANTO:
		tipo_exp(c->a);
		verificar_lista(c->b);
		break;
	case N_FACA:
		verificar_lista(c->a);
		tipo_exp(c->b);
		break;
	case N_SWITCH:
		if (tipo_exp(c->a) == TIPO_REAL) {
			snprintf(msg, sizeof msg, "variavel do switch '%s' precisa ser int", c->a->nome);
			erro_tipo(c->linha, msg);
		}
		for (No *caso = c->b; caso; caso = caso->prox) {
			if (tipo_exp(caso->a) == TIPO_REAL)
				erro_tipo(caso->linha, "valor do caso precisa ser int");
			verificar_lista(caso->b);
		}
		verificar_lista(c->c);	/* padrao */
		break;
	default:
		/* N_DECL, N_PULAR e N_TERMINAR nao tem expressoes */
		break;
	}
}

static void verificar_lista(No* lista)
{
	for (No *c = lista; c; c = c->prox)
		verificar_cmd(c);
}

void verificar_tipos(No* raiz)
{
	if (raiz == NULL)
		return;
	verificar_lista(raiz->a);
}
