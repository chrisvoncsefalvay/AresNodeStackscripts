#!/bin/bash

# ResearchNode installer
#
# Shiny subroutine
#
#
# Sourcing script:
#
#		curl https://raw.githubusercontent.com/chrisvoncsefalvay/stackscripts/master/ResearchNode.part.Shiny.sh | sudo bash -
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

install_shiny {	
	echo "---------------------------------"
	echo "Installing Shiny Server ${1}..."
	echo "---------------------------------"

	if [[ "$1"=~"1.5.7.[0-9]{1,3}" ]]; then
		sudo wget https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-"$1"-amd64.deb -O /tmp/shiny-"$1"-amd64.deb
	else
		sudo wget https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-14.04/x86_64/shiny-server-"$1"-amd64.deb -O /tmp/shiny-"$1"-amd64.deb
	fi

	sudo gdebi -n /tmp/shiny-"$1"-amd64.deb
	sudo rm /tmp/shiny-"$1"-amd64.deb
}