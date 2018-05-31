#!/bin/bash


# ResearchNode installer
#
# PART 02
# PYTHON AND RELATED ITEMS
#
# Linode embedding ID:    000000
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

echo "Loaded subsidiary resource RN02.PYTHON.000000"


# rn02_install_python3
# --------------------
# Installs Python and pip from bootstrap.pypa.io.

rn02_install_python3 () {
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



# rn02_install_barebones
# ----------------------
# Installs the most essential python packages.

rn02_install_barebones () {
	echo "-----------------------------------"
	echo "Installing basic Python packages..."
	echo "-----------------------------------"

	sudo pip3 install Cython requests BeautifulSoup4 scrapy
	sudo pip3 install scipy numpy pandas matplotlib
	sudo pip3 install deap NetworkX simpy epipy mesa 
	sudo pip3 install gensim statsmodels cubes PyMC PyMix BayesPy 
	sudo pip3 install scikit-learn scikit-dataaccess scikit-datasets 
	sudo pip3 install scikit-metrics scikit-neuralnetwork
}



# rn02_install_python3
# --------------------
# Installs python packages essential for 
