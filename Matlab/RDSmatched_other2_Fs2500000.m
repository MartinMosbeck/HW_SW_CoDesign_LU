fny = 2500000/2;

td=1.0/1187.5;
fcut = 2/td;

pairs = 50;
ccount = 2*(pairs+1);
a=zeros(ccount,1);
f=zeros(ccount,1);
points=linspace(0,fcut,pairs+1);

for k = 1:pairs
    j=2*k;
    f(j-1)=points(k)/fny;
    f(j)=points(k+1)/fny;
    a(j-1)=cos(points(k)*td*pi/4);
    a(j)=cos(points(k+1)*td*pi/4);
    
end
a(ccount-1)=0;
a(ccount)=0;
f(ccount-1)=fcut/fny;
f(ccount)=1;

figure(1);
plot(f);
figure(2);
plot(a);

order = 600;
h=firls(order,f,a);
fvtool(h);