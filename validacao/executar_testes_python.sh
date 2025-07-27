#!/bin/bash

# --- Script de Automação para Testes da Versão Python ---
# Este script executa o programa Python com todas as combinações de
# arquivos de entrada e valores de K necessários para a validação.

# Defina o comando para executar seu script Python.
# Altere "main.py" para o nome do seu arquivo principal.
SCRIPT_PYTHON="python3 python/Trab1_Jullie_de_Castro_Quadros.py"

# Define os diretórios padrão de entrada e saída.
DIR_ENTRADA="validacao/entrada"
DIR_SAIDA="validacao/saida_python"

# Cria o diretório de saída se ele ainda não existir.
mkdir -p "$DIR_SAIDA"

# Função para executar um único caso de teste.
# Argumento 1: Número do arquivo base (ex: 1 para base1.csv)
# Argumento 2: Valor de K (número de grupos)
run_test() {
  local base_num=$1
  local k_val=$2
  local input_file="$DIR_ENTRADA/base${base_num}.csv"
  local output_file="$DIR_SAIDA/saida${base_num}k${k_val}.csv"

  echo "Executando teste: base=${base_num}, K=${k_val}"
  echo "  -> Entrada: ${input_file}"
  echo "  -> Saída:   ${output_file}"

  # Verifica se o arquivo de entrada realmente existe antes de continuar.
  if [ ! -f "$input_file" ]; then
    echo "!! ERRO: Arquivo de entrada não encontrado: $input_file"
    echo "----------------------------------------"
    return
  fi

  # Executa o programa Python.
  # O 'here document' (<<EOF) passa as três linhas de texto como
  # entrada padrão para o script.
  $SCRIPT_PYTHON <<EOF
${input_file}
${output_file}
${k_val}
EOF

  echo "Teste concluído."
  echo "----------------------------------------"
}

# --- Execução de todos os testes baseados na imagem de validação ---

echo "Iniciando bateria de testes para a versão Python..."
echo "========================================"

# Testes para base1.csv
run_test 1 1
run_test 1 2
run_test 1 3
run_test 1 4
run_test 1 8

# Testes para base2.csv
run_test 2 2
run_test 2 3
run_test 2 4
run_test 2 5

# Testes para base3.csv
run_test 3 2
run_test 3 3
run_test 3 5

echo "Todos os testes foram executados."
echo "Verifique os arquivos na pasta: $DIR_SAIDA"
