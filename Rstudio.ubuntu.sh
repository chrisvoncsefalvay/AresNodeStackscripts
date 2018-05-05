#!/bin/bash
#
# Jupyterhub for Ubuntu Stack Script
# Installs a Jupyterhub environment with all the goodies,
# including a lot of Python stuff.
# 
# This HAS to be run by a privileged (=root) user as the default authentication
# is PAM. If you want to use a different authentication, such as OAuth, you do
# not need to run Jupyterhub with a privileged user.
#
# (c) Chris von Csefalvay, 2018.
#
# <UDF name="JUPYTER_PORT" label="JupyterHub port" default="8888" />
# <UDF name="BAREBONES" label="Barebones install (only instals basic Python packages)" oneOf="yes,no" default="no" />
# <UDF name="CARTOTOOLS" label="Do you want to install cartography and GIS tools?" oneOf="yes,no" default="no" />
# <UDF name="OPENCV" label="Do you want to install OpenCV and deep learning tools?" oneOf="yes,no" default="no" />
# <UDF name="DEEPLEARNING" label="Do you want to install deep learning support?" oneOf="yes,no" default="no" />
# <UDF name="USER_USERNAME" label="First user username" />
# <UDF name="USER_PASSWORD" label="First user password" />
# <UDF name="USERGROUPNAME" label="Usergroup name for Jupyterhub users" default="jupyter" />
# <UDF name="PROCNAME" label="Process name" default="jupyterhub" />



sudo apt-get updates
sudo apt-get upgrade -y
sudo apt-get build-dep -y libcurl4-gnutls-dev
sudo apt-get build-dep -y libcurl4-openssl-dev
sudo apt-get install libcurl4-openssl-dev
sudo apt-get install -y gdebi-core 
sudo apt-get install r-base r-base-dev gdebi-core
