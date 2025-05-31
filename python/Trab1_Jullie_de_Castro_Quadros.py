import math
import csv

# --- Funções Auxiliares ---

def calculate_euclidean_distance(point1_coords, point2_coords):
    """
    Calcula a distância Euclidiana entre dois pontos.
    Os pontos são representados como listas/tuplas de coordenadas.
    """
    if len(point1_coords) != len(point2_coords):
        raise ValueError("Os pontos devem ter o mesmo número de dimensões para calcular a distância Euclidiana.")
    distance = 0
    for i in range(len(point1_coords)):
        distance += (point1_coords[i] - point2_coords[i])**2
    return math.sqrt(distance)

# --- Leitura de Dados ---

def read_points_from_csv(filename):
    """
    Lê os pontos de um arquivo CSV.
    Cada linha representa um ponto, com suas coordenadas como números float.
    O ID do ponto é indexado em 1, baseado no número da linha do arquivo.
    Retorna uma lista de dicionários, por exemplo: [{'id': 1, 'coords': [x, y, ...]}, ...].
    """
    points = []
    try:
        with open(filename, 'r', newline='') as csvfile:
            reader = csv.reader(csvfile)
            for i, row in enumerate(reader):
                if not row: continue # Pula linhas vazias
                point_id = i + 1 
                try:
                    coords = [float(val) for val in row] # converte para float
                    points.append({'id': point_id, 'coords': coords})
                except ValueError:
                    print(f"Aviso: Pulando linha inválida {i+1} no arquivo {filename}.")
    except FileNotFoundError:
        print(f"Erro: Arquivo de entrada '{filename}' não encontrado.")
        raise
    except Exception as e:
        print(f"Erro ao ler o arquivo de entrada '{filename}': {e}")
        raise
    return points

# --- Algoritmo Parte 1: Construção da Lista Inicial de Ligações ---

def build_initial_links(points_data):
    """
    Constrói uma lista inicial de (N-1) ligações que conectam todos os pontos.
    Inicia com o primeiro ponto lido do arquivo  e conecta
    o ponto corrente ao ponto ainda não escolhido mais próximo.
    Retorna uma lista de dicionários de ligações: [{'p1': id1, 'p2': id2, 'distance': dist}, ...].
    """
    num_points = len(points_data)
    if num_points < 2:  # Não é possível formar ligações com menos de 2 pontos
        return []

    point_coords_map = {p['id']: p['coords'] for p in points_data}

    # id do ponto inicial
    current_point_id = points_data[0]['id'] 
    
    # conjunto de idas de pontos que ainda não foram escolhidos
    available_point_ids = {p['id'] for p in points_data}
    available_point_ids.remove(current_point_id) # remove o id atual

    ordered_links = []  # Armazena as ligacoes
    for _ in range(num_points - 1):
        if not available_point_ids:
            break # Se não houver mais pontos disponíveis

        potential_next_links = []
        # Calcula a distância do ponto corrente para todos os outros pontos ainda não escolhidos
        for next_pid in available_point_ids:
            dist = calculate_euclidean_distance(point_coords_map[current_point_id], point_coords_map[next_pid])
            potential_next_links.append({'target_id': next_pid, 'distance': dist})
        
        # Escolhe o ponto ainda não escolhido mais próximo ao ponto corrente, critério de desempate é o menor ID
        potential_next_links.sort(key=lambda link: (link['distance'], link['target_id']))
        
        chosen_link_info = potential_next_links[0] # o primeiro da ordenação é o mais próximo
        next_point_id = chosen_link_info['target_id']
        min_distance = chosen_link_info['distance']

        # Adiciona à lista de ligações
        ordered_links.append({
            'p1': current_point_id, 
            'p2': next_point_id, 
            'distance': min_distance
        })
    
        # define o novo ponto corrente e o remove da lista de ids disponíveis
        current_point_id = next_point_id 
        available_point_ids.remove(current_point_id)
        
    return ordered_links

# --- Algoritmo Parte 2: Formação dos K Grupos ---

def form_k_groups(points_data, initial_links, k):
    """
    Forma K grupos cortando as K-1 maiores ligações da lista 'initial_links'.
    Utiliza uma estrutura Union Find (UF) para encontrar os pontos conexos
    Os pontos pertencentes à mesma lista formam um grupo
    """
    num_points = len(points_data)

    if k <= 0: raise ValueError("K deve ser positivo.")
    if num_points == 0: return [] 
    if k == 1: # Se K=1 os pontos pertencem a um único grupo
        return [sorted([p['id'] for p in points_data])]
    if k > num_points: # Se K > Número de pontos, então cada ponto forma um único grupo
        return [[p['id']] for p in sorted(points_data, key=lambda x: x['id'])]

    # Ordena as ligações pela distancia de forma a cortar as k-1 maiores. Se considera a preferencia pelo menor id de ponto
    links_sorted_for_cutting = sorted(initial_links, key=lambda link: link['p2'])
    links_sorted_for_cutting.sort(key=lambda link: link['p1'])
    links_sorted_for_cutting.sort(key=lambda link: link['distance'], reverse=True)
    
    num_cuts_to_make = k - 1 
    
    # As ligaçoes que restaram sao as que definem os agrupamentos
    active_links = links_sorted_for_cutting[num_cuts_to_make:]

    # Usa UF pra encontrar os grupos
    point_ids = [p['id'] for p in points_data]
    parent = {pid: pid for pid in point_ids} # Cada ponto é inicialmente seu próprio pai (raiz)
    
    def find_set(pid):
        # Encontra raiz do conjunto ao qual pid pertence 
        if parent[pid] == pid:
            return pid
        parent[pid] = find_set(parent[pid]) # Path compression
        return parent[pid]

    def unite_sets(pid1, pid2):
        # Une os conjuntos que contêm pid1 e pid2
        pid1_root = find_set(pid1)
        pid2_root = find_set(pid2)
        if pid1_root != pid2_root:
            parent[pid2_root] = pid1_root 

    # Executa UF
    for link in active_links:
        unite_sets(link['p1'], link['p2'])

    # Recupera os grupos formados
    groups_map = {} 
    for pid in point_ids:
        root = find_set(pid)
        if root not in groups_map:
            groups_map[root] = []
        groups_map[root].append(pid) # Adiciona o ponto ao grupo de sua raiz
    
    final_groups = []
    for root_node_id in groups_map:
        group_members = sorted(groups_map[root_node_id]) # Ordena os IDs dentro de cada grupo
        final_groups.append(group_members)
        
    # Ordena os grupos em si pelo menor ID do grupo.
    final_groups.sort(key=lambda g: g[0] if g else float('inf')) # trata se acontecer um grupo vazio
        
    return final_groups

# --- Saída dos Resultados ---

def output_results(groups, filename_out):
    """
    Grava os grupos no arquivo CSV especificado
    e os imprime na saída padrão.
    Cada linha corresponde a um grupo, com os IDs separados por vírgula.
    """
    output_lines = []
    for group in groups:
        output_lines.append(", ".join(map(str, group))) 

    # Grava no arquivo de saída CSV 
    try:
        with open(filename_out, 'w', newline='') as csvfile:
            for line in output_lines:
                csvfile.write(line + "\n") # Grava cada grupo em uma nova linha
    except IOError:
        print(f"Erro ao escrever no arquivo de saída '{filename_out}'.")


    # Imprime na saída padrão 
    print("\nAgrupamentos:") 
    for line in output_lines:
        print(line)

# --- Execução Principal ---

def main():
    """
    Função principal para orquestrar o processo de agrupamento.
    1. Lê os parâmetros e os dados de entrada. [cite: 18]
    2. Realiza o agrupamento. [cite: 19]
    3. Gera a saída dos resultados. [cite: 20, 21]
    """
    try:
        input_csv_file = input("Forneca o nome do arquivo de entrada: ")
        output_csv_file = input("Forneca o nome do arquivo de saida: ")
        k_groups_str = input("Forneca o número de grupos (K): ")
        k_groups = int(k_groups_str)

        if k_groups <= 0:
            print("Número de grupos (K) deve ser um inteiro positivo.")
            return

    except ValueError:
        print("Número de grupos (K) inválido. Deve ser um inteiro.")
        return
    except Exception as e:
        print(f"Erro na leitura dos parâmetros: {e}")
        return

    try:
        points = read_points_from_csv(input_csv_file)

        if not points:
            print("Nenhum ponto encontrado no arquivo de entrada ou arquivo vazio.")
            output_results([], output_csv_file) 
            return
        
        if k_groups > len(points):
            print(f"Aviso: K ({k_groups}) é maior que o número de pontos ({len(points)}). Cada ponto formará seu próprio grupo.")

        # Realização do agrupamento de dados
        initial_links = build_initial_links(points)
        final_groups = form_k_groups(points, initial_links, k_groups)
        output_results(final_groups, output_csv_file)

    except FileNotFoundError:
        print(f"Erro: Arquivo não encontrado durante o processamento.")
    except Exception as e:
        print(f"Ocorreu um erro inesperado durante o processamento: {e}")
        import traceback
        traceback.print_exc()


if __name__ == '__main__':
    main()