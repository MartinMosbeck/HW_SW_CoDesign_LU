Fs = (2.5*10^6)/10;		%sample rate
N = 20;					%filter order
Fp = 15;			%Stopband frequency
At = 120;				%attenuation in decibel
Prip = 10;	

d = designfilt('lowpassiir', 'FilterOrder', N, 'PassbandFrequency', Fp, 'StopbandAttenuation', At, 'PassbandRipple', Prip, 'DesignMethod', 'ellip', 'SampleRate', Fs);
fvtool(d,'Fs',Fs,'Color','White') % Visualize filter
[num, den] = tf(d);