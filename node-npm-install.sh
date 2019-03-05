#!/bin/bash
# Version 0.1
script_branch="beta" # or master
# By ptath (https://ptath.ru)

# Script to install Node.js and Homebridge for Raspbian







# Ставим дополнительные пакеты, необходимые для Homebridge
echo "=== Установка дополнительных пакетов..."

# Списком потому что возможно добавятся еще
packages2install=(
git
libavahi-compat-libdnssd-dev
jq
)

for item in ${packages2install[*]}
do
  package_name=$item
  if [ $(dpkg-query -W -f='${Status}' "$package_name" 2>/dev/null | grep -c "ok installed") -eq 0 ];then
        echo "=== > "$package_name" не установлен, ставим..."
        sudo apt install "$package_name" -y
  else
        echo "=== > "$package_name" уже установлен"
  fi
done

# Ставим менеджер пакетов nodejs (он стандартный?)
# echo "=== Устанавливаем (обновляем) менеджер пакетов npm"
echo "=== Установка Homebridge и дополнительных пакетов Node.js"

# Список пакетов
npm_packages2install=(
homebridge
homebridge-config-ui-x
homebridge-zigbee
pm2
)

[ -e /tmp/npm_installed_list ] &&
  rm /tmp/npm_installed_list &&
  echo $(npm list -g --depth 0) > /tmp/npm_installed_list

for item in ${npm_packages2install[*]}
do
  package_name=$item
  if [ $(cat /tmp/npm_installed_list | grep -c "$package_name@") -eq 0 ];then
    echo "=== > "$package_name" не установлен, ставим..."
    npm install -g "$package_name"

    # Удаляем существующие симлинки
    sudo unlink /usr/bin/"$package_name";
    sudo unlink /usr/sbin/"$package_name";
    sudo unlink /sbin/"$package_name";
    sudo unlink /usr/local/bin/"$package_name";

    # Создаем новые симлинки
    sudo ln -s /opt/nodejs/bin/"$package_name" /usr/bin/"$package_name";
    sudo ln -s /opt/nodejs/bin/"$package_name" /usr/sbin/"$package_name";
    sudo ln -s /opt/nodejs/bin/"$package_name" /sbin/"$package_name";
    sudo ln -s /opt/nodejs/bin/"$package_name" /usr/local/bin/"$package_name";

  else
    read -t 10 -n 1 -p "=== > "$package_name" уже установлен, переустановить? (N/y): " reinstall_choice
    [ -z "$reinstall_choice" ] && reinstall_choice="n"
    case $version_choice in
            y|Y )
              echo " Переустанавливаем..." &&
              npm remove -g "$package_name" &&
              npm install -g "$package_name"
            ;;
            n|N|* )
              echo " Оставляем"
            ;;
    esac
  fi
done

#

#wget -O - https://raw.githubusercontent.com/sdesalas/node-pi-zero/master/install-node-v.lts.sh | bash
