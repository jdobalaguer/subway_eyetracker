function [varargout] = t_nanmax(varargin)

% Call [m,ndx] = max(a,b) with as many inputs and outputs as needed
[varargout{1:nargout}] = max(varargin{:});
