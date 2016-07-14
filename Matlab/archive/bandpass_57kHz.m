N   = 400;        % FIR filter order
Fs = 2.5*10^6;
Fst1 = (18)*10^3;     %right edge of first band stop
Fst2 = (58.65)*10^3;     %left edge of second band stop
Fp1 = (57-1.2)*10^3;    %start of band pass
Fp2 = (57+1.2)*10^3;    %end of band pass
Ast1 = 100;         %attenuation in first stop band
Ast2 = 100;         %attenuation in second stop band
Ap = 1;             %ripple


d = fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2',Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2,Fs);
h = design(d,'cheby2');
fvtool(h,'Fs',Fs,'Color','White') % Visualize filter
[num, den] = sos2tf(h.sosMatrix);
