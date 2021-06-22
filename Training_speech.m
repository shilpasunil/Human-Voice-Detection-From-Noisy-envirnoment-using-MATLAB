clc;
clear all;
close all;
% Load a speech waveform
disp('start to speech');
pause(0.5)
disp('.....')
speechin = wavrecord(44100*2,44100); 
disp('end')
%     soundsc(speechin,44100); 
    wavwrite(speechin,44100,'testCurrent.wav');
 [d,sr] = wavread('testCurrent.wav');
 soundsc(d,44100);
 % Look at its regular spectrogram
 figure;
 subplot(211)
 plot(d);title('Input Speech');
 ylabel('Amplitude');
 xlabel('Time(sec)');
  subplot(212)
 specgram(d, 256, sr);title('Speech spectogram');
 ylabel('Frequency');
 xlabel('Time(sec)');
%  
 % Calculate basic RASTA-PLP cepstra and spectra
 [cep1, spec1] = rastaplp(d, sr);
 % .. and plot them
 figure;
 subplot(211)
 imagesc(10*log10(spec1)); % Power spectrum, so dB is 10log10
 ylabel('Frequency');
 xlabel('Time(sec)');
 title('RASTA-PLP Spectogram');
 axis xy
 subplot(212)
 imagesc(cep1)
 ylabel('Frequency');
 xlabel('Time(sec)');
 title('RASTA-PLP Cepstrum');
 axis xy
 
 del1 = deltas(cep1);
%  Double deltas are deltas applied twice with a shorter window
 ddel1 = deltas(deltas(cep1,5),5);
%  Composite, 39-element feature vector, just like we use for speech recognition
 cepDpDD1 = [cep1;del1;ddel1];
 
 
 % Calculate 12th order PLP features without RASTA
 [cep2, spec2] = rastaplp(d, sr, 0, 12);
figure;
 subplot(211)
 imagesc(10*log10(spec2));
 axis xy
 ylabel('Frequency');
 xlabel('Time(sec)');
 title('PLP specstrum');
 subplot(212)
 imagesc(cep2)
 axis xy
 ylabel('Frequency');
 xlabel('Time(sec)');
 title('PLP Cepstrum');
%  % Notice the greater level of temporal detail compared to the 
%  % RASTA-filtered version.  There is also greater spectral detail 
%  % because our PLP model order is larger than the default of 8
%  [rasta and plp spectrograms]
%  Append deltas and double-deltas onto the cepstral vectors
 del = deltas(cep2);
%  Double deltas are deltas applied twice with a shorter window
 ddel = deltas(deltas(cep2,5),5);
%  Composite, 39-element feature vector, just like we use for speech recognition
 cepDpDD = [cep2;del;ddel];
%  % Convert to MFCCs 
 [mm,aspc] = melfcc(d, sr, 'maxfreq', 8000, 'numcep', 20, 'nbands', 22, 'fbtype', 'fcmel', 'dcttype', 1, 'usecmp', 1, 'wintime', 0.032, 'hoptime', 0.016, 'preemph', 0, 'dither', 1);
figure;
 subplot(211)
 imagesc(10*log10(aspc));
 axis xy
ylabel('Frequency');
 xlabel('Time(sec)');
 title('MFCC Spectrum'); 
 subplot(212)
 imagesc(mm)
 ylabel('Frequency');
 xlabel('Time(sec)');
 title('MFCC Cepstrum');
 axis xy
 
 [y,e] = powspec(d, sr);
 figure;
 subplot(211);imagesc(y);axis xy;
 ylabel('Power Spectrum Frequency');
 xlabel('Time(sec)');
 title('Power Spectrum');
 subplot(212);
 plot(e)
 ylabel('Energy of Frequency');
 xlabel('Time(sec)');
 title('Energy of frequency');
 
 feaall=[log(sum(spec1)) log(sum(spec2)) log(sum(aspc)) e];
 