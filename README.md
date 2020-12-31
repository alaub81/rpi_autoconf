# rpi_autoconf
This little bash script helps to setup a Raspberry Pi OS. I use it to deploy my Raspberry Pi's a bit faster then doing all the stuff on each Pi manually. Feel free to add your own needed features and let me know about it, so this script could grow.

## Features
the following features are included:
* change hostname
* change pi user's password
* enable root account and ssh root login with password
* set the timezone
* set the wifi country code
* Optional:
  * Mount /tmp as tmpfs
  * minimize syslog messages
  * uninstall the avahi daemon
  * Power Savings:
    * disable Pi's usbhub
    * disable Bluetooth and uninstallation of the bluez tools
    * disable hdmi port
    * disable sound daemon
  * enable / disable RPI's interfaces
    * i2c
    * spi
    * onewire
    * camera

## Configuration
you have to configure all your stuff at the top in `set the variables` section of the script. Just read the inline comments.

```bash
# set the variables

## Pi's setup configuration
# Pi User new Password
PIPASSWORD="YOURPASS1234"
# Root User new Password
ROOTPASSWORD="YOURPASS1234"
# Raspberry Pi's hostname
PIHOSTNAME="YOURRASPI"
# the wifi Country
WIFICOUNTRY="DE"
# your Raspberry Pi's timezone
TIMEZONE="Europe/Berlin"

## True or False
# Deinstallation of the avahi Daemon
AVAHIUNINSTALL="False"
# Deactivate USB Hub to save power (not working on Pi zero)
USBDISABLE="False"
# Disable Bluetooth to save power
BTDISABLE="False"
# Disable HDMI to save power
HDMIDISABLE="False"
# Disable Soundcard
SOUNDDISABLE="False"
# Minimizie Syslog Messages a little bit
SYSLOGBLOCK="False"
# /tmp as tmpfs mounting
TMPTMPFS="False"
# tmpfs Size (recommended: 32M for pi zero / 128M for Pi 4)
TMPFSSIZE="32M"

## Interface Configuration
## 0 Enable / 1 Disable 
# i2c bus
I2CBUS="1"
# spi bus
SPIBUS="1"
# one wire bus
ONEWIRE="1"
# Raspberry Pi's camera module
CAMERA="1"
```

## More Informations
More Informations on the script can be found here (sorry it's german): 
* https://www.laub-home.de/wiki/Raspberry_Pi_OS_Installation#Raspberry_Pi_OS_via_Skript_konfigurieren
