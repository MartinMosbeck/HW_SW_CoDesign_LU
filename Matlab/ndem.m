clear
close all

fileID = fopen('samples.bin');
inputdata=fread(fileID,'uint8');
fclose(fileID);
%Einlesen und IQ aus Datenpunkten aufbauen
anzsamp=floor(size(inputdata)/(2^6));%Anz der einzulesenden Datenpunkte
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
b=h.';
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
b=h.';
 filteredtonsignal=filter(b,1,fmdemod);
 

%clear up the audio signals
clear a b xhist yhist index

%sound(filteredtonsignal,floor(2.5*10^6/Nth));


%RDS from fmdemod
%f=[-600:600];
%plot(f,abs(fftshift(fft(fmdemod(1:length(f))))))

%synchronization with respect to the 19kHz pilot tone
%retrieve the pilot tone
load('fir_bandpass_165_19kHz.mat');
b=h.';
pilotTone = filter(b,1,fmdemod);

f=[-6000:6000];
%figure
%f=[-size(t,2)/2+1:size(t,2)/2];
%plot(f,abs(fftshift(fft(fmdemod(1:length(f))))));
%hold on
%plot(f,abs(fftshift(fft(pilotTone(1:length(f))))))

%Initialize PLL Loop 
f = 19000;	%carrier frequency
fs = (2.5*10^6)/Nth;
phi_hat(1)=30; 
e(1)=0; 
phd_output(1)=0; 
vco(1)=0; 
%Define Loop Filter parameters (sets damping)
kp=0.15; %Proportional constant 
ki=0.1; %Integrator constant 


symbolRate = 1187.5;
bitFreq = 2*symbolRate;
bitDur = floor(fs/(bitFreq));
vcoRiseEdgeCounter = 0;
bitDurInVcoEdges = 19000/bitFreq;	%number of rising edges of the 19kHz vco during a bit duration
phase = 2*pi*2/7;

load('RDSmatched.mat');
b=h.';
xhist=zeros(length(b),1);
samplePoints = zeros(size(pilotTone)) -0.3;

for n=2:length(pilotTone) 
	%PLL implementation 
	vco(n)=conj(exp(j*(2*pi*n*f/fs+phi_hat(n-1))));	%Compute VCO 
	phd_output(n)=imag(pilotTone(n)*vco(n));	%Complex multiply VCO x pilotTone input 
	e(n)=e(n-1)+(kp+ki)*phd_output(n)-ki*phd_output(n-1);	%Filter integrator 
	phi_hat(n)=phi_hat(n-1)+e(n);	%Update VCO 

	%figure
	%plot(pilotTone,'r');
	%hold on
	%plot(0.55*real(vco),'g');

	%mixing
	mixedsignal(n) = fmdemod(n) * vco(n) * exp(i*phase);
	mixedsignal(n) = mixedsignal(n) * vco(n) * exp(i*phase);
	mixedsignal(n) = mixedsignal(n) * vco(n) * exp(i*phase);

	%Matched Filter
    xhist=circshift(xhist,[1,0]);
    xhist(1)=mixedsignal(n);
    mixedsignal(n)=sum(xhist.*b);
	
	%detect rising edge in vco
	if(real(vco(n-1)) < 0 && real(vco(n)) > 0)
		vcoRiseEdgeCounter = vcoRiseEdgeCounter + 1;
	end
	if vcoRiseEdgeCounter >= bitDurInVcoEdges
		samplePoints(n) = 0.3;
		a = sign(mixedsignal(n));
		phase = phase - 0.3*angle(a*mixedsignal(n));
		vcoRiseEdgeCounter = 0;
	end

	detect zero-crossing in the mixed signal
	if(real(mixedsignal(n-1)) > 0 && real(mixedsignal(n)) < 0) || (real(mixedsignal(n-1)) < 0 && real(mixedsignal(n)) > 0)
		a = sign(mixedsignal(n));
		phase = phase - angle(a*mixedsignal(n));
		vcoRiseEdgeCounter
		vcoRiseEdgeCounter = 0;
	end

end


figure
plot(real(mixedsignal),'g');
hold on
plot(samplePoints, 'r')

%Symbol detection
biphasesymbols=zeros(ceil(length(mixedsignal)/(bitDur+1)),1);
biphaseindex=1;
index=1;
timeToZeroCrossing=0;

while index + floor(bitDur/2) < length(mixedsignal)
      %zero-crossing detection
      if(real(mixedsignal(index)) > 0 && real(mixedsignal(index+1)) < 0) || (real(mixedsignal(index)) < 0 && real(mixedsignal(index+1)) > 0)
          index = index + floor(bitDur/2);	%advance by the half the symbol duration
		  biphasesymbols(biphaseindex) = mixedsignal(index);
		  biphaseindex = biphaseindex + 1;
		  timeToZeroCrossing = 0;

		  %%phase correction? (the phase should actually be fed back to estimate the carrier...)
		  %phase = (angle(mixedsignal(index)) - phaseCorrection);
		  %if (mod(phase, 2*pi) > pi/2) & (mod(phase, 2*pi) < 3*pi/2)
		  %  	phaseCorrection = phaseCorrection + phase-pi;
		  %else
		  %  	phaseCorrection = phaseCorrection + phase;
		  %end;
	  elseif timeToZeroCrossing > bitDur
	      biphasesymbols(biphaseindex) = mixedsignal(index);
		  timeToZeroCrossing = 0;
      end
	timeToZeroCrossing = timeToZeroCrossing + 1;
    index = index + 1;
end

figure
plot(biphasesymbols,'g.');
