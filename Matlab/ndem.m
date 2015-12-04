clear
close all

fileID = fopen('samples.bin');
inputdata=fread(fileID,'uint8');
fclose(fileID);

anzsamp=size(inputdata);%Anz der einzulesenden Datenpunkte
inputdata=inputdata-127;
IQ=inputdata(1:2:anzsamp-1)+1i.*inputdata(2:2:anzsamp);
clear inputdata

t=(0:size(IQ)-1)*1/(2.5*10^6);%von 0-IQsize*1/Fs
amdemodsignal=IQ.*exp(-1i*2*pi*(-0.6*10^6)*t');
clear IQ
fmdemodsignal = angle(conj(amdemodsignal(1:end-1)).*amdemodsignal(2:end));
clear amdemodsignal

%Decimation naiv
Nth=50;%nur jedes Nte bit nehmen
decisignal=[1:floor(size(fmdemodsignal)/Nth)]';
for i=1:floor(size(fmdemodsignal)/Nth)
    decisignal(i)=fmdemodsignal(i*Nth);
end
%Decimation Matlab
%decisignal=decimate(fmdemodsignal, 50, 'fir');
%Keine Decimation mehr
clear fmdemodsignal

sound(decisignal,50000);