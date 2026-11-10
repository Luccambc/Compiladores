.lcomm v_a, 8
.lcomm v_x, 8
  .section .rodata
fmt_int: .string "%ld\n"
fmt_float: .string "%f\n"
  .text
  .globl main
main:
  pushq %rbp
  movq %rsp, %rbp
  pushq $2
  pushq $3
  pushq $4
  popq %rcx
  popq %rax
  imulq %rcx, %rax
  pushq %rax
  popq %rcx
  popq %rax
  addq %rcx, %rax
  pushq %rax
  popq v_a(%rip)
  pushq v_a(%rip)
  popq %rsi
  leaq fmt_int(%rip), %rdi
  xorl %eax, %eax
  call printf@PLT
  pushq $1
  pushq $2
  popq %rcx
  popq %rax
  cmpq %rcx, %rax
  setl %al
  movzbq %al, %rax
  pushq %rax
  popq %rax
  testq %rax, %rax
  je .L0
  pushq $10
  pushq $4
  pushq $2
  popq %rcx
  popq %rax
  cqto
  idivq %rcx
  pushq %rax
  popq %rcx
  popq %rax
  subq %rcx, %rax
  pushq %rax
  popq v_a(%rip)
.L0: # apos if
  pushq v_a(%rip)
  popq %rsi
  leaq fmt_int(%rip), %rdi
  xorl %eax, %eax
  call printf@PLT
  pushq $3
  pushq $5
  popq %rcx
  popq %rax
  cmpq %rcx, %rax
  setge %al
  movzbq %al, %rax
  pushq %rax
  popq %rax
  testq %rax, %rax
  je .L1
  pushq $1
  popq v_a(%rip)
  jmp .L2
.L1: # senao
  pushq $0
  popq v_a(%rip)
  pushq $7
  popq v_a(%rip)
.L2: # fim senao
  pushq v_a(%rip)
  popq %rsi
  leaq fmt_int(%rip), %rdi
  xorl %eax, %eax
  call printf@PLT
  pushq v_a(%rip)
  pushq $14
  popq %rcx
  popq %rax
  cmpq %rcx, %rax
  setle %al
  movzbq %al, %rax
  pushq %rax
  popq %rax
  testq %rax, %rax
  je .L3
  pushq v_a(%rip)
  pushq $2
  popq %rcx
  popq %rax
  imulq %rcx, %rax
  pushq %rax
  popq v_a(%rip)
.L3: # apos if
  pushq v_a(%rip)
  popq %rsi
  leaq fmt_int(%rip), %rdi
  xorl %eax, %eax
  call printf@PLT
  pushq v_a(%rip)
  pushq $10
  popq %rcx
  popq %rax
  cmpq %rcx, %rax
  setg %al
  movzbq %al, %rax
  pushq %rax
  popq %rsi
  leaq fmt_int(%rip), %rdi
  xorl %eax, %eax
  call printf@PLT
  # fim do programa : return 0 como C
  xorl %eax, %eax
  popq %rbp
  ret
  .section .note.GNU-stack,"",@progbits
