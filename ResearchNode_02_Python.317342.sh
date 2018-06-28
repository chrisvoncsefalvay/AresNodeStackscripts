#!/bin/bash


# ResearchNode installer
#
# PART 02
# PYTHON AND RELATED ITEMS
#
# Linode embedding ID:    317342
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

echo "Loaded subsidiary resource RN02.PYTHON.317342"


# rn02_install_python3
# --------------------
# Installs Python and pip from bootstrap.pypa.io.

rn02_install_python3 () {
	echo "----------------------------"
	echo "Installing Python and pip..."
	echo "----------------------------"


        sudo apt-get install -y g++
        cd /tmp
        wget https://www.python.org/ftp/python/$(echo ${PYTHON_VER}|cut -c1-5)/Python-${PYTHON_VER}.tar.xz
        tar -xf Python-${PYTHON_VER}.tar.xz
        cd Python-${PYTHON_VER}
        ./configure
        make
        sudo make install

	pip completion --bash >> ~/.profile

	sudo pip3 install Cython virtualenv virtualenvwrapper
        sudo pip3 install scikit-image scikit-learn python-opencv
	sudo pip3 install numpy scipy pandas matplotlib seaborn sympy nose

	local MAJOR_VERSION=$(echo ${PYTHON_VER} | cut -c1)
	local MINOR_VERSION=$(echo ${PYTHON_VER} | cut -c3)

	if [ $MAJOR_VERSION -eq 2 ]; then
		echo "Your Python version (${PYTHON_VER}) is too low to install Tensorflow."
    		echo "Please upgrade to a version at least 3.4 or above."
	elif [ $MINOR_VERSION -ge 7 ]; then
		echo "Tensorflow has not yet been implemented for your Python version (${PYTHON_VER})."
    		echo "Please downgrade to a version between 3.4 and 3.6."
	elif [ $MINOR_VERSION -le 4 ]; then
		echo "Your Python version (${PYTHON_VER}) is too low to install Tensorflow."
		echo "Please upgrade to a version at least 3.4 or above."
	else
		pip3 install tensorflow keras
	fi

}


rn02_install_python3

# rn02_install_python3 %end%