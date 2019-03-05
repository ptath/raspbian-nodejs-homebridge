#!/bin/bash
# Version 0.1
script_branch="beta" # or master
# By ptath (https://ptath.ru)

# Script to install Node.js and Homebridge for Raspbian

# Checking enviroment
wget -q -N -O /tmp/env-check.sh https://github.com/ptath/raspbian-nodejs-homebridge/raw/"$script_branch"/env-check.sh
[ -e /tmp/env-check.sh ] &&
  chmod +x /tmp/env-check.sh &&
  /tmp/env-check.sh
[ ! -e /tmp/env-check.sh ] && echo_bold "====== ERROR downloading or running /tmp/env-check.sh" && exit

echo "========= TBD =========="
