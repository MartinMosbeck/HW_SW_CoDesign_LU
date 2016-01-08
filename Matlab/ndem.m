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

%NICHT AUSKOMMENTIEREN!
%f=[-6000000:6000000];
%plot(f,abs(fftshift(fft(IQ(1:length(f))))))

%Mixer
t=(0:size(IQ)-1)*1/(2.5*10^6);%von 0-IQsize*1/Fs         
mixedsignal99_9MHz=IQ.*exp(-1i*2*pi*(-0.6*10^6)*t');
clear IQ

%Filter f�r die Frequenzen �ber 100kHz, auskommentieren schaltet Filter aus
load('fir_lowpass_400_60kHz.mat');%b.mat=400 Punkte, b200.mat=200, b14.mat=14, Erstellt mit filterremeztest
b=h';
% xhist=zeros(length(b),1);
% for index=1:length(mixedsignal99_9MHz)
%    xhist=circshift(xhist,[1,0]);
%    xhist(1)=mixedsignal99_9MHz(index);
%    mixedsignal99_9MHz(index)=sum(xhist.*b);
%    if mod(index,100000) == 0%"Fortschritts"balken
%        fprintf('%i|',index);
%    end
%    if mod(index,1400000) == 0
%        fprintf('\n');
%    end
% end
%Bis hier um den Filter auszukommentieren

beforedecsignal=filter(b,1,mixedsignal99_9MHz);

clear mixedsignal99_MHz

%Dezimation naiv reicht, Parameter Nth muss genau austariert werden
Nth=20;%nur jedes Nte bit nehmen
decisignal=[1:floor(size(beforedecsignal)/Nth)]';
for index=1:floor(size(beforedecsignal)/Nth)
    decisignal(index)=beforedecsignal(index*Nth);
end

clear beforedecsignal

%FM-Demodulation
fmdemod = angle(conj(decisignal(1:end-1)).*decisignal(2:end));
%alternativ - funktioniert nicht
% load('fmdemodulate30.mat');
% b=hd';
% xhist=zeros(length(b),1);
% filtereddecisignal=decisignal;
% for index=1:length(decisignal)
%    xhist=circshift(xhist,[1,0]);
%    xhist(1)=decisignal(index);
%    filtereddecisignal(index)=sum(xhist.*b);
%    if mod(index,100000) == 0%"Fortschritts"balken
%        fprintf('%i|',index);
%    end
%    if mod(index,1400000) == 0
%        fprintf('\n');
%    end
% end
% fmdemod = imag(filtereddecisignal.*conj(decisignal));
%clear decisignal

%Carrier-Frequency-Error ausgleichen! (Highpass 15-20Hz, IIR) Filter
% load('15HfilterIIR3.mat');
% b=b';
% a=a';
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

%F�r das Radio kopieren und das Signal filtern (Lowpass zwischen 15-19kHz)
%filteredtonsignal=fmdemod;
%Ab hier den Filter auskommentieren
load('fir_lowpass_400_15kHz.mat');
b=h';
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
 filteredtonsignal=filter(b,1,fmdemod);
 
%Bis hier um den Filter auszukommentieren

%Filtervariablen Radioteil aufr�umen
clear a b xhist yhist index

sound(filteredtonsignal,floor(2.5*10^6/Nth));

%RDS, ausgehend von fmdemod
%Ab hier erste Versuche mit RDS
% 
f=[-60000:60000];
plot(f,abs(fftshift(fft(fmdemod(1:length(f))))))
t=(0:size(fmdemod)-1)*1/(floor(2.5*10^6));
IQfmdemod = fmdemod.*cos(2*pi*57000*t')+1i*fmdemod.*cos(2*pi*57000*t'+90);
mixedsignal=IQfmdemod.*exp(-1i*2*pi*(-57000)*t');
clear IQfmdemod decisignal

for z = 1:size(mixedsignal)
	phaseCorrection = angle(mixedsignal(z));
	if (phaseCorrection > pi/2) & (phaseCorrection < 3*pi/2)
		phaseCorrectedSig(z) = mixedsignal(z)*exp(-1*i*(phaseCorrection+pi));
	else
		phaseCorrectedSig(z) = mixedsignal(z)*exp(-1*i*phaseCorrection);
	end;
end

figure
plot(phaseCorrectedSig, 'g.');

%Matched Filter
load('RDSmatched.mat');
b=h';
mfsignal=filter(b,1,phaseCorrectedSig);
clear mixedsignal phaseCorrectedSig

%BIPHASER
%Idee=alle drei verbleibenden Schritte bis zu den Biphasesymbolen mit dem
%Algo

biphasesymbols=zeros(ceil(length(mfsignal)/105),1)-1;
indexliste=zeros(ceil(length(mfsignal)/105),1)-1;
biphaseindex=1;
index=1;
lastbiphase=0;
startvalueindex1=1;
startvalueindex2=1;
timeToZeroCrossing=0;
%Teil 1: guten Startwert finden durch suchen eines Zero-Crossings
%while index+1<length(mfsignal)
     %Debugausgabe
%      if (real(mfsignal(index))>0 && real(mfsignal(index+1))<0)
%         startvalue(1,startvalueindex1)=index;
%         startvalueindex1=startvalueindex1+1;
%      elseif (real(mfsignal(index))<0 && real(mfsignal(index+1))>0)
%         startvalue(2,startvalueindex2)=index;
%         startvalueindex2=startvalueindex2+1;
%      end
%      zero-crossing detection
%     index=index+1;
%end
%intervalmid=53+startvalue(1,1);%Zero +53 ist ca. der h�chste (Daten-)wert
corrector=0;
index = 1;

while index+1 < length(mfsignal)
      %zero-crossing detection
      if(real(mfsignal(index)) > 0 && real(mfsignal(index+1)) < 0) || (real(mfsignal(index)) < 0 && real(mfsignal(index+1)) > 0)
          index = index + 53;	%advance by the half the symbol duration
		  biphasesymbols(biphaseindex) = mfsignal(index);
		  biphaseindex = biphaseindex + 1;
		  timeToZeroCrossing = 0;
	  elseif timeToZeroCrossing > 105
	      biphasesymbols(biphaseindex) = mfsignal(index);
		  timeToZeroCrossing = 0;
      end
	timeToZeroCrossing = timeToZeroCrossing + 1;
    index = index + 1;
end
%Teil 2: ca. alle 105 Werte einen RDS-Wert rauslesen, CLockphase und Carrier
%Estimation implizit mit dem Korrektor
% while intervalmid+abs(corrector)<length(mfsignal)
%     [~,maxindex]=max(abs(real(mfsignal(intervalmid-4:intervalmid+4))));
%     biphasesymbols(biphaseindex)=mfsignal(maxindex+intervalmid-5);
%     indexliste(biphaseindex)=maxindex+intervalmid-5;
%     biphaseindex=biphaseindex+1;
%     corrector=maxindex-5;
%     intervalindexes(biphaseindex-1)=intervalmid;
%     intervalmid=intervalmid+105-corrector;
% end
