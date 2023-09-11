import numpy as np
from stl import mesh

def stl_converter(file_path):
    #Lendo o arquivo com o stl mesh
    #file_path = "box.stl"
    stl_mesh = mesh.Mesh.from_file(file_path)

    #Listando os vértices
    vertices = stl_mesh.points.reshape((-1, 3))

    indexes = np.unique(vertices, axis=0, return_index=True)[1]

    coordinates = vertices[indexes]

    #print(coordinates)

    #Verificando os vértices que compõe cada face
    facets = []

    for i, face in enumerate(stl_mesh.vectors):
        vertices_face = []
        vertices_face.append(i+1) 
            
        for vertex in face:
            index=int(np.where((coordinates == vertex).all(axis=1))[0])
            vertices_face.append(index+1)
            
        vertices_face.append(1) #ilum flag --> setei tudo 1 para o caso da caixa, precisa ajustar
        vertices_face.append(0) #Rs --> setei tudo 0, precisa ajustar
        
        facets.append(vertices_face)

    facets = np.array(facets)

    #print(facets)

    #Salvar arquivos como .txt
    np.savetxt("coordinates.txt", coordinates, fmt="%d", delimiter=" ")
    np.savetxt("facets.txt", facets, fmt="%d", delimiter=" ")