%taken from web.stanford.edu/class/ee179/labs/Lab5.html
%differentiator filter for the fmdemodulation
fs = 2.5*10^6/10;

hd = firls(30,[0 100000 fs/2*0.99 fs/2]/(fs/2), [0 1 0 0], 'differentiator');
fvtool(hd, 'Fs', fs);