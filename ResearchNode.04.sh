#!/bin/bash


# ResearchNode installer
#
# PART 04
# FRONTENDS
#
# Linode embedding ID:    317448
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

echo "Loaded subsidiary resource RN04.FRONTENDS.317448"

# rn04_install_RStudio
# --------------------
# Installs RStudio and configures it. Automatically distinguishes between stable (1.1.*) and Nightly (1.2.*) releases.
#
rn04_install_RStudio () {
	sudo apt-get install -y gdebi-core

	echo "---------------------------"
	echo "Installing RStudio ${RSTUDIO_VER}..."
	echo "---------------------------"

	if [[ "$RSTUDIO_VER" =~ "1\.1\.\d*" ]]; then
		echo 'Stable version ${RSTUDIO_VER} requested'
		sudo wget https://download2.rstudio.org/rstudio-server/"$1"-amd64.deb -O /tmp/rstudio-"${RSTUDIO_VER}"-amd64.deb
	else
		echo 'Nightly version ${RSTUDIO_VER} requested'
		sudo wget https://s3.amazonaws.com/rstudio-ide-build/server/trusty/amd64/rstudio-server-"${RSTUDIO_VER}"-amd64.deb -O /tmp/rstudio-"$1"-amd64.deb
	fi

	sudo gdebi -n /tmp/rstudio-"${RSTUDIO_VER}"-amd64.deb
	sudo rm /tmp/rstudio-"${RSTUDIO_VER}"-amd64.deb
}

# rn04_create_RStudio_config
# --------------------------
# Creates configuration files for RStudio.
#
rn04_create_RStudio_config () {
	echo "----------------------------------"
	echo "Configuring RStudio config file..."
	echo "----------------------------------"

	cat << EOF > /etc/rstudio/rserver.conf
	www-port=${RSTUDIO_PORT}
	www-address=0.0.0.0
	rsession-which-r=$(which R)
	auth-required-user-group=${USER_GROUP}
	r-cran-repos=https://cloud.r-project-org/
EOF
}

# rn04_configure_RStudio %end%





# rn04_install_Jupyterhub
# -----------------------

rn04_install_Jupyterhub () {
	echo "-----------------------------"
	echo "Installing JupyterHub ${JUPYTERHUB_VER}..."
	echo "-----------------------------"

	npm install -g configurable-http-proxy
	sudo pip3 install jupyterhub==${JUPYTERHUB_VER} sudospawner
	sudo pip3 install --upgrade notebook
}

# rn04_install_Jupyterhub %end%


# rn04_configure_Jupyterhub
# -------------------------

rn04_configure_Jupyterhub () {
	echo "------------------------------------"
	echo "Generating JupyterHub config file..."
	echo "------------------------------------"

	sudo mkdir /etc/jupyterhub
	sudo mkdir /usr/local/jupyterhub
	sudo jupyterhub --generate-config -f /etc/jupyterhub/jupyterhub_config.py

    echo "-------------------------------------"
    echo "Configuring JupyterHub config file..."
    echo "-------------------------------------"

    cat << EOF >> /etc/jupyterhub/jupyterhub_config.py
    c.JupyterHub.ip = '0.0.0.0'
    c.JupyterHub.port = "${JUPYTERHUB_PORT}"
    c.JupyterHub.pid_file = '/var/run/jupyterhub.pid'
    c.Authenticator.admin_users = {'${USER_USERNAME}'}
    c.JupyterHub.db_url = 'sqlite:////usr/local/jupyterhub/jupyterhub.sqlite'
    c.JupyterHub.extra_log_file = '/var/log/jupyterhub.log'
    c.Spawner.cmd = '/usr/local/bin/sudospawner'
    c.SudoSpawner.sudospawner_path = '/usr/local/bin/sudospawner'
EOF

	sudo jupyterhub upgrade-db
	
	
    echo "------------------"
    echo "Creating daemon..."
    echo "------------------"

	    cat << EOF > jupyterhub.service
[Unit]
Description=Jupyterhub
After=syslog.target network.target

[Service]
User=root
ExecStart=/usr/local/bin/jupyterhub -f /etc/jupyterhub/jupyterhub_config.py JupyterHub.spawner_class=sudospawner.SudoSpawner 
WorkingDirectory=/etc/jupyterhub
Restart=always

[Install]
WantedBy=multi-user.target
EOF

    sudo mkdir /usr/lib/systemd/system
    sudo mv jupyterhub.service /usr/lib/systemd/system/jupyterhub.service
    sudo chmod a+x /usr/lib/systemd/system/jupyterhub.service
    sudo systemctl enable jupyterhub
    sudo systemctl daemon-reload
}


