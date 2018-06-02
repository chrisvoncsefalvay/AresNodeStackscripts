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

    sudo apt-get install -y libssl-dev libssl-doc libcurl4-openssl-dev

}

# _install_libssl %end%


# _install_zmq
# ------------
_install_zmq () {

    echo "------------------------------------"
    echo "Configuring 0MQ and CZMQ..."
    echo "------------------------------------"
    
    sudo apt-get install -y libtool autoconf automake libzmq5-dev
    sudo mkdir /tmp/zmq
    git clone https://github.com/zeromq/czmq /tmp/zmq
    cd /tmp/zmq
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


# rn01_create_user_and_usergroup
# ------------------------------
# Creates a user with a given password, and assigns it to a newly created usergroup.

rn01_create_user_and_usergroup () {
    echo "-------------------------------------------------------------"
    echo "Setting up user ${USER_USERNAME} and usergroup ${USER_USERGROUP}..."
    echo "-------------------------------------------------------------"

    sudo addgroup ${USER_USERGROUP}
    sudo su -c "useradd ${USER_USERNAME} -s /bin/bash -m -g ${USER_USERGROUP}"
    sudo echo ${USER_USERNAME}:${USER_PASSWORD} | chpasswd
    
}

# rn01_create_user_and_usergroup %end%



# rn01_create_rsakey
# ------------------
# Creates ssh-rsa key for git and GitHub.
#
#	*****	WARNING	  *****
#	The ssh-rsa key will be generated with the user password as passphrase.
#	Most passwords have very low entropy (<3 bits per character) and are
#	generally not suitable passphrases. To change the password, use the
#	following command:
#
#	$ ssh-keygen -p -f ~/.ssh/id_rsa	
#
#
# Uses the following UDFs:
# $GIT_EMAIL			Git e-mail address
# $USER_USERNAME		System user name

rn01_create_rsakey () {
	echo "Generating public key for ${GIT_EMAIL}..."
	sudo mkdir /home/${USER_USERNAME}/.ssh/
	ssh-keygen -t rsa -b 4096 -f /home/${USER_USERNAME}/.ssh/id_rsa -C "${GIT_EMAIL}" -q -P $USER_PASSWORD
}

# rn01_create_rsakey %end%


# rn01_upload_rsakey
# ------------------
# Uploads an RSA public key to GitHub using the token authentication system.
#
# Uses the following UDFs:
# $USER_USERNAME		System user name
# $GIT_USERNAME			GitHub username
# $GIT_TOKEN_PASSWORD	GitHub Personal Access Token

rn01_upload_rsakey () {
	echo "Preparing to upload your RSA key to GitHub..."
	local PUBLIC_KEY=$(cat /home/${USER_USERNAME}/.ssh/id_rsa.pub)
	local JSON='{"title": "Research box at ${IPADDR} (${USER_USERNAME}:${LINODE_DATACENTERID}.${LINODE_LISHUSERNAME}", "key": "${PUBLIC_KEY}")'
	local UPLOAD_RESULT_STATUS=$(curl -u ${GIT_USERNAME}:${GIT_TOKEN_PASSWORD} --data ${JSON} https://api.github.com/user/keys) | grep HTTP
	echo $UPLOAD_RESULT_STATUS
}

# rn01_upload_rsakey %end%



# rn01_configure_git
# ------------------
# Configures git.
#
# Uses the following UDFs:
# $GIT_FULLNAME			Full name of the user (git basic configuration)
# $GIT_EMAIL			E-mail of the user (git basic configuration)
# $GIT_EDITOR			Preferred editor (default: vim)
# $GIT_USERNAME			GitHub username (GitHub configuration)
# $GIT_TOKEN_PASSWORD	Github Personal Access Token (GitHub configuration)
#
# Basic configuration requires ALL git basic configuration items to be set ($GIT_FULLNAME, $GIT_EMAIL).
# GitHub key upload requires $GIT_USERNAME and $GIT_TOKEN_PASSWORD to be set in addition.
#

rn01_configure_git () {

	if [[ -n ${GIT_FULLNAME} ]] && [[ -n ${GIT_EMAIL} ]]; then
		echo "------------------"
		echo "Configuring git..."
		echo "------------------"

		cat << EOF > /tmp/template.gitconfig
[user]
		name = ${GIT_FULLNAME}
		email = ${GIT_EMAIL}
		username = ${GIT_USERNAME}
[core]
		editor = ${GIT_EDITOR}
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

		# Create rsa-ssh key
		#
		rn01_create_rsakey

		# Configure Github only if Github username and token have been provided
		#
		if [[ -n $GIT_USERNAME ]] && [[ -n $GIT_TOKEN_PASSWORD ]]; then
			
		
			cat << EOF >> /tmp/template.gitconfig
[github]
user = $GIT_USERNAME
token = $GIT_TOKEN_PASSWORD
EOF
			RSA_UPLOAD_STATUS=rn01_upload_rsakey
					
			if [[ $RSA_UPLOAD_STATUS -eq 200 ]]; then
				echo "Key upload successful."
			else
				echo "Key upload failed, server returned Error ${RSA_UPLOAD_STATUS}."
			fi
			
		else
		
			echo "----------------------------------------------"
			echo "git configured, but key could not be uploaded."
			echo "----------------------------------------------"
		
		fi
		

		# Move template to key user .gitconfig if there's at least basic git configuration.
		#
		sudo mv /tmp/template.gitconfig /home/${USER_USERNAME}/.gitconfig

	else

		echo "-----------------------------------"
		echo "Insufficient data to configure git."
		echo "-----------------------------------"

	fi
}

# rn01_attach_key
# ---------------
# Adds key to SSH agent.

rn01_attach_key () {
	eval "$(ssh-agent -s)"
	ssh-add /home/${USER_USERNAME}/.ssh/id_rsa
}



# rn01_print_install_summary
# --------------------------
# Prints install summary.

rn01_print_install_summary () {
	echo "****************************************************"
	echo "            INSTALLATION COMPLETE."
	echo "****************************************************"
	
	echo ""
	echo ""
	
	echo "The following services are now available:"
	echo ""
	echo "JupyterHub			http://${IPADDR}:${JUPYTERHUB_PORT}/"
	echo "${JUPYTERHUB_VER}"
	echo ""
	echo "RStudio				http://${IPADDR}:${RSTUDIO_PORT}/"
	echo "${RSTUDIO_VER}"			
	echo ""
	
	if [ -n ${SHINY_VER} ]; then
	echo "Shiny Server			http://${IPADDR}:3838/"
	echo "${SHINY_VER}"
	echo ""
	fi
	
	echo "Databases: ${INSTALL_DATABASES}"
	echo "Additional kernels: ${JUPYTERHUB_KERNELS}" 
	echo ""
	echo "Key upload status: ${RSA_UPLOAD_STATUS}"
}



echo "-------------------------------------------------------------"
echo "Updating system and installing the good stuff..."
echo "-------------------------------------------------------------"

sudo apt-get update
sudo apt-get install -y software-properties-common build-essential
sudo apt-get install -y python-software-properties python3-software-properties
sudo apt-get install -y git

echo "Updating APT..."
_update_apt
    
DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade
    
echo "Installing basic packages..."
_install_basic_packages

echo "Installing libssl..."
_install_libssl

echo "Installing ZMQ..."
_install_zmq
    
echo "Setting up NodeJS..."
_install_node

