clear
close all

fileID = fopen('samples.bin');
inputdata=fread(fileID,'uint8');
fclose(fileID);
%Einlesen und IQ aus Datenpunkten aufbauen
anzsamp=size(inputdata);%Anz der einzulesenden Datenpunkte
inputdata=inputdata-127;
IQ=inputdata(1:2:anzsamp-1)+1i.*inputdata(2:2:anzsamp);
clear inputdata anzsamp fileID

%AM-Demodulation
t=(0:size(IQ)-1)*1/(2.5*10^6);%von 0-IQsize*1/Fs
amdemodsignal=IQ.*exp(-1i*2*pi*(-0.6*10^6)*t');
clear IQ

%Filter für die Frequenzen über 100kHz, auskommentieren schaltet Filter aus
% open 100kHfilter14.mat; %b.mat=400 Punkte, b200.mat=200, b14.mat=14
% Erstellt mit filterremeztest
% b=ans.h';
% xhist=zeros(length(b),1);
% for index=1:length(amdemodsignal)
%    xhist=circshift(xhist,[1,0]);
%    xhist(1)=amdemodsignal(index);
%    amdemodsignal(index)=sum(xhist.*b);
%    if mod(index,100000) == 0%"Fortschritts"balken
%        fprintf('%i|',index);
%    end
%    if mod(index,1400000) == 0
%        fprintf('\n');
%    end
% end
%Bis hier um den Filter auszukommentieren

%Dezimation naiv reicht, Parameter Nth muss genau austariert werden
Nth=26;%nur jedes Nte bit nehmen
decisignal=[1:floor(size(amdemodsignal)/Nth)]';
for index=1:floor(size(amdemodsignal)/Nth)
    decisignal(index)=amdemodsignal(index*Nth);
end
clear amdemodsignal

%FM-Demodulation
fmdemod = angle(conj(decisignal(1:end-1)).*decisignal(2:end));
clear decisignal

%Carrier-Frequency-Error ausgleichen! (Highpass 15-20Hz, IIR) Filter
% open 15HfilterIIR3.mat
% b=ans.b';
% a=ans.a';
% b=b.*(1/a(1));
% a=a.*(1/a(1));
% a=a(2:end);
% a=-1*a;
% xhist=zeros(length(b),1);
% yhist=zeros(length(a),1);
% for index=1:length(fmdemod)
%     xhist=circshift(xhist,[1,0]);
%     xhist(1)=fmdemod(index);
%     fmdemod(index)=sum(xhist.*b)+sum(yhist.*a);
%     yhist=circshift(yhist,[1,0]);
%     yhist(1)=fmdemod(index);
%     if mod(index,100000) == 0%"Fortschritts"balken
%         fprintf('%i|',index);
%     end
%     if mod(index,1400000) == 0
%         fprintf('\n');
%     end
% end
%Bis hier Filter auskommentieren

%Für das Radio kopieren und das Signal filtern (Lowpass zwischen 15-19kHz)
filteredtonsignal=fmdemod;
%Ab hier den Filter auskommentieren
% open 19kHfilter200.mat
% b=ans.h';
% xhist=zeros(length(b),1);
% for index=1:length(filteredtonsignal)
%     xhist=circshift(xhist,[1,0]);
%     xhist(1)=filteredtonsignal(index);
%     filteredtonsignal(index)=sum(xhist.*b);
%     if mod(index,100000) == 0%"Fortschritts"balken
%         fprintf('%i|',index);
%     end
%     if mod(index,1400000) == 0
%         fprintf('\n');
%     end
% end
%Bis hier um den Filter auszukommentieren

%Filtervariablen Radioteil aufräumen
clear a b xhist yhist index 

sound(filteredtonsignal,floor(2.5*10^6/Nth));

%RDS, ausgehend von fmdemod
%Ab hier erste Versuche mit RDS
t=(0:size(fmdemod)-1)*1/(floor(2.5*10^6/Nth));
IQfmdemod = fmdemod.*cos(2*pi*57000*t')+1i*fmdemod.*cos(2*pi*57000*t'+90);
fmdemod=IQfmdemod.*exp(-1i*2*pi*(-57000)*t');
clear IQfmdemod