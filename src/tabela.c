/* Tabela de simbolos da Esdruxula: implementacao                      */
/* Usa um vetor simples. A busca percorre o vetor do inicio ao fim.    */
#include <stdlib.h>
#include <string.h>
#include "tabela.h"

#define MAX_SIMBOLOS 1000

static Simbolo tabela[MAX_SIMBOLOS];
static int total = 0;

Simbolo *buscar(const char *nome)
{
	for (int i = 0; i < total; i++)
		if (strcmp(tabela[i].nome, nome) == 0)
			return &tabela[i];
	return NULL;
}

Simbolo *inserir(const char *nome, Tipo tipo, int linha)
{
	Simbolo *existente = buscar(nome);
	if (existente)
		return existente;

	if (total == MAX_SIMBOLOS) {
		fprintf(stderr, "Tabela de simbolos cheia (%d variaveis)\n", MAX_SIMBOLOS);
		exit(1);
	}
	tabela[total].nome  = strdup(nome);
	tabela[total].tipo  = tipo;
	tabela[total].linha = linha;
	return &tabela[total++];
}

const char *nome_do_tipo(Tipo tipo)
{
	switch (tipo) {
	case TIPO_INTEIRO: return "int";
	case TIPO_REAL:    return "float";
	default:           return "indefinido";
	}
}

void imprimir_tabela(FILE *saida)
{
	fprintf(saida, "Tabela de simbolos (%d variaveis):\n", total);
	for (int i = 0; i < total; i++)
		fprintf(saida, "  %-32s %-10s linha %d\n",
		        tabela[i].nome, nome_do_tipo(tabela[i].tipo), tabela[i].linha);
}

void percorrer_tabela(void (*acao)(Simbolo *s))
{
	for (int i = 0; i < total; i++)
		acao(&tabela[i]);
}
