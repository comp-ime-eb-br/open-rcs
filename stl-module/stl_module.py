import numpy as np
from stl import mesh

# Lendo o arquivo com o stl mesh
file_path = "box.stl"
stl_mesh = mesh.Mesh.from_file(file_path)

# Listando os vértices únicos
vertices = stl_mesh.points.reshape((-1, 3))
indexes = np.unique(vertices, axis=0, return_index=True)[1]
coordinates = vertices[indexes]

print(coordinates)

# Verificando os vértices que compõem cada face e calculando o ilum flag
facets = []

for i, face in enumerate(stl_mesh.vectors):
    vertices_face = []
    vertices_face.append(i+1)
    
    # Checando se a face é parte de uma estrutura fechada
    is_closed_structure = any((coordinates == face[0]).all(axis=1)) and any((coordinates == face[1]).all(axis=1)) and any(
        (coordinates == face[2]).all(axis=1))

    # Calculando a normal da face
    normal = np.cross(face[1] - face[0], face[2] - face[0])
    
    if normal[2] < 0:
        normal = -normal  # Garantindo os pontos normais para fora
        
    ilum_flag = 1 if is_closed_structure else 0
    
    for vertex in face:
        index = int(np.where((coordinates == vertex).all(axis=1))[0])
        vertices_face.append(index + 1)
    
    vertices_face.append(ilum_flag)
    vertices_face.append(0)  # Rs --> Vamos receber esse parâmetro a partir do input via interface
    
    facets.append(vertices_face)

facets = np.array(facets)

print(facets)

# Salvar arquivos como .txt
np.savetxt("coordinates.txt", coordinates, fmt="%d", delimiter=" ")
np.savetxt("facets.txt", facets, fmt="%d", delimiter=" ")