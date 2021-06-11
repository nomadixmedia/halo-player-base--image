#!/usr/bin/env bash

#Prepare a SD card with the supplied base image
#Boot the Pi with this image
#ssh into the Pi and do the following
#
#Copy these files if needed
#   /home/pi/brand_pisignage_landscape.mp4
#   /home/pi/brand_pisignage_portrait.mp4
#   /home/pi/update_portrait.mp4
#   /home/pi/update_landscape.mp4
#   /home/pi/update.png
#
#
#Copy the following files to both respective directories and also to /home/pi/pisignage-data  only if needed
#   /home/pi/piSignagePro/app/views/emptynotice.ejs
#   /home/pi/piSignagePro/public/app/css/custom.css
#   /home/pi/piSignagePro/public/app/img/favicon.ico
#   /home/pi/piSignagePro/public/app/img/pisignage.png
#
#   /home/pi/pisignage-data/emptynotice.ejs
#   /home/pi/pisignage-data/custom.css
#   /home/pi/pisignage-data/favicon.ico
#   /home/pi/pisignage-data/pisignage.png
#
#   Create a file upgrade.sh in /home/pi/pisignage-data  if you have added any of the files in /home/pi/pisignage-data with contents as follows for the added file
#   #!/usr/bin/env bash
#   cp /home/pi/pisignage-data/emptynotice.ejs /home/pi/piSignagePro/app/views/emptynotice.ejs      #only if this file was added
#   cp /home/pi/pisignage-data/custom.css /home/pi/piSignagePro/public/app/css/custom.css           #only if this file was added
#   cp /home/pi/pisignage-data/favicon.ico /home/pi/piSignagePro/public/app/img/favicon.ico         #only if this file was added
#   cp /home/pi/pisignage-data/pisignage.png /home/pi/piSignagePro/public/app/img/pisignage.png     #only if this file was added
#
#   chmod 777 /home/pi/pisignage-data/upgrade.sh #give executable permission
#
#
#Change the server address in /home/pi/piSignagePro/package.json with your server name (for e.g.)
#   "config_server": "http://partner-server.com",
#   "media_server": "http://partner-server.com",
#
#
#Modify /boot/config.txt    for overscans and other features if needed
#Any other software installations for VPN etc. can be done before running this script
#
#
# edit /boot/cmdline.txt and add  at the end of first line
# logo.nologo vt.global_cursor_default=0
# for removing raspberry pi logo on poweron
#
#
#Finally run this script to prepare the image


notify(){
    printf "\n"
    figlet -f digital -c $1
    printf "\n"
}

change_start_sh(){
	notify "change start.sh"
	sudo rm -rf /home/pi/start.sh

	#check OS and do operation
	if grep -q "buster" /etc/*-release ;
	then
	    notify "buster"
	    sudo cp /home/pi/piSignagePro/misc/stretch/start.sh /home/pi/
	elif grep -q "stretch" /etc/*-release ;
	then
	    notify "stretch"
	    sudo cp /home/pi/piSignagePro/misc/stretch/start.sh /home/pi/
	elif grep -q "jessie" /etc/*-release ;
	then
	    notify "jessie"
	    sudo cp /home/pi/piSignagePro/misc/jessie/start.sh /home/pi/
	else
	    notify "wheezy"
	    sudo cp /home/pi/piSignagePro/misc/wheezy/start.sh /home/pi/
	fi

	cat /home/pi/start.sh
	sudo chmod 777 /home/pi/start.sh

	#add youtube fix
	sudo sed -i 's/player_embedded/detailpage/' /usr/local/lib/python2.7/dist-packages/livestreamer/plugins/youtube.py

	#set wifi country
	sudo iw reg set IN
	echo "country=IN " | sudo tee -a /etc/wpa_supplicant/wpa_supplicant.conf
}

clean_image(){
	# remove all media and settings related to pisignage.com
	notify "clean previous record"
	rm  /home/pi/pi-image.zip
	rm -rf /home/pi/media/*
	rm  /home/pi/install.sh
	rm -rf /home/pi/piSignagePro/config/_settings.json
	rm -rf /home/pi/piSignagePro/config/_config.json
	rm -rf /home/pi/license_*

	sudo rm -r -f /usr/share/doc/*
	sudo rm -r -f /usr/share/man/*

	[ -f /home/pi/build-pisignage-lite.sh ] && rm /home/pi/build-pisignage-lite.sh
	[ -f /home/pi/build_pisignage.sh ] && rm /home/pi/build_pisignage.sh
	[ -f /home/pi/install-gui.log ] && rm /home/pi/install-gui.log
	sudo sed -i '/update_config=1/q0' /etc/wpa_supplicant/wpa_supplicant.conf
	echo "" > /home/pi/forever_out.log
	echo "" > /home/pi/forever_err.log
	rm /home/pi/logs/* 
	cat /home/pi/piSignagePro/package.json
	sudo fdisk -l

	notify "fill zero"
	sudo dd if=/dev/zero of=/home/pi/dummy.img

    sync

	notify "delete image"
	sudo rm -rf /home/pi/dummy.img

	notify "home directory"
	ls -l /home/pi/

	notify "piSignagePro directory "
	ls -l /home/pi/piSignagePro/

	notify "config directory"
	ls -l /home/pi/piSignagePro/config/

	notify "media directory"
	ls -l /home/pi/media/

	notify "app directory"
	ls -l /home/pi/piSignagePro/app/views/

	notify "Show wifi entry"
	sudo cat /etc/wpa_supplicant/wpa_supplicant.conf

	sync
	sync
	history -c # clear all command history
	rm /home/pi/hs.sh
	notify "Setup Complete"
}



#kill running process 
sudo pkill node
sudo pkill uzbl
sudo killall -s 9 chromium-browser
sudo killall -s 9 /usr/lib/chromium-browser/chromium-browser-v7
sudo pkill omx

#wait for processes to stop
sleep 10

change_start_sh
clean_image
