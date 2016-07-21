from math import *
from BitVector import *

#ndem.m im Archivordner mit ehttst_normal: decisignal
#vars = [-10.362452500686903, -53.423110107943245, -48.581612325924180, -25.795073548269755, 13.514946025475460]#I
#vars = [17.758968490622056, 54.915008751271460, 36.540296351427660, 55.178074120221270, 61.564391291389240]#Q

#vars =[28.430089617715772, 26.367256634206857, 28.983603776926730, 5.477048089644526, -0.267890586724897] #I die zweite
#vars =[56.240695755838570, 51.052242790292190,48.532776048184395, 59.520682716240906, 56.910751225586495] #Q die zweite

#vars =[32.893032666260550, 51.393609084999870, 40.798264777838080, 39.159300716291945, 22.332634399248313]#I die dritte
#vars =[47.595963854717620, 35.179956463289290, 43.561769726389706, 40.649904073494950, 52.302541486509960]#Q die dritte

#vars =[-17.376931013823807, -12.050938461215310, 27.724173129914018, 18.466444626602710, 2.711858510949427]#I die vierte
#vars =[58.250718819166465, 49.235539357609530, 52.636911774180525, 52.888395882599816, 59.560697188528900]#Q die vierte

#vars = [0.802734]
#vars = [450]#Test faktor bei demod_FIR um zwischen 0-255 Werte zu erreichen

#vars = [6.283185307179586476925286766559, -6.283185307179586476925286766559]
#vars = [0.01745329251994329576923690768489]

vars = [6.283185307179586476925286766559]

skalierungsfaktor = pow(2,2*8)

i=0
for value in vars:
    vorkomma = abs(int(value))
    nachkomma = abs(int((value-int(value))*skalierungsfaktor))
    bv1 = BitVector(intVal=vorkomma,size=16)
    bv2 = BitVector(intVal=nachkomma,size=16)
    bv = bv1 + bv2

    if(value<0):
        #invert add +1
        bv3 = BitVector(intVal=int(str(~bv),2)+1 ,size=32)
        bv = bv3

    summe = 0
    j = 0
    power = 15 
    for c in str(bv):
        
        if(j==0):
            toadd = -pow(2,power)
        else:
            toadd =  pow(2,power)
        power = power - 1
        summe=summe + toadd * int(c)
        j=j+1

    print(str(format(int(str(bv),2),'08x')))
    i=i+1