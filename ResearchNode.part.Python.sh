#!/bin/bash

# ResearchNode installer
#
# Python packages subroutine
#
#
# Sourcing script:
#
#		curl https://raw.githubusercontent.com/chrisvoncsefalvay/stackscripts/master/ResearchNode.part.Python.sh | sudo bash -
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

install_python3 () {
	echo "----------------------------"
	echo "Installing Python and pip..."
	echo "----------------------------"

	sudo apt-get install -y python python-pip python3 python3-pip python3 libpython3-all-dev
	sudo apt-get install -y g++

	sudo wget https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py
	sudo python3 /tmp/get-pip.py

	sudo pip3 install --upgrade pip setuptools
	sudo pip3 install virtualenv virtualenvwrapper
}

install_barebones () {
	echo "-----------------------------------"
	echo "Installing basic Python packages..."
	echo "-----------------------------------"

	sudo pip3 install Cython requests BeautifulSoup4 scrapy
}
