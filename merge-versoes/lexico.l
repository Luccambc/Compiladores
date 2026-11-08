/* Analisador Lexico - Esdruxula (versao final da dupla)               */
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sintatico.tab.h"

#define MAX_ID_LEN 32

extern FILE *yyin;
extern FILE *yyout;

int erros_lexicos = 0;
extern int verbose;

/* registra o token no arquivo de saida (com -v) e o devolve ao parser */
#define TOKEN(nome, t) \
  do { if (verbose) fprintf(yyout, "[lex] linha %3d: %-11s %s\n", yylineno, nome, yytext); \
       return t; } while (0)
%}

%option yylineno
%option noinput nounput

LETRA [a-zA-Z]
NUM [0-9]

IDENTIFIER {LETRA}({LETRA}|{NUM})*
INTEIRO_LIT {NUM}+
REAL_LIT ({NUM}+\.{NUM}*|\.{NUM}+)


%%

"//".*                          ;   /* comentario de linha: ignorado */
"/*"([^*]|"*"+[^*/])*"*"+"/"    ;   /* comentario de bloco: ignorado */
"/*"       {
  fprintf(yyout, "Erro lexico (linha %d): comentario nao fechado\n", yylineno);
  erros_lexicos++;
}

"=="       { TOKEN("IGUAL", IGUAL); }
"!="       { TOKEN("DIFERENTE", DIFERENTE); }
"<="       { TOKEN("MENOR_IGUAL", MENOR_IGUAL); }
">="       { TOKEN("MAIOR_IGUAL", MAIOR_IGUAL); }
[-+*/()={};<>:]  { TOKEN("simbolo", yytext[0]); }

"int"      { TOKEN("TIPO_INT", TIPO_INT); }       /* tipos das declaracoes */
"float"    { TOKEN("TIPO_FLOAT", TIPO_FLOAT); }

"se"       { TOKEN("SE", SE); }
"senao"    { TOKEN("SENAO", SENAO); }
"enquanto" { TOKEN("ENQUANTO", ENQUANTO); }
"faca"     { TOKEN("FACA", FACA); }   /* "faca" = "faça" (o "do" do C), escrito sem cedilha */
"pular"    { TOKEN("PULAR", PULAR); }
"terminar" { TOKEN("TERMINAR", TERMINAR); }
"switch"   { TOKEN("SWITCH", SWITCH); }
"caso"     { TOKEN("CASO", CASO); }
"padrao"   { TOKEN("PADRAO", PADRAO); }

{IDENTIFIER} {
  if (yyleng > MAX_ID_LEN) {
    fprintf(yyout, "Erro lexico (linha %d): identificador com mais de %d caracteres: %s\n",
            yylineno, MAX_ID_LEN, yytext);
    erros_lexicos++;
  }
  yylval.text = strdup(yytext);
  TOKEN("ID", ID);
}
{REAL_LIT} {
  yylval.fval = atof(yytext);
  TOKEN("REAL", REAL);
}
{INTEIRO_LIT} {
  yylval.ival = atoi(yytext);
  TOKEN("INTEIRO", INTEIRO);
}
[ \t\r\n]+    ;
. {
  fprintf(yyout, "Erro lexico (linha %d): caractere nao reconhecido: %s\n", yylineno, yytext);
  erros_lexicos++;
}


%%
int yywrap() {
 return 1;
}
