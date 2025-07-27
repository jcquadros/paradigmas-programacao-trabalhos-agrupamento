# Trabalho de Agrupamento Multidimensional - Implementação Python

Este diretório contém a implementação em Python para o problema de agrupamento multidimensional, conforme especificado para a disciplina de Paradigmas de Programação.

## Requisitos

* **Python:** Recomenda-se Python 3.10 ou superior.
* **Bibliotecas:** Nenhuma biblioteca externa além das padrão do Python (`csv`, `math`) é necessária para a execução deste script.

## Como Executar o Programa

1.  **Prepare o Arquivo de Entrada:**
    * Crie um arquivo CSV (por exemplo, `base.csv`).
    * Cada linha do arquivo CSV deve representar um ponto, com suas coordenadas separadas por vírgulas.
        * Exemplo de linha: `7,5.4,6.32,9`

2.  **Execute o Script via Terminal:**
    * Abra um terminal ou prompt de comando.
    * Navegue até o diretório onde você salvou o script Python e o arquivo de entrada.
    * Execute o script usando o comando:
        ```bash
        python Trab1_Jullie_de_Castro_Quadros.py
        ```

3.  **Interação com o Programa:**
    * O programa solicitará que você forneça:
        * O nome do arquivo de entrada (ex: `base.csv`).
        * O nome desejado para o arquivo de saída (ex: `saida.csv`).
        * O número de grupos (K) a serem formados.

    * **Exemplo de Interação no Terminal:**
        ```
        Forneca o nome do arquivo de entrada: base.csv
        Forneca o nome do arquivo de saida: saida.csv
        Forneca o número de grupos (K): 2
        ```

4.  **Verifique os Resultados:**
    * Após a execução, os agrupamentos serão impressos no terminal.
    * Um arquivo de saída (ex: `saida.csv`) será criado na mesma pasta, contendo os grupos formados, com cada linha representando um grupo e os IDs dos pontos separados por vírgula e espaço.

**Observações**

Na pasta "validacao" contém um exemplos dos arquivos de entrada e saída. Para testar, crie uma pasta chamada saída e execute o script informando o caminho até ela: `validacao/entrada/base1.csv`, `validacao/saida/saida2k3.csv`. O gabarito para a respectiva saída estará na pasta gabarito, o gabarito não está ordenado.

**Automação de Testes**
Para facilitar a validação em massa, você pode usar o script executar_testes_python.sh:

Dê permissão de execução ao script:
```sh
chmod +x validacao/executar_testes_python.sh
```
Execute o script:
```sh
.validacao/executar_testes.sh
```
O script rodará todos os casos de teste pré-definidos e salvará os resultados na pasta validacao/saida_python/.