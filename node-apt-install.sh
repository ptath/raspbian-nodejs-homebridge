#!/bin/bash
# Version 0.1
script_branch="beta" # or master
# By ptath (https://ptath.ru)

function echo_bold() {
  tput bold
  echo "$1"
  tput sgr0
}

echo_bold "=========================="
echo_bold "======================= SETTING UP REPOSITORY AND INSTALLING NODEJS FROM NODESOURCE"
echo_bold "=======================        https://github.com/nodesource/distributions"
echo_bold "=========================="

# Checking last Node.js version

NODE_VERSION=$(
  curl https://nodejs.org/dist/index.json |
  egrep "{\"version\":\"v([0-9]+\.?){3}\"[^{]*\"linux-"$PI_ARM_VERSION"[^}]*lts\":\"[^\"]+\"" -o |
  head -n 1
);

VERSION=$(
  echo $NODE_VERSION |
  egrep 'v([0-9]+\.?){3}' -o
);

LTS_VERSION=$(echo $NODE_VERSION |
  egrep '"[^"]+"$' -o |
  egrep '[a-zA-Z]+' -o |
  tr '[:upper:]' '[:lower:]'
);


PI_ARM_VERSION=$(
  uname -a |
  egrep 'armv[0-9]+l' -o
);

case $PI_ARM_VERSION in
  armv6l )
    # Pi 1/2/3A/zero
    echo_bold "====== ERROR ====== This script does not supports $PI_ARM_VERSION"
    echo_bold "====== ERROR ====== Use node-bin-install.sh instead"
  ;;

  armv7l )
    # Modern Pi (2B or better)
    if [ $(dpkg-query -W -f='${Status}' "nodejs" 2>/dev/null | grep -c "ok installed") -eq 0 ];then
      echo_bold "====== Installing Node.js LTS (10.x) from deb.nodesource.com"
      curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
      sudo apt install -y nodejs
      echo_bold "====== Node.js installed from apt, checking version..."
      echo "=== Executing 'node -v', keep in mind that latest available is $VERSION"
      node -v
      echo "=== Executing 'npm -v'"
      npm -v
    else
      if [ -f "/etc/apt/sources.list.d/nodesource.list" ]; then
        echo_bold "====== Node.js already installed from apt, checking version..."
        echo "=== Executing 'node -v', keep in mind that latest available is $VERSION"
        node -v
        echo "=== Executing 'npm -v'"
        npm -v
        echo_bold "====== Node.js nodesource repo already installed, updating and upgrading..."
        sudo apt update && sudo apt upgrade nodejs -y
      else
        echo_bold "====== Node.js already installed from UNKNOWN apt"
        echo "=== Executing 'node -v', keep in mind that latest available is $VERSION"
        node -v
        echo "=== Executing 'npm -v'"
        npm -v
        read -t 15 -n 1 -p "====== Add nodesource repo and reinstall from it (Y/n): " choice
        [ -z "$choice" ] && choice="y"
        case $version_choice in
                y|Y )
                  echo " Yes"
                  echo_bold "====== Installing Node.js LTS (10.x) from deb.nodesource.com"
                  curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
                  sudo apt install -y nodejs
                  echo_bold "====== Node.js installed from apt, checking version..."
                  echo "=== Executing 'node -v', keep in mind that latest available is $VERSION"
                  node -v
                  echo "=== Executing 'npm -v'"
                  npm -v
                ;;
                n|N|* )
                  echo " No" && exit
                ;;
        esac
      fi
    fi
  ;;

  armv8l ) echo "====== OMG $PI_ARM_VERSION =) 64-bit Raspbian versions does not supported yet" && exit;;
  *) echo "====== $PI_ARM_VERSION What are you? This architecture does not supported yet" && exit;;
esac
