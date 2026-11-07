# Compilador: flex + bison
#
#   make            gera o parser, o lexer e compila ./comp
#   make run        roda ./comp em test.txt e escreve saida.txt (com trace -v)
#   make clean      apaga os arquivos gerados

CC         = gcc
CFLAGS     = -Wall -g
BISON      = bison
BISONFLAGS = -d -Wall -Wcounterexamples
FLEX       = flex
FLEXFLAGS  =

ALVO    = comp
ENTRADA = test.txt
SAIDA   = saida.txt

all: $(ALVO)

# 1. bison gera o parser (.c) e o header com os tokens (.h)
sintatico.tab.c sintatico.tab.h: sintatico.y
	$(BISON) $(BISONFLAGS) sintatico.y

# 2. flex gera o lexer; ele inclui sintatico.tab.h, entao vem depois do bison
lex.yy.c: lexico.l sintatico.tab.h
	$(FLEX) $(FLEXFLAGS) -o lex.yy.c lexico.l

# 3. compila e liga tudo
$(ALVO): sintatico.tab.c lex.yy.c
	$(CC) $(CFLAGS) -o $@ sintatico.tab.c lex.yy.c

run: $(ALVO)
	./$(ALVO) -v $(ENTRADA) $(SAIDA)

clean:
	rm -f $(ALVO) sintatico.tab.c sintatico.tab.h lex.yy.c y.tab.c y.tab.h $(SAIDA)

.PHONY: all run clean
