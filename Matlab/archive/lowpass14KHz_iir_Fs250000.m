Fs = (2.5*10^6)/10;		%sample rate
N = 3;					%filter order
Fp = 14*10^3;			%Stopband frequency
At = 30;				%attenuation in decibel
Prip = 6;               %Passband Ripple in decibel

d = designfilt('lowpassiir', 'FilterOrder', N, 'PassbandFrequency', Fp, 'StopbandAttenuation', At, 'PassbandRipple', Prip, 'DesignMethod', 'ellip', 'SampleRate', Fs);
fvtool(d,'Fs',Fs,'Color','White') % Visualize filter
[num, den] = tf(d);