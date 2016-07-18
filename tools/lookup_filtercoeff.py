from math import *
from BitVector import *



bSkal = 1

# lowpass_4_60kHz # Verwendet für Filter vor den Decimators
# b = [0.00113346381387758,-0.00378921524655597,0.00538179194115286,-0.00378921524655597,0.00113346381387758]

# lowpass_4_15kHz
#b = [0.001000281537096, -0.003955076520888, 0.005909873212025, -0.003955076520888, 0.001000281537096]

# lowpass_4_12kHz # Verwendet für Filter vor der Radioausgabe
#b = [0.004187114898740, 0.0009994182181411220, 0.005831711006898, 0.0009994182181411220, 0.004187114898740]

#bandpass_7_19kHz
#b = [0.000894338131378939,-0.00204191135309592,0.00202869620505740,0,-0.00202869620505740,0.00204191135309592,-0.000894338131378939]

#Filter der Demoduliert
b = [0.003364592077873, -0.008352459804073, 0.011336128616423, -0.014368443293008, 0.017763147099626, -0.021695039894509, 0.026341925690623, -0.031964020683474, 0.038948345863624, -0.047956234761468, 0.060158529138933, -0.077927635627284, 0.106771055270666, -0.163276832680953, 0.330306227303649, 0, -0.330306227303649, 0.163276832680953, -0.106771055270666, 0.077927635627284, -0.060158529138933, 0.047956234761468, -0.038948345863624, 0.031964020683474, -0.026341925690623, 0.021695039894509, -0.017763147099626, 0.014368443293008, -0.011336128616423, 0.008352459804073, -0.003364592077873]




aSkal = 1
# lowpass_4_60kHz # Verwendet für Filter vor den Decimators
# a = [-3.88963739674497,5.69719400516089,-3.72388799179207,0.916430669334689] 

#lowpass_4_15kHz
#a = [-3.976719547394894,5.931878396258008,-3.933574917081451,0.978416468311742]

#lowpass_4_12kHz # Verwendet für Filter vor der Radioausgabe
a = [-3.301349975804374, 4.409181614887121, -2.790757280522690, 0.705815497694625]

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

    print("\t\t\twhen "+str(i)+" =>")
    print('\t\t\t\treturn "',end="")
    print(str(bv)+'";') 
    #print("\t0b"+str(bv)+",")
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

    print("\t\t\twhen "+str(i)+" =>")
    print('\t\t\t\treturn "',end="")
    print(str(bv)+'";') 
    #print("\t0b"+str(bv)+",")
    i=i+1
    #print("Wert:"+str(value)+ " = " + str(summe))
    #print("Delta= " + str(abs(value-summe)))
    #print("");
