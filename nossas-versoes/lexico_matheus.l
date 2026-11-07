%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"

extern FILE *yyin;
extern FILE *yyout;
%}

LETRA [a-zA-Z]
NUM [0-9]

IDENTIFIER {LETRA}({LETRA}|{NUM}){0,31}
NUMBER ({NUM}+(\.{NUM}*)?|\.{NUM}+)


%%

[-+*/()={};<>:]  { return yytext[0]; }

"se" {return SE;}
"senao" {return SENAO;}
"fim" {return FIM;}
"enquanto" {return ENQUANTO;}
"pular" {return PULAR;}
"terminar" {return TERMINAR;}
"caso" {return CASO;}
"switch" {return SWITCH;}

{IDENTIFIER} {
  yylval.text = strdup(yytext);
  return ID;
}
{NUMBER} {
  yylval.num = atof(yytext);
  return NUMERO;
}
[ \t\r\n]+    ;
. { printf("Erro lexico: caractere nao reconhecido: %s\n", yytext); }

 
%%
/* recomendavel declarar sempre
   funcao yywrap() */
int yywrap ();


int yywrap() {
 return 1;
}

