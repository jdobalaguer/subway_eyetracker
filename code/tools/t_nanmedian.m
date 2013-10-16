function y = t_nanmedian(x,dim)

if nargin == 1
    y = prctile(x, 50);
else
    y = prctile(x, 50,dim);
end
