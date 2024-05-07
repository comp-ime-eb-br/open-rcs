function matlab_function()
    addpath('C:/Users/rafae/Downloads/pofacets4.5/pofacets4.5');
    pofacets
    method = 'bistatic';
    modelname = 'acone';
    monofig = openfig([method,'.fig'])
    designModified('OpenFile','C:/Users/rafae/Downloads/pofacets4.5/pofacets4.5/CAD Library Pofacets/',[modelname,'.mat']);
    waitfor(@() is_design_loaded());
    close(gcf)
    rsmethod = get_params_values(method,monofig,'C:/Users/rafae/Documents/GitHub/open-rcs/input_files/');
    
    if strcmpi(method,'monostatic')
        CalcMonoAuto(rsmethod,'C:/Users/rafae/Documents/GitHub/open-rcs/results/Pofacets/',[modelname,'.m'])
    else
        CalcBistatAuto(rsmethod,'C:/Users/rafae/Documents/GitHub/open-rcs/results/Pofacets/',[modelname,'.m'])
    end
end

function loaded = is_design_loaded()
    loaded = ~isempty(findobj('Tag', 'MinhaLinha'));
end

function rsmethod = get_params_values(method,figure,path)
    input_data_file = [path,'input_data_file_',method,'.dat'];

    % Abra o arquivo para leitura
    fid = fopen(input_data_file, 'r');

    % Verifique se o arquivo foi aberto com sucesso
    if fid == -1
        error('Não foi possível abrir o arquivo.');
    end

    % Inicialize a lista de parâmetros
    param_list = {};

    % Leia cada linha do arquivo
    tline = fgetl(fid);
    while ischar(tline)
        % Remova o caractere de nova linha
        tline = strtrim(tline);
        
        % Verifique se a linha não começa com '#'
        if ~startsWith(tline, '#')
            % Converta para número inteiro se for numérico
            param_list{end+1} = tline;
        end
        
        % Leia a próxima linha
        tline = fgetl(fid);
    end

    % Feche o arquivo
    fclose(fid);

    set_params_values(method,param_list)
    rs = str2num(param_list{6});
    rsmethod = rs+1; 
end