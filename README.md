# rpi_autoconf
This little bash script helps to setup a Raspberry Pi OS. I use it to deploy my Raspberry Pi's a bit faster then doing all the stuff on each Pi manualy. Feel free to add your own features you need and let me know about it, so this script could grow.

## Features
the following features are included:
* change hostname
* change pi user's password
* enable root account and ssh root login with password
* set the timezone
* set the wifi country code
* Optional:
** uninstall the avahi daemon
** Power Savings:
*** disable Pi's usbhub
*** disable Bluetooth and uninstallation of the bluez tools
*** disable hdmi port
*** disable sound daemon
** enable / disable RPI's interfaces
*** i2c
*** spi
*** onewire
*** camera

## Configuration
you have to configure all your stuff at the top in `set the variables` section of the script. Just read the inline comments.

```bash
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

## Interface Configuration
## 0 Enable / 1 Disable 
# i2c bus
I2CBUS="1"
# spi bus
SPIBUS="1"
# one wire bus
ONEWIRE="0"
# Raspberry Pi's camera module
CAMERA="1"
```

## More Informations
More Informations on the script can be found here (sorry it's german): 
* https://www.laub-home.de/wiki/Raspberry_Pi_OS_Installation#Raspberry_Pi_OS_via_Skript_konfigurieren
