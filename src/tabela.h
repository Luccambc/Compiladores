/* Tabela de simbolos da Esdruxula                                     */
/* Guarda cada variavel declarada, com o seu tipo e a linha            */
/* da declaracao. Ha um unico escopo (global).                         */
#ifndef TABELA_H
#define TABELA_H

#include <stdio.h>

typedef enum {
	TIPO_INDEFINIDO,	/* ainda nao sabemos (a tipagem vai preencher) */
	TIPO_INTEIRO,
	TIPO_REAL
} Tipo;

typedef struct {
	char *nome;
	Tipo  tipo;
	int   linha;		/* linha da declaracao */
} Simbolo;

/* Guarda a variavel, se ela ainda nao estiver na tabela.
   Devolve o simbolo (o novo ou o que ja existia). */
Simbolo *inserir(const char *nome, Tipo tipo, int linha);

/* Procura a variavel. Devolve o simbolo, ou NULL se ela nao existir. */
Simbolo *buscar(const char *nome);

/* Escreve a tabela inteira no arquivo (por exemplo, a saida com -v). */
void imprimir_tabela(FILE *saida);

/* Chama a funcao 'acao' uma vez para cada variavel da tabela,
   na ordem em que foram inseridas (util para a geracao de codigo). */
void percorrer_tabela(void (*acao)(Simbolo *s));

/* Nome do tipo em texto: "int", "float" ou "indefinido". */
const char *nome_do_tipo(Tipo tipo);

#endif
