%Erster Versuch die Audidateien mit dem FPGA-Audio direkt abzuspielen
%Audio dafür in Ganzzahlwerte zwischen 0 und 255 bringen
%--> FUNZT

%Zusatzdeci für den Audio (geht auch ohne aber anpassen an Sampling rate
%des FPGA is gscheiter)
Nth=2;%sollte eigentlich 4 sein ist aber zu schnell, deshalb probeweise 2
decisignal=[1:floor(size(filteredtonsignal)/Nth)]';
for index=1:floor(size(filteredtonsignal)/Nth)
    decisignal(index)=filteredtonsignal(index*Nth);
end
%Wenn kein Deci gewünscht:
%decisignal=filteredtonsignal;

%Werte zwischen -128 und 127 bringen
rndtonsignal=round(decisignal.*(128/max(abs(min(decisignal)),max(decisignal))));
%Zwischen 0 und 255 verschieben
utonsignal=rndtonsignal+127;

%Bis hierher diese fancy scheisse in HW machen und dem scatter geben=PROFIT

%Werte aus Variable in txt schreiben (kann direkt in den FPGA per < exp.txt
%in run ins tse_tutorial-Programm geladen werden
fileID = fopen('exp.txt','w');
fprintf(fileID,'%u\n',utonsignal);
fclose(fileID);