Fs = (2.5*10^6);		%sample rate
N = 4;					%filter order
Fp = 6*10^4;			%Stopband frequency
At = 60;				%attenuation in decibel
Prip = 3;	

d = designfilt('lowpassiir', 'FilterOrder', N, 'PassbandFrequency', Fp, 'StopbandAttenuation', At, 'PassbandRipple', Prip, 'DesignMethod', 'ellip', 'SampleRate', Fs);
fvtool(d,'Fs',Fs,'Color','White') % Visualize filter
[num, den] = tf(d);