import subprocess
import sys
import os
import time
from datetime import datetime
from rcs_monostatic import rcs_monostatic
from rcs_bistatic import rcs_bistatic
from stl_module import stl_converter
from output_validation import OutputValidation

MATLAB_EXECUTABLE_PATH = "C:\\Program Files\\MATLAB\\R2024a\\bin\\matlab.exe"
AUTOMATOR_INPUT = 'automator_input.txt'

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

def getSimulationParams():
    input_data_file = f"./input_files/input_data_file_{method}.dat"
    params = open(input_data_file, 'r')
    param_list = []
    for line in params:
        line=line.strip("\n")
        if not line.startswith("#"):
            if line.isnumeric(): param_list.append(float(line))
            else: param_list.append(line)
    params.close()
    return param_list

def calculate_rcs_openrcs(method):
    param_list = getSimulationParams()
    input_model = param_list[0]

    stl_converter("./stl_models/"+input_model)
    print(input_model)

    if method == 'monostatic':
        input_model, freq, corr, delstd, ipol, rs, pstart, pstop, delp, tstart, tstop, delt = param_list
        return rcs_monostatic(input_model, float(freq), corr, delstd, ipol, pstart, pstop, delp, tstart, tstop, delt, rs)
    else:
        input_model, freq, corr, delstd, ipol, rs, pstart, pstop, delp, tstart, tstop, delt, thetai, phii = param_list
        return rcs_bistatic(input_model, float(freq), corr, delstd, ipol, pstart, pstop, delp, tstart, tstop, delt, phii, thetai, rs) 

def generate_open_rcs_files(method):
    input_model, plot_name, fig_name, file_name = calculate_rcs_openrcs(method)  
    input_model = input_model.split('.')[0]
    return file_name, input_model

def generate_pofacets_file(method,input_model,matlabExecutablePath):
    print('>>> Executando Pofacets <<<\n')
    command = [matlabExecutablePath, '-r', f"automatic_simulation_script"]
    os.chdir('./automator')
    subprocess.run(command)

    start_time = update_automator_input(method)

    pofacets_file = '../results/POfacets/'+input_model+'_'+start_time+'.mat'

    return pofacets_file

def generate_datum(method, matlabExecutablePath):
    print('>>>>>>>>>>>>> Iniciando comparação de modelos <<<<<<<<<<<<<\n')
    print('>>> Executando Open-RCS <<<\n')

    open_rcs_file, input_model = generate_open_rcs_files(method)
    wait_file_creation(open_rcs_file)

    print('Concluido.\n')

    pofacets_file = generate_pofacets_file(method,input_model,matlabExecutablePath)
    wait_file_creation(pofacets_file)

    print('Concluido.\n')

    return open_rcs_file,pofacets_file

if __name__ == '__main__':
    params = sys.argv
    method = params[1]
    if method != 'monostatic' and method != 'bistatic':
        print('método não válido')
    else:  
        open_rcs_file, pofacets_file = generate_datum(method, MATLAB_EXECUTABLE_PATH)
        open_rcs_file = '.'+open_rcs_file 

        print('>>> Calculando erro médio quadrático <<<\n')
        compare = OutputValidation(pofacets_file, open_rcs_file)
        print("Testing method Sth\n", compare.mse_relative("Sth"))
        print("Testing method Sph\n", compare.mse_relative("Sph"))