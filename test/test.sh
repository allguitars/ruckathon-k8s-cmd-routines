#!/bin/bash

# figlet -c -w 140 -W -f standard Running: 3
# figlet -c -w 140 -W -f standard container: 2
# figlet -c -w 140 -W -f standard Terminating: 1
# figlet -c -w 140 -W -f standard Error: 0

set -e
echo hello >> $HOME/random/log || echo bye
