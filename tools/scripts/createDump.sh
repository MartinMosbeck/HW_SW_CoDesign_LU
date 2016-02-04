#!/bin/bash
sudo rm dump*

sudo tshark -i enp0s25 -T fields -e data -Y 'eth.type == 0x88b5' | tr -d '\n' > dump1.txt  
# ./pkt2bin.py dump.txt dump1.txt dump2.txt
