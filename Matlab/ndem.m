clear
close all

fileID = fopen('samples.bin');
inputdata=fread(fileID,'uint8');
fclose(fileID);
%Einlesen und IQ aus Datenpunkten aufbauen
anzsamp=floor(size(inputdata)/(2^7));%Anz der einzulesenden Datenpunkte
inputdata=inputdata-127;
IQ=inputdata(1:2:anzsamp-1)+1i.*inputdata(2:2:anzsamp);
clear inputdata anzsamp fileID

%f=[-6000000:6000000];
%plot(f,abs(fftshift(fft(IQ(1:length(f))))))

%Mixer
t=(0:size(IQ)-1)*1/(2.5*10^6);%von 0-IQsize*1/Fs         
mixedsignal99_9MHz=IQ.*exp(-1i*2*pi*(-0.6*10^6)*t');
clear IQ

%Lowpass filter
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

clear mixedsignal99_9MHz

%Decimation
Nth=20;		%take every 20th sample
decisignal=[1:floor(size(beforedecsignal)/Nth)]';
for index=1:floor(size(beforedecsignal)/Nth)
    decisignal(index)=beforedecsignal(index*Nth);
end

clear beforedecsignal

%FM-Demodulation
fmdemod = angle(conj(decisignal(1:end-1)).*decisignal(2:end));
%alternative - does not work
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

%lowpass filter the audio signal
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
 

%clear up the audio signals
clear a b xhist yhist index

%sound(filteredtonsignal,floor(2.5*10^6/Nth));


%RDS from fmdemod
%f=[-600:600];
%plot(f,abs(fftshift(fft(fmdemod(1:length(f))))))

%synchronization with respect to the 19kHz pilot tone
%retrieve the pilot tone

load('fir_bandpass_557_19kHz.mat');
b=h';
pilotTone = filter(b,1,fmdemod);
%plot(f,abs(fftshift(fft(pilotTone(1:length(f))))))

%attempt to build a phase locked loop by hand
K0 = 200;	%frequency gain of the variable frequency generator
t=(0:size(fmdemod)-1)/(floor(2.5*10^6/Nth));

%initialize filter
load('fir_lowpass_100_1kHz.mat');
b=h';
xhist = zeros(length(b),1);
filteredProduct = zeros(size(pilotTone));
for z = 1:length(pilotTone)
	%multiply the pilot tone with the synchronized signal
	if z == 1
		product = real(pilotTone(z))*0.0;
	else
		product = real(pilotTone(z))*synchronizedSig;
	end

	%low pass filtering
	 xhist = circshift(xhist,[1,0]);
	 xhist(1) = product;
	 filteredProduct(z) = sum(xhist.*b);	%the phase difference as steady component in filteredProduct

	 %variable frequency synthesis
	 synchronizedSig = cos((2*pi*19000 + K0*filteredProduct(z))*t(z));
end
clear xhist

figure
plot(0.55*cos(2*pi*19000*t' + K0*filteredProduct.*t'), 'g');
hold on
plot(real(pilotTone),'r');

%mixing
t=(0:size(fmdemod)-1)/(floor(2.5*10^6/Nth));
mixedsignal = fmdemod.*cos(-2*pi*(57000 + K0*filteredProduct(z))*t')+1i*fmdemod.*sin(-2*pi*(57000 + K0*filteredProduct(z))*t');
clear fmdemod


%f=[-6000:6000];
%figure
%f=[-size(t,2)/2+1:size(t,2)/2];
%plot(f,abs(fftshift(fft(pilotTone(1:length(f))))),'r');
%hold on
%f=[-size(t,2)/2+1:size(t,2)/2];
%plot(f,abs(fftshift(fft(sin(2*pi*19000*t')/100))),'g');


%%"phase correction"
%phaseCorrection = 0;
%for z = 1:size(mixedsignal)
%	phaseCorrectedSig(z) = mixedsignal(z) * exp(-1*i*phaseCorrection);
%	phase = angle(mixedsignal(z));
%	if (mod(phase-phaseCorrection, 2*pi) > pi/2) & (mod(phase - phaseCorrection, 2*pi) < 3*pi/2)
%		phaseCorrection = phaseCorrection + ((phase-phaseCorrection)-pi);
%	else
%		phaseCorrection = phaseCorrection + (phase-phaseCorrection);
%	end;
%end

%figure
%plot(phaseCorrectedSig, 'g.');
%hold on
%plot(mixedsignal, 'r.');

%Matched Filter
load('RDSmatched.mat');
b=h';
mfsignal=filter(b,1,mixedsignal);
clear mixedsignal

%Symbol detection

biphasesymbols=zeros(ceil(length(mfsignal)/52),1);
indexliste=zeros(ceil(length(mfsignal)/52),1)-1;
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
phaseCorrection = 0;

while index+26< length(mfsignal)
      %zero-crossing detection
      if(real(exp(1*i*phaseCorrection)*mfsignal(index)) > 0 && real(exp(1*i*phaseCorrection)*mfsignal(index+1)) < 0) || (real(exp(1*i*phaseCorrection)*mfsignal(index)) < 0 && real(exp(1*i*phaseCorrection)*mfsignal(index+1)) > 0)
          index = index + 26;	%advance by the half the symbol duration
		  biphasesymbols(biphaseindex) = mfsignal(index);
		  biphaseindex = biphaseindex + 1;
		  timeToZeroCrossing = 0;

		  %phase correction? (the phase should actually be fed back to estimate the carrier...)
		  phase = (angle(mfsignal(index)) - phaseCorrection);
		  if (mod(phase, 2*pi) > pi/2) & (mod(phase, 2*pi) < 3*pi/2)
		    	phaseCorrection = phaseCorrection + phase-pi;
		  else
		    	phaseCorrection = phaseCorrection + phase;
		  end;
	  elseif timeToZeroCrossing > 52
	      biphasesymbols(biphaseindex) = mfsignal(index);
		  timeToZeroCrossing = 0;
      end
	timeToZeroCrossing = timeToZeroCrossing + 1;
    index = index + 1;
end

figure
plot(biphasesymbols,'g.');

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

