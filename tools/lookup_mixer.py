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

for x in index:
#    print("sin("+str(x)+")=" + str(sin(x/180*pi)))
    print("cos("+str(x)+")=" + str(cos(x/180*pi)))

skalierungsfaktor = pow(2,3*8)


print("\nCOSINUS")
i=0
for x in index:
    value= cos(x/180*pi)
    print("\t\t\twhen "+str(i)+" =>")
    print('\t\t\t\treturn "',end="") 
    if(value==1):
        print(7*"0"+"1"+24*"0",end="")
    elif(value==-1):
        print("1"+7*"0"+24*"0",end="")
    else:
        kommas = abs(int(value * skalierungsfaktor))
        bv = BitVector(intVal=kommas,size=24)
        if(value >0):
            print("0"+7*"0"+str(bv),end="")
        else:
            print("1"+7*"0"+str(bv),end="")
    print('";')
    i=i+1


print("\nSINUS")
i=0
for x in index:
    value= sin(x/180*pi)
    print("\t\t\twhen "+str(i)+" =>")
    print('\t\t\t\treturn "',end="") 
    if(value==1):
        print(7*"0"+"1"+24*"0",end="")
    elif(value==-1):
        print("1"+7*"0"+24*"0",end="")
    else:
        kommas = abs(int(value * skalierungsfaktor))
        bv = BitVector(intVal=kommas,size=24)
        if(value >0):
            print("0"+7*"0"+str(bv),end="")
        else:
            print("1"+7*"0"+str(bv),end="")
    print('";')
    i=i+1
