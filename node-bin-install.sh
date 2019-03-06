#!/bin/bash
# Version 0.1
script_branch="beta" # or master
# By ptath (https://ptath.ru)

#

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

print_title "INSTALLING NODEJS FROM OFFICIAL BINARIES" "https://nodejs.org/dist/"

PI_ARM_VERSION=$(
  uname -a |
  egrep 'armv[0-9]+l' -o
);

case $PI_ARM_VERSION in
  armv6l )
    # Pi 1/2/3A/zero
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

    read -t 15 -n 1 -p " Which one to install $(print_green "LTS (S)") or latest $VERSION (L)? (S/l): " version_choice
    [ -z "$version_choice" ] && version_choice="s"
    case $version_choice in
            s|S|* )
              echo " LTS" &&
              script_url="https://github.com/sdesalas/node-pi-zero/raw/master/install-node-v.lts.sh"
            ;;
            l|L )
              echo " Latest $VERSION" &&
              script_url="https://github.com/sdesalas/node-pi-zero/raw/master/install-node-v.last.sh"
            ;;
    esac

    echo " Downloading and $(print_cyan "installing Node.js")..."
    wget -q -N -O /tmp/install-node.sh "$script_url" &&
      chmod +x /tmp/install-node.sh &&
      /tmp/install-node.sh &&
      rm /tmp/install-node.sh

    if [ $(cat ~/.profile 2>/dev/null | grep -c "export PATH=\$PATH:/opt/nodejs/bin") -eq 0 ];then
      echo "  Adding /opt/nodejs/bin to $(print_cyan "PATH") in ~/.profile"
      echo "export PATH=\$PATH:/opt/nodejs/bin" >> ~/.profile
    else
      echo " $(print_cyan "PATH") /opt/nodejs/bin $(print_green "already set") in ~/.profile, skipping"
    fi

    print_title "Installation of Node.js is complete" "Run this script again anytime to upgrade"
    echo " Executing 'node -v', keep in mind that latest available is $VERSION"
    node -v
    echo " Executing 'npm -v'"
    npm -v
  ;;

  armv7l )
    # Modern Pi (2B or better)
    echo " $(print_red " This script does not supports $PI_ARM_VERSION")"
    echo " $(print_red " Should use node-apt-install.sh instead")"
  ;;

  * )
    # Unknown
    echo " $(print_red "$PI_ARM_VERSION -- what are you? This architecture does not supported yet")"
    exit
  ;;
esac
