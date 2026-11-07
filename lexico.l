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

"=="       { TOKEN("IGUAL", IGUAL); }
"!="       { TOKEN("DIFERENTE", DIFERENTE); }
"<="       { TOKEN("MENOR_IGUAL", MENOR_IGUAL); }
">="       { TOKEN("MAIOR_IGUAL", MAIOR_IGUAL); }
[-+*/()={};<>:]  { TOKEN("simbolo", yytext[0]); }

"se"       { TOKEN("SE", SE); }
"senao"    { TOKEN("SENAO", SENAO); }
"fim"      { TOKEN("FIM", FIM); }
"enquanto" { TOKEN("ENQUANTO", ENQUANTO); }
"pular"    { TOKEN("PULAR", PULAR); }
"terminar" { TOKEN("TERMINAR", TERMINAR); }
"caso"     { TOKEN("CASO", CASO); }
"padrao"   { TOKEN("PADRAO", PADRAO); }
"switch"   { TOKEN("SWITCH", SWITCH); }

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
/* recomendavel declarar sempre
   funcao yywrap() */
int yywrap ();


int yywrap() {
 return 1;
}
