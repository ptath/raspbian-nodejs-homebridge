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

print_title "INSTALLING HOMEBRIDGE" "http://homebridge.io"

echo " Checking npm packages to install..."

wget -q -N -O /tmp/npm.list https://github.com/ptath/raspbian-nodejs-homebridge/raw/"$script_branch"/lists/npm.list
[ -e /tmp/npm.list ] && echo "  Will check these apt packages: " && cat /tmp/npm.list
[ ! -e /tmp/npm.list ] && echo "  $(print_red "ERROR downloading or parsing packages list to /tmp/npm.list")" && exit

IFS=$'\n' GLOBIGNORE='*' command eval 'SSM=($(cat /tmp/npm.list))'
npms=${SSM[*]}

[ -e /tmp/npm_installed_list ] &&
  rm /tmp/npm_installed_list &&
  echo $(npm list -g --depth 0) > /tmp/npm_installed_list

  for item in ${npms[*]}
  do
    package_name=$item
    if [ $(cat /tmp/npm_installed_list | grep -c "$package_name@") -eq 0 ];then
      echo " Installing $(print_cyan "$package_name")..."
      npm install -g "$package_name"

      # Removing symlinks
      sudo unlink /usr/bin/"$package_name";
      sudo unlink /usr/sbin/"$package_name";
      sudo unlink /sbin/"$package_name";
      sudo unlink /usr/local/bin/"$package_name";

      # Adding symlinks
      sudo ln -s /opt/nodejs/bin/"$package_name" /usr/bin/"$package_name";
      sudo ln -s /opt/nodejs/bin/"$package_name" /usr/sbin/"$package_name";
      sudo ln -s /opt/nodejs/bin/"$package_name" /sbin/"$package_name";
      sudo ln -s /opt/nodejs/bin/"$package_name" /usr/local/bin/"$package_name";

    else
      read -t 10 -n 1 -p " $(print_cyan "$package_name") already installed, $(print_red "reinstall")? (N/y): " reinstall_choice
      [ -z "$reinstall_choice" ] && reinstall_choice="n"
      case $version_choice in
              y|Y )
                echo " Reinstalling..." &&
                npm remove -g "$package_name" &&
                npm install -g "$package_name"
              ;;
              n|N|* )
                echo " Leaving"
              ;;
      esac
    fi
  done

print_title "CONFIGURING HOMEBRIDGE" "Creating sample config file and so on"

[ -e ~/.homebridge/config.json ] &&
  mkdir ~/.homebridge/conf-backups/ &&
  cp ~/.homebridge/config.json ~/.homebridge/config.json.$(date -d "today" +"%Y%m%d%H%M")
  echo " Config file backup created in $(print_cyan ~/.homebridge/conf-backups/")"

wget -q -N -O ~/.homebridge/config.json https://github.com/ptath/raspbian-nodejs-homebridge/raw/"$script_branch"/lists/config.json.default
[ -e ~/.homebridge/config.json ] && echo " Default config file copied to Homebridge dir"
[ ! -e ~/.homebridge/config.json ] && echo "  $(print_red "ERROR downloading or copying default config file")" && exit
