#!/bin/bash
# Version 0.1
script_branch="beta" # or master
# By ptath (https://ptath.ru)

#

function echo_bold() {
  tput bold
  echo "$1"
  tput sgr0
}

echo_bold "=========================="
echo_bold "======================= INSTALLING NODEJS FROM OFFICIAL BINARIES"
echo_bold "=======================        https://nodejs.org/dist/"
echo_bold "=========================="

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

    read -t 15 -n 1 -p "====== Which one to install LTS (S) or latest $VERSION (L)? (S/l): " version_choice
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

    echo "====== Downloading and installing Node.js..."
    wget -q -N -O /tmp/install-node.sh "$script_url" &&
      chmod +x /tmp/install-node.sh &&
      /tmp/install-node.sh &&
      rm /tmp/install-node.sh

    if [ $(cat ~/.profile 2>/dev/null | grep -c "export PATH=\$PATH:/opt/nodejs/bin") -eq 0 ];then
      echo "====== Adding /opt/nodejs/bin to PATH in ~/.profile"
      echo "export PATH=\$PATH:/opt/nodejs/bin" >> ~/.profile
    else
      echo "=== > PATH /opt/nodejs/bin already set in ~/.profile, skipping"
    fi

    echo_bold "=========================="
    echo_bold "======================= Installation of Node.js is complete"
    echo_bold "======================= Run this script again anytime to upgrade"
    echo_bold "=========================="
    echo "=== Executing 'node -v', keep in mind that latest available is $VERSION"
    node -v
    echo "=== Executing 'npm -v'"
    npm -v
  ;;

  armv7l )
    # Modern Pi (2B or better)
    echo_bold "====== ERROR ====== This script does not supports $PI_ARM_VERSION"
    echo_bold "====== ERROR ====== Use node-apt-install.sh instead"
  ;;

  armv8l ) echo "====== OMG $PI_ARM_VERSION =) 64-bit Raspbian versions does not supported yet" && exit;;
  *) echo "====== $PI_ARM_VERSION What are you? This architecture does not supported yet" && exit;;
esac
