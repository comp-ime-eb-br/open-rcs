function matlab_script()
    addpath('../pofacets4.5');
    pofacets
    method = 'monostatic'; %monostatic or bistatic
    fig = openfig([method,'.fig']);

    %colocar quantas vezes quiser
    generate_rcs_data(fig,method);
    generate_rcs_data(fig,method);
end

function generate_rcs_data(fig,method)
    %get parameters from input input_files
    params = get_params_values(method,fig,'../input_files/');
    modelname = params{1};

    %load model
    designModified('OpenFile','../pofacets4.5/CAD Library Pofacets/',[modelname,'.mat']);
    waitfor(@() is_design_loaded());
    close(gcf);

    set_params_values(method,params);
    rs = str2num(params{6});
    rsmethod = rs+1;

    %generate rcs results files 
    if strcmpi(method,'monostatic')
        CalcMonoAuto(rsmethod,'../results/Pofacets/',[modelname,'.m'])
    else
        CalcBistatAuto(rsmethod,'../results/Pofacets/',[modelname,'.m'])
    end
end

function loaded = is_design_loaded()
    loaded = ~isempty(findobj('Tag', 'MinhaLinha'));
end