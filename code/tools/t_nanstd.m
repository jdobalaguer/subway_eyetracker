function y = t_nanstd(varargin)

% Call nanvar(x,flag,dim) with as many inputs as needed
y = sqrt(t_nanvar(varargin{:}));
