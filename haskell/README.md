# Trabalho de Agrupamento Multidimensional - Implementação Haskell
Este diretório contém a implementação em Haskell para o problema de agrupamento multidimensional, conforme especificado para a disciplina de Paradigmas de Programação.

## Requisitos
* GHC (Glasgow Haskell Compiler): Recomenda-se a versão 9.0 ou superior. A maneira mais fácil de instalar o GHC e as ferramentas associadas é através do GHCup.

* Bibliotecas do Sistema: Em sistemas baseados em Linux (como o WSL), pode ser necessário instalar a biblioteca de aritmética de precisão múltipla do GNU. Isso pode ser feito com o comando:
```sh
sudo apt-get install libgmp-dev
```

## Como Compilar e Executar o Programa
1. Prepare o Arquivo de Entrada
    * Crie um arquivo CSV (por exemplo, `base.csv`).
    * Cada linha do arquivo CSV deve representar um ponto, com suas coordenadas separadas por vírgulas.
    * Exemplo de linha: `7,5.4,6.32,9`

2. Compile o Programa via Terminal
    * Abra um terminal ou prompt de comando.
    * Navegue até o diretório onde você salvou o script Haskell (.hs).
    * Execute o comando de compilação:
    ```sh
        ghc --make Trab1_Jullie_de_Castro_Quadros.hs
    ```
    * Este comando criará um arquivo executável chamado Trab1_Jullie_de_Castro_Quadros (no Linux) ou Trab1_Jullie_de_Castro_Quadros.exe (no Windows).

3. Execute o Programa Compilado
    * No mesmo terminal, execute o programa recém-criado:
    ```sh
    ./Trab1_Jullie_de_Castro_Quadros
    ```
4. Interação com o Programa
    * **O programa solicitará que você forneça:**
        * O nome do arquivo de entrada (ex: base.csv).
        * O nome desejado para o arquivo de saída (ex: saida.csv).
        * O número de grupos (K) a serem formados.

    * **Exemplo de Interação no Terminal:**
        ```
        Forneca o nome do arquivo de entrada: base.csv
        Forneca o nome do arquivo de saida: saida.csv
        Forneca o número de grupos (K): 2
        ```

5. Verifique os Resultados
    * Após a execução, os agrupamentos serão impressos no terminal.
    * Um arquivo de saída (ex: saida.csv) será criado na mesma pasta, contendo os grupos formados, com cada linha representando um grupo e os IDs dos pontos separados por vírgula e espaço.

**Observações**
Na pasta validacao contém exemplos dos arquivos de entrada e saída. Para testar, execute o programa e, quando solicitado, informe os caminhos relativos, por exemplo: validacao/entrada/base1.csv e validacao/saida2/saida1k2.csv. O gabarito para a respectiva saída estará na pasta gabarito. Note que o gabarito pode não estar com os IDs dos pontos ordenados dentro de cada grupo.

**Automação de Testes**
Para facilitar a validação em massa, você pode usar o script executar_testes_haskell.sh:

Dê permissão de execução ao script:
```sh
chmod +x validacao/executar_testes_haskell.sh
```
Execute o script:
```sh
./validacao/executar_testes.sh
```
O script rodará todos os casos de teste pré-definidos e salvará os resultados na pasta validacao/saida_haskell/.