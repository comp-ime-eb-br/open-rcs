import subprocess
import sys
import os
import time
from datetime import datetime
from rcs_monostatic import rcs_monostatic
from rcs_bistatic import rcs_bistatic
from stl_module import stl_converter
from output_validation import OutputValidation

def update_automator_input(method):
    data_hora_atual = datetime.now()
    formato_desejado = '%Y%m%d%H%M%S'
    data_hora_formatada = data_hora_atual.strftime(formato_desejado)

    with open('automator_input.txt', 'w') as arquivo:
        arquivo.write(method+'\n')
        arquivo.write(data_hora_formatada)
    
    return data_hora_formatada

def wait_file_creation(path):
    isCreate = os.path.exists(path)
    while not isCreate:
        time.sleep(2)
        isCreate = os.path.exists(path)

def generate_open_rcs_files(method):
    input_data_file = f"./input_files/input_data_file_{method}.dat"
    params = open(input_data_file, 'r')
    param_list = []
    for line in params:
        line=line.strip("\n")
        if not line.startswith("#"):
            if line.isnumeric(): param_list.append(float(line))
            else: param_list.append(line)
    file_name =''
    input_model =''
    if method == 'monostatic':
        input_model, freq, corr, delstd, ipol, rs, pstart, pstop, delp, tstart, tstop, delt = param_list
        stl_converter("./stl_models/"+input_model)
        print(input_model)
        plot_name, fig_name, file_name = rcs_monostatic(input_model, float(freq), corr, delstd, ipol, pstart, pstop, delp, tstart, tstop, delt, rs) 
    else:
        input_model, freq, corr, delstd, ipol, rs, pstart, pstop, delp, tstart, tstop, delt, thetai, phii = param_list
        print(input_model)
        stl_converter("./stl_models/"+input_model)
        plot_name, fig_name, file_name = rcs_bistatic(input_model, float(freq), corr, delstd, ipol, pstart, pstop, delp, tstart, tstop, delt, phii, thetai, rs)    
    
    params.close()
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
        #>>>>>>>> Change your executable matlab path <<<<<<<<<<
        matlabExecutablePath = "C:\\Program Files\\MATLAB\\R2024a\\bin\\matlab.exe"
        #^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        open_rcs_file, pofacets_file = generate_datum(method, matlabExecutablePath)
        open_rcs_file = '.'+open_rcs_file 
        print('>>> Calculando erro médio quadrático <<<\n')
        val = OutputValidation(pofacets_file)
        print("Testing method Sth\n", val.mse(key="Sth", path=open_rcs_file))
        print("Testing method Sph\n", val.mse(key="Sph", path=open_rcs_file))