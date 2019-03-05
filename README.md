# raspbian-nodejs-homebridge
Script to real simple install Node.js and Homebridge to Raspberry Pi 2/3/zero

## Getting started
[Homebridge](https://github.com/nfarina/homebridge)


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

### Installing and running
One-line command is:

```
TBA
```

## Based on scripts:
* **Kees C. Bakker** (KeesTalksTech)
* **Richard Stanley** @ https://github.com/audstanley/Node-MongoDb-Pi
* **Steven de Salas** @ https://github.com/sdesalas/node-pi-zero

List of [contributors](https://github.com/ptath/raspbian-nodejs-homebridge/graphs/contributors).
