td=1/1187.5;
N=200;
filterOrder=100;

f1=linspace(0,1,N);
h1=1.222*cos(pi*td/4*2/td.*f1);

d = fdesign.arbmagnphase('n,f,h',filterOrder,f1,h1);
D = design(d,'firls');
fvtool(D,'Analysis','freq');

h=D.Numerator;