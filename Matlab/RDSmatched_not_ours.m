% Octave RDS matched filter generation tool
% Author : Alexandre Marquet

%Parameters
Fe=5.0e6/7;	%Sampling rate
Te=1/Fe;	%Sampling period
Tb=1/1187.5;	%Symbol duration
Ls=6;		%Filter length in terms of symbols
L=Ls*Tb/Te;	%Filter length

% Impulsive response generation
k=0:L;
w=4*(k./(Tb*Fe)-floor(Ls/2));
h=(sinc(w+1/2)+sinc(w-1/2))/Tb;

%Normalization
h=h/norm(h);

freqz(h)
