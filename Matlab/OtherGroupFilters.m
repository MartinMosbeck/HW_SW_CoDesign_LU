fs = 2.5*10^5;

hDiff = firls(30, [0 100000 fs/2*0.95 fs/2]/ fs/2, [0 1 0 0], 'differentiator');

fvtool(hDiff, 'Fs', fs);
%hLimit = fir1(40, 0.1);