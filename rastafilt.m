function y = rastafilt(x)
% y = rastafilt(x)
%
% rows of x = critical bands, cols of x = frame
% same for y but after filtering
% 

% rasta filter
numer = [-2:2];
numer = -numer ./ sum(numer.*numer);
denom = [1 -0.94];

% Initialize the state.  This avoids a big spike at the beginning 
% resulting from the dc offset level in each band.
[y,z] = filter(numer, 1, x(:,1:4)',[],1);
y = 0*y';

size(z)
size(x)

% Apply the full filter to the rest of the signal, append it
y = [y,filter(numer, denom, x(:,5:end)',z,1)'];
