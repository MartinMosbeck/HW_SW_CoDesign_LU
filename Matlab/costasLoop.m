clear all
%60 kHz lowpass (FIR)
load('fir_lowpass_1500_60kHz_Fs2500000.mat');
b60kHzLowpass = h.';
filterState60kHz = zeros(length(b60kHzLowpass)-1, 1);

load('fir_demodFilter_Fs250000.mat');
hd = h.';
filterStateDemod = zeros(length(hd)-1, 1);

%lowpass filter for the audio signal
load('fir_lowpass_400_12kHz_Fs250000.mat');
b12kHzLowpass = h.';
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
b114kHzBandpass = h.';
filterState114kHz = zeros(length(b114kHzBandpass)-1, 1);

%57kHz lowpass filter
load('fir_lowpass_500_57kHz_Fs250000.mat');
b57kHzLowpass = h.';
filterState57kHz = zeros(length(b57kHzLowpass)-1, 1);
filterState57kHzVco = zeros(length(b57kHzLowpass)-1, 1);

%lowpass phase filter
load('fir_lowpass_500_phaseDiff_Fs250000.mat');
bPhaseDiff = h.';
filterStatePhaseDiff = zeros(length(bPhaseDiff)-1, 1);

%matched filter
load('RDSmatched_Fs250000.mat');
bMatched = h.';
filterStateMatchedI = zeros(length(bMatched) - 1,1);
filterStateMatchedQ = zeros(length(bMatched) - 1,1);


fs = 250000;	%sampling rate
fc = 57000;		%carrier frequency
ferr = 1000;	%frequency error
symbolRate = 1187.5;
t=0:50000;

%message signal
m = cos(2*pi*symbolRate.*t/fs);

%carrier
carrier = cos(2*pi*(fc+ferr).*t/fs + 2*pi/5);

%modulation
modulatedSig = m.*carrier;

%figure
%plot(m, 'b');
%hold on
%plot(carrier, 'r');
%hold on
%plot(modulatedSig, 'g');
%title('message: blue; carrier: red; modulatedSig: green');

%Y_modulatedSig = fft(modulatedSig);
%Y_modulatedSig = abs(Y_modulatedSig(1:ceil(length(Y_modulatedSig)/2)));
%f = fs*(0:length(Y_modulatedSig)-1)/(2*length(Y_modulatedSig));
%figure
%plot(f, Y_modulatedSig, 'b');
%title('spectrum of modulatedSig');

%************costas loop**********************************

P_PHASE = 0.05;
I_PHASE = 0.02;
phi = 0;
phiInc = 2*pi*fc/fs;
phiIncHistory = zeros(size(modulatedSig));
phaseDiff = zeros(size(modulatedSig));
vco = zeros(size(modulatedSig));
vco(1) = 0;

for n=2:length(modulatedSig)	
	%calculate the input to the vco (if phaseDiff(n-1) is 0 then the 
	%proportional part of vco controller
	%phi = phi + P_PHASE*phaseDiff(n-1);
	%integrator of vco controller
	%phiInc = phiInc + I_PHASE*phaseDiff(n-1);
	phiIncHistory(n) = phiInc;
	%voltage controlled oscillator
	vco(n)=exp(1i*phi);

	%mixing
	mixedI(n) = modulatedSig(n) * real(vco(n));
	mixedQ(n) = modulatedSig(n) * (-imag(vco(n)));

	%Matched Filter
	[mixedFI(n), filterStateMatchedI] = filter(bMatched, 1, mixedI(n), filterStateMatchedI);
	[mixedFQ(n), filterStateMatchedQ] = filter(bMatched, 1, mixedQ(n), filterStateMatchedQ);

	%phase detector (multiplier)
	phaseDiff(n) = mixedFI(n) * mixedFQ(n);

	%phase filter
	[phaseDiff(n), filterStatePhaseDiff] = filter(bPhaseDiff, 1, phaseDiff(n), filterStatePhaseDiff);

	phi = phi + phiInc;
end


%Y_m = fft(m);
%Y_m = abs(Y_m(1:ceil(length(Y_m)/2)));
%f = fs*(0:length(Y_m)-1)/(2*length(Y_m));
%figure
%plot(f, Y_m, 'b');
%title('spectrum of m');
%
%Y_mixedFI = fft(mixedFI);
%Y_mixedFI = abs(Y_mixedFI(1:ceil(length(Y_mixedFI)/2)));
%f = fs*(0:length(Y_mixedFI)-1)/(2*length(Y_mixedFI));
%figure
%plot(f, Y_mixedFI, 'b');
%title('spectrum of mixedFI');
%
%Y_mixedI = fft(mixedI);
%Y_mixedI = abs(Y_mixedI(1:ceil(length(Y_mixedI)/2)));
%f = fs*(0:length(Y_mixedI)-1)/(2*length(Y_mixedI));
%figure
%plot(f, Y_mixedI, 'b');
%title('spectrum of mixedI');

figure
plot(mixedI, 'b');
hold on
plot(mixedFI, 'g');
hold on
plot(m,'r');
title('mixedI: blue; mixedFI: green; m: red');

figure
plot(phaseDiff);
title('phaseDiff');
