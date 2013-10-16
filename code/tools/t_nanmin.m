function [varargout] = t_nanmin(varargin)

% Call [m,ndx] = min(a,b) with as many inputs and outputs as needed
[varargout{1:nargout}] = min(varargin{:});
