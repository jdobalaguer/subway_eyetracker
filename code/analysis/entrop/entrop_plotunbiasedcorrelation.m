
function entrop_plotunbiasedcorrelation(ep)

    nb_models = 7;
    nb_participants = length(ep.unbiasedcorrelation.yy_g);

    % find max sumcrosstations
    max_sumcrosstations = 0;
    for i_participant = 1:nb_participants
        nb_sumcrosstations = length(ep.unbiasedcorrelation.yy_g{i_participant});
        if max_sumcrosstations < nb_sumcrosstations
            max_sumcrosstations = nb_sumcrosstations;
        end
    end
    
    % initialise variables
    ccor_g = cell(1,max_sumcrosstations);
    ccor_c = cell(1,max_sumcrosstations);
    ccor_e = cell(1,max_sumcrosstations);
    ccor_b = cell(1,max_sumcrosstations);
    ccor_r = cell(1,max_sumcrosstations);
    ccor_le = cell(1,max_sumcrosstations);
    ccor_lb = cell(1,max_sumcrosstations);
    ccor_lr = cell(1,max_sumcrosstations);
    
    % get values
    for i_participant = 1:nb_participants
        nb_sumcrosstations = length(ep.unbiasedcorrelation.yy_g{i_participant});
        for i_crosstations = 1:nb_sumcrosstations
            ccor_g {i_crosstations}(end+1)  = ep.unbiasedcorrelation.cor_g{i_participant}(i_crosstations);
            ccor_c {i_crosstations}(end+1)  = ep.unbiasedcorrelation.cor_c{i_participant}(i_crosstations);
            ccor_e {i_crosstations}(end+1)  = ep.unbiasedcorrelation.cor_e{i_participant}(i_crosstations);
            ccor_b {i_crosstations}(end+1)  = ep.unbiasedcorrelation.cor_b{i_participant}(i_crosstations);
            ccor_r {i_crosstations}(end+1)  = ep.unbiasedcorrelation.cor_r{i_participant}(i_crosstations);
            ccor_le{i_crosstations}(end+1)  = ep.unbiasedcorrelation.cor_le{i_participant}(i_crosstations);
            ccor_lb{i_crosstations}(end+1)  = ep.unbiasedcorrelation.cor_lb{i_participant}(i_crosstations);
            ccor_lr{i_crosstations}(end+1)  = ep.unbiasedcorrelation.cor_lr{i_participant}(i_crosstations);
        end
    end
    
    % remove nans
    for i_crosstations = 1:max_sumcrosstations
        ccor_g {i_crosstations}(isnan(ccor_g{i_crosstations})) = [];
        ccor_c {i_crosstations}(isnan(ccor_c{i_crosstations})) = [];
        ccor_e {i_crosstations}(isnan(ccor_e{i_crosstations})) = [];
        ccor_b {i_crosstations}(isnan(ccor_b{i_crosstations})) = [];
        ccor_r {i_crosstations}(isnan(ccor_r{i_crosstations})) = [];
        ccor_le {i_crosstations}(isnan(ccor_le{i_crosstations})) = [];
        ccor_lb {i_crosstations}(isnan(ccor_lb{i_crosstations})) = [];
        ccor_lr {i_crosstations}(isnan(ccor_lr{i_crosstations})) = [];
    end
    
    % all-in-one
    % M = [max_sumcrosstations, nb_models, nb_samples]
    M = nan(max_sumcrosstations,nb_models,15);
    for i_crosstations = 1:max_sumcrosstations
        MM = [ccor_g{i_crosstations};ccor_e{i_crosstations};ccor_b{i_crosstations};ccor_r{i_crosstations};ccor_le{i_crosstations};ccor_lb{i_crosstations};ccor_lr{i_crosstations}];
        s1 = size(MM,2);
        M(i_crosstations,1:nb_models,1:s1) = MM;
    end
    
    % plot
    figure;
    tools_dotplot(permute(M,[3,2,1]),{''},{'o','o','o','o','o','o','o','o'},{[0,0,1],...
                                                                             [1,0,0],[.7,0,0],[.3,0,0],...
                                                                             [0,1,0],[0,.7,0],[0,.3,0]});
end
