/* Analisador Lexico */
/* Tokens do projeto da turma + operadores de comparacao do C */
%{
  #include "sintatico.tab.h"
%}
%%
enquanto			{return ENQUANTO;}
terminar			{return TERMINAR;}
pular				{return PULAR;}
se				{return SE;}
senao				{return SENAO;}
fim				{return FIM;}
"=="				{return IGUAL;}
"!="				{return DIFERENTE;}
"<="				{return MENOR_IGUAL;}
">="				{return MAIOR_IGUAL;}
[A-Z][A-Z][A-Z]			{return ID;}
[0-9]+\.[0-9]*|[0-9]*\.[0-9]+	{return NUMERO;}
[ \t\r]+				{;}
.|\n				{return yytext[0];}
%%
int yywrap() {
  return 1;
}
