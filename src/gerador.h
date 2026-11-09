/*
 * gerador de asm
 * transforma a AST direto em asm x86
 * por enquanto usamos uma maquina de pilha por simplicidade
 * ex:
 * a = a + 5 
 * seria:
 * push a
 * push 5
 * pop rcx
 * pop rax
 * add rcx, rax
 * push rax
 * pop a
 *
 * o asm vai ser compilado pelo gcc, entao ele usa formato at-t
 *  add rcx, rax -> rax = rax + rcx (finge que ta lendo manga)
 */

#ifndef GERADOR_H
#define GERADOR_H

#include "ast.h"
#include <stdio.h> // FILE
#include <stdlib.h>

/*
 * recebe o no raiz da ast e o arquivo de saida do compilador
 * escreve o asm do programa no arquivo de saida,
 */
 int ast_para_asm(No* raiz, FILE* out);

/*recebe uma intrucao assembly como se fosse um print
 * ex: add_inst("pushq $%d", 5);
 * saida : pushq $5
 * alem disso: adiciona \n e indentacoes pro asm
 *
 * */
void add_inst(const char* fmt, ...);

/* recebe um no que representa uma expresao e gera seu codigo*/
void gera_exp(No* no);

/* recebe um no que representa um comando e gera seu codigo*/
void gera_comando(No* no);

/*recebe uma lista de comandos e gera em sequencia*/
void gera_comandos(No*no);
/*
 * adiciona a operacao binaria referente no asm, sempre usa rcx e rax
 * considera que ambos ja estao nos regs, chamar apos os pops
 */
void gera_op(OpBin op);

/*
 * devolve um numero de rotulo novo a cada chamada (0, 1, 2, ...)
 * o rotulo no asm fica .L<numero>, ex: .L0, .L1
 * nao escreve nada na saida, so reserva o numero
 */
int gera_rotulo(void);

/*
 * escreve o rotulo na saida, ex: add_rotulo(3, "apos if")
 * saida: .L3: # apos if
 * o comentario serve so pra facilitar a leitura do asm
 */
void add_rotulo(int rotulo, const char* comentario);

/*
 * compara rax (esquerda) com rcx (direita) e deixa 1 ou 0 em rax
 * comp e a instrucao set do resultado: setl (<), setg (>), sete (==),
 * setne (!=), setle (<=), setge (>=)
 * igual o gera_op, chamar com os 2 valores ja nos regs
 */
void gera_comparacao(const char* comp);

/*
 * gera o codigo de uma condicao (se, enquanto, ...)
 * calcula a expressao e pula pro rotulo_jump se ela for falsa (== 0)
 * se for verdadeira continua na proxima instrucao
 */
void gera_cond(No* cond, int rotulo_jump);

#endif
