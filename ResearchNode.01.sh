#!/bin/bash


# ResearchNode installer
#
# PART 01
# PRE-FLIGHT
#
# Linode embedding ID:    316999
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

echo "Loaded subsidiary resource RN01.PRE_FLIGHT.316999"

# rn01_update_system
# ------------------
# Runs a system update, installs libssl, NodeJS, Yarn, etc.

rn01_update_system {
    echo "-------------------------------------------------------------"
    echo "Updating system and installing the good stuff..."
    echo "-------------------------------------------------------------"

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
    curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
         echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
         sudo apt-get update && sudo apt-get install -y yarn
}

# rn01_update_system %end%



# rn01_create_user_and_usergroup
# ------------------------------
# Creates a user with a given password, and assigns it to a newly created usergroup.
#
# @param $1: user name
# @param $2: user password
# @param $3: usergroup name

rn01_create_user_and_usergroup {
    echo "-------------------------------------------------------------"
    echo "Setting up user $1 and usergroup $3..."
    echo "-------------------------------------------------------------"

    sudo addusergroup "$1"
    sudo su -c "useradd \"$1\" -s /bin/bash -m -g \"$3\""
    sudo echo "$1":"$2" | chpasswd   
}

# rn01_create_user_and_usergroup %end%


