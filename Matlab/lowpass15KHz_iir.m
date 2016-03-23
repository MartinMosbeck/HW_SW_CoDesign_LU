Fs = (2.5*10^6);		%sample rate
N = 6;					%filter order
Fp = 15*10^3;			%Stopband frequency
At = 60;				%attenuation in decibel
Prip = 3;               %Passband Ripple in decibel

d = designfilt('lowpassiir', 'FilterOrder', N, 'PassbandFrequency', Fp, 'StopbandAttenuation', At, 'PassbandRipple', Prip, 'DesignMethod', 'ellip', 'SampleRate', Fs);
fvtool(d,'Fs',Fs,'Color','White') % Visualize filter
[num, den] = tf(d);