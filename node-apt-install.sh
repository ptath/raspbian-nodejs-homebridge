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
        printf "${bold}${standout}${red}${text}${normal}"
}

print_green() {
        text="$1"
        printf "${bold}${standout}${green}${text}${normal}"
}

print_cyan() {
        text="$1"
        printf "${bold}${standout}${cyan}${text}${normal}"
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

print_title "SETTING UP REPOSITORY AND INSTALLING NODEJS FROM NODESOURCE" "https://github.com/nodesource/distributions"

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
    echo " $(print_red " This script does not supports $PI_ARM_VERSION")"
    echo " $(print_red " Should use node-bin-install.sh instead")"
  ;;

  armv7l )
    # Modern Pi (2B or better)
    if [ $(dpkg-query -W -f='${Status}' "nodejs" 2>/dev/null | grep -c "ok installed") -eq 0 ];then
      echo " Installing $(print_cyan "Node.js LTS (10.x)") from deb.nodesource.com"
      curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
      sudo apt install -y nodejs
      echo " $(print_green "Node.js installed") from apt, checking version..."
      echo "  Executing 'node -v', keep in mind that latest available is $VERSION"
      node -v
      echo "  Executing 'npm -v'"
      npm -v
    else
      if [ -f "/etc/apt/sources.list.d/nodesource.list" ]; then
        echo " Node.js $(print_green "already installed from apt"), checking version..."
        echo "  Executing 'node -v', keep in mind that latest available is $VERSION"
        node -v
        echo "  Executing 'npm -v'"
        npm -v
        echo " Node.js nodesource repo $(print_green "already installed"), updating and upgrading..."
        sudo apt update && sudo apt upgrade nodejs -y
      else
        echo " Node.js already installed from $(print_cyan "UNKNOWN") apt"
        echo "  Executing 'node -v', keep in mind that latest available is $VERSION"
        node -v
        echo "  Executing 'npm -v'"
        npm -v
        read -t 15 -n 1 -p " $(print_green "Add") nodesource repo and $(print_green "reinstall") from it? (Y/n): " choice
        [ -z "$choice" ] && choice="y"
        case $version_choice in
                y|Y )
                  echo " $(print_green "Yes")"
                  echo " Installing $(print_cyan "Node.js LTS (10.x)") from deb.nodesource.com"
                  curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
                  sudo apt install -y nodejs
                  echo " $(print_green "Node.js installed") from apt, checking version..."
                  echo "  Executing 'node -v', keep in mind that latest available is $VERSION"
                  node -v
                  echo "  Executing 'npm -v'"
                  npm -v
                ;;
                n|N|* )
                  echo " $(print_red "No")" && exit
                ;;
        esac
      fi
    fi
  ;;

  * )
    # Unknown
    echo " $(print_red "$PI_ARM_VERSION -- what are you? This architecture does not supported yet")"
    exit
  ;;
esac
