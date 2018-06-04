#!/usr/bin/env python

import random
import subprocess

def run_cmd(cmd):
    proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (out, err) = proc.communicate()
    proc.wait()
    return out

animals = []
for lines in run_cmd(['cowsay', '-l']).splitlines()[1:]:
    for name in lines.split():
        animals.append(name)


informs = ['cowsay', 'cowthink']
states = ['-b', '-d', '-g', '-p', '-s', '-t', '-w', '-y']

inform = random.choice(informs)
state = random.choice(states)
animal = random.choice(animals)
message = run_cmd(['fortune', '-aes'])

print run_cmd([inform, state, '-f', animal, message])
