clc
clear
close all
warning off all
disp('start for speech');
pause(0.5)
disp('.....')
speechin = wavrecord(44100*2,44100); 
disp('end')
    soundsc(speechin,44100); 
    wavwrite(speechin,44100,'testF.wav');