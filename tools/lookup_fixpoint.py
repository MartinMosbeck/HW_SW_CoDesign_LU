from math import *
from BitVector import *

#vars = [-10.362452500686903, -53.423110107943245, -48.581612325924180, -25.795073548269755, 13.514946025475460]#I
#vars = [17.758968490622056, 54.915008751271460, 36.540296351427660, 55.178074120221270, 61.564391291389240]#Q

vars = [0.802734]

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