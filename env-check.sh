#!/bin/bash
# Version 0.1
script_branch="beta" # or master
# By ptath (https://ptath.ru)

# misc

function echo_bold() {
  tput bold
  echo "$1"
  tput sgr0
}

echo_bold "=========================="
echo_bold "======================= CHECKING ENVIROMENT"
echo_bold "=========================="

echo "====== Checking apt packages list..."

wget -q -N -O /tmp/apt.list https://github.com/ptath/raspbian-nodejs-homebridge/raw/"$script_branch"/lists/apt.list
[ -e /tmp/apt.list ] && echo "====== Will install these apt packages: " && cat /tmp/apt.list
[ ! -e /tmp/apt.list ] && echo_bold "====== ERROR downloading or parsing packages list to /tmp/apt.list" && exit

IFS=$'\n' GLOBIGNORE='*' command eval 'SSM=($(cat /tmp/apt.list))'
apts=${SSM[*]}

echo "====== Updating apt packages..."
sudo apt update

read -t 15 -n 1 -p "====== Upgrade now? (N/y): " choice
[ -z "$choice" ] && choice="n"
case $version_choice in
        y|Y )
          echo " Yes"
          sudo apt upgrade -y
        ;;
        n|N|* )
          echo " No"
        ;;
esac

echo "====== Installing necessary apt packages..."
for item in ${apts[*]}
do
  package_name=$item
  if [ $(dpkg-query -W -f='${Status}' "$package_name" 2>/dev/null | grep -c "ok installed") -eq 0 ];then
        echo "=== Installing "$package_name"..."
        sudo apt install "$package_name" -y
  else
        echo "=== Already installed: "$package_name
  fi
done

# Checking architecture

PI_ARM_VERSION=$(
  uname -a |
  egrep 'armv[0-9]+l' -o
);

case $PI_ARM_VERSION in

  armv6l )
    # Pi 1/2/3A/zero
    echo_bold "====== $PI_ARM_VERSION architecture should install binaries from official Node.js website"
    echo_bold "====== Downloading and running node-bin-install.sh for $PI_ARM_VERSION"
    wget -q -N -O /tmp/node-bin-install.sh https://github.com/ptath/raspbian-nodejs-homebridge/raw/"$script_branch"/node-bin-install.sh
    [ -e /tmp/node-bin-install.sh ] &&
      chmod +x /tmp/node-bin-install.sh &&
      /tmp/node-bin-install.sh
    [ ! -e /tmp/node-bin-install.sh ] && echo_bold "====== ERROR downloading or running /tmp/node-bin-install.sh" && exit
  ;;

  armv7l )
    # Modern Pi (2B or better)
    echo_bold "====== $PI_ARM_VERSION architecture can be set up for using nodesource repository"
    echo_bold "====== Downloading and running node-apt-install.sh for $PI_ARM_VERSION"
    wget -q -N -O /tmp/node-apt-install.sh https://github.com/ptath/raspbian-nodejs-homebridge/raw/"$script_branch"/node-apt-install.sh
    [ -e /tmp/node-apt-install.sh ] &&
      chmod +x /tmp/node-apt-install.sh &&
      /tmp/node-apt-install.sh
    [ ! -e /tmp/node-apt-install.sh ] && echo_bold "====== ERROR downloading or running /tmp/node-apt-install.sh" && exit
  ;;

  * )
    # Unknown
    echo_bold "====== $PI_ARM_VERSION What are you? This architecture does not supported yet"
    exit
  ;;

esac
