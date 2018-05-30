#!/bin/bash

# ResearchNode installer
#
# OpenCV packages subroutine
#
#
# Sourcing script (DIRECTLY INVOKED – NO FUNCTION CALL NEEDED!):
#
#		curl https://raw.githubusercontent.com/chrisvoncsefalvay/stackscripts/master/ResearchNode.part.OpenCV.sh | sudo bash -
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

echo "--------------------"
echo "Installing OpenCV..."
echo "--------------------"
sudo apt-get install -y libpng12-dev libjpeg8-dev libtiff5-dev libjasper-dev
sudo apt-get install -y qtbase5-dev libavcodec-dev libavformat-dev libswscale-dev 
sudo apt-get install -y libgtk2.0-dev libv4l-dev libatlas-base-dev gfortran
sudo apt-get install -y libhdf5-serial-dev
pip3 install opencv-contrib-python