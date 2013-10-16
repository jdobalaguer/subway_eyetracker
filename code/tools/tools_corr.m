function r = tools_corr(x,y)
    nx = length(x);
    ny = length(y);
    if nx~=ny
        error('tools_corr: x and y have different lengths');
    end
    n = nx;
    mx = mean(x);
    my = mean(y);
    cov_xy = sum((x-mx).*(y-my));
    
    if ~cov_xy
        r = 0;
    else
        s_x = sqrt(sum(power(x-mx,2)));
        s_y = sqrt(sum(power(y-my,2)));
        r = cov_xy / (s_x * s_y);
    end
end