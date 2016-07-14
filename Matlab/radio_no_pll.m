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
anzsamp=floor(size(inputdata)/(2^4));%Anz der einzulesenden Datenpunkte
inputdata=inputdata-127;
IQ=inputdata(1:2:anzsamp-1)+1i.*inputdata(2:2:anzsamp);
clear inputdata anzsamp fileID

%Mixer
t=(0:size(IQ)-1)*1/(2.5*10^6);%von 0-IQsize*1/Fs         
mixedsignal99_9MHz=IQ.*exp(-1i*2*pi*(-0.608*10^6)*t');
tp = t;
clear IQ t

%60 kHz lowpass (FIR)
load('fir_lowpass_1500_60kHz_Fs2500000.mat');
b=h';

a = 1;

beforedecsignal=filter(b,a,mixedsignal99_9MHz);

clear mixedsignal99_9MHz

%Decimation
Nth=10;		%take every 10th sample
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


%%lowpass filter the audio signal
%load('fir_lowpass_400_12kHz_Fs125000.mat');
%b=h';
%a = 1;
%filteredtonsignal=filter(b,a,fmdemod);
%
%sound(filteredtonsignal, fs);

%clear up the audio signals
clear a b xhist yhist index filteredtonsignal


%RDS from fmdemod

if AUDIO_ONLY == 0
%synchronization with respect to the 19kHz pilot tone
%retrieve the pilot tone
load('fir_bandpass_500_19kHz_Fs250000.mat');
b=h.';
a = 1;
pilotTone = filter(b,a,fmdemod);
clear a b

%the PLL has trouble handling the pilot tone, when the pilot tone's size differs too much from its own output
pilotTone = 2*pilotTone;

symbolRate = 1187.5;
bitRate = 2*symbolRate;
bitDur = floor(fs/(bitRate));
vcoRiseEdgeCounter = 0;
bitDurInVcoEdges = 19000/bitRate;	%number of rising edges of the 19kHz vco during a bit duration

%matched filter
%load('RDSmatched_other.mat');
load('RDSmatched_Fs250000.mat');
b=h.';
xhist=zeros(length(b),1);

load('fir_lowpass_400_2kHz_Fs125000.mat');
bLow=h.';
xhistLow=zeros(length(bLow),1);

PHASE_STEPS = 1;

f = 57000;
samplePoints = zeros(size(pilotTone)) - 0.3;
samplePointsBiphase = zeros(size(pilotTone)) - 0.3;
biphasesymbols=zeros(ceil(length(pilotTone)/(bitDur)), 1, PHASE_STEPS);
biphaseindex=1;
samples = zeros(100,1);	%samples during one bit clock
sampleCounter = 1;
timeAfterZeroCrossing = -10000;
locked = 0;		%if 1, then we have found two successive valid bits with the same value
				%meaning that we now know where a symbol starts
startOfSymbol = 1;
symbols = zeros(ceil(size(biphasesymbols,1)/2), 1, PHASE_STEPS);
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

PPhaseOut = 0;
IPhaseOut = 0;

k = 1;
phSteps = 1;

%P_PHASE = 0.5;
I_PHASE = 0.3;
%I_FREQ = 0.001;

phi = 0;
phiInc = 2*pi*f/fs;
phaseCorr = 0;

deltaPhiAvg = 0;
feedback = 0;

zeroCrossings = zeros(size(pilotTone));

for n=2:length(pilotTone) 
	%mixing
	mixedsignal(n, k, phSteps) = fmdemod(n) * exp(-1i*phi);

	%Matched Filter
	xhist=circshift(xhist,[1,0]);
	xhist(1)=mixedsignal(n, k, phSteps);
	mixedsignal(n, k, phSteps)=sum(xhist.*b);

	%additional low pass filter (cutoff at around 2kHz)
	%xhistLow=circshift(xhistLow,[1,0]);
	%xhistLow(1)=mixedsignal(n);
	%mixedsignal(n)=sum(xhistLow.*bLow);

	%apply actual phase correction only after mixing and matched filtering
	mixedsignal(n, k, phSteps) = mixedsignal(n, k, phSteps) * exp(1i*phaseCorr);
	
	%detect zero-crossing in the mixed signal
	if(real(mixedsignal(n-1)) > 0 && real(mixedsignal(n)) < 0) || (real(mixedsignal(n-1)) < 0 && real(mixedsignal(n)) > 0)
		timeAfterZeroCrossing = 0;
		zeroCrossings(n) = 0.005;
	end
	if mod(timeAfterZeroCrossing, bitDur) == ceil(bitDur/2)

		%**********experimental phase and frequency correction**********
		a = sign(real(mixedsignal(n)));
		feedback = angle(a*mixedsignal(n));

		%delta_phi = angle(mixedsignal(n, k, phSteps));
		%if real(mixedsignal(n, k, phSteps))>0
		%	feedback_source = wrapToPi(delta_phi);  
		%else
		%	feedback_source = -(pi - wrapTo2Pi(delta_phi)) ;     
		%end

		if sign(feedback) ~= sign(deltaPhiAvg)
			 deltaPhiAvg = -deltaPhiAvg;
		end
		
		deltaPhiAvg = deltaPhiAvg - deltaPhiAvg / bitDur + feedback / bitDur;
		feedback = deltaPhiAvg;

		if(abs(mixedsignal(n, k, phSteps)) > 0.01)
			 if(feedback > 0.4)
				feedback = 0.4;
			 elseif(feedback < -0.4)
				feedback = -0.4;
			 end
			 phaseCorr = phaseCorr + feedback / 50;
		end



		%timeAfterZeroCrossing = -ceil(bitDur/2);
		samplePoints(n) = mixedsignal(n);
		biphasesymbols(biphaseindex, k, phSteps) = mixedsignal(n);

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

	phi = phi + phiInc;
	 
	timeAfterZeroCrossing = timeAfterZeroCrossing + 1;
	sampleCounter = sampleCounter + 1;
	%wait with the sampling until the first zero crossing (only relevent in the beginning)
	if timeAfterZeroCrossing > 0
		samples(sampleCounter) = mixedsignal(n);
	end;
end
clear a b e n fs phd_output sampleCounter ki kp
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
	figure
	plot(real(mixedsignal(:,1,1)),'g');
	%hold on
	%plot(sampleBitSymb, 'b.');
	hold on
	plot(real(samplePoints), 'r.')
	hold on
	plot(real(zeroCrossings), 'k');
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
	plot(biphasesymbols(:,1,1),'b.');
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
