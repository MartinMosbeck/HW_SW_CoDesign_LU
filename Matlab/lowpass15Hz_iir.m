Fs = (2.5*10^6)/10;		%sample rate
nyquistF = Fs/2;		%nyquist frequency
N = 10;					%default filter order
Fp = 15;				%Passband frequency edge
Ft = 20;                %Stopband frequency edge
Rp = 10; 				%passband ripple in decibels
At = 40; 				%stopband attenuation in decibels

%supposedly this is a special polyphase filter design, which leads to more stable IIR filter designs
%with a near linear phase
IIRLowpassDesign = fdesign.lowpass(Fp, Ft, Rp, At, Fs);
IIRFilter = design(IIRLowpassDesign, 'ellip', 'SystemObject', true);
[num, den] = tf(IIRFilter);
fvtool(num, den,'Fs',Fs,'Color','White') % Visualize filter
IIRisStable = isstable(num, den);
filterCost = cost(IIRFilter);
