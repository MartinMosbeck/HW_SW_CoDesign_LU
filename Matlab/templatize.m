%Erster Versuch die Audidateien mit dem FPGA-Audio direkt abzuspielen
%Audio dafür in Ganzzahlwerte zwischen 0 und 255 bringen

%Werte zwischen -128 und 127 bringen
rndtonsignal=round(tonsignal.*(128/max(abs(min(tonsignal)),max(tonsignal))));
%Zwischen 0 und 255 verschieben
utonsignal=rndtonsignal+128;

%Werte aus Variable in txt schreiben (kann direkt in den FPGA per < exp.txt
%in run ins tse_tutorial-Programm geladen werden
fileID = fopen('exp.txt','w');
fprintf(fileID,'%u\n',utonsignal);
fclose(fileID);