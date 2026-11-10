#!/bin/bash
# Roda cada caso dos arquivos de teste separadamente (um programa por arquivo)
# e confere se o resultado bate com o esperado (ok ou erro).
# Nao compila: use "make test", ou rode "make" antes.
# Uso: ./rodar_testes.sh [arquivo...]
#   padrao: tests/sintatico.txt tests/semantico.txt
# Formato dos arquivos:
#   ### ok | descricao        (ou ### erro | descricao)
#   { programa }
# Linhas que comecam com "#" (sem ser "### ") sao comentarios e sao ignoradas.
RAIZ=$(cd "$(dirname "$0")" && pwd)
COMP="$RAIZ/build/comp"
if [ ! -x "$COMP" ]; then
  echo "Erro: $COMP nao encontrado. Rode \"make\" antes." >&2
  exit 1
fi
if [ $# -eq 0 ]; then
  set -- "$RAIZ/tests/sintatico.txt" "$RAIZ/tests/semantico.txt"
fi

total_passou=0; total_falhou=0
for ARQ in "$@"; do
  echo "===== $(basename "$ARQ") ====="
  DIR=$(mktemp -d)
  awk -v dir="$DIR" '
    /^### / { n++; f = sprintf("%s/caso%03d.txt", dir, n); sub(/^### /, ""); print > (dir "/cabecalho" sprintf("%03d", n)); next }
    /^#/    { next }
    n > 0   { print > f }
  ' "$ARQ"
  passou=0; falhou=0
  for cab in "$DIR"/cabecalho*; do
    n=${cab##*cabecalho}
    linha=$(cat "$cab")
    esperado=$(echo "$linha" | cut -d'|' -f1 | tr -d ' ')
    descricao=$(echo "$linha" | cut -d'|' -f2- | sed 's/^ //')
    "$COMP" "$DIR/caso$n.txt" "$DIR/saida$n.txt" > /dev/null
    if [ $? -eq 0 ]; then obtido=ok; else obtido=erro; fi
    if [ "$obtido" = "$esperado" ]; then status="PASSOU"; passou=$((passou+1)); else status="FALHOU"; falhou=$((falhou+1)); fi
    printf "%-6s [esperado %-4s] %s\n" "$status" "$esperado" "$descricao"
    if [ "$obtido" = "erro" ]; then grep -v "^programa com erros" "$DIR/saida$n.txt" | head -2 | sed 's/^/                       /'; fi
  done
  rm -rf "$DIR"
  echo "-- $(basename "$ARQ"): $passou passaram, $falhou falharam"
  echo
  total_passou=$((total_passou+passou)); total_falhou=$((total_falhou+falhou))
done
echo "Total: $total_passou passaram, $total_falhou falharam"
[ "$total_falhou" -eq 0 ]
