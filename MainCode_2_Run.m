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
 CatFeat=[];
 load Database
Class_testA=[];
AllFrame=[];
voiceout=ones(size(d));
noiseout=-(ones(size(d)));
 for ic=1:8820:length(d)
     df=d(ic:ic+8819);
     dfpl=zeros(size(d));
     dfpl(ic:ic+8819)=df;
 [cepf1, specf1] = rastaplp(df);
 [cepf2, specf2] = rastaplp(df,sr, 0, 12);
[mmf,aspcf] = melfcc(df, 8820, 'maxfreq', 8000, 'numcep', 20, 'nbands', 22, 'fbtype', 'fcmel', 'dcttype', 1, 'usecmp', 1, 'wintime', 0.032, 'hoptime', 0.016, 'preemph', 0, 'dither', 1);
[yf,ef] = powspec(df, 8820);
feaall=[log(sum(specf2)) log(sum(aspcf)) ef];
%  %% MULTI-CLASS SVM
% % training
training = svmtrain(Allfeat,Lables);

testing_label_vector = randi([1 2],1);
% classifiying
Class_test = svmclassify(training,feaall);
Class_testA=[Class_testA Class_test];
if Class_test==1
    noiseout(ic:ic+8819)=ones(1,8820);
     voiceout(ic:ic+8819)=-(ones(1,8820));
else
    voiceout(ic:ic+8819)=ones(1,8820);
     noiseout(ic:ic+8819)=-(ones(1,8820));
end   
CatFeat=[CatFeat; feaall];
figure(111);
plot(d);hold on;
plot(dfpl,'g');
AllFrame=[AllFrame ;df'];
% soundsc(dfpl,44100);
% pause(5);
 end
 Class_testA
 N=find(Class_testA==2);
 Vo=find(Class_testA==1);
 if ~isempty(N)
     noisesignal=zeros(size(d));
     for z=1:length(N)
         frN=N(z);
         noisesignal((frN-1)*8820+1:frN*8820)=AllFrame(frN,:);
     end
 else
     noisesignal=zeros(size(d));
 end
 if ~isempty(Vo)
     Voicesignal=zeros(size(d));
     for z=1:length(Vo)
         frV=Vo(z);
         Voicesignal((frV-1)*8820+1:frV*8820)=AllFrame(frV,:);
     end
 else
     Voicesignal=zeros(size(d));
 end
 
 figure;
 plot(noisesignal,'r');
 hold on;plot(Voicesignal);
 ylabel('Amplitude');
 xlabel('Time(sec)');
 title('Classified Speech');
 legend('noise','voice')
 
 dnew=fdesign.lowpass('Fp,Fst,Ap,Ast',0.015,0.025,1,60);
 Hd=design(dnew,'equiripple');
%  fvtool(Hd);
 dfilt=filter(Hd,Voicesignal);
 dfilt2=filter(Hd,noisesignal);
  figure
 plot(dfilt2,'r');
 hold on;
plot(dfilt);
  ylabel('Filtered coefficients');
 xlabel('Time(sec)');
 title('Filtered coefficients');
 legend('noise','voice')
 
 figure
 plot(noiseout(1:8820:end),'b-');
hold on;plot(voiceout(1:8820:end),'r-x');
 ylim([-2 2]);
 ylabel('SVM Binary Output');
 xlabel('Time(sec)');
 title('binary coefficients');
 legend('noise','voice')