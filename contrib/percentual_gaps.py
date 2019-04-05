#!/usr/bin/python

# usage: ./script.py <percentage> <i3 config>
import sys, os

# get screen dimensions
os.system("xrandr > xrandr_output.txt")
with open("xrandr_output.txt") as output:
    for line in output:
        if not line.startswith("Screen"):
            continue

        line = line.split(",")
        current = line[1].split()
        height = int(current[3])
        width = int(current[1])

os.system("rm xrandr_output.txt")

# calculate pixel size based on percentage
percentage = int(sys.argv[1])
pixel = height * 0.01 * percentage

# edit config file (add new pixel size)
c_str = sys.argv[2]
with open(c_str) as config:
    buff = []
    #search for gaps line
    for line in config:
        if line.startswith("gaps"):
            line = line.split()
            line[2] = str(int(pixel)) + "\n"
            line = " ".join(line)
        buff.append(line)

#re-write file with edited line
with open(c_str, "w") as config:
    for line in buff:
        config.write(line)
