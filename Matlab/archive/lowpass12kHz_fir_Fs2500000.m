N   = 400;        % FIR filter order
Fp  = 12e3;       % 12 kHz passband-edge frequency
Fs  = 2.5*10^6;       % 96 kHz sampling frequency
Rp  = 0.00057565; % Corresponds to 0.01 dB peak-to-peak ripple
Rst = 1e-4;       % Corresponds to 80 dB stopband attenuation

h = firceqrip(N,Fp/(Fs/2),[Rp Rst],'passedge'); % h = vector of coeffs
fvtool(h,'Fs',Fs,'Color','White') % Visualize filter