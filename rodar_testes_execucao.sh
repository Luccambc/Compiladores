#!/bin/bash
# Testes de execucao: para cada caso do arquivo,
#  1. compila o programa com -asm
#  2. monta e liga o asm com gcc
#  3. roda o executavel e compara o que ele escreveu com a saida esperada
# Mostra a saida esperada e a obtida de cada teste.
# Nao compila o compilador: use "make test", ou rode "make" antes.
# Uso: ./rodar_testes_execucao.sh [arquivo]   (padrao: tests/execucao.txt)
# Formato do arquivo:
#   ### descricao
#   { programa }
#   >>> saida
#   uma linha por print
RAIZ=$(cd "$(dirname "$0")" && pwd)
COMP="$RAIZ/build/comp"
ARQ=${1:-$RAIZ/tests/execucao.txt}
LIMITE=5   # segundos ate considerar que o programa travou
if [ ! -x "$COMP" ]; then
  echo "Erro: $COMP nao encontrado. Rode \"make\" antes." >&2
  exit 1
fi

DIR=$(mktemp -d)
# separa cada caso em: descricaoNNN, casoNNN.txt (programa), esperadoNNN.txt
awk -v dir="$DIR" '
  /^### /        { n++; parte = "prog"; sub(/^### /, "");
                   print > (dir sprintf("/descricao%03d", n));
                   printf "" > (dir sprintf("/caso%03d.txt", n));
                   printf "" > (dir sprintf("/esperado%03d.txt", n)); next }
  /^>>> saida/   { parte = "saida"; next }
  /^#/           { next }
  n == 0         { next }
  parte == "prog"               { print > (dir sprintf("/caso%03d.txt", n)) }
  parte == "saida" && NF > 0    { print > (dir sprintf("/esperado%03d.txt", n)) }
' "$ARQ"

# junta as linhas de um arquivo numa linha so, separadas por espaco
em_linha() { paste -sd' ' "$1"; }
recuo() { sed 's/^/           /'; }

passou=0; falhou=0
for desc in "$DIR"/descricao*; do
  n=${desc##*descricao}
  descricao=$(cat "$desc")
  caso="$DIR/caso$n.txt"; esperado="$DIR/esperado$n.txt"; obtido="$DIR/obtido$n.txt"
  problema=""

  if ! "$COMP" -asm "$DIR/prog$n.s" "$caso" "$DIR/comp$n.txt" > /dev/null; then
    problema="o compilador rejeitou o programa"
    detalhe=$(grep -v "^programa com erros" "$DIR/comp$n.txt" | head -3)
  elif ! gcc "$DIR/prog$n.s" -o "$DIR/prog$n" 2> "$DIR/gcc$n.txt"; then
    problema="gcc nao conseguiu montar/ligar o asm"
    detalhe=$(head -3 "$DIR/gcc$n.txt")
  else
    timeout "$LIMITE" "$DIR/prog$n" > "$obtido"
    codigo=$?
    if [ "$codigo" -eq 124 ]; then
      problema="o programa nao terminou em ${LIMITE}s"
    elif [ "$codigo" -ne 0 ]; then
      problema="o programa terminou com codigo $codigo"
    elif ! diff -q -B "$esperado" "$obtido" > /dev/null; then
      problema="saida diferente da esperada"
    fi
    detalhe=""
  fi

  if [ -z "$problema" ]; then
    status="PASSOU"; passou=$((passou+1))
  else
    status="FALHOU"; falhou=$((falhou+1))
  fi
  echo "$status $descricao"
  echo "       esperado: $(em_linha "$esperado")"
  if [ -f "$obtido" ]; then
    echo "       obtido:   $(em_linha "$obtido")"
  fi
  if [ -n "$problema" ]; then
    echo "       -> $problema"
    [ -n "$detalhe" ] && echo "$detalhe" | recuo
  fi
done
rm -rf "$DIR"
echo "-----"
echo "Total: $passou passaram, $falhou falharam"
[ "$falhou" -eq 0 ]
