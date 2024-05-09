function params = get_params_values(method,figure,path)
     % Abra o arquivo para leitura
    input_data_file = [path,'input_data_file_',method,'.dat'];
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

    model = param_list{1};
    model_split = strsplit(model, '.');
    param_list{1} = model_split{1};
    params = param_list;
end