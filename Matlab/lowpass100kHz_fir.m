N   = 1500;        % FIR filter order
Fp  = 100e3;       % 100 kHz passband-edge frequency
Fs  = 2.5*10^6;       % 2.5*10^6 Hz sampling frequency
Rp  = 0.00057565; % Corresponds to 0.01 dB peak-to-peak ripple
Rst = 1e-6;       % Corresponds to 120 dB stopband attenuation

h = firceqrip(N,Fp/(Fs/2),[Rp Rst],'passedge'); % NUM = vector of coeffs
fvtool(h,'Fs',Fs,'Color','White') % Visualize filter