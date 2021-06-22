function [cepstra,aspectrum,pspectrum] = melfcc(samples, sr, varargin)
%[cepstra,aspectrum,pspectrum] = melfcc(samples, sr[, opts ...])
%  Calculate Mel-frequency cepstral coefficients by:
%   - take the absolute value of the STFT
%   - warp to a Mel frequency scale
%   - take the DCT of the log-Mel-spectrum
%   - return the first <ncep> components
%  This version allows a lot of options to be controlled, as optional 
%  'name', value pairs from the 3rd argument on: (defaults in parens)
%    'wintime' (0.025): window length in sec
%    'hoptime' (0.010): step between successive windows in sec
%    'numcep'     (13): number of cepstra to return
%    'lifterexp' (0.6): exponent for liftering; 0 = none; < 0 = HTK sin lifter
%    'sumpower'    (1): 1 = sum abs(fft)^2; 0 = sum abs(fft)
%    'preemph'  (0.97): apply pre-emphasis filter [1 -preemph] (0 = none)
%    'dither'      (0): 1 = add offset to spectrum as if dither noise
%    'minfreq'     (0): lowest band edge of mel filters (Hz)
%    'maxfreq'  (4000): highest band edge of mel filters (Hz)
%    'nbands'     (40): number of warped spectral bands to use
%    'bwidth'    (1.0): width of aud spec filters relative to default
%    'dcttype'     (2): type of DCT used - 1 or 2 (or 3 for HTK or 4 for feac)
%    'fbtype'  ('mel'): frequency warp: 'mel','bark','htkmel','fcmel'
%    'usecmp'      (0): apply equal-loudness weighting and cube-root compr.
%    'modelorder'  (0): if > 0, fit a PLP model of this order
%    'broaden'     (0): flag to retain the (useless?) first and last bands
%    'useenergy'   (0): overwrite C0 with true log energy

if nargin < 2;   sr = 16000;    end

% Parse out the optional arguments
[wintime, hoptime, numcep, lifterexp, sumpower, preemph, dither, ...
 minfreq, maxfreq, nbands, bwidth, dcttype, fbtype, usecmp, modelorder, ...
 broaden, useenergy] = ...
    process_options(varargin, 'wintime', 0.025, 'hoptime', 0.010, ...
          'numcep', 13, 'lifterexp', 0.6, 'sumpower', 1, 'preemph', 0.97, ...
	  'dither', 0, 'minfreq', 0, 'maxfreq', 4000, ...
	  'nbands', 40, 'bwidth', 1.0, 'dcttype', 2, ...
	  'fbtype', 'mel', 'usecmp', 0, 'modelorder', 0, ...
          'broaden', 0, 'useenergy', 0);

if preemph ~= 0
  samples = filter([1 -preemph], 1, samples);
end

% Compute FFT power spectrum
[pspectrum,logE] = powspec(samples, sr, wintime, hoptime, dither);

aspectrum = audspec(pspectrum, sr, nbands, fbtype, minfreq, maxfreq, sumpower, bwidth);

if (usecmp)
  % PLP-like weighting/compression
  aspectrum = postaud(aspectrum, maxfreq, fbtype, broaden);
end

if modelorder > 0

  if (dcttype ~= 1) 
    disp(['warning: plp cepstra are implicitly dcttype 1 (not ', num2str(dcttype), ')']);
  end
  
  % LPC analysis 
  lpcas = dolpc(aspectrum, modelorder);

  % convert lpc to cepstra
  cepstra = lpc2cep(lpcas, numcep);

  % Return the auditory spectrum corresponding to the cepstra?
%  aspectrum = lpc2spec(lpcas, nbands);
  % else return the aspectrum that the cepstra are based on, prior to PLP

else
  
  % Convert to cepstra via DCT
  cepstra = spec2cep(aspectrum, numcep, dcttype);

end

cepstra = lifter(cepstra, lifterexp);

if useenergy
  cepstra(1,:) = logE;
end
  

