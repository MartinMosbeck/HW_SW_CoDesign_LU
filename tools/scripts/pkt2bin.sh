#!/bin/bash
# Usage ./pkt2bin infile.pcab outfile.bin
# The packets may be captured by:
# tshark -i eth0 -w ~/Downloads/dump.pcap
FILE=`mktemp`

tshark -r $1 -T fields -e data -Y 'eth.type == 0x88b5' | tr -d '\n' > $FILE
./pkt2bin.py $FILE > $2

rm $FILE
