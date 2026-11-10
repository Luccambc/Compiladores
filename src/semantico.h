/*
 *  aanalise semantica: verificacao de tipos (type check)
 *  Percorre a AST depois do parser, preenche o campo "tipo" das
 *  expressoes e acusa os erros de tipo.
 */
#ifndef SEMANTICO_H
#define SEMANTICO_H

#include "ast.h"

/* recebe a raiz da AST (um N_PROGRAMA) e verifica o programa inteiro */
void verificar_tipos(No* raiz);

#endif
