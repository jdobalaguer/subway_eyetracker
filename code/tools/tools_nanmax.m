function m = tools_nanmax(x)
    x = x(:);
    x(isnan(x)) = [];
    m = max(x);
end