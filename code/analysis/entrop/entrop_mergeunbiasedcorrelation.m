
function entrop_mergeunbiasedcorrelation(ep)

    % numbers
    nb_participants = length(ep.unbiasedcorrelation.yy_g);
    
    % initliaize
    mcor_g = [];
    mcor_c = [];
    mcor_e = [];
    mcor_b = [];
    mcor_r = [];
    mcor_le = [];
    mcor_lb = [];
    mcor_lr = [];
    
    for i_participant = 1:nb_participants
        nb_sumcrosstations = length(ep.unbiasedcorrelation.yy_g{i_participant});
        for i_crosstations = 2:nb_sumcrosstations
            mcor_g(end+1)  = ep.unbiasedcorrelation.cor_g{i_participant}(i_crosstations);
            mcor_c(end+1)  = ep.unbiasedcorrelation.cor_c{i_participant}(i_crosstations);
            mcor_e(end+1)  = ep.unbiasedcorrelation.cor_e{i_participant}(i_crosstations);
            mcor_b(end+1)  = ep.unbiasedcorrelation.cor_b{i_participant}(i_crosstations);
            mcor_r(end+1)  = ep.unbiasedcorrelation.cor_r{i_participant}(i_crosstations);
            mcor_le(end+1)  = ep.unbiasedcorrelation.cor_le{i_participant}(i_crosstations);
            mcor_lb(end+1)  = ep.unbiasedcorrelation.cor_lb{i_participant}(i_crosstations);
            mcor_lr(end+1)  = ep.unbiasedcorrelation.cor_lr{i_participant}(i_crosstations);
        end
        %{
            mcor_g(end+1)  = mean(ep.unbiasedcorrelation.cor_g{i_participant}(2:end));
            mcor_c(end+1)  = mean(ep.unbiasedcorrelation.cor_c{i_participant}(2:end));
            mcor_e(end+1)  = mean(ep.unbiasedcorrelation.cor_e{i_participant}(2:end));
            mcor_b(end+1)  = mean(ep.unbiasedcorrelation.cor_b{i_participant}(2:end));
            mcor_r(end+1)  = mean(ep.unbiasedcorrelation.cor_r{i_participant}(2:end));
            mcor_le(end+1)  = mean(ep.unbiasedcorrelation.cor_le{i_participant}(2:end));
            mcor_lb(end+1)  = mean(ep.unbiasedcorrelation.cor_lb{i_participant}(2:end));
            mcor_lr(end+1)  = mean(ep.unbiasedcorrelation.cor_lr{i_participant}(2:end));
        %}
    end
    
    % store correlations --------------------------------------------------
    ep.unbiasedcorrelation.mcor_g  = mcor_g;
    ep.unbiasedcorrelation.mcor_c  = mcor_c;
    ep.unbiasedcorrelation.mcor_e  = mcor_e;
    ep.unbiasedcorrelation.mcor_b  = mcor_b;
    ep.unbiasedcorrelation.mcor_r  = mcor_r;
    ep.unbiasedcorrelation.mcor_le = mcor_le;
    ep.unbiasedcorrelation.mcor_lb = mcor_lb;
    ep.unbiasedcorrelation.mcor_lr = mcor_lr;
end
