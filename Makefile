# Compilador: flex + bison
#
#   make            gera o parser, o lexer e compila build/comp
#   make test       compila, se preciso, e roda os testes
#   make clean      apaga a pasta build/
#
# Os fontes ficam em src/ e tudo que e gerado fica em build/ 

CC         = gcc
CFLAGS     = -Wall -g
BISON      = bison
BISONFLAGS = -d -Wall -Wcounterexamples
FLEX       = flex
FLEXFLAGS  =

SRC     = src
BUILD   = build
ALVO    = $(BUILD)/comp

all: $(ALVO)

$(BUILD):
	mkdir -p $(BUILD)

# 1. bison gera o parser (.c) e o header com os tokens (.h)
$(BUILD)/sintatico.tab.c $(BUILD)/sintatico.tab.h: $(SRC)/sintatico.y | $(BUILD)
	$(BISON) $(BISONFLAGS) -o $(BUILD)/sintatico.tab.c $(SRC)/sintatico.y

# 2. flex gera o lexer; ele inclui sintatico.tab.h, entao vem depois do bison
$(BUILD)/lex.yy.c: $(SRC)/lexico.l $(BUILD)/sintatico.tab.h
	$(FLEX) $(FLEXFLAGS) -o $(BUILD)/lex.yy.c $(SRC)/lexico.l

# 3. compila e liga tudo (inclui a tabela de simbolos e a AST)
#    -I$(SRC): os arquivos gerados em build/ incluem tabela.h e ast.h, que estao em src/
$(ALVO): $(BUILD)/sintatico.tab.c $(BUILD)/lex.yy.c $(SRC)/tabela.c $(SRC)/tabela.h $(SRC)/ast.c $(SRC)/ast.h
	$(CC) $(CFLAGS) -I$(SRC) -o $@ $(BUILD)/sintatico.tab.c $(BUILD)/lex.yy.c $(SRC)/tabela.c $(SRC)/ast.c

test: $(ALVO)
	./rodar_testes.sh

clean:
	rm -rf $(BUILD)

.PHONY: all test clean
