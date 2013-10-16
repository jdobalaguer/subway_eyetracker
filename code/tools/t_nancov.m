function c = t_nancov(x,varargin)

if nargin<1
   error('MATLAB:corrcoef:NotEnoughInputs', 'Not enough input arguments.');
end

% Should we ignore NaNs by complete rows or pairwise?
dopairwise = false;
if numel(varargin)>0
   temp = varargin{end};
   if ischar(temp)
      j = strmatch(temp, {'pairwise' 'complete'});
      if isempty(j)
         error('stats:nancov:InvalidArg','Invalid argument ''%s''.',temp);
      end
      dopairwise = (j==1);
      varargin(end) = [];
   end
end

% Should we use the mle (divide by N) or unbiased estimate (N-1)?
domle = false;
if numel(varargin)>0
   temp = varargin{end};
   if isequal(temp,0) || isequal(temp,1)
      domle = (temp==1);
      varargin(end) = [];
   end
end

if numel(varargin)>1
   error('stats:nancov:TooManyArgs','Two many agruments.');
end
if numel(varargin)>0
   y = varargin{1};

   % Two inputs, convert to equivalent single input
   x = x(:);
   y = y(:);
   if length(x)~=length(y)
      error('stats:nancov:XYmismatch', 'The lengths of X and Y must match.');
   end
   x = [x y];
elseif ndims(x)>2
   error('stats:nancov:InputDim', 'Inputs must be 2-D.');
end

if isvector(x)
  x = x(:);
end

xnan = isnan(x);
[m,n] = size(x);
if ~dopairwise || ~any(any(xnan)) || n<=2    % no need to do pairwise
   nanrows = any(xnan,2);
   if any(nanrows)
       x = x(~nanrows,:);
   end
   c = localcov(x,domle);
else                                         % pairwise with some NaNs
   % Compute variance using complete data separately by column
   c = zeros(n,n,class(x));
   x(xnan) = 0;
   colsize = sum(~xnan,1);
   xmean = sum(x,1) ./ max(1,colsize);
   xmean(colsize==0) = NaN;
   xc = x - repmat(xmean,m,1);
   xc(xnan) = 0;
   xvar = sum(xc.^2,1);
   if domle
      denom = colsize;
   else
      denom = max(0,colsize-1);
   end
   xvar(denom>1) = xvar(denom>1) ./ denom(denom>1);
   xvar(denom==0) = NaN;
   c(1:n+1:end) = xvar;

   % Now compute off-diagonal entries
   jk = 1:2;
   for j = 2:n
      jk(1) = j;
      for k=1:j-1
         jk(2) = k;
         rowsjk = ~any(xnan(:,jk),2);
         njk = sum(rowsjk);
         if njk<=1
            cjk = NaN;
         else
            cjk = localcov(x(rowsjk,jk),domle);
            cjk = cjk(1,2);
         end
         c(j,k) = cjk;
      end
   end
   c = c + tril(c,-1)';
end

% Force symmetric if we know that must be true
if isreal(x)
  c = 0.5*(c+c');
end

% ------------------------------------------------
function [c,n] = localcov(x,domle)
%LOCALCOV Compute cov with no error checking and assuming NaNs are removed

[m,n] = size(x);
if domle
   denom = m;
else
   denom = max(0,m-1);
end

if denom==0
   c = NaN(n,n,class(x));
elseif m==1   % and doing mle, be sure to get exact 0
   c = zeros(n,n,class(x));
else
   xc = x - repmat(mean(x),m,1);
   c = xc' * xc / denom;
end

