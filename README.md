## Rodando testes

```
make test
```

Resultado esperado: `Total: 59 passaram, 0 falharam`.

(Se adicionar mais testes, o resultado esperado vai mudar)

Para adicionar um teste, escreva em `tests/testes.txt`. A estrutura dos testes é mostrada abaixo:

```
### ok | descrição
{ int a; a = 1; }

### erro | descrição
{ int a; a = 1 }
```
