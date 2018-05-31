#!/bin/bash

# ResearchNode installer
#
# PART 01
# PRE-FLIGHT
#
# Linode embedding ID:
# Linode URL:
#
# Part of the CBRD/ResearchNode project.
#
# For information, please visit:
# 
#	http://www.github.com/chrisvoncsefalvay/stackscripts
#
# (c) Chris von Csefalvay, 2018.
#	  <chris@chrisvoncsefalvay.com>
#



# Getting the IP address of the current box

IPADDR=$(/sbin/ifconfig eth0 | awk '/inet / { print $2 }' | sed 's/addr://')

echo ""
echo "  _____                               _     _   _           _       "
echo " |  __ \                             | |   | \ | |         | |      "
echo " | |__) |___  ___  ___  __ _ _ __ ___| |__ |  \| | ___   __| | ___  "
echo " |  _  // _ \/ __|/ _ \/ _` | '__/ __| '_ \| . ` |/ _ \ / _` |/ _ \. "
echo " | | \ \  __/\__ \  __/ (_| | | | (__| | | | |\  | (_) | (_| |  __/ "
echo " |_|  \_\___||___/\___|\__,_|_|  \___|_| |_|_| \_|\___/ \__,_|\___| "
echo ""
echo "Autodeploy - v. ${VERSION_ID} - github.com/chrisvoncsefalvay/stackscripts"
echo " "
echo " "


#--- RUNNING SYSTEM UPDATE

echo "------------------------------------------------"
echo "Updating system and installing the good stuff..."
echo "------------------------------------------------"

sudo apt-get update
DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade
sudo apt-get install -y libxml2-dev wget autoremove libcurl3-dev libfreetype6-dev
sudo apt-get install -y swig build-essential cmake g++ gfortran libopenblas-dev
sudo apt-get install -y checkinstall libreadline-gplv2-dev libncursesw5-dev 
sudo apt-get install -y libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev
sudo apt-get install -y libdb5.3-dev libexpat1-dev liblzma-dev git git-*
sudo apt-get install -y libv8-dev


echo "------------------------------------"
echo "Configuring libssl and linking it..."
echo "------------------------------------"

sudo apt-get install -y software-properties-common build-essential
sudo apt-get install -y python-software-properties python3-software-properties
sudo apt-get install -y libssl-dev libssl-doc libcurl4-openssl-dev


echo "--------------------"
echo "Installing NodeJS..."
echo "--------------------"

curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
sudo apt-get install -y nodejs

