clear
close all

fileID = fopen('samples.bin');
inputdata=fread(fileID,'uint8');
fclose(fileID);
%Einlesen und IQ aus Datenpunkten aufbauen
anzsamp=floor(size(inputdata)/(2^4));%Anz der einzulesenden Datenpunkte
inputdata=inputdata-127;
IQ=inputdata(1:2:anzsamp-1)+1i.*inputdata(2:2:anzsamp);
clear inputdata anzsamp fileID

%Mixer
t=(0:size(IQ)-1)*1/(2.5*10^6);%von 0-IQsize*1/Fs         
mixedsignal99_9MHz=IQ.*exp(-1i*2*pi*(-0.6*10^6)*t');
clear IQ

%Lowpass filter
load('fir_lowpass_400_60kHz.mat');%b.mat=400 Punkte, b200.mat=200, b14.mat=14, Erstellt mit filterremeztest
b=h.';
% xhist=zeros(length(b),1);
% for index=1:length(mixedsignal99_9MHz)
%    xhist=circshift(xhist,[1,0]);
%    xhist(1)=mixedsignal99_9MHz(index);
%    mixedsignal99_9MHz(index)=sum(xhist.*b);
%    if mod(index,100000) == 0%"Fortschritts"balken
%        fprintf('%i|',index);
%    end
%    if mod(index,1400000) == 0
%        fprintf('\n');
%    end
% end
%Bis hier um den Filter auszukommentieren

beforedecsignal=filter(b,1,mixedsignal99_9MHz);

clear mixedsignal99_9MHz

%Decimation
Nth=20;		%take every 20th sample
decisignal=[1:floor(size(beforedecsignal)/Nth)]';
for index=1:floor(size(beforedecsignal)/Nth)
    decisignal(index)=beforedecsignal(index*Nth);
end

clear beforedecsignal

%FM-Demodulation
fmdemod = angle(conj(decisignal(1:end-1)).*decisignal(2:end));
%eig ja fmdemod = imag(conj(decisignal(1:end-1)).*decisignal(2:end)); in HW
clear decisignal

%lowpass filter the audio signal
load('fir_lowpass_400_15kHz.mat');
b=h.';
 filteredtonsignal=filter(b,1,fmdemod);
 

%clear up the audio signals
clear a b xhist yhist index

%sound(filteredtonsignal,floor(2.5*10^6/Nth));


%RDS from fmdemod

%synchronization with respect to the 19kHz pilot tone
%retrieve the pilot tone
load('fir_bandpass_165_19kHz.mat');
b=h.';
pilotTone = filter(b,1,fmdemod);

%Initialize PLL Loop 
f = 19000;	%carrier frequency
fs = (2.5*10^6)/Nth;
phi_hat(1)=30; 
e(1)=0; 
phd_output(1)=0; 
vco(1)=0; 
%Define Loop Filter parameters (sets damping)
kp=0.15; %Proportional constant 
ki=0.1; %Integrator constant 


symbolRate = 1187.5;
bitFreq = 2*symbolRate;
bitDur = floor(fs/(bitFreq));
vcoRiseEdgeCounter = 0;
bitDurInVcoEdges = 19000/bitFreq;	%number of rising edges of the 19kHz vco during a bit duration
phase = 2*pi*5/12;

%experimental filter - should be replaced by actual matched filter
load('RDSmatched.mat');
b=h.';
xhist=zeros(length(b),1);
samplePoints = zeros(size(pilotTone)) -0.3;
samplePointsBiphase = zeros(size(pilotTone)) -0.3;
biphasesymbols=zeros(ceil(length(pilotTone)/(bitDur)),1);
biphaseindex=1;
samples = zeros(100,1);	%samples during one bit clock
sampleCounter = 1;
timeAfterZeroCrossing = -10000;
validThreshold = 0.00;	%empiric threshold for two successive bits with the same value to be valid
locked = 0;		%if 1, then we have found two successive valid bits with the same value
				%meaning that we now know where a symbol starts
startOfSymbol = 1;
symbols = zeros(ceil(size(biphasesymbols)/2));
symbolsIndex = 1;
index=1;

for n=2:length(pilotTone) 
	%PLL implementation 
	vco(n)=conj(exp(j*(2*pi*n*f/fs+phi_hat(n-1))));	%Compute VCO 
	phd_output(n)=imag(pilotTone(n)*vco(n));	%Complex multiply VCO x pilotTone input 
	e(n)=e(n-1)+(kp+ki)*phd_output(n)-ki*phd_output(n-1);	%Filter integrator 
	phi_hat(n)=phi_hat(n-1)+e(n);	%Update VCO 

	%figure
	%plot(pilotTone,'r');
	%hold on
	%plot(0.55*real(vco),'g');

	%mixing
	mixedsignal(n) = fmdemod(n) * vco(n) * exp(i*phase);
	mixedsignal(n) = mixedsignal(n) * vco(n) * exp(i*phase);
	mixedsignal(n) = mixedsignal(n) * vco(n) * exp(i*phase);

	%Matched Filter
    xhist=circshift(xhist,[1,0]);
    xhist(1)=mixedsignal(n);
    mixedsignal(n)=sum(xhist.*b);
	
	%%detect rising edge in vco
	%if(real(vco(n-1)) < 0 && real(vco(n)) > 0)
	%	vcoRiseEdgeCounter = vcoRiseEdgeCounter + 1;
	%end
	%if vcoRiseEdgeCounter >= bitDurInVcoEdges
	%	%a = sign(mixedsignal(n));
	%	%phase = phase - 0.3*angle(a*mixedsignal(n));
	%	biphasesymbols(biphaseindex) = mixedsignal(n);
	%	biphaseindex = biphaseindex + 1;
	%	vcoRiseEdgeCounter = 0;
	%	samplePoints(n) = 0.3;
	%end

	%sample around the clock given by the 19kHz pilot
	%if vcoRiseEdgeCounter >= 7/8*bitDurInVcoEdges && vcoRiseEdgeCounter <= bitDurInVcoEdges
	%	samples(sampleCounter) = mixedsignal(n);
	%	sampleCounter = sampleCounter + 1;
	%	samplePoints(n) = 0.3;
	%end
	%if vcoRiseEdgeCounter >= 9/8*bitDurInVcoEdges
	%	%a = sign(mixedsignal(n));
	%	%phase = phase - 0.3*angle(a*mixedsignal(n));
	%	biphasesymbols(biphaseindex) = sum(samples);
	%	samples = zeros(ceil((9/8 - 7/8)*bitDurInVcoEdges*fs/f),1);
	%	biphaseindex = biphaseindex + 1;
	%	vcoRiseEdgeCounter = 0;
	%	sampleCounter = 1;
	%end

	%detect zero-crossing in the mixed signal
    if(real(mixedsignal(n-1)) > 0 && real(mixedsignal(n)) < 0) || (real(mixedsignal(n-1)) < 0 && real(mixedsignal(n)) > 0) %&& (timeAfterZeroCrossing > ceil(bitDur/6))
		timeAfterZeroCrossing = 0;
    end
	if timeAfterZeroCrossing == ceil(bitDur/2)
		%phase correction
		a = sign(real(mixedsignal(n)));
		phase = phase - 0.3*angle(a*mixedsignal(n));

		%timeAfterZeroCrossing = -ceil(bitDur/2);
		%biphaseindex = biphaseindex + 1;
	end

	%reset samples
	if timeAfterZeroCrossing == 0 || timeAfterZeroCrossing == bitDur
		samples = zeros(100,1);
    end

	%bit interpretation
	if timeAfterZeroCrossing == floor(11/16*bitDur)		%11/16 should make sure that we sample over the peak but not too far after that
		[~, index] = max(abs(real(samples(1:bitDur))));
		biphasesymbols(biphaseindex) = samples(index);
		%symbol decoding
		if (locked == 0) && (biphaseindex > 1)
			symbCurSign = sign(real(biphasesymbols(biphaseindex)));
			symbOldSign = sign(real(biphasesymbols(biphaseindex-1)));
			if symbCurSign*real(biphasesymbols(biphaseindex)) > validThreshold && symbOldSign*real(biphasesymbols(biphaseindex-1)) > validThreshold && symbCurSign == symbOldSign
				locked = 1;
				startOfSymbol = 0;
			end
		elseif locked == 1
			if startOfSymbol == 0
				symbCurSign = sign(real(biphasesymbols(biphaseindex)));
				symbOldSign = sign(real(biphasesymbols(biphaseindex-1)));
				%most likely an error happened and the symbol start needs to be reset
				if symbCurSign*real(biphasesymbols(biphaseindex)) > validThreshold && symbOldSign*real(biphasesymbols(biphaseindex-1)) > validThreshold && symbCurSign == symbOldSign
					startOfSymbol = 0;

					%store the last symbol as this symbol (just to get the expected number of symbols and not skip any)
					if symbolsIndex > 1
						symbols(symbolsIndex) = symbols(symbolsIndex-1);
					else
						symbols(symbolsIndex) = biphasesymbols(biphaseindex);
					end
					symbolsIndex = symbolsIndex + 1;
				%decode the biphase symbol
				else
					symbols(symbolsIndex) = (biphasesymbols(biphaseindex-1) - biphasesymbols(biphaseindex));
					symbolsIndex = symbolsIndex + 1;
					startOfSymbol = 1;
					samplePoints(n) = real(symbols(symbolsIndex-1));
				end
			else
				startOfSymbol = 0;
			end
		end
		biphaseindex = biphaseindex + 1;
	end
	  
	timeAfterZeroCrossing = timeAfterZeroCrossing + 1;
	%wait with the sampling until the first zero crossing (only relevent in the beginning)
	if timeAfterZeroCrossing > 0
		samples(timeAfterZeroCrossing) = mixedsignal(n);
	end;
end
clear a b e f n fs locked phd_output phi_hat pilotTone sampleCounter ki kp
clear samples startOfSymbol t symbCurSign symbOldSign symbolRate h phase
clear validThreshold vco vcoRiseEdgeCounter xhist bitDur bitDurInVcoEdges
clear biphaseindex bitFreq index timeAfterZeroCrossing fmdemod symbolsIndex

draw=0;
if draw==1
figure
plot(real(mixedsignal),'g');
hold on
plot(samplePoints, 'r.')
hold on
plot(samplePointsBiphase, 'b.');
end
clear mixedsignal samplePoints samplePointsBiphase

if draw == 1
figure
plot(biphasesymbols,'b.');
hold on
plot(symbols,'g.');
end
clear biphasesymbols

%In Binärrepresentation bringen
bitsymbols=sign(real(symbols));
bitsymbols(bitsymbols(:,1)==-1)=0;
clear symbols
%Decodieren (=Aufruf des C-Teils, ein Teil soll dann aber HW werden)
fileID = fopen('decodedaten.txt','w');
fprintf(fileID,'%d\n',bitsymbols);
fclose(fileID);
!./RDSDecoder < decodedaten.txt