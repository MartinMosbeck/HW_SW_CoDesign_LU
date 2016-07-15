clear
close all

AUDIO_ONLY = 1;		%skips the RDS part
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
anzsamp=floor(size(inputdata)/(2^9));%Anz der einzulesenden Datenpunkte
inputdata=inputdata-127;
IQ=inputdata(1:2:anzsamp-1)+1i.*inputdata(2:2:anzsamp);
clear inputdata fileID


%60 kHz lowpass (FIR)
load('fir_lowpass_1500_60kHz_Fs2500000.mat');
b60kHzLowpass = h';
filterState60kHz = zeros(length(b60kHzLowpass)-1, 1);

load('fir_demodFilter_Fs250000.mat');
hd = h';
filterStateDemod = zeros(length(hd)-1, 1);

%lowpass filter for the audio signal
load('fir_lowpass_400_12kHz_Fs250000.mat');
b12kHzLowpass = h';
filterState12kHz = zeros(length(b12kHzLowpass)-1, 1);

%15Hz lowpass (IIR)
load('iir_lowpass_20_15Hz_num.mat');
bIIRLowpass = num.';
load('iir_lowpass_20_15Hz_den.mat');
aIIRLowpass = den.';
filterStateIIR = zeros(length(aIIRLowpass)-1, 1);

%decimator parameter (only take every Nth value)
Nth = 10;
delay15 = zeros(15, 1);
phi = 0;
phiInc = 2*pi*0.6*10^6/fs;
phiCorr = 0;
fmdemodCount = 1;
threshold = 0.1;
fmdemod = zeros(ceil(length(IQ)/Nth), 1);

for n = 1 : length(IQ)
	%Mixer
	mixedsignal99_9MHz = IQ(n) * exp(-1i*phi);

	%60kHz lowpass filtering
	[lpFiltered filterState60kHz] = filter(b60kHzLowpass, 1, mixedsignal99_9MHz, filterState60kHz);

	%FM Demodulation
	if lpFiltered ~= 0
		dl = lpFiltered./abs(lpFiltered);
	else
		dl = 0;
	end

	[signal filterStateDemod] = filter(hd, 1, dl, filterStateDemod);
	delayOut = delay15(15);
	delay15 = circshift(delay15, [1, 0]);
	delay15(1) = dl;
	demod = imag(signal*conj(delayOut));

	%lowpass filter the demodulated signal below 15Hz and feed it back to the mixer as frequency correction
	[feedback filterStateIIR] = filter(bIIRLowpass, aIIRLowpass, demod, filterStateIIR);

	phiCorr = phiCorr - 0.00000001*2*pi*feedback/(fs);

	if mod(n,Nth) == 0
		fmdemod(fmdemodCount) = demod;
		fmdemodCount = fmdemodCount + 1;
	end

	%print progress to console
	if mod(n, Nth*100) == 0
		fmdemodCount
	end

	phi = phi + phiInc + phiCorr;
end
fs = fs/Nth;

%12kHz filtering for audio output
filteredtonsignal = filter(b12kHzLowpass, 1, fmdemod);
sound(filteredtonsignal, 200000);
plot(fftshift(abs(fft(fmdemod))));
%RDS from fmdemod
%clear filteredtonsignal

if AUDIO_ONLY == 0

symbolRate = 1187.5;
bitRate = 2*symbolRate;
bitDur = floor(fs/(bitRate));

%matched filter
load('RDSmatched_Fs250000.mat');
b=h.';
xhist=zeros(length(b),1);

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
