#!/usr/bin/env python3
import sys

decFactor=20
lenBlock=4

file_in=open(sys.argv[1],"r")
data_in=file_in.read()
file_formated=open("formated.txt","w")
file_decimated=open("decimated.txt","w")

#write it formated in blocks to a file
data_out= '\n'.join([data_in[i:i+lenBlock] for i in range(0, len(data_in), lenBlock)])
file_formated.write(data_out)

#do the decimation
data_out= "".join([data_in[i:i+4] for i in range(lenBlock*decFactor-lenBlock,len(data_in),lenBlock*decFactor)])

#-----------
#to view formated
#data_out= '|'.join([data_out[i:i+lenBlock] for i in range(0, len(data_out), lenBlock)])
#-----------

file_decimated.write(data_out)

file_in.close()
file_formated.close()
file_decimated.close()



