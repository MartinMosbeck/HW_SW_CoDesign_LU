N = 500;        % FIR filter order
Fs = 2.5*10^6/10;
Fst1 = 54*10^3;     %right edge of first band stop
Fst2 = 60*10^3;     %left edge of second band stop
Fp1 = 55*10^3;    %start of band pass
Fp2 = 59*10^3;    %end of band pass
Ast1 = 80;         %attenuation in first stop band
Ast2 = 80;         %attenuation in second stop band
%Ap = 10;             %passband ripple


d = designfilt('bandpassfir', 'FilterOrder', N, 'StopbandFrequency1',Fst1,...
    'PassbandFrequency1',Fp1, 'PassbandFrequency2',Fp2, 'StopbandFrequency2',Fst2,...
    'DesignMethod','ls', 'SampleRate',Fs);
fvtool(d,'Fs',Fs,'Color','White') % Visualize filter
[num, den] = tf(d);