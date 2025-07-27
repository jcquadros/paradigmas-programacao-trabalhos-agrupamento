import Data.List (sortBy, intercalate, sort, minimumBy) 
import Data.Ord (comparing) 
import System.IO 

-- --- Definição dos Tipos de Dados ---

-- Representa um ponto no espaço n-dimensional.
data Point = Point {
    pointId :: Int,      -- Identificador único do ponto, baseado na linha do arquivo.
    coords  :: [Double]  -- Lista de coordenadas (números de ponto flutuante).
} deriving (Show, Eq)

-- Representa uma ligação (aresta) entre dois pontos.
data Link = Link {
    p1       :: Int,     -- ID do primeiro ponto da ligação.
    p2       :: Int,     -- ID do segundo ponto da ligação.
    distance :: Double   -- Distância Euclidiana entre p1 e p2.
} deriving (Show, Eq)

-- Define um 'Group' (Grupo) como um sinônimo para uma lista de IDs de pontos (Int).
type Group = [Int]

-- --- Função Principal (main) ---
-- Ponto de entrada do programa. Orquestra a leitura dos parâmetros,
-- a execução do algoritmo e a gravação dos resultados.
main :: IO ()
main = do
    putStr "Forneca o nome do arquivo de entrada: "
    hFlush stdout
    inputFile <- getLine

    putStr "Forneca o nome do arquivo de saida: "
    hFlush stdout
    outputFile <- getLine

    putStr "Forneca o número de grupos (K): "
    hFlush stdout
    kStr <- getLine
    let k = read kStr :: Int

    points <- readPointsFromCSV inputFile

    if null points
        then do
            putStrLn "Nenhum ponto válido encontrado no arquivo."
            outputResults [] outputFile
        else do
            let initialLinks = buildInitialLinks points
            let finalGroups = formKGroups points initialLinks k
            outputResults finalGroups outputFile

-- --- Funções de Leitura e Auxiliares ---

-- Lê os pontos de um arquivo CSV, convertendo cada linha em um tipo 'Point'.
readPointsFromCSV :: FilePath -> IO [Point]
readPointsFromCSV filename = do
    content <- readFile filename
    let fileLines = lines content
    return $ parseLinesRecursive 1 fileLines
    where
        -- Função recursiva que atribui um ID a cada linha e a converte para um Ponto.
        parseLinesRecursive :: Int -> [String] -> [Point]
        parseLinesRecursive _ [] = []
        parseLinesRecursive idx (line:restOfLines) =
            let currentPoint = parseLine idx line
            in currentPoint : parseLinesRecursive (idx + 1) restOfLines

        -- Converte uma única linha (String) em um Ponto.
        parseLine :: Int -> String -> Point
        parseLine idx line =
            let stringParts = splitBy ',' line
                doubleCoords = map read stringParts
            in Point idx doubleCoords

        -- Função auxiliar que divide uma string por um caractere delimitador.
        splitBy :: Char -> String -> [String]
        splitBy delimiter = foldr (\c acc -> if c == delimiter then "" : acc else (c : head acc) : tail acc) [""]

-- Calcula a distância Euclidiana entre dois pontos (representados por suas listas de coordenadas).
calculateEuclideanDistance :: [Double] -> [Double] -> Double
calculateEuclideanDistance c1 c2 = sqrt (sumOfSquaredDiffs c1 c2)
    where
        -- Função recursiva para calcular a soma das diferenças ao quadrado entre as coordenadas.
        sumOfSquaredDiffs :: [Double] -> [Double] -> Double
        sumOfSquaredDiffs [] [] = 0
        sumOfSquaredDiffs (x:xs) (y:ys) =
            let diff = x - y
                squaredDiff = diff * diff
            in squaredDiff + sumOfSquaredDiffs xs ys
        sumOfSquaredDiffs _ _ = error "Os pontos devem ter o mesmo número de dimensões"

-- --- Algoritmo Parte 1: Construção da Lista Inicial de Ligações ---

-- Constrói a lista inicial de (N-1) ligações conectando todos os pontos,
-- iniciando pelo ponto 1 e conectando-o sempre ao vizinho mais próximo ainda não escolhido.
buildInitialLinks :: [Point] -> [Link]
buildInitialLinks points
    | length points < 2 = []
    | otherwise =
        let startPoint = head points
            availablePoints = tail points
        in buildLinksRecursive [] startPoint availablePoints

-- Função recursiva que constrói as ligações, uma por vez.
buildLinksRecursive :: [Link] -> Point -> [Point] -> [Link]
buildLinksRecursive accLinks _ [] = reverse accLinks
buildLinksRecursive accLinks currentPoint availablePoints =
    let closestPoint = minimumBy (compareDistanceAndId currentPoint) availablePoints
        newLink = Link (pointId currentPoint) (pointId closestPoint) (calculateEuclideanDistance (coords currentPoint) (coords closestPoint))
        remainingPoints = filter (\p -> pointId p /= pointId closestPoint) availablePoints
    in buildLinksRecursive (newLink : accLinks) closestPoint remainingPoints
    where
        -- Define a regra de "proximidade" para encontrar o vizinho mais próximo.
        -- Compara primeiro pela distância e usa o ID do ponto como critério de desempate.
        compareDistanceAndId :: Point -> Point -> Point -> Ordering
        compareDistanceAndId from pA pB =
            let distA = calculateEuclideanDistance (coords from) (coords pA)
                distB = calculateEuclideanDistance (coords from) (coords pB)
            in compare (distA, pointId pA) (distB, pointId pB)

-- --- Algoritmo Parte 2: Formação dos K Grupos ---

-- Forma K grupos a partir da lista de ligações inicial, cortando as K-1 maiores.
formKGroups :: [Point] -> [Link] -> Int -> [Group]
formKGroups points initialLinks k
    | k <= 0 = []
    | k == 1 = [map pointId points]
    | k > length points = map (\p -> [pointId p]) points
    | otherwise =
        let sortedLinks = sortBy sortForCutting initialLinks
            numCuts = k - 1
            activeLinks = drop numCuts sortedLinks
            allPids = map pointId points
            adj = buildAdjacencyList allPids activeLinks
        in sortBy (comparing head) $ findConnectedComponents allPids adj

-- Define a ordem de corte das ligações: maior distância primeiro,
-- com desempate pelos IDs dos pontos em ordem crescente.
sortForCutting :: Link -> Link -> Ordering
sortForCutting a b =
    let distCompare = compare (distance b) (distance a)
    in if distCompare /= EQ
        then distCompare
        else
            let p1Compare = compare (p1 a) (p1 b)
            in if p1Compare /= EQ
                then p1Compare
                else
                    compare (p2 a) (p2 b)

-- Constrói uma lista de adjacência (um mapa de cada ponto para seus vizinhos) a partir das ligações ativas.
buildAdjacencyList :: [Int] -> [Link] -> [(Int, [Int])]
buildAdjacencyList pids links =
    map (\pid -> (pid, findNeighbors pid links)) pids
    where
        -- Para um dado 'pid', encontra todos os pontos conectados a ele nas 'links'.
        findNeighbors pid allLinks =
            [if p1 l == pid then p2 l else p1 l | l <- allLinks, p1 l == pid || p2 l == pid]

-- Encontra todos os componentes conectados (grupos) em um grafo.
findConnectedComponents :: [Int] -> [(Int, [Int])] -> [Group]
findConnectedComponents allPids adj = findComponentsRecursive allPids []
    where
        -- Itera sobre todos os IDs de pontos para garantir que todos os grupos sejam encontrados.
        findComponentsRecursive :: [Int] -> [Int] -> [Group]
        findComponentsRecursive [] _ = []
        findComponentsRecursive (pid:remainingPids) visited
            | pid `elem` visited = findComponentsRecursive remainingPids visited
            | otherwise =
                let newGroup = sort (dfs adj [pid] [])
                in newGroup : findComponentsRecursive remainingPids (visited ++ newGroup)

-- Implementação da Busca em Profundidade (DFS) para encontrar todos os nós de um componente conectado.
dfs :: [(Int, [Int])] -> [Int] -> [Int] -> [Int]
dfs _ [] visited = visited
dfs adj (p:stack) visited
    | p `elem` visited = dfs adj stack visited
    | otherwise =
        let neighbors = case lookup p adj of
                            Just n -> n
                            Nothing -> []
        in dfs adj (neighbors ++ stack) (p:visited)

-- --- Saída dos Resultados ---

-- Grava os grupos em um arquivo de saída e também os imprime na tela.
outputResults :: [Group] -> FilePath -> IO ()
outputResults groups filename = do
    let outputLines = map (intercalate ", " . map show) groups
        fileContent = unlines outputLines
    writeFile filename fileContent
    putStrLn "\nAgrupamentos:"
    putStr fileContent
