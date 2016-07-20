Fs = 250000;
Fd = 3125;

[num, den] = rcosine(Fd, Fs, 'iir');
fvtool(num, den, 'Fs', Fs);

%for Fd=2501:5000
%	if(mod(Fs,Fd) == 0)
%		break;
%	end
%end
IIRstable = isstable(num, den);