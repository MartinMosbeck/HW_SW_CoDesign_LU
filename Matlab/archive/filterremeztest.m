N=200;%Anzahl Koeffizienten
%be=[0 0.072 0.08 1];%0, Ende High, Start Low, Abtastfrequenz/2
be=[0 0.0128 0.0152 1];
m=[1 1 0 0];%Gewünschte Form des Filters zu der jeweiligen Frequenz
w=[1 1];
h=firpm(N-1,be,m,w);
Nf=512;
f=linspace(0,1,Nf/2+1);
H=fft(h,Nf);
plot(f,abs(H(1:Nf/2+1))),xlabel('\theta/\pi');
ylabel('|H(e^{j\theta})|'),grid on;

%Variable h links im Workspace save as und den Namen dann beim Filter
%open... einfügen (Zeile 20)