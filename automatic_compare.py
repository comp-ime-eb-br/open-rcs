import subprocess
import sys
import os
import time
from datetime import datetime
from output_validation import CorrectOutput
from rcs_monostatic import rcs_monostatic
from rcs_bistatic import rcs_bistatic
from stl_module import stl_converter
from rcs_functions import getParamsFromFile

MATLAB_EXECUTABLE_PATH = "C:\\Program Files\\MATLAB\\R2024a\\bin\\matlab.exe"
AUTOMATOR_INPUT = 'automator_input.txt'
input_model = ''

def update_automator_input(method):
    data_hora_atual = datetime.now()
    formato_desejado = '%Y%m%d%H%M%S'
    data_hora_formatada = data_hora_atual.strftime(formato_desejado)

    with open(AUTOMATOR_INPUT, 'w') as arquivo:
        arquivo.write(method+'\n')
        arquivo.write(data_hora_formatada)
    
    return data_hora_formatada

def wait_file_creation(path):
    isCreate = os.path.exists(path)
    while not isCreate:
        time.sleep(2)
        isCreate = os.path.exists(path)

def run_rcs_simulation(method):
    global input_model
    input_model, param_list = getParamsFromFile(method)

    stl_converter("./stl_models/"+ input_model)

    input_model = input_model.split('.')[0]
    
    if method == 'monostatic': return rcs_monostatic(param_list)
    elif method == 'bistatic': return rcs_bistatic(param_list)
    
    
def generate_open_rcs_files(method):
    plot_name, fig_name, file_name = run_rcs_simulation(method) 
    wait_file_creation(file_name)
    print('Concluido.\n')

    return file_name

def generate_pofacets_file(method):
    global input_model
    print('>>> Executando Pofacets <<<\n')
    command = [MATLAB_EXECUTABLE_PATH, '-r', f"automatic_simulation_script"]
    os.chdir('./automator')
    subprocess.run(command)

    start_time = update_automator_input(method)
    pofacets_file = '../results/POfacets/'+input_model+'_'+start_time+'.mat'
    wait_file_creation(pofacets_file)
    print('Concluido.\n')
    return pofacets_file

def generate_datum(method):
    print('>>>>>>>>>>>>> Iniciando comparação de modelos <<<<<<<<<<<<<\n')
    print('>>> Executando Open-RCS <<<\n')

    open_rcs_file = generate_open_rcs_files(method)
    
    pofacets_file = generate_pofacets_file(method)
    

    return open_rcs_file,pofacets_file

if __name__ == '__main__':
    params = sys.argv
    method = params[1]
    if method != 'monostatic' and method != 'bistatic':
        print('método não válido')
    else:  
        open_rcs_file, pofacets_file = generate_datum(method)
        open_rcs_file = '.'+open_rcs_file 

        print('>>> Calculando erro médio quadrático <<<\n')
        pofacetOutput = CorrectOutput(pofacets_file)
        pofacetOutput.setPredictOutputFile(open_rcs_file)
        print("Testing method Sth\n", pofacetOutput.mseBetweenResultsFiles("Sth"))
        print("Testing method Sph\n", pofacetOutput.mseBetweenResultsFiles("Sph"))