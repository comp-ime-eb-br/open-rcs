import numpy as np
from typing import Literal
from scipy.io import loadmat
from sklearn.metrics import mean_squared_error

validKeys = Literal["Ethscat", "Ephscat", "freq", "phi", "theta", "Sth", "Sph"]

class CorrectOutput:
    def __init__(self, trueFilePath:str) -> None:
        if not trueFilePath:  
            raise ValueError("A valid file path must be specified.")
        
        self.trueFilePath = trueFilePath

    def setPredictOutputFile(self, path_to_predict_file: str) -> None:
        if not path_to_predict_file:  
            raise ValueError("A valid file path must be specified.")
        
        self.predictFilePath = path_to_predict_file

    def extension_validation(self, path:str) -> str | None:
        fileType = path[::-1].split(".", 1)[0][::-1]

        if fileType != 'mat' and fileType != 'dat':
            return None
        else:
            return fileType

    def getValuesListWithin(self,key: validKeys, path: str) -> list:

            _file_type = self.extension_validation(path)

            if _file_type == None:
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

    def getSequenceValues(self, key:validKeys) -> tuple[list,list]:
        trueValues = self.getValuesListWithin(key,self.trueFilePath)
        predictValues = self.getValuesListWithin(key,self.predictFilePath)
        if len(trueValues) == 0 or len(predictValues) == 0:
            raise TypeError("Impossible to extract values of one file.")
        return trueValues, predictValues


    def calculateMSEBetweenOutputsForColumn(self, key: validKeys) -> float:
        try:
            trueValues, predictValues = self.getSequenceValues(key)
            return mean_squared_error(trueValues,predictValues)
        
        except TypeError as e:
            print(f"Error: {e}")

    def calculateRelativeMSEBetweenOutputsForColumn(self, key: validKeys)-> float:
        try:
            trueValues, predictValues = self.getSequenceValues(key)
            relative_erro = 0.0
            for i in range(0,len(trueValues)):
                relative_erro += (trueValues[i] - predictValues[i])**2 / (trueValues[i]**2)
            return relative_erro
        
        except TypeError as e:
            print(f"Error: {e}")

    def printMSEBetweenOutputsForColumn(self, key: validKeys) -> None:
        print(f"Testing column {key}:\n", self.calculateMSEBetweenOutputsForColumn(key))

    def printRelativeMSEBetweenOutputsForColumn(self, key: validKeys) -> None:
        print(f"Testing column {key}:\n", self.calculateRelativeMSEBetweenOutputsForColumn(key))

if __name__ == "__main__":
    PATH_POFACETS = "./results/POfacets/acone_20240802092618.mat"
    PATH_OPENRCS = "./results/temp_20240802092618.dat"

    pofacetOutput = CorrectOutput(PATH_POFACETS)
    pofacetOutput.setPredictOutputFile(PATH_OPENRCS)

    pofacetOutput.printMSEBetweenOutputsForColumn("Sth")
    pofacetOutput.printMSEBetweenOutputsForColumn("Sph")
