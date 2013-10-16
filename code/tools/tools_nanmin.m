function m = tools_nanmin(x)
    x = x(:);
    x(isnan(x)) = [];
    m = min(x);
end