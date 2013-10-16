function m = tools_nanmean(x)
    s_x = size(x);
    m = nan(1,s_x(2));
    for i_x = 1:s_x(2)
        xx = x(:,i_x);
        xx(isnan(xx)) = [];
        m(i_x) = sum(xx);
    end
end