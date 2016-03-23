from math import *
from BitVector import *



bSkal = 1

# lowpass_5_60kHz
b = [0.00113346381387758,-0.00378921524655597,0.00538179194115286,-0.00378921524655597,0.00113346381387758]

#bandpass_7_19kHz
#b = [0.000894338131378939,-0.00204191135309592,0.00202869620505740,0,-0.00202869620505740,0.00204191135309592,-0.000894338131378939]




aSkal = 1
# lowpass_5_60kHz
a = [-3.88963739674497,5.69719400516089,-3.72388799179207,0.916430669334689] 

#bandpass_7_19kHz
#a = [-3.45269383242918,6.94670643083800,-8.37374250735840,6.89638853812718,-3.40283483442992,0.978422750372621] 


skalierungsfaktor = pow(2,2*8)

i=0
print("a:")
for value in a:
    value = value * aSkal

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

    #print("\t\t\twhen "+str(i)+" =>")
    #print('\t\t\t\treturn "',end="")
    #print(str(bv)+'";') 
    print("\t0b"+str(bv)+",")
    i=i+1
    #print("Wert:"+str(value)+ " = " + str(summe))
    #print("Delta= " + str(abs(value-summe)))
    #print("");

i=0
print("b:")
for value in b:
    value = value * bSkal

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

    #print("\t\t\twhen "+str(i)+" =>")
    #print('\t\t\t\treturn "',end="")
    #print(str(bv)+'";') 
    print("\t0b"+str(bv)+",")
    i=i+1
    #print("Wert:"+str(value)+ " = " + str(summe))
    #print("Delta= " + str(abs(value-summe)))
    #print("");
