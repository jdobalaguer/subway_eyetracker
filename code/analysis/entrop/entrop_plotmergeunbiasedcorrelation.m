
function entrop_plotmergeunbiasedcorrelation(ep)

    % get values
    mcor_g  = ep.unbiasedcorrelation.mcor_g;
    mcor_e  = ep.unbiasedcorrelation.mcor_e;
    mcor_b  = ep.unbiasedcorrelation.mcor_b;
    mcor_r  = ep.unbiasedcorrelation.mcor_r;
    mcor_le = ep.unbiasedcorrelation.mcor_le;
    mcor_lb = ep.unbiasedcorrelation.mcor_lb;
    mcor_lr = ep.unbiasedcorrelation.mcor_lr;
    
    % remove nans
    i_toremove = zeros(1,length(mcor_g));
    i_toremove(isnan(mcor_g)) = 1;
    i_toremove(isnan(mcor_e)) = 1;
    i_toremove(isnan(mcor_b)) = 1;
    i_toremove(isnan(mcor_r)) = 1;
    i_toremove(isnan(mcor_le)) = 1;
    i_toremove(isnan(mcor_lb)) = 1;
    i_toremove(isnan(mcor_lr)) = 1;
    i_toremove = find(i_toremove);
    
    if ~isempty(i_toremove)
        fprintf(['entrop_plotmergecorrelation: warning. removing nans ',num2str(i_toremove),'\n']);
        mcor_g(i_toremove) = [];
        mcor_e(i_toremove) = [];
        mcor_b(i_toremove) = [];
        mcor_r(i_toremove) = [];
        mcor_le(i_toremove) = [];
        mcor_lb(i_toremove) = [];
        mcor_lr(i_toremove) = [];
    end

    % plot
    figure;
    tools_dotplot([ mcor_g; ...
                    mcor_e; ...
                    mcor_b; ...
                    mcor_r; ...
                    mcor_le; ...
                    mcor_lb; ...
                    mcor_lr]');
    set(gca,'xtick',1:7);
    set(gca,'xticklabel',{'g','e','b','r','le','lb','lr'});
end
