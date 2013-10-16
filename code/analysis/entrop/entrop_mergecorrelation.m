
function entrop_mergecorrelation(ep)

    % numbers
    nb_participants = length(ep.correlation.yy_g);
    
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
        nb_sumcrosstations = length(ep.correlation.yy_g{i_participant});
        for i_crosstations = 2:nb_sumcrosstations
            mcor_g(end+1)  = ep.correlation.cor_g{i_participant}(i_crosstations);
            mcor_c(end+1)  = ep.correlation.cor_c{i_participant}(i_crosstations);
            mcor_e(end+1)  = ep.correlation.cor_e{i_participant}(i_crosstations);
            mcor_b(end+1)  = ep.correlation.cor_b{i_participant}(i_crosstations);
            mcor_r(end+1)  = ep.correlation.cor_r{i_participant}(i_crosstations);
            mcor_le(end+1)  = ep.correlation.cor_le{i_participant}(i_crosstations);
            mcor_lb(end+1)  = ep.correlation.cor_lb{i_participant}(i_crosstations);
            mcor_lr(end+1)  = ep.correlation.cor_lr{i_participant}(i_crosstations);
        end
    end
    
    % store correlations --------------------------------------------------
    ep.correlation.mcor_g  = mcor_g;
    ep.correlation.mcor_c  = mcor_c;
    ep.correlation.mcor_e  = mcor_e;
    ep.correlation.mcor_b  = mcor_b;
    ep.correlation.mcor_r  = mcor_r;
    ep.correlation.mcor_le = mcor_le;
    ep.correlation.mcor_lb = mcor_lb;
    ep.correlation.mcor_lr = mcor_lr;
end
