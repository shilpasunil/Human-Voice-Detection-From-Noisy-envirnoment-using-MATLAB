function y = dolpc(x,modelorder)
%y = dolpc(x,modelorder)
%
% compute autoregressive model from spectral magnitude samples
%
% rows(x) = critical band
% col(x) = frame
%
% row(y) = lpc a_i coeffs, scaled by gain
% col(y) = frame
%
[nbands,nframes] = size(x);

if nargin < 2
  modelorder = 8;
end

% Calculate autocorrelation 
r = real(ifft([x;x([(nbands-1):-1:2],:)]));
% First half only
r = r(1:nbands,:);

% Find LPC coeffs by durbin
[y,e] = levinson(r, modelorder);

% Normalize each poly by gain
y = y'./repmat(e',(modelorder+1),1);
