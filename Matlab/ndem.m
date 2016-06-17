clear
close all

AUDIO_ONLY = 1;		%skips the RDS part

debugread=0;
if debugread==0
fileID = fopen('samples.bin');
inputdata=fread(fileID,'uint8');
fclose(fileID);
else
%! nur hexwerte in einer Zeile erlaubt!!!
% fileID = fopen('dump1.txt');
% inputdata=textscan(fileID,'%2c',100000);
% fclose(fileID);
inputdata = textread('dump1.txt','%2c');
inputdata=hex2dec(char(inputdata));
end
%Einlesen und IQ aus Datenpunkten aufbauen
anzsamp=floor(size(inputdata)/(2^4));%Anz der einzulesenden Datenpunkte
inputdata=inputdata-127;
IQ=inputdata(1:2:anzsamp-1)+1i.*inputdata(2:2:anzsamp);
clear inputdata anzsamp fileID

%Mixer
t=(0:size(IQ)-1)*1/(2.5*10^6);%von 0-IQsize*1/Fs         
mixedsignal99_9MHz=IQ.*exp(-1i*2*pi*(-0.6*10^6)*t');
clear IQ

%Lowpass filter
%load('fir_lowpass_400_60kHz.mat');%b.mat=400 Punkte, b200.mat=200, b14.mat=14, Erstellt mit filterremeztest
%b=h.';
% xhist=zeros(length(b),1);
% for index=1:length(mixedsignal99_9MHz)
%    xhist=circshift(xhist,[1,0]);
%    xhist(1)=mixedsignal99_9MHz(index);
%    mixedsignal99_9MHz(index)=sum(xhist.*b);
% end
%Bis hier um den Filter auszukommentieren

%IIR Filter als Referenz
load('iir_lowpass_5_60kHz_num.mat');
b=num';
load('iir_lowpass_5_60kHz_den.mat');
a=den';

b=b.*(1/a(1));
a=a.*(1/a(1));

beforedecsignal=filter(b,a,mixedsignal99_9MHz);

%a=a(2:end);
%a=-1*a;
%xhist=zeros(length(b),1);
%yhist=zeros(length(a),1);
%for index=1:length(mixedsignal99_9MHz)
%   xhist=circshift(xhist,[1,0]);
%   xhist(1)=mixedsignal99_9MHz(index);
%   beforedecsignal(index)=sum(xhist.*b)+sum(yhist.*a);
%   yhist=circshift(yhist,[1,0]);
%   yhist(1)=beforedecsignal(index);
%end
%Bis hier Filter auskommentieren

clear mixedsignal99_9MHz

%Decimation
Nth=20;		%take every 20th sample
decisignal=[1:floor(size(beforedecsignal)/Nth)]';
for index=1:floor(size(beforedecsignal)/Nth)
    decisignal(index)=beforedecsignal(index*Nth);
end

clear beforedecsignal

%FM-Demodulation
%fmdemod = angle(conj(decisignal(1:end-1)).*decisignal(2:end));
%fmdemod = imag(conj(decisignal(1:end-1)).*decisignal(2:end));

%taken from web.stanford.edu/class/ee179/labs/Lab5.html
dl = decisignal./abs(decisignal);
%differentiator filter for the fmdemodulation
hd = firls(30,[0 100000 127000 128000]/128000, [0 1 0 0], 'differentiator');

signal = filter(hd, 1, dl);
signal((length(t)/Nth):(length(t)/Nth+15)) = 0;
fmdemod = imag(signal(16:(length(t)/Nth)+15).*conj(dl));



%eig ja fmdemod = imag(conj(decisignal(1:end-1)).*decisignal(2:end)); in HW
clear decisignal



%lowpass filter the audio signal
load('iir_lowpass_4_12kHz_num.mat');
b=num';
load('iir_lowpass_4_12kHz_den.mat');
a=den';
filteredtonsignal=filter(b,a,fmdemod);
%filteredtonsignal=fmdemod;
 

%clear up the audio signals
clear a b xhist yhist index

sound(filteredtonsignal,floor(2.5*10^6/Nth));


%RDS from fmdemod

if AUDIO_ONLY == 0
%synchronization with respect to the 19kHz pilot tone
%retrieve the pilot tone
load('iir_bandpass_7_19kHz_den.mat');
a=den.';
load('iir_bandpass_7_19kHz_num.mat');
b=num.';
pilotTone = filter(b,a,fmdemod);

%the PLL has trouble handling the pilot tone, when it gets too large
pilotTone = 2*pilotTone;

%Initialize PLL Loop
f = 19000;	%carrier frequency
fs = (2.5*10^6)/Nth;
phi_hat(1)=30; 
e(1)=0; 
phd_output(1)=0; 
vco = zeros(size(pilotTone));
%Define Loop Filter parameters (sets damping)
kp=0.15; %Proportional constant 
ki=0.1; %Integrator constant 


symbolRate = 1187.5;
bitRate = 2*symbolRate;
bitDur = floor(fs/(bitRate));
vcoRiseEdgeCounter = 2;
bitDurInVcoEdges = 19000/bitRate;	%number of rising edges of the 19kHz vco during a bit duration
phase = 2*pi*5/12;

%matched filter
load('RDSmatched_other.mat');
b=h.';
xhist=zeros(length(b),1);

load('fir_lowpass_400_2_4kHz.mat');
bLow=h.';
xhistLow=zeros(length(bLow),1);

samplePoints = zeros(size(pilotTone)) - 0.3;
samplePointsBiphase = zeros(size(pilotTone)) - 0.3;
biphasesymbols=zeros(ceil(length(pilotTone)/(bitDur)),1);
biphaseindex=1;
samples = zeros(100,1);	%samples during one bit clock
sampleCounter = 1;
timeAfterZeroCrossing = -10000;
locked = 0;		%if 1, then we have found two successive valid bits with the same value
				%meaning that we now know where a symbol starts
startOfSymbol = 1;
symbols = zeros(ceil(size(biphasesymbols)/2)) - 0.3;
symbolsIndex = 1;
index=1;
sampleInt = zeros(size(pilotTone)) - 0.3;
sampleDur = floor(9/16*bitDur);
validThreshold = 0.03;
bitsymbolsIndex = 1;
bitsymbols = zeros(ceil(length(biphasesymbols)/2),1) - 1;
sampleBitSymb = zeros(size(pilotTone)) - 0.3;
lockedHere = zeros(size(pilotTone));

for n=2:length(pilotTone) 
	%PLL implementation 
	vco(n)=conj(exp(1i*(2*pi*n*f/fs+phi_hat(n-1))));	%Compute VCO 
	phd_output(n)=imag(pilotTone(n)*vco(n));	%Complex multiply VCO x pilotTone input 
	e(n)=e(n-1)+(kp+ki)*phd_output(n)-ki*phd_output(n-1);	%Filter integrator 
	phi_hat(n)=phi_hat(n-1)+e(n);	%Update VCO 
    vco3(n) = vco(n) * vco(n) * vco(n);
	%mixing
	mixedsignal(n) = fmdemod(n) * vco3(n) * exp(1i*phase);

	%Matched Filter
    xhist=circshift(xhist,[1,0]);
    xhist(1)=mixedsignal(n);
    mixedsignal(n)=sum(xhist.*b);

	%%additional low pass filter
    %xhistLow=circshift(xhistLow,[1,0]);
    %xhistLow(1)=mixedsignal(n);
    %mixedsignal(n)=sum(xhistLow.*bLow);
	
	%detect rising edge in vco
	if(real(vco(n-1)) < 0 && real(vco(n)) >= 0)
		vcoRiseEdgeCounter = vcoRiseEdgeCounter + 1;
	end

	%use the 19kHz pilot for sampling
	if vcoRiseEdgeCounter == bitDurInVcoEdges
		%phase correction
		a = sign(mixedsignal(n));
		phase = phase - 0.3*angle(a*mixedsignal(n));

		biphasesymbols(biphaseindex) = mixedsignal(n);
		samplePoints(n) = mixedsignal(n);
		vcoRiseEdgeCounter = 0;

		%symbol decoding
		if (locked == 0) && (biphaseindex > 1)
			symbCurSign = sign(real(biphasesymbols(biphaseindex)));
			symbOldSign = sign(real(biphasesymbols(biphaseindex-1)));
			if symbCurSign == symbOldSign && (abs(real(biphasesymbols(biphaseindex))) > validThreshold) && (abs(real(biphasesymbols(biphaseindex-1))) > validThreshold)
				locked = 1;
				startOfSymbol = 0;
				lockedHere(n) = 0.1;
			end
		elseif locked == 1
			if startOfSymbol == 0
				symbCurSign = sign(real(biphasesymbols(biphaseindex)));
				symbOldSign = sign(real(biphasesymbols(biphaseindex-1)));
				
				%symbol 1
				if real(biphasesymbols(biphaseindex-1)) > real(biphasesymbols(biphaseindex))
					symbols(symbolsIndex) = abs(real(biphasesymbols(biphaseindex-1) - biphasesymbols(biphaseindex))) + 1*i*imag(biphasesymbols(biphaseindex-1) - biphasesymbols(biphaseindex));
					bitsymbols(bitsymbolsIndex) = 1;
					sampleBitSymb(n) = 0.1;
				%symbol 0
				elseif real(biphasesymbols(biphaseindex-1)) < real(biphasesymbols(biphaseindex))
					symbols(symbolsIndex) = -abs(real(biphasesymbols(biphaseindex-1) - biphasesymbols(biphaseindex))) + 1*i*imag(biphasesymbols(biphaseindex-1) - biphasesymbols(biphaseindex));
					bitsymbols(bitsymbolsIndex) = 0;
					sampleBitSymb(n) = -0.1;
				end
				bitsymbolsIndex = bitsymbolsIndex + 1;
				symbolsIndex = symbolsIndex + 1;
				startOfSymbol = 1;
			else
				startOfSymbol = 0;
			end
		end
		biphaseindex = biphaseindex + 1;
	end

	%%detect zero-crossing in the mixed signal
    %if(real(mixedsignal(n-1)) > 0 && real(mixedsignal(n)) < 0) || (real(mixedsignal(n-1)) < 0 && real(mixedsignal(n)) > 0)
	%	timeAfterZeroCrossing = 0;

	%	%%symbol clock correction
	%	%vcoRiseEdgeCounter = ceil(bitDurInVcoEdges/2);
    %end
	%if timeAfterZeroCrossing == ceil(bitDur/2)
	%	%phase correction
	%	a = sign(real(mixedsignal(n)));
	%	phase = phase - 0.3*angle(a*mixedsignal(n));

	%	%timeAfterZeroCrossing = -ceil(bitDur/2);
	%	%biphaseindex = biphaseindex + 1;
	%end

	%%reset samples
	%if timeAfterZeroCrossing == 0 || timeAfterZeroCrossing == bitDur
	%	samples = zeros(100,1);
	%	sampleInt(n) = 0.1;
	%	sampleCounter = 0;
    %end

	%%bit interpretation
	%if (timeAfterZeroCrossing == floor(sampleDur)) || (timeAfterZeroCrossing == (bitDur + floor(sampleDur)))
	%	[~, index] = max(abs(real(samples(1:bitDur))));
	%	biphasesymbols(biphaseindex) = samples(index);
	%	samplePoints(n-sampleDur+index) = samples(index);
	%	%symbol decoding
	%	if (locked == 0) && (biphaseindex > 1)
	%		symbCurSign = sign(real(biphasesymbols(biphaseindex)));
	%		symbOldSign = sign(real(biphasesymbols(biphaseindex-1)));
	%		if symbCurSign == symbOldSign
	%			locked = 1;
	%			startOfSymbol = 0;
	%		end
	%	elseif locked == 1
	%		if startOfSymbol == 0
	%			symbCurSign = sign(real(biphasesymbols(biphaseindex)));
	%			symbOldSign = sign(real(biphasesymbols(biphaseindex-1)));
	%			%most likely an error happened and the symbol start needs to be reset
	%			if symbCurSign == symbOldSign
	%				startOfSymbol = 0;

	%				%store the last symbol as this symbol (just to get the expected number of symbols and not skip any)
	%				if symbolsIndex > 1
	%					symbols(symbolsIndex) = symbols(symbolsIndex-1);
	%				else symbols(symbolsIndex) = biphasesymbols(biphaseindex);
	%				end
	%				symbolsIndex = symbolsIndex + 1;
	%			%decode the biphase symbol
	%			else
	%				symbols(symbolsIndex) = (biphasesymbols(biphaseindex-1) - biphasesymbols(biphaseindex));
	%				symbolsIndex = symbolsIndex + 1;
	%				startOfSymbol = 1;
	%				sampleBitSymb(n) = real(symbols(symbolsIndex-1));
	%			end
	%		else
	%			startOfSymbol = 0;
	%		end
	%	end
	%	biphaseindex = biphaseindex + 1;
	%	sampleInt(n) = 0.05;
	%end
	% 
	%timeAfterZeroCrossing = timeAfterZeroCrossing + 1;
	%sampleCounter = sampleCounter + 1;
	%%wait with the sampling until the first zero crossing (only relevent in the beginning)
	%if timeAfterZeroCrossing > 0
	%	samples(sampleCounter) = mixedsignal(n);
	%end;
end
clear a b e f n fs phd_output phi_hat sampleCounter ki kp
clear startOfSymbol t symbCurSign symbOldSign symbolRate h phase
clear sampleDur vcoRiseEdgeCounter xhist bitDur bitDurInVcoEdges
clear bitRate index timeAfterZeroCrossing

draw = 1;
if draw == 1
    %figure 
    %plot(abs(fftshift(fft(fmdemod))));
    
    figure 
    plot(abs(fftshift(fft(vco))),'r');
    
	figure
	plot(real(mixedsignal),'g');
	hold on
	plot(sampleBitSymb, 'b.');
	hold on
	plot(real(samplePoints), 'r.')
	hold on
	plot(real(lockedHere), 'y');

	figure
	plot(pilotTone,'r');
	hold on
	plot(real(vco),'g');
    hold on
    plot(real(vco3),'b');
end
clear mixedsignal samplePoints samplePointsBiphase

if draw == 1
	figure
    axis normal;
	plot(biphasesymbols,'b.');
	%hold on
	%plot(symbols,'g.');
end

%clear biphasesymbols

%clear symbols
%Decodieren (=Aufruf des C-Teils, ein Teil soll dann aber HW werden)
fileID = fopen('decodedaten.txt','w');
fprintf(fileID,'%d\n',bitsymbols);
fclose(fileID);
%!./RDSDecoder < decodedaten.txt
end
