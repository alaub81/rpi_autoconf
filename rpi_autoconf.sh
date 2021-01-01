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
# Disable Swap File (be carefull with that!)
SWAPDISABLE="False"
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
# tmpfs Size (recommended: 16M for pi zero / 64M for Pi 4)
TMPFSSIZE="16M"

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
# Change the pi User Password
echo -e "$PIPASSWORD\n$PIPASSWORD" | sudo passwd pi
# set the root password
echo -e "$ROOTPASSWORD\n$ROOTPASSWORD" | sudo passwd
# enable SSH Root Login
echo -e "\n# Enable Root SSH Login\nPermitRootLogin yes" | sudo tee -a /etc/ssh/sshd_config
sudo systemctl restart ssh
# create autostart cron file
echo -e "# Stuff which will running on System Startup" | sudo tee -a /etc/cron.d/autostart
# Update package lists
sudo apt update
# Backup config.txt
sudo cp /boot/config.txt /boot/config.txt.bak 

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
	echo -e "# disable the USB Hub\n@reboot root /usr/sbin/uhubctl -a 0" | sudo tee -a /etc/cron.d/autostart
fi
# disable Bluetooth
if [ $BTDISABLE == "True" ]; then
	sudo apt purge --autoremove -y bluez
	echo -e "\n# disable bluetooth\ndtoverlay=disable-bt" | sudo tee -a /boot/config.txt
fi
# disable HDMI
if [ $HDMIDISABLE == "True" ]; then
	echo -e "\n# HDMI Blanking\nhdmi_blanking=1" | sudo tee -a /boot/config.txt
	echo -e "# disable the HDMI port\n@reboot root /usr/bin/tvservice -o" | sudo tee -a /etc/cron.d/autostart
fi
# disable Soundcard
if [ $SOUNDDISABLE == "True" ]; then
	sudo systemctl disable alsa-restore.service alsa-state.service
fi
# mount tmp as tmpfs
if [ $TMPTMPFS == "True" ]; then
	echo -e "\ntmpfs /tmp tmpfs defaults,noatime,nosuid,nodev,noexec,mode=1777,size=$TMPFSSIZE 0 0" | sudo tee -a /etc/fstab
	echo -e "tmpfs /var/tmp tmpfs defaults,noatime,nosuid,nodev,noexec,mode=1777,size=$TMPFSSIZE 0 0" | sudo tee -a /etc/fstab
fi
# Syslog Blocklist
if [ $SYSLOGBLOCK == "True" ]; then
	sudo cp /etc/rsyslog.conf /etc/rsyslog.conf.bak
	sudo sed -i 's/^*.*;auth,authpriv.none/*.*;cron,auth,authpriv.none/g' /etc/rsyslog.conf
	sudo sed -i 's/^mail./#mail./g' /etc/rsyslog.conf
	sudo sed -i 's/^daemon./#daemon./g' /etc/rsyslog.conf
	sudo sed -i 's/^kern./#kern./g' /etc/rsyslog.conf
	sudo sed -i 's/^lpr./#lpr./g' /etc/rsyslog.conf
	sudo sed -i 's/^user./#user./g' /etc/rsyslog.conf
	sudo sed -i 's/^*.=/#*.=/g' /etc/rsyslog.conf
	sudo sed -i 's/^\t/#\t/g' /etc/rsyslog.conf
	sudo tee -a /etc/rsyslog.d/01-blocklist.conf <<EOF
# Cronjob-Spam umleiten
if \$msg contains "pam_unix(cron:session):" then {
	stop
}
# SSH Login without string
if \$msg contains "Did not receive identification string from" then {
	stop
}
# rngd stop logging
if \$programname == "rngd" then {
	stop
}
EOF
fi


# setup raspberry pi
sudo raspi-config nonint do_hostname $PIHOSTNAME
sudo raspi-config nonint do_wifi_country $WIFICOUNTRY
sudo timedatectl set-timezone $TIMEZONE
sudo raspi-config nonint do_i2c $I2CBUS
sudo raspi-config nonint do_spi $SPIBUS
sudo raspi-config nonint do_onewire $ONEWIRE
sudo raspi-config nonint do_camera $CAMERA

# Include ASCII Art on login
sudo apt install figlet -y
figlet $PIHOSTNAME | sudo tee -a /etc/motd /etc/motd.tail

# cleanup Raspberry Pi OS
sudo apt purge --autoremove -y htop nfs-common ntfs-3g python

# Install Updates
sudo apt dist-upgrade -y

# last, do a reboot
echo -e "\n\n#########################\n\nAll done!!!\nreconnect with:\n# ssh root@$PIHOSTNAME"
sleep 3
sudo reboot
