import subprocess
import sys
import os
import time
from datetime import datetime
from output_validation import CorrectOutput
from rcs_monostatic import rcs_monostatic
from rcs_bistatic import rcs_bistatic
from rcs_functions import getParamsFromFile,INPUT_MODEL

MATLAB_EXECUTABLE_PATH = "C:\\Program Files\\MATLAB\\R2024a\\bin\\matlab.exe"
AUTOMATOR_INPUT = 'automator_input.txt'
model = ''

def update_automator_input(method):
    data_hora_atual = datetime.now()
    formato_desejado = '%Y%m%d%H%M%S'
    data_hora_formatada = data_hora_atual.strftime(formato_desejado)

    with open(AUTOMATOR_INPUT, 'w') as arquivo:
        arquivo.write(method+'\n')
        arquivo.write(data_hora_formatada)
    
    return data_hora_formatada

def get_pofacet_file_fullpath(method):
    global model
    start_time = update_automator_input(method)
    full_path = '../results/POfacets/'+model+'_'+start_time+'.mat'
    return full_path

def wait_file_creation(path):
    isCreate = os.path.exists(path)
    while not isCreate:
        time.sleep(2)
        isCreate = os.path.exists(path)

def set_and_print_model(input_model):
    global model
    model = input_model.split('.')[0]
    print(f"Modelo analisado: {input_model}\n")


def generate_pofacets_file(method):
    command = [MATLAB_EXECUTABLE_PATH, '-r', f"automatic_simulation_script"]
    os.chdir('./automator')

    print('>>> Executando Pofacets <<<\n')
    subprocess.run(command)

    pofacets_file = get_pofacet_file_fullpath(method)

    wait_file_creation(pofacets_file)
    print('Concluido.\n')

    return pofacets_file

def run_openrcs_simulation(method):
    param_list = getParamsFromFile(method)

    set_and_print_model(param_list[INPUT_MODEL])

    print('>>> Executando Open-RCS <<<\n')
    if method == 'monostatic': return rcs_monostatic(param_list)
    elif method == 'bistatic': return rcs_bistatic(param_list)
    
def generate_open_rcs_files(method):
    plot_name, fig_name, file_name = run_openrcs_simulation(method) 
    wait_file_creation(file_name)
    print('Concluido.\n')

    return '.'+file_name

def generate_datum(method):
    print('>>>>>>>>>>>>> Iniciando comparação de modelos <<<<<<<<<<<<<\n')

    open_rcs_file = generate_open_rcs_files(method)
    
    pofacets_file = generate_pofacets_file(method)
    
    return open_rcs_file,pofacets_file

class InvalidInput(Exception):
    def __init__(self,message = "Invalid Input"):
        self.message = message
        print(self.message)
        super().__init__(self.message)

def get_method():
    params = sys.argv

    if len(params) != 2:
        raise InvalidInput("Erro: invalid number of arguments")
    else:
        if params[1] != 'monostatic' and params[1] != 'bistatic':
            raise InvalidInput(f"Erro: Method '{params[1]}' invalid.")
        
    method = params[1]
    return method

def automatic_compare():

    method = get_method()

    open_rcs_file, pofacets_file = generate_datum(method)

    print('>>> Calculando erro médio quadrático <<<\n')
    pofacetOutput = CorrectOutput(pofacets_file)
    pofacetOutput.setPredictOutputFile(open_rcs_file)

    pofacetOutput.printMSEBetweenOutputsForColumn("Sth")
    pofacetOutput.printMSEBetweenOutputsForColumn("Sph")


if __name__ == '__main__':
    try:
        automatic_compare()
    except InvalidInput:
        print('Correct input command: python automatic_compare.py <monostatic|bistatic>')
    except Exception as e:
        print(f'error:{e}')
