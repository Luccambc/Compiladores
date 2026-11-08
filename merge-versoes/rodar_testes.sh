#!/bin/bash
# Roda cada caso do testes.txt separadamente (um programa por arquivo)
# e confere se o resultado bate com o esperado (ok ou erro).
# Uso: ./rodar_testes.sh [arquivo]   (padrao: testes.txt)
ARQ=${1:-testes.txt}
bison -d sintatico.y && flex lexico.l && gcc sintatico.tab.c lex.yy.c -o comp || exit 1
DIR=$(mktemp -d)
awk -v dir="$DIR" '
  /^### / { n++; f = sprintf("%s/caso%03d.txt", dir, n); sub(/^### /, ""); print > (dir "/cabecalho" sprintf("%03d", n)); next }
  n > 0  { print > f }
' "$ARQ"
passou=0; falhou=0
for cab in "$DIR"/cabecalho*; do
  n=${cab##*cabecalho}
  linha=$(cat "$cab")
  esperado=$(echo "$linha" | cut -d'|' -f1 | tr -d ' ')
  descricao=$(echo "$linha" | cut -d'|' -f2- | sed 's/^ //')
  ./comp "$DIR/caso$n.txt" "$DIR/saida$n.txt" > /dev/null
  if [ $? -eq 0 ]; then obtido=ok; else obtido=erro; fi
  if [ "$obtido" = "$esperado" ]; then status="PASSOU"; passou=$((passou+1)); else status="FALHOU"; falhou=$((falhou+1)); fi
  printf "%-6s [esperado %-4s] %s\n" "$status" "$esperado" "$descricao"
  if [ "$obtido" = "erro" ]; then grep -v "^programa com erros" "$DIR/saida$n.txt" | head -2 | sed 's/^/                       /'; fi
done
echo "-----"
echo "Total: $passou passaram, $falhou falharam"
rm -rf "$DIR"
