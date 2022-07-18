#!/bin/bash
################################################################################
# Original Author:   Afiniel
# Modified by : Afiniel (https://github.com/Afiniel/yiimp_install_scrypt)
# Web: https://www.afiniel.xyz    
#
#   Install Daemon Coin on Ubuntu 16.04/18.04 running Nginx, MariaDB, and php7.3
#   v0.2 (update Juillet, 2022)
#
# Current modified by : Vaudois
# web: https://coinXpool.com
# Program:
#   Install Daemon Coin on Ubuntu 16.04/18.04
#   v0.1 (2022-07-17)
# 
################################################################################
	
	clear

	output() {
	printf "\E[0;33;40m"
	echo $1
	printf "\E[0m"
	}

	displayErr() {
	echo
	echo $1;
	echo
	exit 1;
	}

	#Add user group sudo + no password
	whoami=`whoami`
	sudo usermod -aG sudo ${whoami}
	echo '# yiimp
	# It needs passwordless sudo functionality.
	'""''"${whoami}"''""' ALL=(ALL) NOPASSWD:ALL
	' | sudo -E tee /etc/sudoers.d/${whoami} >/dev/null 2>&1

	 #Copy needed files
	cd
	sudo mkdir buildcoin
	cd $HOME/daemon_install_script
	sudo cp -r conf/functions.sh /etc/
	sudo cp -r utils/screen-scrypt.sh /etc/
	sudo cp -r utils/screen-stratum.sh /etc/
	sudo cp -r utils/builder.sh $HOME/buildcoin
	sudo cp -r utils/addport /usr/bin/
	sudo cp -r conf/editconf.py /usr/bin/
	sudo chmod +x /usr/bin/editconf.py
	sudo chmod +x /etc/screen-scrypt.sh
	sudo chmod 755 /usr/bin/addport

	source /etc/functions.sh

	term_art

	# Update package and Upgrade Ubuntu
	echo
	echo
	echo -e "$CYAN => Updating system and installing required packages :$COL_RESET"
	echo 
	sleep 3

	hide_output sudo apt -y update 
	hide_output sudo apt -y upgrade
	hide_output sudo apt -y autoremove
	hide_output sudo apt-get install -y software-properties-common
	apt_install dialog python3 python3-pip acl nano apt-transport-https figlet
	echo -e "$GREEN Done...$COL_RESET"

	source conf/prerequisite.sh
	sleep 3
	source conf/getip.sh

	echo 'PUBLIC_IP='"${PUBLIC_IP}"'
	PUBLIC_IPV6='"${PUBLIC_IPV6}"'
	DISTRO='"${DISTRO}"'
	PRIVATE_IP='"${PRIVATE_IP}"'' | sudo -E tee conf/pool.conf >/dev/null 2>&1

	echo
	echo
	echo -e "$RED Make sure you double check before hitting enter! Only one shot at these! $COL_RESET"
	echo
	read -e -p "Domain Name Stratum in MAIN server (Enter Domain name: stratum.example.com or ip of your server) : " server_name
	read -e -p "Enter password for Stratum in MAIN server : " stratum_password
	read -e -p "Enter DATABASE name mysql in MAIN server : " database_name
	read -e -p "Enter USER mysql in MAIN server : " user_database
	read -e -p "Enter PASSWORD mysql in MAIN server : " password_database
	read -e -p "Enter support email (e.g. admin@example.com) : " EMAIL

	# Switch Aptitude
	echo
	echo -e "$CYAN Switching to Aptitude $COL_RESET"
	echo 
	sleep 3
	apt_install aptitude
	echo -e "$GREEN Done...$COL_RESET $COL_RESET"

	# Installing other needed files
	echo
	echo
	echo -e "$CYAN => Installing other needed files : $COL_RESET"
	echo
	sleep 3

	hide_output sudo apt install libgmp3-dev libmysqlclient-dev libcurl4-gnutls-dev libkrb5-dev libldap2-dev libidn11-dev gnutls-dev \
	librtmp-dev sendmail mutt screen git
	hide_output sudo apt install pwgen unzip -y
	echo -e "$GREEN Done...$COL_RESET"
	sleep 3

	# Installing Package to compile crypto currency
	echo
	echo
	echo -e "$CYAN => Installing Package to compile crypto currency $COL_RESET"
	echo
	sleep 3

	hide_output sudo apt install build-essential libzmq5 \
	libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils git cmake libboost-all-dev zlib1g-dev libz-dev libseccomp-dev libcap-dev libminiupnpc-dev gettext
	hide_output sudo apt install libminiupnpc10
	hide_output sudo apt install libcanberra-gtk-module libqrencode-dev libzmq3-dev \
	libqt5gui5 libqt5core5a libqt5webkit5-dev libqt5dbus5 qttools5-dev qttools5-dev-tools libprotobuf-dev protobuf-compiler
	hide_output sudo add-apt-repository -y ppa:bitcoin/bitcoin
	hide_output sudo apt -y update
	hide_output sudo apt install libdb4.8-dev libdb4.8++-dev libdb5.3 libdb5.3++
	echo -e "$GREEN Done...$COL_RESET"

	# Installing Package to compile crypto currency
	echo
	echo
	echo -e "$CYAN => Installing additional system files required for daemons $COL_RESET"
	echo
	sleep 3

	echo -e "$YELLOW Installing additional system files required for daemons...$COL_RESET"
	hide_output sudo apt-get update
	hide_output sudo apt install build-essential libtool autotools-dev \
	automake pkg-config libssl-dev libevent-dev bsdmainutils git libboost-all-dev libminiupnpc-dev \
	libqt5gui5 libqt5core5a libqt5webkit5-dev libqt5dbus5 qttools5-dev qttools5-dev-tools libprotobuf-dev \
	protobuf-compiler libqrencode-dev libzmq3-dev libgmp-dev \
	cmake libunbound-dev libsodium-dev libunwind8-dev liblzma-dev libreadline6-dev libldns-dev libexpat1-dev \
	libpgm-dev libhidapi-dev libusb-1.0-0-dev libudev-dev libboost-chrono-dev libboost-date-time-dev libboost-filesystem-dev \
	libboost-locale-dev libboost-program-options-dev libboost-regex-dev libboost-serialization-dev libboost-system-dev libboost-thread-dev \
	python3 ccache doxygen graphviz default-libmysqlclient-dev libnghttp2-dev librtmp-dev libssh2-1 libssh2-1-dev libldap2-dev libidn11-dev libpsl-dev

	sudo mkdir -p $HOME/daemon_setup/tmp
	cd $HOME/daemon_setup/tmp
	echo -e "$GREEN Additional System Files Completed...$COL_RESET"

	echo -e "$YELLOW Building Berkeley 4.8, this may take several minutes...$COL_RESET"
	sudo mkdir -p $HOME/daemoncoin/berkeley/db4/
	hide_output sudo wget 'http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz'
	hide_output sudo tar -xzvf db-4.8.30.NC.tar.gz
	cd db-4.8.30.NC/build_unix/
	hide_output sudo ../dist/configure --enable-cxx --disable-shared --with-pic --prefix=$HOME/daemoncoin/berkeley/db4/
	hide_output sudo make install
	cd $HOME/daemon_setup/tmp
	sudo rm -r db-4.8.30.NC.tar.gz db-4.8.30.NC
	echo -e "$GREEN Berkeley 4.8 Completed...$COL_RESET"

	echo -e "$YELLOW Building Berkeley 5.1, this may take several minutes...$COL_RESET"
	sudo mkdir -p $HOME/daemoncoin/berkeley/db5/
	hide_output sudo wget 'http://download.oracle.com/berkeley-db/db-5.1.29.tar.gz'
	hide_output sudo tar -xzvf db-5.1.29.tar.gz
	cd db-5.1.29/build_unix/
	hide_output sudo ../dist/configure --enable-cxx --disable-shared --with-pic --prefix=$HOME/daemoncoin/berkeley/db5/
	hide_output sudo make install
	cd $HOME/daemon_setup/tmp
	sudo rm -r db-5.1.29.tar.gz db-5.1.29
	echo -e "$GREEN Berkeley 5.1 Completed...$COL_RESET"

	echo -e "$YELLOW Building Berkeley 5.3, this may take several minutes...$COL_RESET"
	sudo mkdir -p $HOME/daemoncoin/berkeley/db5.3/
	hide_output sudo wget 'http://anduin.linuxfromscratch.org/BLFS/bdb/db-5.3.28.tar.gz'
	hide_output sudo tar -xzvf db-5.3.28.tar.gz
	cd db-5.3.28/build_unix/
	hide_output sudo ../dist/configure --enable-cxx --disable-shared --with-pic --prefix=$HOME/daemoncoin/berkeley/db5.3/
	hide_output sudo make install
	cd $HOME/daemon_setup/tmp
	sudo rm -r db-5.3.28.tar.gz db-5.3.28
	echo -e "$GREEN Berkeley 5.3 Completed...$COL_RESET"

	echo -e "$YELLOW Building Berkeley 6.2, this may take several minutes...$COL_RESET"
	sudo mkdir -p $HOME/daemoncoin/berkeley/db6.2/
	hide_output sudo wget 'http://download.oracle.com/berkeley-db/db-6.2.23.tar.gz'
	hide_output sudo tar -xzvf db-6.2.23.tar.gz
	cd db-6.2.23/build_unix/
	hide_output sudo ../dist/configure --enable-cxx --disable-shared --with-pic --prefix=$HOME/daemoncoin/berkeley/db6.2/
	hide_output sudo make install
	cd $HOME/daemon_setup/tmp
	sudo rm -r db-6.2.23.tar.gz db-6.2.23
	echo -e "$GREEN Berkeley 6.2 Completed...$COL_RESET"

	echo -e "$YELLOW Building OpenSSL 1.0.2g, this may take several minutes...$COL_RESET"
	cd $HOME/daemon_setup/tmp
	hide_output sudo wget https://www.openssl.org/source/old/1.0.2/openssl-1.0.2g.tar.gz --no-check-certificate
	hide_output sudo tar -xf openssl-1.0.2g.tar.gz
	cd openssl-1.0.2g
	hide_output sudo ./config --prefix=$HOME/daemoncoin/openssl --openssldir=$HOME/daemoncoin/openssl shared zlib
	hide_output sudo make
	hide_output sudo make install
	cd $HOME/daemon_setup/tmp
	sudo rm -r openssl-1.0.2g.tar.gz openssl-1.0.2g
	echo -e "$GREEN OpenSSL 1.0.2g Completed...$COL_RESET"

	echo -e "$YELLOW Building bls-signatures, this may take several minutes...$COL_RESET"
	cd $HOME/daemon_setup/tmp
	hide_output sudo wget 'https://github.com/codablock/bls-signatures/archive/v20181101.zip'
	hide_output sudo unzip v20181101.zip
	cd bls-signatures-20181101
	hide_output sudo cmake .
	hide_output sudo make install
	cd $HOME/daemon_setup/tmp
	sudo rm -r v20181101.zip bls-signatures-20181101
	echo -e "$GREEN bls-signatures Completed...$COL_RESET"

	# Test Email
	echo
	echo
	echo -e "$CYAN => Testing to see if server emails are sent $COL_RESET"
	echo
	sleep 3

	if [[ "$root_email" != "" ]]; then
		echo $root_email > sudo tee --append ~/.email
		echo $root_email > sudo tee --append ~/.forward

	if [[ ("$send_email" == "y" || "$send_email" == "Y" || "$send_email" == "") ]]; then
		echo "This is a mail test for the SMTP Service." > sudo tee --append /tmp/email.message
		echo "You should receive this !" >> sudo tee --append /tmp/email.message
		echo "" >> sudo tee --append /tmp/email.message
		echo "Cheers" >> sudo tee --append /tmp/email.message
		sudo sendmail -s "SMTP Testing" $root_email < sudo tee --append /tmp/email.message

		sudo rm -f /tmp/email.message
		echo "Mail sent"
	fi
	fi
	echo -e "$GREEN Done...$COL_RESET"

	# Installing Stratum
	echo
	echo
	echo -e "$CYAN => Installing Stratum $COL_RESET"
	echo
	echo -e "Grabbing Stratum fron Github, building files and setting file structure."
	echo
	sleep 3

	# Compil Blocknotify
	cd ~
	hide_output git clone https://github.com/vaudois/stratum
	cd $HOME/stratum/blocknotify
	sudo sed -i 's/tu8tu5/'$stratum_password'/' blocknotify.cpp
	hide_output sudo make -j$(nproc)

	# Compil iniparser
	cd $HOME/stratum
	hide_output sudo make -C iniparser/ -j$(nproc)
	
	# Compil algos
	hide_output sudo make -C algos/ -j$(nproc)
	
	# Compil sha3
	hide_output sudo make -C sha3 -j$(nproc)
	
	# Compil stratum
	hide_output sudo make -f Makefile -j$(nproc)

	# Copy Files (Blocknotify,iniparser,Stratum)
	sudo mkdir -p /var/stratum
	sudo cp -a config.sample/. /var/stratum/config
	sudo cp -r stratum /var/stratum
	sudo cp -r run.sh /var/stratum
	sudo cp -r $HOME/stratum/bin/. /bin/
	sudo cp -r $HOME/stratum/blocknotify/blocknotify /usr/bin/
	sudo cp -r $HOME/stratum/blocknotify/blocknotify /var/stratum/
	#fixing run.sh
	sudo rm -r /var/stratum/config/run.sh
	echo '
	#!/bin/bash
	ulimit -n 10240
	ulimit -u 10240
	cd /var/stratum
	while true; do
	./stratum /var/stratum/config/$1
	sleep 2
	done
	exec bash
	' | sudo -E tee /var/stratum/config/run.sh >/dev/null 2>&1
	sudo chmod +x /var/stratum/config/run.sh

	echo -e "$GREEN Done...$COL_RESET"

	# Update Timezone
	echo
	echo
	echo -e "$CYAN => Update default timezone. $COL_RESET"
	echo

	echo -e " Setting TimeZone to UTC...$COL_RESET"
	if [ ! -f /etc/timezone ]; then
	echo "Setting timezone to UTC."
	echo "Etc/UTC" > sudo /etc/timezone
	sudo systemctl restart rsyslog
	fi
	sudo systemctl status rsyslog | sed -n "1,3p"
	echo
	echo -e "$GREEN Done...$COL_RESET"

	# Updating stratum config files with database connection info
	echo
	echo
	echo -e "$CYAN => Updating stratum config files with database connection info. $COL_RESET"
	echo
	sleep 3

	cd /var/stratum/config
	sudo sed -i 's/password = tu8tu5/password = '$stratum_password'/g' *.conf
	sudo sed -i 's/server = yaamp.com/server = '$server_name'/g' *.conf
	sudo sed -i 's/host = yaampdb/host = '$server_name'/g' *.conf
	sudo sed -i 's/database = yaamp/database = '$database_name'/g' *.conf
	sudo sed -i 's/username = root/username = '$user_database'/g' *.conf
	sudo sed -i 's/password = patofpaq/password = '$password_database'/g' *.conf
	cd ~
	echo -e "$GREEN Done...$COL_RESET"


	# Final Directory permissions
	echo
	echo
	echo -e "$CYAN => Final Directory permissions $COL_RESET"
	echo
	sleep 3

	whoami=`whoami`
	sudo usermod -aG www-data $whoami
	sudo usermod -a -G www-data $whoami

	sudo chgrp www-data /var/stratum -R
	sudo chmod 775 /var/stratum

	#Add to contrab screen-scrypt
	(crontab -l 2>/dev/null; echo "@reboot sleep 20 && /etc/screen-scrypt.sh") | crontab -
	(crontab -l 2>/dev/null; echo "@reboot sleep 20 && /etc/screen-stratum.sh") | crontab -

	#Misc
	sudo rm -rf $HOME/stratum-install-finish
	sudo mv $HOME/stratum/ $HOME/stratum-install-finish
	sudo rm -rf $HOME/daemon_install_script
	sudo rm -rf $HOME/daemon_setup

	#Restart service
	sudo systemctl restart cron.service

	echo
	echo -e "$GREEN Done...$COL_RESET"
	sleep 3

	echo
	install_end_message
	echo
	echo
