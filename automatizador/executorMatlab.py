import subprocess

# Caminho para o executável do MATLAB 
matlab_executable = "C:\\Program Files\\MATLAB\\R2024a\\bin\\matlab.exe"

# Caminho completo para o script do MATLAB
matlab_script = 'matlabScript'

# Combinando tudo em um comando para o subprocesso
command = [matlab_executable, '-r', f'"{matlab_script}"']

# Executando o comando
subprocess.run(command)