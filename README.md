# raspbian-nodejs-homebridge
Script to install Node.js and Homebridge (with UI) to Raspberry Pi 2/3/zero

## Warning
This is beta, use with caution! Not recommended to run on production machine!
Tested with clean Raspbian on Raspberry Pi 3 and zero.

## Installing and running
One-line command is:
```
wget -q -N -O /tmp/install.sh http://bit.ly/raspbian-nodejs-homebridge-beta && chmod +x /tmp/install.sh && /tmp/install.sh
```
After reboot you should have fully updated/upgraded Raspbian with latest LTS Node.js and Homebridge with web-interface running port 8080. 

## Getting started
* [Raspbian](https://www.raspberrypi.org/downloads/raspbian) — Raspbian is the Foundation’s official supported operating system.
* [Node.js](https://nodejs.org/en/about/) —
As an asynchronous event driven JavaScript runtime, Node is designed to build scalable network applications.
* [Homebridge](https://github.com/nfarina/homebridge) — Homebridge allows you to integrate with smart home devices that do not support the HomeKit protocol. Here are just some of the manufacturers you can integrate with.

### Prerequisites
* Raspberry Pi (any model), SD-card (8GB or more) with latest [Raspbian](https://www.raspberrypi.org/downloads/raspbian/) image file
* SSH client
* About 15-30 minutes

You can create files named `ssh` (any content) and `wpa_supplicant.conf` with content:

```
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
country=GB
update_config=1

network={
    ssid="YOUR_WIFI_NAME"
    psk="YOUR_WIFI_PASSWORD"
}
```

and write them to the `/boot` FAT32 partition of flashed Raspbian SD-card to avoid connecting display and keyboard to yours Pi.

## What that script exactly do
1. `sudo apt update` and `sudo apt upgrade`
2. Installs `git`, `libavahi-compat-libdnssd-dev` and `jq`
3. Checks your Raspberry model and installs latest Node.JS for
   * armv6l — binaries from [Node.js](https://nodejs.org/dist) website
   * armv7l — from [NodeSource](https://github.com/nodesource/distributions)
4. Installs `pm2`, `homebridge` and `homebridge-config-ui-x`
5. Adds default homebridge config
6. Daemonizes homebridge via pm2

## Based on scripts:
* **Kees C. Bakker** (KeesTalksTech)
* **Richard Stanley** @ https://github.com/audstanley/Node-MongoDb-Pi
* **Steven de Salas** @ https://github.com/sdesalas/node-pi-zero

List of [contributors](https://github.com/ptath/raspbian-nodejs-homebridge/graphs/contributors).
