from typing import Literal

import numpy as np
from scipy.io import loadmat
from sklearn.metrics import mean_squared_error

INVALID_TYPE = "None"

class OutputValidation:
    def __init__(self, trueFilePath, predictFilePath):
        self.trueFilePath = trueFilePath
        self.predictFilePath = predictFilePath

    def extension_validation(self, path):
        fileType = path[::-1].split(".", 1)[0][::-1]

        if fileType != 'mat' and fileType != 'dat':
            return INVALID_TYPE
        else:
            return fileType

    def readValues(
            self,
            key: Literal["Ethscat", "Ephscat", "freq", "phi", "theta", "Sth", "Sph"],
            path: str | None = None,
        ) -> np.ndarray:

            _file_type = self.extension_validation(path)

            if _file_type == INVALID_TYPE:
                print(f"File {path} with invalid format type")
                return []

            match _file_type:
                case "mat":
                    res: dict = loadmat(path)
                    vetor = res[key]
                    #print(vetor[0].tolist())
                    listaLinear = []
                    for lista in vetor:
                        for r in lista:
                            listaLinear.append(r)
                    #print(listaLinear)
                    #print('\n')
                    return listaLinear
                
                case "dat":
                    with open(path, "r") as file:
                        content = file.readlines()
                        rcs_float = []
                        lista = []
                        if key == 'Sth':
                            RCS_start_index = content.index("RCS Theta (dBsm):\n") + 1
                            RCS_end_index = content.index("Phi (deg):\n")
                            lista = content[RCS_start_index:RCS_end_index-1]
                        elif key == 'Sph':
                            RCS_start_index = content.index("RCS Phi (dBsm):\n") + 1
                            lista = content[RCS_start_index:]

                        for line in lista:
                            value = ''
                            for x in line:
                                if x ==' ' or x == ']' or x == '\n':
                                    if value != '':
                                        rcs_float.append(float(value))
                                    value =''

                                elif x != '[' and x != ']':
                                    value+=x

                        #print(rcs_float)
                        return rcs_float

    def getSequenceValues(self, key):
        trueValues = self.readValues(key,self.trueFilePath)
        predictValues = self.readValues(key,self.predictFilePath)
        if len(trueValues) == 0 or len(predictValues) == 0:
            raise TypeError("Impossible to extract values of one file.")
        return trueValues, predictValues


    def mseBetweenResultsFiles(self, key: Literal["Ethscat", "Ephscat", "freq", "phi", "theta", "Sth", "Sph"]):
        try:
            trueValues, predictValues = self.getSequenceValues(key)
            return mean_squared_error(trueValues,predictValues)
        
        except TypeError as e:
            print(f"Error: {e}")

    def mse_relative(self, key: Literal["Ethscat", "Ephscat", "freq", "phi", "theta", "Sth", "Sph"]):
        try:
            trueValues, predictValues = self.getSequenceValues(key)
            relative_erro = 0.0
            for i in range(0,len(trueValues)):
                relative_erro += (trueValues[i] - predictValues[i])**2 / (trueValues[i]**2)
            return relative_erro
        
        except TypeError as e:
            print(f"Error: {e}")

if __name__ == "__main__":
    PATH_POFACETS = "./results/POfacets/acone_20240802092618.mat"
    PATH_OPENRCS = "./results/temp_20240802092618.dat"
    compare = OutputValidation(PATH_POFACETS, PATH_OPENRCS)
    print("Testing method Theta \n", compare.mseBetweenResultsFiles("Sth"))
    print("Testing method Phi\n", compare.mseBetweenResultsFiles("Sph"))
