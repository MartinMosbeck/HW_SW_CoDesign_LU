%Simple PLL m-file demonstration
%Run program from editor Debug (F5)
%JC 5/17/09
%This m-file demonstrates a PLL which tracks and demodulates an FM carrier.
clear all; 
close all; 
f=19000;%Carrier frequency 
fErr = 2000;		%Carrier frequency error
fs=100000;%Sample frequency
N=500;%Number of samples
Ts=1/fs;
t=(0:Ts:(N*Ts)- Ts);
%Create the message signal
f1=1000;%Modulating frequency
msg=sin(2*pi*f1*t);
kf=.0628;%Modulation index
%Create the real and imaginary parts of a CW modulated carrier to be tracked.
Signal=exp(j*(2*pi*(f+fErr)*t+2*pi*kf*cumsum(msg)));%Modulated carrier
Signal1=exp(j*(2*pi*(f+fErr)*t));%Unmodulated carrier
%Initilize PLL Loop 
phi_hat(1)=30; 
e(1)=0; 
phd_output(1)=0; 
vco(1)=0; 
%Define Loop Filter parameters(Sets damping)
kp=0.15; %Proportional constant 
ki=0.1; %Integrator constant 
%PLL implementation 
for n=2:length(Signal) 
	vco(n)=conj(exp(j*(2*pi*n*f/fs+phi_hat(n-1))));%Compute VCO 
	phd_output(n)=imag(Signal(n)*vco(n));%Complex multiply VCO x Signal input 
	e(n)=e(n-1)+(kp+ki)*phd_output(n)-ki*phd_output(n-1);%Filter integrator 
	phi_hat(n)=phi_hat(n-1)+e(n);%Update VCO 
end; 

figure
plot(real(Signal),'r');
hold on
plot(real(vco),'g');
