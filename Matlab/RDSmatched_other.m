Fs = (2.5*10^6)/20;
td=1.0/1187.5;
fcut = 2/td;
disp('f_cut of matched filter:');
disp(fcut);
disp('Normalized:');
disp(fcut/(Fs/2));

rolloff = 1; % roll off factor
span = 16; % 1 symbol
sps = round(Fs/(2*1187.5)); % Samples per symbol
if rem(sps,2) == 1 
    sps = sps + 1;
end
matched = rcosdesign(rolloff,span,sps,'normal');

fvtool(matched);
