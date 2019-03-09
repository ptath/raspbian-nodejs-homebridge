#!/bin/bash
# Version 0.1
script_branch="beta" # or master
# By ptath (https://ptath.ru)

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

print_title "CHECKING ENVIROMENT" "Now will install necessary packages and check device architecture"

echo " Checking apt packages to install..."

wget -q -N -O /tmp/apt.list https://github.com/ptath/raspbian-nodejs-homebridge/raw/"$script_branch"/lists/apt.list
[ ! -e /tmp/apt.list ] && echo "  $(print_red "ERROR downloading or parsing packages list to /tmp/apt.list")" && exit

IFS=$'\n' GLOBIGNORE='*' command eval 'SSM=($(cat /tmp/apt.list))'
apts=${SSM[*]}

echo " Updating $(print_cyan "apt") packages..."

read -t 15 -n 1 -p " Update now? Y/n): " choice
[ -z "$choice" ] && choice="y"
case $choice in
        y|Y )
          echo " $(print_green "Yes")"
          sudo apt update
        ;;
        n|N|* )
          echo " $(print_red "No")"
        ;;
esac

read -t 15 -n 1 -p " Upgrade now? Y/n): " choice
[ -z "$choice" ] && choice="y"
case $version_choice in
        y|Y )
          echo " $(print_green "Yes")"
          sudo apt upgrade -y
        ;;
        n|N|* )
          echo " $(print_red "No")"
        ;;
esac

echo " Installing necessary $(print_cyan "apt packages")..."
for item in ${apts[*]}
do
  package_name=$item
  if [ $(dpkg-query -W -f='${Status}' "$package_name" 2>/dev/null | grep -c "ok installed") -eq 0 ];then
        echo "  Installing: $(print_cyan "$package_name")..."
        sudo apt install "$package_name" -y
  else
        echo "  Already installed: $(print_green "$package_name")"
  fi
done

# check if Node.JS already installed
if [ $(which node 2>/dev/null | grep -c "/node") -eq 0 ];then
  echo " Node.JS is $(print_cyan "not installed...")"
else
  echo " Node.JS $(print_green "already installed") in $(which node)"
  node_ver=$(
    node -v |
    egrep 'v[0-10]'
  );
  read -t 15 -n 1 -p " Install it again (all current Node.JS settings and packages $(print_red "will be lost"))? (N/y): " choice
  case $choice in
    Y|y) echo " Proceeding...";;
    N|n|*) exit;;
  esac
fi

# Checking architecture
PI_ARM_VERSION=$(
  uname -a |
  egrep 'armv[0-9]+l' -o
);

case $PI_ARM_VERSION in

  armv6l )
    # Pi 1/2/3A/zero
    echo " $(print_green "$PI_ARM_VERSION") architecture should install binaries from official Node.js website"
    echo "  Downloading and running $(print_cyan "node-bin-install.sh") for $PI_ARM_VERSION"
    wget -q -N -O /tmp/node-bin-install.sh https://github.com/ptath/raspbian-nodejs-homebridge/raw/"$script_branch"/node-bin-install.sh
    [ -e /tmp/node-bin-install.sh ] &&
      chmod +x /tmp/node-bin-install.sh &&
      /tmp/node-bin-install.sh
    [ ! -e /tmp/node-bin-install.sh ] && echo " $(print_red "ERROR downloading or running /tmp/node-bin-install.sh")" && exit
  ;;

  armv7l )
    # Modern Pi (2B or better)
    echo " $(print_green "$PI_ARM_VERSION") architecture can be set up for using nodesource repository"
    echo "  Downloading and running $(print_cyan "node-apt-install.sh") for $PI_ARM_VERSION"
    wget -q -N -O /tmp/node-apt-install.sh https://github.com/ptath/raspbian-nodejs-homebridge/raw/"$script_branch"/node-apt-install.sh
    [ -e /tmp/node-apt-install.sh ] &&
      chmod +x /tmp/node-apt-install.sh &&
      /tmp/node-apt-install.sh
    [ ! -e /tmp/node-apt-install.sh ] && echo " $(print_red "ERROR downloading or running /tmp/node-apt-install.sh")" && exit
  ;;

  * )
    # Unknown
    echo " $(print_red "$PI_ARM_VERSION -- what are you? This architecture does not supported yet")"
    exit
  ;;
esac
