#!/usr/bin/env python
import sys

if len(sys.argv) != 2:
    print("You must specify a hostname as the first and only command line argument.")
    exit(-1)

hostname=sys.argv[1]

cap = 5000
priority = 1

for chr in hostname:
    chr_ord=ord(chr)
    if (priority + chr_ord) > cap:
        priority = 1
    priority += chr_ord

print(priority)