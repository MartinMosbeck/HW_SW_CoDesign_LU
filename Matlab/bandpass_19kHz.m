N   = 400;        % FIR filter order
Fs = 2.5*10^6/20;
Fst1 = 18*10^3;     %right edge of first band stop
Fst2 = 20*10^3;     %left edge of second band stop
Fp1 = 18.5*10^3;    %start of band pass
Fp2 = 19.5*10^3;    %end of band pass
Ast1 = 100;         %attenuation in first stop band
Ast2 = 100;         %attenuation in second stop band
Ap = 10;             %ripple


d = fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2',Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2,Fs);
h = design(d,'equiripple');
fvtool(h,'Fs',Fs,'Color','White') % Visualize filter