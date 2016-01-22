%attempt to build a phase locked loop by hand
K0 = 200;	%frequency gain of the variable frequency generator
t=(0:size(fmdemod)-1)/(floor(2.5*10^6/Nth));

%initialize filter
load('fir_lowpass_100_1kHz.mat');
b=h';
xhist = zeros(length(b),1);
filteredProduct = zeros(size(pilotTone));
for z = 1:length(pilotTone)
	%multiply the pilot tone with the synchronized signal
	if z == 1
		product = real(pilotTone(z))*0.0;
	else
		product = real(pilotTone(z))*synchronizedSig;
	end

	%low pass filtering
	 xhist = circshift(xhist,[1,0]);
	 xhist(1) = product;
	 filteredProduct(z) = sum(xhist.*b);	%the phase difference as steady component in filteredProduct

	 %variable frequency synthesis
	 synchronizedSig = cos((2*pi*19000 + K0*filteredProduct(z))*t(z));
end
clear xhist
