#!/bin/bash

# ResearchNode installer
#
# System and SSL subroutine
#
#
# Sourcing script (DIRECTLY INVOKED – NO FUNCTION CALL NEEDED!):
#
#		curl https://raw.githubusercontent.com/chrisvoncsefalvay/stackscripts/master/ResearchNode.part.System.sh | sudo bash -
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

install_system_update_system () {
    echo "------------------------------------------------"
    echo "Updating system and installing the good stuff..."
    echo "------------------------------------------------"

    sudo apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade
    sudo apt-get install -y libxml2-dev wget autoremove libcurl3-dev libfreetype6-dev
    sudo apt-get install -y swig build-essential cmake g++ gfortran libopenblas-dev
    sudo apt-get install -y checkinstall libreadline-gplv2-dev libncursesw5-dev 
    sudo apt-get install -y libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev
    sudo apt-get install -y libdb5.3-dev libexpat1-dev liblzma-dev git git-flow
    sudo apt-get install -y libv8-dev
}


install_system_libssl () {
    echo "------------------------------------"
    echo "Configuring libssl and linking it..."
    echo "------------------------------------"

    sudo apt-get install -y software-properties-common build-essential
    sudo apt-get install -y python-software-properties python3-software-properties
    sudo apt-get install -y libssl-dev libssl-doc libcurl4-openssl-dev
}

install_system_nodejs () {
    echo "--------------------"
    echo "Installing NodeJS..."
    echo "--------------------"

    curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
    sudo apt-get install -y nodejs
}

system_create_usergroup () {
    echo "-----------------------------"
    echo "Creating usergroup ${1}..."
    echo "-----------------------------"

    sudo addusergroup "$1"    

}

system_create_admin_user () {
    echo "----------------------------------"
    echo "Creating admin user ${1}"
    echo "----------------------------------"
    
    sudo su -c "useradd \"$1\" -s /bin/bash -m -g \"$3\""
    sudo echo "$1":"$2" | chpasswd

}

system_configure_git () {
# Params:
# @param $1		Full name for Git
# @param $2		Email
# @param $3		User username
# @param $4		Preferred editor
# @param $5		Github username

	echo "------------------"
	echo "Configuring git..."
	echo "------------------"

	cat << EOF > /tmp/template.gitconfig
[user]
		name = ${1}
		email = ${2}
		username = ${3}
[core]
		editor = ${4}
		whitespace = fix,-indent-with-non-tab,trailing-space,cr-at-eol
		excludesfile = ~/.gitignore	
[push]
		default = matching
[color]
		ui = auto
[color "branch"]
		current = yellow bold
		local = green bold
		remote = cyan bold
[color "diff"]
		meta = yellow bold
		frag = magenta bold
		old = red bold
		new = green bold
		whitespace = red reverse
[color "status"]
		added = green bold
		changed = yellow bold
		untracked = red bold
[diff]
		tool = vimdiff
[difftool]
		prompt = false
[gitflow "prefix"]
		feature = feature-
		release = release-
		hotfix = hotfix-
		support = support-
		versiontag = v
EOF

if [ -n $5 ]; then

	cat << EOF >> /tmp/template.gitconfig
[github]
user = $GIT_USERNAME
EOF

fi

}