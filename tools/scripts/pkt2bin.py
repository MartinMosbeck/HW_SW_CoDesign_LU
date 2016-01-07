#!/usr/bin/python
# Taken from: https://ask.wireshark.org/questions/15374/dump-raw-packet-data-field-only
import binascii
import sys
string = open(sys.argv[1],'r').read()
sys.stdout.write(binascii.unhexlify(string)) # needs to be stdout.write to avoid trailing newline

