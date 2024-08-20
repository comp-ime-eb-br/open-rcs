function automatic_simulation_script()
    addpath('./pofacets4.5');
    pofacets
    method_and_time = get_params_values('automator_input.txt'); %monostatic or bistatic
    method = method_and_time{1};
    start_time = method_and_time{2};

    fig = openfig([method,'.fig']);

    %colocar quantas vezes quiser
    generate_rcs_data(fig,method,start_time);

    %fechar janelas
    close(gcf)
    close(gcf)
end

function generate_rcs_data(fig,method,start_time)
    %get parameters from input input_files
    params = get_params_values(['../input_files/','input_data_file_',method,'.dat']);
    modelname = params{1};

    %load model
    designModified('OpenFile','./pofacets4.5/CAD Library Pofacets/',[modelname,'.mat']);
    waitfor(@() is_design_loaded());
    close(gcf);

    set_params_values(method,params);
    rs = str2num(params{6});
    rsmethod = rs+1;

    %generate rcs results files 
    if strcmpi(method,'monostatic')
        %mudar modelname
        CalcMonoAuto(rsmethod,'../results/Pofacets/',[modelname,'_',start_time,'.mat'])
    else
        CalcBistatAuto(rsmethod,'../results/Pofacets/',[modelname,'_',start_time,'.mat'])
    end
end

function loaded = is_design_loaded()
    loaded = ~isempty(findobj('Tag', 'MinhaLinha'));
end

