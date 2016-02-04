#!/usr/bin/env python3
import sys

file1_name=sys.argv[1]
file2_name=sys.argv[2]

file1=open(file1_name,"r")
file2=open(file2_name,"r")

data1 = file1.read().rstrip()
data2 = file2.read().rstrip()


if(len(data1)!=len(data2)):
    print("Length mismatch\n")


len_min = min([len(data1),len(data2)])

mismatches = [i for i in range(len_min) if data1[i] != data2[i]]

for pos in mismatches:
    print("Missmatch at {0}: \n\tIn {1}: {2}\n\tIn {3}: {4}\n".format(pos,file1_name,data1[pos],file2_name,data2[pos]))


