#!/bin/bash

# ResearchNode installer
#
# R base subroutine
#
#
# Sourcing script:
#
#		curl https://raw.githubusercontent.com/chrisvoncsefalvay/stackscripts/master/ResearchNode.part.R_base.sh | sudo bash -
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

echo "------------------"
echo "Adding apt repo..."
echo "------------------"

sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
echo 'deb [arch=amd64,i386] https://cran.rstudio.com/bin/linux/ubuntu xenial/' >> /etc/apt/sources.list
sudo apt-get update


echo "---------------"
echo "Installing R..."
echo "---------------"

sudo apt-get install -y r-base r-base-dev r-base-core r-base-core-dbg r-base-latex
