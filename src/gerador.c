#include "gerador.h"
#include "tabela.h" 
#include <stdarg.h> // pra ter funcao com parametros variaveis
#include <assert.h>



FILE* saida;

int gera_rotulo(void){
  static int rotulo = 0;
  return rotulo++;
}

void add_rotulo(int rotulo, const char* comentario){
  fprintf(saida, ".L%d: # %s\n",rotulo, comentario);
}




//TODO: adicionar variaveis da tabela de simbolo
int ast_para_asm(No* raiz, FILE* out){
    assert(out != NULL);
    assert(raiz->tipo_no == N_PROGRAMA);
    
    saida = out;
    //adiciona aqui
    add_inst(".section .rodata");
    
    //section de codigo, declaramos como se fosse uma main em c, 
    //de brinde isso faz o gcc linkar libc pra gente, se quiser no futuro
    //da pra usar um print ou malloc da vida
    
    add_inst(".text");
    add_inst(".globl main");
    fprintf(saida, "main:\n");
    //inicio de funcao padrao, boilerplate
    add_inst("pushq %%rbp");
    add_inst("movq %%rsp, %%rbp");
    
    //nosso programa em si
    gera_comandos(raiz->a);
    
    //fim do programa, return 0; como se C
    add_inst("# fim do programa : return 0 como C");
    add_inst("xorl %%eax, %%eax");
    add_inst("popq %%rbp");
    add_inst("ret");
    add_inst(".section .note.GNU-stack,\"\",@progbits");

    return 0;
 }



void add_inst(const char* fmt, ...){
  va_list args; // parametros em ...
  va_start(args, fmt); // sem isso args fica com lixo (comportamento indefinido)
  fputs("  ", saida);
  vfprintf(saida, fmt, args); // recebe numero variavel de argumento
  fputc('\n', saida);
  va_end(args);
}

// cmpq compara os valores e salva flags sobre o resultado
// a instrucao de comparacao seguinte (comp) define qual resultado conferimos
// o resutlado final da comparacao fica salvo em rax como 1 ou 0 (true or false)
void gera_comparacao(const char* comp){
  add_inst("cmpq %%rcx, %%rax");
  add_inst("%s %%al", comp);
  add_inst("movzbq %%al, %%rax");
}

void gera_op(OpBin op){
switch (op) {
  case OP_SOMA: add_inst("addq %%rcx, %%rax"); break;
  case OP_SUB: add_inst("subq %%rcx, %%rax"); break;
  case OP_MUL: add_inst("imulq %%rcx, %%rax"); break;
  case OP_DIV:
    add_inst("cqto");
    add_inst("idivq %%rcx");
  break;
  case OP_MENOR: gera_comparacao("setl"); break;
  case OP_MAIOR: gera_comparacao("setg"); break;
  case OP_IGUAL: gera_comparacao("sete"); break;
  case OP_DIFERENTE: gera_comparacao("setne"); break;
  case OP_MENOR_IGUAL: gera_comparacao("setle"); break;
  case OP_MAIOR_IGUAL: gera_comparacao("setge"); break;
}
}


void gera_exp(No* no){
  switch (no->tipo_no){
    case  N_INTEIRO:
      add_inst("pushq $%d", no->ival);
      break;
    case  N_REAL: // nao vamos lidar com float por enquanto
      break;
    case  N_VAR:
      add_inst("pushq v_%s(%%rip)", no->nome);
      break;
    case  N_BINOP:
      //primeiro calculamos os 2 lados da operacao
      gera_exp(no->a);
      gera_exp(no->b);
      add_inst("popq %%rcx");
      add_inst("popq %%rax");
      gera_op(no->op);
      add_inst("pushq %%rax"); 
      break;

    default:
      break;

  }

}



void gera_comandos(No*no){

  for(No* iterador = no; iterador != NULL; iterador = iterador->prox){
    gera_comando(iterador);
  }

}


void gera_cond(No* cond, int rotulo_jump){
  gera_exp(cond); //resultado no topo da pilha
  add_inst("popq %%rax"); // pop em x86-64 so aceita registrador de 64 bits
  add_inst("testq %%rax, %%rax");
  add_inst("je .L%d", rotulo_jump); // verifica flag zf (jump se eax == 0, no caso false)
}


void gera_comando(No* no){
  switch (no->tipo_no){
    case  N_DECL:
      // nao gera instrucao: o espaco da variavel vem da tabela de simbolos
      break;
    case  N_ATRIB:
      gera_exp(no->a); // var = no->a;
      add_inst("popq v_%s(%%rip)",no->nome); // tira o resultado da pilha e guarda na variavel
      break;
    case  N_SE:
      // sem senao
      if(no->c == NULL){
        // como nao tem else, caso a condicao seja falsa so pula o bloco do if
        int rotulo_depois_do_se = gera_rotulo();
        gera_cond(no->a, rotulo_depois_do_se);

        //bloco if (e uma lista de comandos, nao um comando so)
        gera_comandos(no->b);

        add_rotulo(rotulo_depois_do_se, "apos if");
      }
      // else tem else (meta else)
      else{
        int rotulo_senao = gera_rotulo();
        int rotulo_apos_senao = gera_rotulo();

        gera_cond(no->a, rotulo_senao); // se condicao for falsa pula pro else
        // bloco dentro do if, pula apos o else quando termina com o jmp
        gera_comandos(no->b);
        add_inst("jmp .L%d", rotulo_apos_senao);
        //rotulo do comeco do else e bloco do else
        add_rotulo(rotulo_senao, "senao");
        gera_comandos(no->c);
        // rotulo apos o else, quando o if termina ele pula pra ca
        add_rotulo(rotulo_apos_senao, "fim senao");
      }

      break;
    case  N_SWITCH:
      break;
    case  N_CASO:
      break;
    case  N_ENQUANTO:
      break;
    case  N_FACA:
      break;
    case  N_PULAR:
      break;
    case  N_TERMINAR:
      break;
    default:
      break;

  }

}
