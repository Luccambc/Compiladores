## Rodando testes

```
make test
```

Roda todos os grupos de teste e mostra o total de cada um. Também dá pra rodar um grupo só:

| comando               | arquivo                 | o que confere                                          |
|-----------------------|-------------------------|--------------------------------------------------------|
| `make test-sintatico` | `tests/sintatico.txt`   | erros léxicos e sintáticos: o programa é aceito ou não |
| `make test-semantico` | `tests/semantico.txt`   | declarações, tipos, divisão por zero, pular/terminar   |
| `make test-execucao`  | `tests/execucao.txt`    | compila até virar executável, roda e confere o `print` |
| `make test-gerador`   | `tests/gerador/`        | o asm gerado é igual ao esperado                       |

### Testes de aceitação (`sintatico.txt` e `semantico.txt`)

```
## comentario (linhas com # sao ignoradas)

### ok | descrição
{ int a; a = 1; }

### erro | descrição
{ int a; a = 1 }
```

### Testes de execução (`execucao.txt`)

O programa é compilado, ligado com o gcc e executado. Cada `print` escreve uma linha,
e a saída tem que ser igual à que vem depois de `>>> saida`. O teste mostra a saída
esperada e a obtida.

```
### descrição
{ int a; a = 2 + 3; print(a); print(a * 2); }
>>> saida
5
10
```
