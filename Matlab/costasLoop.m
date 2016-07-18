m=Am*cos(2*pi*fm*t); %---- AM signal generator
theta=1;
input = Ac*sin(2*pi*fc*t+theta).* m;  %Input is a modulated signal
hilbert_output = filter(b, 1, input); %--- after Hilbert filter
%Initialization
out = [];
phi = [];
phi(1) = 0;
temp_out1=0;
temp_pre_out1=0;
temp_out2=0;
temp_out3=0;
%Simulation
for I=1:len - groupdelay
    phi(I)= temp_out3; 
    phase(I) = exp(-i*phi(I));
    c1(I) = real(analytic(I)*phase(I));
    c2(I) = imag(analytic(I)*phase(I));
    out(I)= sign(c1(I));
    q(I) = sign(c1(I))*c2(I);
    temp_out1=temp_pre_out1+q(I)*beta;
    temp_out2=alpha*q(I)+ temp_out1;
    temp_out3=2*pi*fc/fs+phi(I)+temp_out2;
    temp_pre_out1=temp_out1;
end;
