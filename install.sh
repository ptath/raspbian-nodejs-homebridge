#!/bin/bash
# Version 0.1
script_branch="beta" # or master
# By ptath (https://ptath.ru)

# Script to install Node.js and Homebridge for Raspbian

# misc

# Colors for terminal (works with Raspbian)
if test -t 1; then
    ncolors=$(which tput > /dev/null && tput colors)
    if test -n "$ncolors" && test $ncolors -ge 8; then
        termcols=$(tput cols)
        bold="$(tput bold)"
        standout="$(tput smso)"
        normal="$(tput sgr0)"
        red="$(tput setaf 1)"
        green="$(tput setaf 2)"
        cyan="$(tput setaf 6)"
    fi
fi

print_red() {
        text="$1"
        printf "${bold}${red}${text}${normal}"
}

print_green() {
        text="$1"
        printf "${bold}${green}${text}${normal}"
}

print_cyan() {
        text="$1"
        printf "${bold}${cyan}${text}${normal}"
}

print_title() {
    title="$1"
    text="$2"

    echo
    echo "${cyan}================================================================================${normal}"
    echo
    echo -e "  ${bold}${cyan}${title}${normal}"
    echo
    echo -en "  ${text}"
    echo
    echo "${cyan}================================================================================${normal}"
    echo
}

# Script starts here

# Checking enviroment and installing Node.JS
wget -q -N -O /tmp/env-check.sh https://github.com/ptath/raspbian-nodejs-homebridge/raw/"$script_branch"/env-check.sh
[ -e /tmp/env-check.sh ] &&
  chmod +x /tmp/env-check.sh &&
  /tmp/env-check.sh
[ ! -e /tmp/env-check.sh ] && echo " $(print_red "ERROR downloading or running /tmp/env-check.sh")" && exit

# installing npm packages
wget -q -N -O /tmp/node-npm-install.sh https://github.com/ptath/raspbian-nodejs-homebridge/raw/"$script_branch"/node-npm-install.sh
[ -e /tmp/node-npm-install.sh ] &&
  chmod +x /tmp/node-npm-install.sh &&
  /tmp/node-npm-install.sh
[ ! -e /tmp/node-npm-install.sh ] && echo " $(print_red "ERROR downloading or running /tmp/node-npm-install.sh")" && exit
