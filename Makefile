# Compilador: flex + bison
#
#   make            gera o parser, o lexer e compila build/comp
#   make test       compila, se preciso, e roda todos os testes
#   make test-sintatico   so os testes lexicos/sintaticos (tests/sintatico.txt)
#   make test-semantico   so os testes semanticos (tests/semantico.txt)
#   make test-execucao    so os testes de execucao (tests/execucao.txt)
#   make test-gerador     so o teste do asm gerado (tests/gerador/)
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

# 3. compila e liga tudo (tabela de simbolos, AST, type check e gerador)
#    -I$(SRC): os arquivos gerados em build/ incluem tabela.h e ast.h, que estao em src/
$(ALVO): $(BUILD)/sintatico.tab.c $(BUILD)/lex.yy.c $(SRC)/tabela.c $(SRC)/tabela.h $(SRC)/ast.c $(SRC)/ast.h $(SRC)/gerador.c $(SRC)/gerador.h $(SRC)/semantico.c $(SRC)/semantico.h
	$(CC) $(CFLAGS) -I$(SRC) -o $@ $(BUILD)/sintatico.tab.c $(BUILD)/lex.yy.c $(SRC)/tabela.c $(SRC)/ast.c $(SRC)/gerador.c $(SRC)/semantico.c

# roda todos os grupos mesmo que um falhe, e falha no fim se algum falhou
test: $(ALVO)
	@falhou=0; \
	./rodar_testes.sh || falhou=1; echo; \
	echo "===== execucao.txt ====="; \
	./rodar_testes_execucao.sh || falhou=1; echo; \
	echo "===== gerador ====="; \
	./rodar_teste_gerador.sh || falhou=1; \
	exit $$falhou

test-sintatico: $(ALVO)
	./rodar_testes.sh tests/sintatico.txt

test-semantico: $(ALVO)
	./rodar_testes.sh tests/semantico.txt

test-execucao: $(ALVO)
	./rodar_testes_execucao.sh

# so o teste do gerador de codigo (compara o asm com tests/gerador/esperado.s)
test-gerador: $(ALVO)
	./rodar_teste_gerador.sh

clean:
	rm -rf $(BUILD)

.PHONY: all test test-sintatico test-semantico test-execucao test-gerador clean
