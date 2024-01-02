#!/usr/bin/env bash
#########################################################################
#Name: rpi_autoconf.sh
#Subscription: This Script setups a Raspeberry Pi OS
##by A. Laub
#andreas[-at-]laub-home.de
#
#License:
#This program is free software: you can redistribute it and/or modify it
#under the terms of the GNU General Public License as published by the
#Free Software Foundation, either version 3 of the License, or (at your option)
#any later version.
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
#or FITNESS FOR A PARTICULAR PURPOSE.
#########################################################################
#Set the language
export LANG="en_US.UTF-8"
#Load the Pathes
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
# set the variables

## Pi's setup configuration
# Root User new Password
ROOTPASSWORD="YOURPASS1234"

## True or False
# Disable IPv6 systemwide
IPV6DISABLE="False"
# Disable Swap File (be carefull with that!)
SWAPDISABLE="False"
# Deinstallation of the avahi Daemon
AVAHIUNINSTALL="False"
# Deactivate USB Hub to save power (not working on Pi zero)
USBDISABLE="False"
# Disable Wifi if you are using LAN
WIFIDISABLE="False"
# Disable Bluetooth to save power
BTDISABLE="False"
# Disable HDMI to save power
HDMIDISABLE="False"
# Disable Soundcard
SOUNDDISABLE="False"
# /tmp as tmpfs mounting
TMPTMPFS="False"
# tmpfs Size (recommended a minimum of 32M)
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


### Do the stuff
# which Raspberry Pi Board is used?
PIVERSION=$(cat /sys/firmware/devicetree/base/model | awk '{print $3}')
# Update package lists
sudo apt update
# Install Updates
sudo apt dist-upgrade -y

# set the root password
echo -e "$ROOTPASSWORD\n$ROOTPASSWORD" | sudo passwd
# enable SSH Root Login
echo -e "\n# Enable Root SSH Login\nPermitRootLogin yes" | sudo tee -a /etc/ssh/sshd_config.d/permitrootlogin.conf
sudo systemctl restart ssh
# create autostart cron file
echo -e "# Stuff which will running on System Startup" | sudo tee -a /etc/cron.d/autostart
# Backup config.txt
sudo cp /boot/config.txt /boot/config.txt.bak 

# disable ipv6
if [ $IPV6DISABLE == "True" ]; then
	sudo echo "net.ipv6.conf.all.disable_ipv6=1" > /etc/sysctl.d/10-disable_ipv6.conf
fi
# disable swap file
if [ $SWAPDISABLE == "True" ]; then
	sudo systemctl disable dphys-swapfile
fi
# Avahi deinstall
if [ $AVAHIUNINSTALL == "True" ]; then
	sudo apt -y --auto-remove purge avahi-daemon
fi
# disable usbhub
if [ $USBDISABLE == "True" ]; then
	sudo apt install uhubctl -y
	echo -e "# disable the USB Hub" | sudo tee -a /etc/cron.d/autostart
	if [ $PIVERSION == "5" ]; then
		echo -e "@reboot root /usr/sbin/uhubctl -l 1 -p 1 -a 0" | sudo tee -a /etc/cron.d/autostart
		echo -e "@reboot root /usr/sbin/uhubctl -l 1 -p 2 -a 0" | sudo tee -a /etc/cron.d/autostart
		echo -e "@reboot root /usr/sbin/uhubctl -l 3 -p 1 -a 0" | sudo tee -a /etc/cron.d/autostart
		echo -e "@reboot root /usr/sbin/uhubctl -l 3 -p 2 -a 0" | sudo tee -a /etc/cron.d/autostart
	fi
	if [ $PIVERSION == "4" ]; then
		echo -e "@reboot root /usr/sbin/uhubctl -l 2 -p 1 -a 0" | sudo tee -a /etc/cron.d/autostart
		echo -e "@reboot root /usr/sbin/uhubctl -l 2 -p 2 -a 0" | sudo tee -a /etc/cron.d/autostart
		echo -e "@reboot root /usr/sbin/uhubctl -l 2 -p 3 -a 0" | sudo tee -a /etc/cron.d/autostart
		echo -e "@reboot root /usr/sbin/uhubctl -l 2 -p 4 -a 0" | sudo tee -a /etc/cron.d/autostart
	fi
	if [ $PIVERSION == "3" ]; then
		echo -e "@reboot root /usr/sbin/uhubctl -l 1-1 -a 0" | sudo tee -a /etc/cron.d/autostart
		echo -e "@reboot root /usr/sbin/uhubctl -l 1-1.1 -a 0" | sudo tee -a /etc/cron.d/autostart
	fi
fi

# disable Bluetooth
if [ $BTDISABLE == "True" ]; then
	sudo apt purge --autoremove -y bluez
	echo -e "\n# disable bluetooth\ndtoverlay=disable-bt" | sudo tee -a /boot/config.txt
fi
# disable wifi
if [ $WIFIDISABLE == "True" ]; then
	echo -e "\n# disable wifi\ndtoverlay=disable-wifi" | sudo tee -a /boot/config.txt
fi
# disable HDMI
if [ $HDMIDISABLE == "True" ]; then
	echo -e "\n# HDMI Blanking\nhdmi_blanking=1" | sudo tee -a /boot/config.txt
	echo -e "\n# HDMI Off\ndtparam=hdmi=off" | sudo tee -a /boot/config.txt
fi
# disable Soundcard
if [ $SOUNDDISABLE == "True" ]; then
	sudo sed -i 's/dtparam=audio=on/dtparam=audio=off/g' /boot/config.txt
	sudo systemctl disable alsa-restore.service alsa-state.service
fi
# mount tmp as tmpfs
if [ $TMPTMPFS == "True" ]; then
	echo -e "\ntmpfs /tmp tmpfs defaults,noatime,nosuid,nodev,noexec,mode=1777,size=$TMPFSSIZE 0 0" | sudo tee -a /etc/fstab
	echo -e "tmpfs /var/tmp tmpfs defaults,noatime,nosuid,nodev,noexec,mode=1777,size=$TMPFSSIZE 0 0" | sudo tee -a /etc/fstab
fi

# setup raspberry pi
sudo raspi-config nonint do_i2c $I2CBUS
sudo raspi-config nonint do_spi $SPIBUS
sudo raspi-config nonint do_onewire $ONEWIRE
sudo raspi-config nonint do_camera $CAMERA

# Include ASCII Art on login
sudo apt install figlet -y
figlet $(hostname -s) | sudo tee -a /etc/motd /etc/motd.tail

# cleanup Raspberry Pi OS
sudo apt purge --autoremove -y htop nfs-common ntfs-3g
sudo apt autoremove -y

# last, do a reboot
echo -e "\n\n#########################\n\nAll done...\nPi $PIVERSION is now rebooting, wait a few moments...\n\nafter reboot reconnect with:\n# ssh root@$(hostname)"
sleep 3
sudo reboot
