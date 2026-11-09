#!/bin/bash
# Teste do gerador de codigo:
#  1. compila tests/gerador/programa.txt com -asm
#  2. compara o asm gerado com tests/gerador/esperado.s (tem que ser identico)
#  3. monta o asm com "gcc -c" pra conferir que e asm valido
#     (so monta, nao liga: as variaveis v_* ainda nao tem espaco reservado)
# Nao compila o compilador: use "make test-gerador", ou rode "make" antes.
RAIZ=$(cd "$(dirname "$0")" && pwd)
COMP="$RAIZ/build/comp"
DIR_TESTE="$RAIZ/tests/gerador"
if [ ! -x "$COMP" ]; then
  echo "Erro: $COMP nao encontrado. Rode \"make\" antes." >&2
  exit 1
fi
TMP=$(mktemp -d)
falhou=0

if ! "$COMP" -asm "$TMP/saida.s" "$DIR_TESTE/programa.txt" "$TMP/saida.txt" > /dev/null; then
  echo "FALHOU gerador: o compilador rejeitou o programa"
  cat "$TMP/saida.txt"
  rm -rf "$TMP"
  exit 1
fi

if diff -u "$DIR_TESTE/esperado.s" "$TMP/saida.s" > "$TMP/diff.txt"; then
  echo "PASSOU gerador: asm igual ao esperado"
else
  echo "FALHOU gerador: asm diferente do esperado (- esperado, + gerado)"
  sed 's/^/    /' "$TMP/diff.txt"
  falhou=1
fi

if gcc -c "$TMP/saida.s" -o "$TMP/saida.o" 2> "$TMP/gcc.txt"; then
  echo "PASSOU gerador: gcc monta o asm sem erro"
else
  echo "FALHOU gerador: gcc nao conseguiu montar o asm"
  sed 's/^/    /' "$TMP/gcc.txt"
  falhou=1
fi

rm -rf "$TMP"
[ "$falhou" -eq 0 ]
