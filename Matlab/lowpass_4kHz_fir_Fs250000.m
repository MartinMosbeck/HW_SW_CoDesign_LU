N   = 500;        % FIR filter order
Fp  = 4000;       %  passband-edge frequency
Fs  = 2.5*10^6/10; 
Rp  = 0.00057565; % Corresponds to 0.01 dB peak-to-peak ripple
Rst = 1e-5;       % Corresponds to 100 dB stopband attenuation

h = firceqrip(N,Fp/(Fs/2),[Rp Rst],'passedge'); % NUM = vector of coeffs
fvtool(h,'Fs',Fs,'Color','White') % Visualize filter