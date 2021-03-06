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

print_title "INSTALLING HOMEBRIDGE" "http://homebridge.io"

echo " Checking npm packages to install..."

[ -e /tmp/npm.list ] && rm /tmp/npm.list

wget -q -N -O /tmp/npm.list https://github.com/ptath/raspbian-nodejs-homebridge/raw/"$script_branch"/lists/npm.list
[ ! -e /tmp/npm.list ] && echo "  $(print_red "ERROR downloading or parsing packages list /tmp/npm.list")" && exit

IFS=$'\n' GLOBIGNORE='*' command eval 'SSM=($(cat /tmp/npm.list))'
npms=${SSM[*]}

# Get installed npm packages
[ -e /tmp/npm_installed_list ] &&
  rm /tmp/npm_installed_list
echo $(npm list -g --depth 0) > /tmp/npm_installed_list

# Install packages, excluding already installed
for item in ${npms[*]}
do
  package_name=$item
  if [ $(cat /tmp/npm_installed_list | grep -c "$package_name@") -eq 0 ];then
    echo "  Installing $(print_cyan "$package_name")..."
    npm install -g "$package_name"
  else
    read -t 15 -n 1 -p "  $(print_green "$package_name") already installed, $(print_red "reinstall")? (N/y): " reinstall_choice
    [ -z "$reinstall_choice" ] && reinstall_choice="n"
    case $version_choice in
            y|Y )
              echo " Reinstalling...";
              npm remove -g "$package_name";
              npm install -g "$package_name";
            ;;
            n|N|* )
              echo " No"
            ;;
    esac
fi
done

# Homebridge configuration
print_title "CONFIGURING HOMEBRIDGE" "Creating sample config file, setting startup and so on"

[ ! -d ~/.homebridge ] && mkdir ~/.homebridge

[ -e ~/.homebridge/config.json ] &&
  [ ! -d ~/.homebridge/conf-backups ] && mkdir ~/.homebridge/conf-backups
  mkdir ~/.homebridge/conf-backups/ &&
  cp ~/.homebridge/config.json ~/.homebridge/conf-backups/config.json.$(date -d "today" +"%Y%m%d%H%M") &&
  echo " Config file backup created in $(print_cyan "~/.homebridge/conf-backups/")"

wget -q -N -O ~/.homebridge/config.json https://github.com/ptath/raspbian-nodejs-homebridge/raw/"$script_branch"/homebridge-configs/config.json.default
[ -e ~/.homebridge/config.json ] &&
  echo " Default config file downloaded and copied to Homebridge dir"
[ ! -e ~/.homebridge/config.json ] &&
  echo "  $(print_red "ERROR downloading or copying default config file")" && exit

echo " Setting up $print_cyan("pm2") to start Homebridge after reboot or crash"

[ -e /tmp/pm2.systemd.script ] && rm /tmp/pm2.systemd.script
pm2 startup systemd > /tmp/pm2.systemd.script

if [ $(cat /tmp/pm2.systemd.script 2>/dev/null | grep -c "sudo env") -eq 1 ];then
  echo "  Installing pm2 to systemd..."
  eval $(cat /tmp/pm2.systemd.script | grep "sudo env")
  rm /tmp/pm2.systemd.script
else
  echo " $(print_red "ERROR:") "
  cat /tmp/pm2.systemd.script && exit
fi

echo "  Daemonizing $print_cyan("homebridge") via pm2..."
pm2 start homebridge
echo "  Saving pm2 configuration..."
pm2 save
echo "  Read this http://pm2.keymetrics.io/docs/usage/specifics/#listening-on-port-80-w-o-root"

print_title "HOMEBRIDGE INSTALLATION COMPLETE" "Should reboot now"

read -t 15 -n 1 -p " Stop rebooting? (N/y): " choice
[ -z "$choice" ] && choice="n"
case $version_choice in
        n|N|* )
          echo " Rebooting...";
          sudo reboot now
        ;;
        y|Y )
          echo " Bad idea, nothing will work properly =("
        ;;
esac
