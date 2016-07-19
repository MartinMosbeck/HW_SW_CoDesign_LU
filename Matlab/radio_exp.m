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
clear inputdata fileID

	%Y_IQ = fft(IQ);
	%Y_IQ = abs(Y_IQ(1:ceil(length(Y_IQ)/2)));
	%f = fs*(0:length(Y_IQ)-1)/(2*length(Y_IQ));
	%figure
	%plot(f, Y_IQ, 'b');
	%title('spectrum of IQ');

%60 kHz lowpass (FIR)
load('fir_lowpass_1500_100kHz_Fs2500000.mat');
b100kHzLowpass = h';
filterState60kHz = zeros(length(b100kHzLowpass)-1, 1);

load('fir_demodFilter_Fs250000.mat');
hd = h';
filterStateDemod = zeros(length(hd)-1, 1);

%lowpass filter for the audio signal
load('fir_lowpass_400_12kHz_Fs250000.mat');
b12kHzLowpass = h';
filterState12kHz = zeros(length(b12kHzLowpass)-1, 1);

%15Hz lowpass (IIR)
load('iir_lowpass_15Hz_Fs250000num.mat');
bIIRLowpass = num.';
load('iir_lowpass_15Hz_Fs250000den.mat');
aIIRLowpass = den.';
filterStateLength = max(length(aIIRLowpass), length(bIIRLowpass))-1;
filterStateIIR = zeros(filterStateLength, 1);

%57kHz bandpass filter
load('fir_bandpass_500_57kHz_Fs250000.mat');
b57kHzBandpass = h.';

%114kHz bandpass filter
load('fir_bandpass_500_114kHz_Fs250000.mat');
b114kHzBandpass = h';
filterState114kHz = zeros(length(b114kHzBandpass)-1, 1);

%57kHz lowpass filter
load('fir_lowpass_500_57kHz_Fs250000.mat');
b57kHzLowpass = h';
filterState57kHz = zeros(length(b57kHzLowpass)-1, 1);
filterState57kHzVco = zeros(length(b57kHzLowpass)-1, 1);

%lowpass phase filter
load('fir_lowpass_500_phaseDiff_Fs250000.mat');
bPhaseDiff = h';
filterStatePhaseDiff = zeros(length(bPhaseDiff)-1, 1);
%decimator parameter (only take every Nth value)
Nth = 10;
delay15 = zeros(15, 1);
phi = 0;
phiInc = 2*pi*0.6*10^6/fs;
phiCorr = 0;
fmdemodCount = 1;
threshold = 0.1;
fmdemod = zeros(ceil(length(IQ)/Nth), 1);

%factor for the frequency correction (controller parameter)
FREQ_CORR_I = 0.1;

%for n = 1 : length(IQ)
%	%Mixer
%	mixedsignal99_9MHz = IQ(n) * exp(-1i*phi);
%
%	%60kHz lowpass filtering
%	[lpFiltered, filterState60kHz] = filter(b100kHzLowpass, 1, mixedsignal99_9MHz, filterState60kHz);
%
%	%FM Demodulation
%	if lpFiltered ~= 0
%		dl = lpFiltered./abs(lpFiltered);
%	else
%		dl = 0;
%	end
%
%	[signal, filterStateDemod] = filter(hd, 1, dl, filterStateDemod);
%	delayOut = delay15(15);
%	delay15 = circshift(delay15, [1, 0]);
%	delay15(1) = dl;
%	demod = imag(signal*conj(delayOut));
%
%	%lowpass filter the demodulated signal below 15Hz and feed it back to the mixer as frequency correction
%	[feedback, filterStateIIR] = filter(bIIRLowpass, aIIRLowpass, demod, filterStateIIR);
%
%	phiCorr = phiCorr + FREQ_CORR_I*2*pi*feedback/(fs);
%
%	if mod(n,Nth) == 0
%		fmdemod(fmdemodCount) = demod;
%		fmdemodCount = fmdemodCount + 1;
%	end
%
%	%print progress to console
%	if mod(n, Nth*100) == 0
%		fmdemodCount
%	end
%
%	phi = phi + phiInc + phiCorr;
%end

%%12kHz filtering for audio output
%filteredtonsignal = filter(b12kHzLowpass, 1, fmdemod);
%sound(filteredtonsignal, 200000);

%--------------------------------------------------------
%signal processingn without the mixer feedback
t=(0:size(IQ)-1)*1/(2.5*10^6);%von 0-IQsize*1/Fs         
mixed_alt = IQ.*exp(-1i*2*pi*(0.608*10^6)*t');


	%Y_mixed_alt = fft(mixed_alt);
	%Y_mixed_alt = abs(Y_mixed_alt(1:ceil(length(Y_mixed_alt)/2)));
	%f = fs*(0:length(Y_mixed_alt)-1)/(2*length(Y_mixed_alt));
	%figure
	%plot(f, Y_mixed_alt, 'b');
	%title('spectrum of mixed_alt');

fs = fs/Nth;
%100 kHz lowpass (FIR)
beforedecsignal=filter(b100kHzLowpass, 1, mixed_alt);
clear mixed_alt t

%Decimation
Nth=10;		%take every 10th sample
decisignal=[1:floor(size(beforedecsignal)/Nth)]';
for index=1:floor(size(beforedecsignal)/Nth)
    decisignal(index)=beforedecsignal(index*Nth);
end
clear beforedecsignal
dl = decisignal./abs(decisignal);
signal = filter(hd, 1, dl);
signal(length(dl):length(dl)+15) = 0;
fmdemod_alt = imag(signal(16:length(dl)+15).*conj(dl));
fmdemod = fmdemod_alt;

%12kHz filtering for audio output
filteredtonsignal = filter(b12kHzLowpass, 1, fmdemod);
sound(filteredtonsignal, 200000);

clear fmdemod_alt
%--------------------------------------------------------

%%comparison between the mixing with and without feedback
%Y = fft(fmdemod);
%Y = abs(Y(1:ceil(length(Y)/2)));
%f = fs*(0:length(Y)-1)/(2*length(Y));
%figure
%plot(f, Y, 'r');
%
%Y_alt = fft(fmdemod_alt);
%Y_alt = abs(Y_alt(1:ceil(length(Y_alt)/2)));
%f = fs*(0:length(Y_alt)-1)/(2*length(Y_alt));
%figure
%plot(f, Y_alt, 'b');

%RDS from fmdemod
%clear filteredtonsignal

if AUDIO_ONLY == 0

symbolRate = 1187.5;
bitRate = 2*symbolRate;
bitDur = floor(fs/(bitRate));

%matched filter
load('RDSmatched_Fs250000.mat');
bMatched = h.';
filterStateMatched = zeros(length(bMatched) - 1,1);

PHASE_STEPS = 1;

% define PLL parameters
phd_output = zeros(size(fmdemod));
e = zeros(size(fmdemod));
phi_hat = zeros(size(fmdemod));
phi_hat(1)=30; 
e(1)=0; 
phd_output(1)=0; 
vco = zeros(size(fmdemod));
%Define Loop Filter parameters (sets damping)
kp=0.15; %Proportional constant 
ki=0.1; %Integrator constant 


samplePoints = zeros(size(fmdemod)) - 0.3;
biphasesymbols=zeros(ceil(length(fmdemod)/(bitDur)), 1, PHASE_STEPS);
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
sampleDur = floor(9/16*bitDur);
validThreshold = 0.01;
bitsymbolsIndex = 1;
bitsymbols = zeros(ceil(size(biphasesymbols,1)/2),1) - 1;
sampleBitSymb = zeros(size(fmdemod)) - 0.3;
lockedHere = zeros(size(fmdemod));
mixed = zeros(size(fmdemod));

PPhaseOut = 0;
IPhaseOut = 0;

k = 1;
phSteps = 1;

f = 57000;

P_PHASE = 0.5;
I_PHASE = 0.2;
%I_FREQ = 0.001;

phi = 0;
phiInc = 2*pi*f/fs;
phiIncHistory = zeros(size(fmdemod));
phaseCorrHistory = zeros(size(fmdemod));
phaseCorr = 0;

deltaPhiAvg = 0;
feedback = 0;

zeroCrossings = zeros(size(fmdemod));
phaseDiff = zeros(size(fmdemod));

fmdemodFiltered = filter(b57kHzBandpass, 1, fmdemod);

for n=2:length(fmdemod) 
	mixed(n) = fmdemod(n) * exp(-1i*phi);

	%Matched Filter
	[mixed(n), filterStateMatched] = filter(bMatched, 1, mixed(n), filterStateMatched);

	mixed(n) = mixed(n) * exp(-1i*phaseCorr);

	%detect zero-crossing in the mixed signal
	if(mixed(n-1) > 0 && mixed(n) < 0) || (mixed(n-1) < 0 && mixed(n) > 0)
		timeAfterZeroCrossing = 0;
		zeroCrossings(n) = 0.005;
	end
	if mod(timeAfterZeroCrossing, bitDur) == ceil(bitDur/2)

		%**********experimental phase and frequency correction**********
		a = sign(real(mixed(n)));
		feedback = angle(a*mixed(n));



		% stuff from the other group
		
		if sign(feedback) ~= sign(deltaPhiAvg)
			 deltaPhiAvg = -deltaPhiAvg;
		end

		deltaPhiAvg = deltaPhiAvg - deltaPhiAvg / bitDur + feedback / bitDur;
		feedback = deltaPhiAvg;

		if(abs(mixed(n)) > 0.01)
			 if(feedback > 0.4)
				feedback = 0.4;
			 elseif(feedback < -0.4)
				feedback = -0.4;
			 end
			 phaseCorr = phaseCorr + feedback / 50;
			 phaseCorrHistory(n) = phaseCorr;
		end




		%timeAfterZeroCrossing = -ceil(bitDur/2);
		samplePoints(n) = real(mixed(n));
		biphasesymbols(biphaseindex, k, phSteps) = mixed(n);

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
end
clear a b e n phd_output sampleCounter ki kp
clear startOfSymbol t symbCurSign symbOldSign h phase
clear sampleDur vcoRiseEdgeCounter xhist
clear index timeAfterZeroCrossing

draw = 1;
if draw == 1
    %figure 
    %plot(abs(fftshift(fft(fmdemod))));
    
    %figure 
    %plot(abs(fftshift(fft(vco))),'r');

	%figure
	%plot(mixedsignal, 'g');
    %
	figure
	plot(real(mixed),'g');
	%hold on
	%plot(sampleBitSymb, 'b.');
	hold on
	plot(samplePoints, 'r.')
	hold on
	plot(zeroCrossings, 'k');
	title('Sampling of mixed');
	%hold on
	%plot(real(lockedHere), 'y');

	figure
	plot(phaseCorrHistory, 'b');
	title('phaseCorrHistory');

	figure
	plot(fmdemod);
	title('fmdemod');

	Y_fmdemod = fft(fmdemod);
	Y_fmdemod = abs(Y_fmdemod(1:ceil(length(Y_fmdemod)/2)));
	f = fs*(0:length(Y_fmdemod)-1)/(2*length(Y_fmdemod));
	figure
	plot(f, Y_fmdemod, 'b');
	title('spectrum of fmdemod');
	
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
