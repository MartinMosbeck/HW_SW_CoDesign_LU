from math import *
from BitVector import *

arg = [0.78539816339745,1.10714871779409,1.24904577239825,1.32581766366803,1.37340076694502,1.40564764938027,1.42889927219073,1.44644133224814,1.46013910562100,1.47112767430373,1.48013643959415,1.48765509490646,1.49402443552512,1.49948886200961,1.50422816301907,1.50837751679894,0.46364760900081,0.78539816339745,0.98279372324733,1.10714871779409,1.19028994968253,1.24904577239825,1.29249666778979,1.32581766366803,1.35212738092095,1.37340076694502,1.39094282700242,1.40564764938027,1.41814699839963,1.42889927219073,1.43824479449822,1.44644133224814,0.32175055439664,0.58800260354757,0.78539816339745,0.92729521800161,1.03037682652431,1.10714871779409,1.16590454050981,1.21202565652432,1.24904577239825,1.27933953231703,1.30454427764397,1.32581766366803,1.34399747874101,1.35970299357215,1.37340076694502,1.38544837679920,0.24497866312686,0.46364760900081,0.64350110879328,0.78539816339745,0.89605538457134,0.98279372324733,1.05165021254837,1.10714871779409,1.15257199721567,1.19028994968253,1.22202532321099,1.24904577239825,1.27229739520872,1.29249666778979,1.31019393504756,1.32581766366803,0.19739555984988,0.38050637711236,0.54041950027058,0.67474094222355,0.78539816339745,0.87605805059819,0.95054684081208,1.01219701145133,1.06369782240256,1.10714871779409,1.14416883366802,1.17600520709514,1.20362249297668,1.22777238637419,1.24904577239825,1.26791145841993,0.16514867741463,0.32175055439664,0.46364760900081,0.58800260354757,0.69473827619670,0.78539816339745,0.86217005466723,0.92729521800161,0.98279372324733,1.03037682652431,1.07144960511477,1.10714871779409,1.13838855122436,1.16590454050981,1.19028994968253,1.21202565652432,0.14189705460416,0.27829965900511,0.40489178628508,0.51914611424652,0.62024948598282,0.70862627212767,0.78539816339745,0.85196632717327,0.90975315794421,0.96007036240569,1.00406710927139,1.04272187836854,1.07685495787532,1.10714871779409,1.13416916698136,1.15838588519751,0.12435499454676,0.24497866312686,0.35877067027057,0.46364760900081,0.55859931534356,0.64350110879328,0.71882999962162,0.78539816339745,0.84415398611317,0.89605538457134,0.94200004037946,0.98279372324733,1.01914134426635,1.05165021254837,1.08083900054117,1.10714871779409,0.11065722117390,0.21866894587394,0.32175055439664,0.41822432957923,0.50709850439234,0.58800260354757,0.66104316885069,0.72664234068173,0.78539816339745,0.83798122500839,0.88506681588861,0.92729521800161,0.96525166318993,0.99945884696127,1.03037682652431,1.05840686648416,0.09966865249116,0.19739555984988,0.29145679447787,0.38050637711236,0.46364760900081,0.54041950027058,0.61072596438921,0.67474094222355,0.73281510178651,0.78539816339745,0.83298126667443,0.87605805059819,0.91510070055336,0.95054684081208,0.98279372324733,1.01219701145133,0.09065988720075,0.17985349979248,0.26625204915093,0.34877100358391,0.42662749312688,0.49934672168013,0.56672921752351,0.62879628641543,0.68572951090629,0.73781506012046,0.78539816339745,0.82884905878898,0.86853939528589,0.90482708941579,0.93804749179271,0.96850898065993,0.08314123188844,0.16514867741463,0.24497866312686,0.32175055439664,0.39479111969976,0.46364760900081,0.52807444842636,0.58800260354757,0.64350110879328,0.69473827619670,0.74194726800592,0.78539816339745,0.82537685052074,0.86217005466723,0.89605538457134,0.92729521800161,0.07677189126978,0.15264932839527,0.22679884805389,0.29849893158618,0.36717383381822,0.43240777557054,0.49394136891958,0.55165498252855,0.60554466360497,0.65569562624154,0.70225693150901,0.74541947627416,0.78539816339745,0.82241827927138,0.85670562818274,0.88847977192015,0.07130746478529,0.14189705460416,0.21109333322275,0.27829965900511,0.34302394042070,0.40489178628508,0.46364760900081,0.51914611424652,0.57133747983363,0.62024948598282,0.66596923737911,0.70862627212767,0.74837804752352,0.78539816339745,0.81986726439696,0.85196632717327,0.06656816377582,0.13255153229667,0.19739555984988,0.26060239174734,0.32175055439664,0.38050637711236,0.43662715981354,0.48995732625373,0.54041950027058,0.58800260354757,0.63274883500218,0.67474094222355,0.71409069861216,0.75092906239794,0.78539816339745,0.81764504583270,0.06241880999596,0.12435499454676,0.18534794999569,0.24497866312686,0.30288486837497,0.35877067027057,0.41241044159739,0.46364760900081,0.51238946031074,0.55859931534356,0.60228734613496,0.64350110879328,0.68231655487475,0.71882999962162,0.75315128096219,0.78539816339745]

skalierungsfaktor = pow(2,2*8)

bitinsgesamt=8

i=0
print("VOLL ARG EUDA:")
for value in arg:

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

    string = "0" * (bitinsgesamt-len(str(bin(i))[2:])) + str(bin(i))[2:];

    print('\t\t\twhen "'+string+'" =>',end="")
    print(' erg := "',end="")
    print(str(bv)+'";') 
    #print("\t0b"+str(bv)+",")
    i=i+1
    #print("Wert:"+str(value)+ " = " + str(summe))
    #print("Delta= " + str(abs(value-summe)))
    #print("");