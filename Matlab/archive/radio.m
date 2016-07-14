clear
close all

AUDIO_ONLY = 0;		%skips the RDS part
fs = 2.5*10^6;
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
anzsamp=floor(size(inputdata)/(2^7));%Anz der einzulesenden Datenpunkte
inputdata=inputdata-127;
IQ=inputdata(1:2:anzsamp-1)+1i.*inputdata(2:2:anzsamp);
clear inputdata anzsamp fileID

%Mixer
t=(0:size(IQ)-1)*1/(2.5*10^6);%von 0-IQsize*1/Fs         
mixedsignal99_9MHz=IQ.*exp(-1i*2*pi*(-0.6*10^6)*t');
tp = t;
clear IQ t

%60 kHz lowpass (FIR)
load('fir_lowpass_1500_60kHz_Fs2500000.mat');
b=h';

a = 1;

beforedecsignal=filter(b,a,mixedsignal99_9MHz);

clear mixedsignal99_9MHz

%Decimation
Nth=20;		%take every 20th sample
decisignal=[1:floor(size(beforedecsignal)/Nth)]';
for index=1:floor(size(beforedecsignal)/Nth)
    decisignal(index)=beforedecsignal(index*Nth);
end
fs = fs/Nth;

clear beforedecsignal


%taken from web.stanford.edu/class/ee179/labs/Lab5.html
dl = decisignal./abs(decisignal);
%differentiator filter for the fmdemodulation
hd = firls(30,[0 60000 61000 fs/2]/(fs/2), [0 1 0 0], 'differentiator');

%fvtool(hd);

signal = filter(hd, 1, dl);
signal(length(dl):length(dl)+15) = 0;
fmdemod = imag(signal(16:length(dl)+15).*conj(dl));

clear decisignal dl signal hd b a


%lowpass filter the audio signal
load('fir_lowpass_400_12kHz_Fs125000.mat');
b=h';
a = 1;
filteredtonsignal=filter(b,a,fmdemod);

sound(filteredtonsignal, fs);

%clear up the audio signals
clear a b xhist yhist index filteredtonsignal


%RDS from fmdemod

if AUDIO_ONLY == 0
%synchronization with respect to the 19kHz pilot tone
%retrieve the pilot tone
load('fir_bandpass_500_19kHz_Fs125000.mat');
b=h.';
a = 1;
pilotTone = filter(b,a,fmdemod);
clear a b

%the PLL has trouble handling the pilot tone, when the pilot tone's size differs too much from its own output
pilotTone = 2*pilotTone;

%Initialize PLL Loop
f = 19000;	%carrier frequency
%fs = (2.5*10^6)/Nth;
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
vcoRiseEdgeCounter = 0;
bitDurInVcoEdges = 19000/bitRate;	%number of rising edges of the 19kHz vco during a bit duration

%matched filter
%load('RDSmatched_other.mat');
load('RDSmatched.mat');
b=h.';

load('fir_lowpass_400_2kHz_Fs125000.mat');
bLow=h.';
xhistLow=zeros(length(bLow),1);

PHASE_STEPS = 12;

samplePoints = zeros(size(pilotTone)) - 0.3;
samplePointsBiphase = zeros(size(pilotTone)) - 0.3;
biphasesymbols=zeros(ceil(length(pilotTone)/(bitDur)), bitDurInVcoEdges, PHASE_STEPS);
biphaseindex=1;
samples = zeros(100,1);	%samples during one bit clock
sampleCounter = 1;
timeAfterZeroCrossing = -10000;
locked = 0;		%if 1, then we have found two successive valid bits with the same value
				%meaning that we now know where a symbol starts
startOfSymbol = 1;
symbols = zeros(ceil(size(biphasesymbols,1)/2), bitDurInVcoEdges, PHASE_STEPS);
symbolsIndex = 1;
index=1;
sampleInt = zeros(size(pilotTone)) - 0.3;
sampleDur = floor(9/16*bitDur);
validThreshold = 0.01;
bitsymbolsIndex = 1;
bitsymbols = zeros(ceil(size(biphasesymbols,1)/2),1) - 1;
sampleBitSymb = zeros(size(pilotTone)) - 0.3;
lockedHere = zeros(size(pilotTone));
mixedsignal = zeros(length(pilotTone), bitDurInVcoEdges, PHASE_STEPS);

phases = zeros(size(pilotTone));

%experimental mixing and machted filtering in one step without the pll
%t=(0:size(pilotTone)-1)/(fs);%von 0-IQsize*1/Fs         
%%mixing
%mixedsignal = fmdemod.*exp(-1i*2*pi*3*f*t' + 1i*2*pi*(1/4));
%%matched filtering
%mixedsignal = filter(b, 1, mixedsignal);
%figure
%plot(real(mixedsignal), 'g');
%figure
%plot(abs(fftshift(fft(mixedsignal))));

for phSteps = 1 : PHASE_STEPS
phase = 2*pi*(phSteps/PHASE_STEPS);
	for k = 1 : bitDurInVcoEdges
		vcoRiseEdgeCounter = k
		xhist=zeros(length(b),1);
		biphaseindex = 1;
		symbolsIndex = 1;
		locked = 0;
		startOfSymbol = 0;
		for n=2:length(pilotTone) 
			%PLL implementation 
			vco(n)=conj(exp(1i*(2*pi*n*f/fs+phi_hat(n-1))));	%Compute VCO 
			phd_output(n)=imag(pilotTone(n)*vco(n));	%Complex multiply VCO x pilotTone input 
			e(n)=e(n-1)+(kp+ki)*phd_output(n)-ki*phd_output(n-1);	%Filter integrator 
			phi_hat(n)=phi_hat(n-1)+e(n);	%Update VCO 
			vco3(n) = vco(n) * vco(n) * vco(n);
			%mixing
			mixedsignal(n, k, phSteps) = fmdemod(n) * vco3(n) * exp(1i*phase);

			%Matched Filter
			xhist=circshift(xhist,[1,0]);
			xhist(1)=mixedsignal(n, k, phSteps);
			mixedsignal(n, k, phSteps)=sum(xhist.*b);

			%additional low pass filter (cutoff at around 2kHz)
			%xhistLow=circshift(xhistLow,[1,0]);
			%xhistLow(1)=mixedsignal(n);
			%mixedsignal(n)=sum(xhistLow.*bLow);
			
			%detect rising edge in vco
			if(real(vco(n-1)) < 0 && real(vco(n)) >= 0)
				vcoRiseEdgeCounter = vcoRiseEdgeCounter + 1;
			end

			%use the 19kHz pilot for sampling
			if vcoRiseEdgeCounter >= bitDurInVcoEdges
				%phase correction
				%a = sign(mixedsignal(n, k, phSteps));
				%phase = phase - 0.3*angle(a*mixedsignal(n, k, phSteps));
				%phases(n) = phase;

				biphasesymbols(biphaseindex, k, phSteps) = mixedsignal(n, k, phSteps);
				samplePoints(n) = mixedsignal(n, k, phSteps);
				vcoRiseEdgeCounter = 0;

				%symbol decoding
				if (locked == 0) && (biphaseindex > 1)
					symbCurSign = sign(real(biphasesymbols(biphaseindex, k, phSteps)));
					symbOldSign = sign(real(biphasesymbols(biphaseindex-1, k, phSteps)));
					if symbCurSign == symbOldSign && (abs(real(biphasesymbols(biphaseindex, k, phSteps))) > validThreshold) && (abs(real(biphasesymbols(biphaseindex-1, k, phSteps))) > validThreshold)
						locked = 1;
						startOfSymbol = 0;
						lockedHere(n) = 0.1;
					end
				elseif locked == 1
					if startOfSymbol == 0
						symbCurSign = sign(real(biphasesymbols(biphaseindex, k, phSteps)));
						symbOldSign = sign(real(biphasesymbols(biphaseindex-1, k, phSteps)));
						
						%symbol 1
						if real(biphasesymbols(biphaseindex-1, k, phSteps)) > real(biphasesymbols(biphaseindex, k, phSteps))
							symbols(symbolsIndex, k, phSteps) = abs(real(biphasesymbols(biphaseindex-1, k, phSteps) - biphasesymbols(biphaseindex, k, phSteps))) + 1i*imag(biphasesymbols(biphaseindex-1, k, phSteps) - biphasesymbols(biphaseindex, k, phSteps));
							bitsymbols(bitsymbolsIndex) = 1;
							sampleBitSymb(n) = 0.1;
						%symbol 0
						elseif real(biphasesymbols(biphaseindex-1, k, phSteps)) < real(biphasesymbols(biphaseindex, k, phSteps))
							symbols(symbolsIndex, k, phSteps) = -abs(real(biphasesymbols(biphaseindex-1, k, phSteps) - biphasesymbols(biphaseindex, k, phSteps))) + 1*i*imag(biphasesymbols(biphaseindex-1, k, phSteps) - biphasesymbols(biphaseindex, k, phSteps));
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
	end
end
clear a b e f n fs phd_output sampleCounter ki kp
clear startOfSymbol t symbCurSign symbOldSign h phase
clear sampleDur vcoRiseEdgeCounter xhist
clear index timeAfterZeroCrossing

draw = 1;
if draw == 1
    figure 
    plot(abs(fftshift(fft(fmdemod))));
    
    %figure 
    %plot(abs(fftshift(fft(vco))),'r');

	%figure
	%plot(mixedsignal, 'g');
    %
	%figure
	%plot(real(mixedsignal),'g');
	%hold on
	%plot(sampleBitSymb, 'b.');
	%hold on
	%plot(real(samplePoints), 'r.')
	%hold on
	%plot(real(lockedHere), 'y');

	%figure
	%plot(real(0.2*exp(1i*2*pi*19000*20*tp)), 'g');
	%hold on
	%plot(pilotTone,'r');
	%hold on
	%plot(real(vco),'g');
    %hold on
    %plot(real(vco3),'b');
end
clear samplePoints samplePointsBiphase

if draw == 1
	figure
    axis normal;
	plot(biphasesymbols,'b.');
	hold on
	plot(symbols,'g.');
end

%clear biphasesymbols

%clear symbols
%Decodieren (=Aufruf des C-Teils, ein Teil soll dann aber HW werden)
fileID = fopen('decodedaten.txt','w');
fprintf(fileID,'%d\n',bitsymbols);
fclose(fileID);
%!./RDSDecoder < decodedaten.txt
end
