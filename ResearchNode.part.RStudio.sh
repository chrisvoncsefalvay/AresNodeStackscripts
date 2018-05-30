#!/bin/bash

# ResearchNode installer
#
# RStudio and Shiny subroutine
#
#
# Sourcing script:
#
#		curl https://raw.githubusercontent.com/chrisvoncsefalvay/stackscripts/master/ResearchNode.part.RStudio.sh | sudo bash -
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


sudo apt-get install -y gdebi-core

echo "---------------------------"
echo "Installing RStudio \"$1\"..."
echo "---------------------------"

if [[ "$1" =~ "1\.1\.\d*" ]]
then
	echo 'Stable version ${1} requested'
	sudo wget https://download2.rstudio.org/rstudio-server/"$1"-amd64.deb -O /tmp/rstudio-"$1"-amd64.deb
	
else

	echo 'Nightly version ${1} requested'
	sudo wget https://s3.amazonaws.com/rstudio-ide-build/server/trusty/amd64/rstudio-server-"$1"-amd64.deb -O /tmp/rstudio-"$1"-amd64.deb
	
fi

sudo gdebi -n /tmp/rstudio-"$1"-amd64.deb
sudo rm /tmp/rstudio-"$1"-amd64.deb