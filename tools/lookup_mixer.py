#Überlegung
# In den sinus und cosinus beim Mixer
# bleibt folgendes übrig : 86.4 * x
# das ergibt eine 25 werte periodische lookup tabelle 
# =D =D =D


from math import *
from BitVector import *

index=[]
x=0

for i in range(0,25):
    if ( x>360):
        x=x-360
    index.append(x)
    x=x+86.4


skalierungsfaktor = pow(2,3*8)

print("\nCOSINUS")
i=0
for x in index:
    value= cos(x/180*pi)
    
    vorkomma = abs(int(value))
    nachkomma = abs(int((value-int(value))*skalierungsfaktor))
    
    bv1 = BitVector(intVal=vorkomma,size=8)
    bv2 = BitVector(intVal=nachkomma,size=24)
    bv = bv1 + bv2

    if(value<0):
        #invert add +1
        bv3 = BitVector(intVal=int(str(~bv),2)+1 ,size=32)
        bv = bv3

    summe = 0
    j = 0
    power = 7 
    for c in str(bv):
        
        if(j==0):
            toadd = -pow(2,power)
        else:
            toadd =  pow(2,power)
        power = power - 1
        summe=summe + toadd * int(c)
        j=j+1
    #print("Wert:"+str(value)+ " = " + str(summe))
    #print("Delta= " + str(abs(value-summe)))

    
    print("\t\t\twhen "+str(i)+" =>")
    print('\t\t\t\treturn "',end="")
    print(str(bv)+'";') 
    i=i+1


print("\nSINUS")
i=0
for x in index:
    value= sin(x/180*pi)
    
    vorkomma = abs(int(value))
    nachkomma = abs(int((value-int(value))*skalierungsfaktor))
    
    bv1 = BitVector(intVal=vorkomma,size=8)
    bv2 = BitVector(intVal=nachkomma,size=24)
    bv = bv1 + bv2

    if(value<0):
        #invert add +1
        bv3 = BitVector(intVal=int(str(~bv),2)+1 ,size=32)
        bv = bv3

    summe = 0
    j = 0
    power = 7 
    for c in str(bv):
        
        if(j==0):
            toadd = -pow(2,power)
        else:
            toadd =  pow(2,power)
        power = power - 1
        summe=summe + toadd * int(c)
        j=j+1
    #print("Wert:"+str(value)+ " = " + str(summe))
    #print("Delta= " + str(abs(value-summe)))


    print("\t\t\twhen "+str(i)+" =>")
    print('\t\t\t\treturn "',end="")
    print(str(bv)+'";') 
    i=i+1
