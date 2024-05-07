function matlab_function()
    addpath('C:/Users/rafae/Downloads/pofacets4.5/pofacets4.5');
    pofacets
    modelname = 'box';
    monofig = openfig('monostatic.fig')
    designModified('OpenFile','C:/Users/rafae/Downloads/pofacets4.5/pofacets4.5/CAD Library Pofacets/',[modelname,'.mat']);
    waitfor(@() is_design_loaded());
    close(gcf)
    rsmethod = load_params(monofig,'C:/Users/rafae/Documents/GitHub/open-rcs/input_files/input_data_file_monostatic.dat');
    CalcMonoAuto(rsmethod,'C:/Users/rafae/Documents/GitHub/open-rcs/results/Pofacets/',[modelname,'.m'])
end

function loaded = is_design_loaded()
    loaded = ~isempty(findobj('Tag', 'MinhaLinha'));
end

function rsmethod = load_params(figure,file)
    input_data_file = file;

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
            if isstrprop(tline, 'digit')
                param_list{end+1} = str2num(tline);
            else
                param_list{end+1} = tline;
            end
        end
        
        % Leia a próxima linha
        tline = fgetl(fid);
    end

    % Feche o arquivo
    fclose(fid);

    [input_model, freq, corr, delstd, i_pol, rs, pstart, pstop, delp, tstart, tstop, delt] = param_list{:};
    
      h_tstart = findobj(gcf,'Tag','TStart'); 
      set(h_tstart,'String',num2str(tstart));
      
      h_tstop = findobj(gcf,'Tag','TStop'); 
      set(h_tstop,'String',num2str(tstop));
    if delt > 0
      h_delt = findobj(gcf,'Tag','Delt');
      set(h_delt,'String',num2str(delt));     
    end      
      h_pstart = findobj(gcf,'Tag','PStart');
      set(h_pstart,'String',num2str(pstart));

      h_pstop = findobj(gcf,'Tag','PStop'); 
      set(h_pstop,'String',num2str(pstop));
    
    if delp > 0 
        h_delp = findobj(gcf,'Tag','Delp');
        set(h_delp,'String',num2str(delp));     
    end

      h_Lt = findobj(gcf,'Tag','LRegion');
      set(h_Lt,'String',num2str(1e-5));    
      
      h_Nt = findobj(gcf,'Tag','NTerms');
      set(h_Nt,'String',num2str(5)); 
      
      h_ipol = findobj(gcf,'Tag','IncPolar');
      val = i_pol+1;
      if val == 1
         Et = 1;
         Ep = 0;
      else
         Et = 0;
         Ep = 1;
      end
      
      h_freq = findobj(gcf,'Tag','Freq');
      set(h_freq,'String',num2str(freq/1000000000));     

      h_corr = findobj(gcf,'Tag','Corr');
      set(h_corr,'String',num2str(corr));

      h_Std = findobj(gcf,'Tag','Std');
      set(h_Std,'String',num2str(delstd));
      rsmethod = rs+1; 
end