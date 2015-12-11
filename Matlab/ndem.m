clear
close all

fileID = fopen('samples.bin');
inputdata=fread(fileID,'uint8');
fclose(fileID);
%Einlesen und IQ aus Datenpunkten aufbauen
anzsamp=size(inputdata);%Anz der einzulesenden Datenpunkte
inputdata=inputdata-127;
IQ=inputdata(1:2:anzsamp-1)+1i.*inputdata(2:2:anzsamp);
clear inputdata

%AM-Demodulation
t=(0:size(IQ)-1)*1/(2.5*10^6);%von 0-IQsize*1/Fs
amdemodsignal=IQ.*exp(-1i*2*pi*(-0.6*10^6)*t');
clear IQ

%Filter für die Frequenzen über 100kHz, auskommentieren schaltet Filter aus
open b14.mat; %b.mat=400 Punkte, b200.mat=200, b14.mat=14
b=ans.h';
xhist=zeros(length(b),1);
for i=1:length(amdemodsignal)
    circshift(xhist,[1,0]);
    xhist(1)=amdemodsignal(i);
    amdemodsignal(i)=sum(xhist.*b);
    if mod(i,100000) == 0%"Fortschritts"balken
        fprintf('%i|',i);
    end
    if mod(i,1400000) == 0
        fprintf('\n');
    end
end
%Bis hier um den Filter auszukommentieren
clear b xhist

%Dezimation naiv reicht, Parameter Nth muss genau austariert werden
Nth=26;%nur jedes Nte bit nehmen
decisignal=[1:floor(size(amdemodsignal)/Nth)]';
for i=1:floor(size(amdemodsignal)/Nth)
    decisignal(i)=amdemodsignal(i*Nth);
end
clear amdemosignal

%FM-Demodulation
fmdemod = angle(conj(decisignal(1:end-1)).*decisignal(2:end));
clear decisignal

%Carrier-Frequency-Error ausgleichen! (Highpass 15-20Hz, IIR?)
filteredfmdemod=fmdemod;
load('IIRCoeff.mat');
filteredfmdemod = filter(IIRCoeff,fmdemod);
clear fmdemod

%Für das Radio kopieren und das Signal filtern (Lowpass zwischen 15-19kHz)
filteredtonsignal=filteredfmdemod;
%Ab hier den Filter auskommentieren
open radiotonfilter200.mat;
b=ans.h';
xhist=zeros(length(b),1);
for i=1:length(filteredtonsignal)
    circshift(xhist,[1,0]);
    xhist(1)=filteredtonsignal(i);
    filteredtonsignal(i)=sum(xhist.*b);
    if mod(i,100000) == 0%"Fortschritts"balken
        fprintf('%i|',i);
    end
    if mod(i,1400000) == 0
        fprintf('\n');
    end
end
%Bis hier um den Filter auszukommentieren

sound(filteredtonsignal,floor(2.5*10^6/Nth));

%Komplett fehlend: RDS!!!, ausgehend von filteredfmdemod
