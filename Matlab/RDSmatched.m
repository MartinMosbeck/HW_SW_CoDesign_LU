% td=1/1187.5;
% fp = 2375/((2.5*10^6)/2);   %cutoff frequency
% N=500;
% filterOrder=500;
% 
% f1=linspace(0,fp,N);
% h1=1.222*cos(pi*td/4*2/td.*f1);
% 
% d = fdesign.arbmagnphase('n,f,h',filterOrder,f1,h1);
% D = design(d,'firls');
% fvtool(D,'Analysis','freq');
% 
% h=D.Numerator;
%--------------------------------------------------------------------------

f_nyquist = 2500000/2;
td = 1/1187.5;
n = 100;


% 0<f<=2/td a= cos((1/4)*pi*td*.f)
% f>2/td a= 0

f_break = 2/td;

num_f1 = floor(f_break/n)-1;
num_f2 = floor((f_nyquist-f_break)/n)+1; %+1 because of >2/td
filterorder=700;

f1 = linspace(0,f_break,num_f1);
f2 = linspace(f_break,f_nyquist,num_f2);

a1 = cos((1/4)*pi*td.*f1);
a2 = zeros(1,num_f2);

f = horzcat(f1(1:1:end),f2(2:1:end));
a = horzcat(a1(1:1:end),a2(2:1:end));
f_norm= f / f_nyquist;

%Plot the filter specification
figure
plot(f, a);

h=firls(filterorder,f_norm,a);

fvtool(h,'Analysis','freq');
impz(h);