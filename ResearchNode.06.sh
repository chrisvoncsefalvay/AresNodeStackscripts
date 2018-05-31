#!/bin/bash


# ResearchNode installer
#
# PART 04
# CORE APPLICATIONS
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

echo "Loaded subsidiary resource RN04.COREAPPS.000000"


# rn04_install_jupyterhub
# -----------------------
# Installs Jupyterhub.
#
rn04_install_jupyterhub () {
    npm install -g configurable-http-proxy
    sudo pip3 install jupyterhub sudospawner virtualenv
    sudo pip3 install --upgrade notebook
}

# rn04_install_jupyterhub %end%



# rn04_install_RStudio
# --------------------
# Installs RStudio.
#
rn04_install_RStudio () {



}



# rn04_configure_jupyterhub
# -----------------------
# Configures Jupyterhub.
#
# @param $1    Jupyterhub port
#
rn04_configure_jupyterhub () {
    # Generate jupyter config
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
c.JupyterHub.port = "$1"
c.JupyterHub.pid_file = '/var/run/jupyterhub.pid'
c.JupyterHub.db_url = 'sqlite:////usr/local/jupyterhub/jupyterhub.sqlite'
c.JupyterHub.extra_log_file = '/var/log/jupyterhub.log'
c.Spawner.cmd = '/usr/local/bin/sudospawner'
c.SudoSpawner.sudospawner_path = '/usr/local/bin/sudospawner'
EOF
}

# rn04_configure_jupyterhub %end%



# rn04_configure_Jupyterhub_for_PAM
# ---------------------------------
# Sets up PAM authentication implicitly, and puts the comma separated list of users provided in as users.
#
# @param $@    Single user or comma separated list of users to add
#
rn04_configure_Jupyterhub_for_PAM () {
    local CLEANED_USER_LIST=$(echo "$@" | sed -e "s/\s//g")
    echo "c.Authenticator.admin_users = {'${CLEANED_USER_LIST}'}" >> /etc/jupyterhub/jupyerhub_config.py
}

# rn04_configure_for_PAM %end%


# rn04_configure_Jupyterhub_daemon
# --------------------------------
# Configures daemon for Jupyterhub and sets up autostart.
#
configure_jupyterhub () {

    # Upgrading the jupyterhub DB
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

    echo "-----------------"
    echo "Placing daemon..."
    echo "-----------------"

    sudo mkdir /usr/lib/systemd/system
    sudo mv jupyterhub.service /usr/lib/systemd/system/jupyterhub.service
    sudo chmod a+x /usr/lib/systemd/system/jupyterhub.service
    sudo systemctl enable jupyterhub
    sudo systemctl daemon-reload
}


