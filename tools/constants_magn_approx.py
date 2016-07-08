from math import *
from BitVector import *

skalierungsfaktor = pow(2,2*8) #16 after .

alpha =(2*cos(pi/8))/(1+cos(pi/8))
beta = (2*sin(pi/8))/(1+cos(pi/8))

values = [alpha,beta]
names = ["alpha","beta"]

i = 0
for i in range(0,len(values)) :
    value = values[i]
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

    print(names[i]+":")
    print("Wert:"+str(value)+ " = " + str(summe))
    print("")
    print(str(bv))

    print("")

