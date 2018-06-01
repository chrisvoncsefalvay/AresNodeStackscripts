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

_update_apt () {
    # Add ALL packages
    echo "Adding package: Yarn/Node"
    echo "-------------------------"
    
    curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
    
    
    echo "Adding package: CRAN Ubuntu"
    echo "---------------------------"
    
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
	sudo add-apt-repository -y 'deb http://cran.rstudio.com/bin/linux/ubuntu xenial/'
	sudo add-apt-repository -y "ppa:marutter/rrutter"
    sudo add-apt-repository -y "ppa:marutter/c2d4u"
	

    # Update
    sudo apt-get update
}

# _update_apt %end%



_install_basic_packages () {
    sudo apt-get install -y git-all git-flow
    sudo apt-get install -y libxml2-dev wget autoremove libcurl3-dev libfreetype6-dev
    sudo apt-get install -y swig build-essential cmake g++ gfortran libopenblas-dev
    sudo apt-get install -y checkinstall libreadline-gplv2-dev libncursesw5-dev 
    sudo apt-get install -y libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev
    sudo apt-get install -y libdb5.3-dev libexpat1-dev liblzma-dev libnlopt-dev
    sudo apt-get install -y libv8-dev libpango1.0-dev libmagic-dev libblas-dev
    sudo apt-get install -y libtinfo-dev libzmq-dev libzmq3-dev libcairo2-dev
    sudo apt-get install -y libtool libffi-dev autoconf pkg-config liblapack-dev
}

# _install_basic_packages %end%



_install_libssl () {
    echo "------------------------------------"
    echo "Configuring libssl and linking it..."
    echo "------------------------------------"

    sudo apt-get install -y software-properties-common build-essential
    sudo apt-get install -y python-software-properties python3-software-properties
    sudo apt-get install -y libssl-dev libssl-doc libcurl4-openssl-dev
}

# _install_libssl %end%


# _install_zmq
# ------------
_install_zmq () {
    echo "------------------------------------"
    echo "Configuring 0MQ and CZMQ..."
    echo "------------------------------------"

    mkdir
    git clone https://github.com/zeromq/czmq /tmp
    cd /tmp/czmq
    ./autogen.sh && ./configure
    sudo make
    sudo make install
}

# _install_zmq %end%



# _install_node
# -------------
_install_node () {
    echo "--------------------"
    echo "Installing NodeJS..."
    echo "--------------------"

    curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
    sudo apt-get install -y nodejs
    sudo apt-get install -y yarn
}

# _install_node %end%




# rn01_update_system
# ------------------
# Runs a system update, installs libssl, NodeJS, Yarn, etc.

rn01_update_system {
    echo "-------------------------------------------------------------"
    echo "Updating system and installing the good stuff..."
    echo "-------------------------------------------------------------"

    echo "Updating APT..."
    _update_apt
    
    # Upgrade
    DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade
    
    # Install fundamental packages
    _install_basic_packages

    # Set up libSSL
    _install_libssl

    # Download and complile 0MQ
    _install_zmq
    
    # Install NodeJS
    _install_node
}

rn01_update_system

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


