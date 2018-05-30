#!/bin/bash

# ResearchNode installer
#
# Jupyter subroutine
#
#
# Sourcing script:
#
#		curl https://raw.githubusercontent.com/chrisvoncsefalvay/stackscripts/master/ResearchNode.part.Jupyter.sh | sudo bash -
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


echo "------------------------"
echo "Installing JupyterHub..."
echo "------------------------"

npm install -g configurable-http-proxy
sudo pip3 install jupyterhub sudospawner virtualenv
sudo pip3 install --upgrade notebook

# Generate jupyter config
echo "------------------------------------"
echo "Generating JupyterHub config file..."
echo "------------------------------------"

sudo mkdir /etc/jupyterhub
sudo mkdir /usr/local/jupyterhub
sudo jupyterhub --generate-config -f /etc/jupyterhub/jupyterhub_config.py


configure_jupyterhub () {
    echo "-------------------------------------"
    echo "Configuring JupyterHub config file..."
    echo "-------------------------------------"

    cat << EOF >> /etc/jupyterhub/jupyterhub_config.py
    c.JupyterHub.ip = '0.0.0.0'
    c.JupyterHub.port = "$1"
    c.JupyterHub.pid_file = '/var/run/jupyterhub.pid'
    c.Authenticator.admin_users = {'$2'}
    c.JupyterHub.db_url = 'sqlite:////usr/local/jupyterhub/jupyterhub.sqlite'
    c.JupyterHub.extra_log_file = '/var/log/jupyterhub.log'
    c.Spawner.cmd = '/usr/local/bin/sudospawner'
    c.SudoSpawner.sudospawner_path = '/usr/local/bin/sudospawner'
    EOF

    # Upgrading the jupyterhub DB
    sudo jupyterhub upgrade-db
}