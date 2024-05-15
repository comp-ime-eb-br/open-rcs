from typing import Literal

import numpy as np
from scipy.io import loadmat
from sklearn.metrics import mean_squared_error


class InvalidFileType(Exception): ...


class OutputValidation:
    """
    Recebe os arquivos de output do POFacets e do RCS Simulator e avalia o erro quadratico
    medio

    Args:
        - path (str): path as string where the file is registered
        - file_type (Literal['mat', 'dat']): file extension type. Defaults to .mat files
    """

    @classmethod
    def extension_validation(cls, path: str) -> str:
        _type = path[::-1].split(".", 1)[0][::-1]
        assert _type in ["mat", "dat"], InvalidFileType
        return _type

    def __init__(self, path: str) -> None:
        self._file_type = self.extension_validation(path)
        self.__path = path

    @property
    def path(self) -> str:
        return self.__path

    def read(
        self,
        key: Literal["Ethscat", "Ephscat", "freq", "phi", "theta", "Sth", "Sph"],
        path: str | None = None,
    ) -> np.ndarray:
        """
        Reads the file and returns a parsed numpy array

        Args:
            - key (Literal["Ethscat", "Ephscat", "freq", "phi", "theta", "Sth", "Sph"]):
                Which metric will be evaluated
            - path (str | None): Optional path to be used as a diference reference. Defaults to None
        """
        _path = path or self.__path

        if path : _file_type = self.extension_validation(path)
        else: _file_type = self._file_type

        match _file_type:
            case "mat":
                res: dict = loadmat(_path)
                vetor = res[key]
                #print(vetor[0].tolist())
                return vetor[0].tolist()
            
            case "dat":
                with open(_path, "r") as file:
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

    # def clean_pofacets(self) -> list[float]:
    #     # Extrai o vetor RCS do output em forma de texto do POFacets
    #     with open(self.__path, "r") as file:
    #         return [map(float, line.split("   ")) for line in file.readlines()]

    def mse(
        self,
        key: Literal["Ethscat", "Ephscat", "freq", "phi", "theta", "Sth", "Sph"],
        series: np.ndarray | None = None,
        path: str | None = None,
    ) -> float:
        """
        Runs the MSE between the reference series (declared as path) and the values fed

        Args:
            - key (Literal["Ethscat", "Ephscat", "freq", "phi", "theta", "Sth", "Sph"]):
                Which metric will be evaluated
            - series (np.ndarray | None): np.array representing the series for comparison
            - path (str | None): comparison series path
        """
        assert not (series and path), "There should be a series or a path, not both"
        if path:
            self.extension_validation(path)
        return mean_squared_error(
            self.read(key), series if series is not None else self.read(key, path=path)
        )


if __name__ == "__main__":
    PATH_ACONE = "./results/POfacets/acone.mat"
    PATH_BLACK = "./results/RCSSimulator_20240513102546.dat"
    val = OutputValidation(PATH_ACONE)
    print("Testing method\n", val.mse(key="Sph", path=PATH_BLACK))
