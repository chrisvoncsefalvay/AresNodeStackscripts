#!/bin/bash
#
# Complete ResearchNode script: installs
# * a complete Jupyterhub environment,
# * a complete R and RStudio environment,
# * selectable Python and RStudio packages.
# 
# This HAS to be run by a privileged (=root) user as the default authentication
# is PAM. If you want to use a different authentication, such as OAuth, you do
# not need to run Jupyterhub with a privileged user.
#
# (c) Chris von Csefalvay, 2018.
#
# <UDF name="JUPYTER_PORT" label="PYTHON: JupyterHub port" default="8888" />
# <UDF name="PYTHON_VERSION" label="PYTHON: Python version" oneOf="3.5" default="3.5" />
# <UDF name="RSTUDIO_PORT" label="RSTUDIO: RStudio port" default="9999" />
# <UDF name="RSTUDIO_VERSION" label="RSTUDIO: RStudio version" oneOf="1.1.453,1.2.672" default="1.1.453" />
# <UDF name="SHINYSERVER_VERSION" label="RSTUDIO: Shiny server version (stable: 1.5.7.907)" default="1.5.7.907" />
# <UDF name="BAREBONES" label="FEATURES: Barebones install (only instals basic Python packages)" oneOf="yes,no" default="no" />
# <UDF name="CARTOTOOLS" label="FEATURES: Do you want to install cartography and GIS tools?" oneOf="yes,no" default="no" />
# <UDF name="OPENCV" label="FEATURES: Do you want to install OpenCV and deep learning tools?" oneOf="yes,no" default="no" />
# <UDF name="BIOINFORMATICS" label="FEATURES: Do you want to install bioinformatics tools?" oneOf="yes,no" default="no" />
# <UDF name="DEEPLEARNING" label="FEATURES: Do you want to install deep learning tools?" oneOf="yes,no" default="no" />
# <UDF name="DOWNLOAD_CORPORA" label="FEATURES: Do you want to download corpora?" oneOf="yes,no" default="no" />
# <UDF name="INSTALL_MONGO" label="DATABASES: Do you want to install MongoDB?" oneOf="yes,no" default="yes" />
# <UDF name="INSTALL_NEO4J" label="DATABASES: Do you want to install Neo4j?" oneOf="yes,no" default="yes" />
# <UDF name="USER_USERNAME" label="SYSTEM: First user username" />
# <UDF name="USER_PASSWORD" label="SYSTEM: First user password" />
# <UDF name="USERGROUPNAME" label="SYSTEM: Usergroup name for Jupyterhub users" default="jupyter" />
# <UDF name="PREFERRED_EDITOR" label="SYSTEM: Preferred editor" oneOf="vim,nano" />
# <UDF name="GIT_USERNAME" label="GIT: Github username" />
# <UDF name="GIT_FULLNAME" label="GIT: Full name" />
# <UDF name="GIT_EMAIL" label="GIT: E-mail address" />
# <UDF name="GIT_PASSWORD" label="GIT: Key for your generated GitHub RSA key" />
# <UDF name="GITHUB_TOKEN" label="GIT: GitHub Access Token to allow direct upload of your generated key to your account as an authenticated key. This key MUST HAVE ALL user/public_key permissions." />
# <UDF name="TESTING" label="TEST VARIABLE: choose some shit" manyOf="One,Two,Three,Potatoes" />

# IMPORTING STACK SCRIPTS
source <ssinclude StackScriptID=1>	# Linode stock functions - https://www.linode.com/stackscripts/view/1


# Declaring R package installer function

install_Rpkg () {  
  for pkg in "$@"
  do
    echo "Installing R package $pkg..."
    echo "install.packages('$pkg', lib='/usr/local/lib/R/site-library', repos='http://cran.us.r-project.org')" | sudo -i R --no-save
  done
}


# Declaring function for generating the ssh key

create_ssh_key () {

	if [ -z $1 ]; then	
		KEY_LOCATION="/home/${USER_USERNAME}/.ssh/id_rsa"
	else
		KEY_LOCATION="$1"
	fi
	
	echo "Generating public key for ${GIT_EMAIL} to ${KEY_LOCATION}..."
	
	ssh-keygen -t rsa -b 4096 -f "${KEY_LOCATION}" -C "${GIT_EMAIL}" -q -P "$GIT_PASSWORD"
	eval "$(ssh-agent -s)"
	ssh-add ~/.ssh/id_rsa
	
	PUBLIC_KEY=$(cat ${KEY_LOCATION})
	
	local RESULT_STATUS = $(curl -u ${GIT_USERNAME}:${GITHUB_TOKEN} --data '{"title": "Research box at ${IPADDR} (${USER_USERNAME}:${LINODE_DATACENTERID}.${LINODE_LISHUSERNAME})", "key": "${PUBLIC_KEY}"}' https://api.github.com/user/keys)
	
	KEY_UPLOAD_RESULT = "$(RESULT_STATUS | grep HTTP)"
	
	echo "${KEY_UPLOAD_RESULT}"
}


# Declaring base variables

USER=root


# Initiating process

echo "Welcome to Chris's awesome Jupyterhub stackscript ;)"
echo "****************************************************"
echo "This will take you through the installation of Jupyterhub."
echo ""
echo "Your component settings"
echo "======================="
echo ""
echo "Python"
echo "------"
echo "Version: $PYTHON_VERSION"
echo ""

echo "R & RStudio"
echo "-----------"
echo "R version: "
echo "RStudio version: $RSTUDIO_VERSION"
echo ""

echo "Components"
echo "----------"
echo "OpenCV:               $OPENCV"
echo "GIS tools:            $CARTOTOOLS"
echo "Deep learning tools:  $DEEPLEARNING"
echo "Bioinformatics tools: $BIOINFORMATICS"
echo ""


# --- SYSTEM PREPARATION -----------------------------------------------------

##	Downloading installer script
source <(curl -s https://raw.githubusercontent.com/chrisvoncsefalvay/stackscripts/master/ResearchNode.part.System.sh)


##	Updating system
install_system_update_system

##	Installing libssl
install_system_libssl

##	Installing NodeJS
install_system_nodejs

## Creating user group
system_create_usergroup ${USERGROUPNAME}

## Configuring Git

system_configure_git "${GIT_FULLNAME}" $GIT_EMAIL $USER_USERNAME $PREFERRED_EDITOR $GIT_USERNAME 


# --- INSTALLING PYTHON -------------------------------------------------------

source <(curl -s https://raw.githubusercontent.com/chrisvoncsefalvay/stackscripts/master/ResearchNode.part.Python.sh)

# --- INSTALLING R -----------------------------------------------------------

source <(curl -s https://raw.githubusercontent.com/chrisvoncsefalvay/stackscripts/master/ResearchNode.part.R_base.sh)

# --- INSTALLING DATABASES ----------------------------------------------------

if [ $INSTALL_NEO4J = "yes" ]
then
	install_db_neo4j
	
fi

if [ $INSTALL_MONGO = "yes" ]
then
	install_db_mongodb
	
fi

install_db_postgresql


# --- INSTALLING OPENCV -------------------------------------------------------

if [ $OPENCV = "yes" ]
then
	
	source <(curl -s https://raw.githubusercontent.com/chrisvoncsefalvay/stackscripts/master/ResearchNode.part.OpenCv.sh)

fi


# --- INSTALLING PYTHON PACKAGES ----------------------------------------------

# Source installation scripts
source<(curl -s https://raw.githubusercontent.com/chrisvoncsefalvay/stackscripts/master/ResearchNode.part.Python.sh)

install_barebones

if [ $BAREBONES = "no" ]
then

	install_general
	install_dataviz
	install_nlp
	install_ML

fi

if [ $BAREBONES = "no" ] && [ $INSTALL_CORPORA = "yes" ]
then

	download_corpora
	
fi


# --- INSTALLING GIS TOOLS ----------------------------------------------------

if [ $BAREBONES = "no" ] && [ $CARTOTOOLS = "yes" ]
then
	install_cartotools

fi



# --- INSTALLING BIOINFORMATICS TOOLS -----------------------------------------

if [ $BAREBONES = "no" ] && [ $BIOINFORMATICS = "yes" ]
then
	install_bioinformatics

fi


# --- INSTALLING JUPYTERHUB ---------------------------------------------------

source <(curl -s https://raw.githubusercontent.com/chrisvoncsefalvay/stackscripts/master/ResearchNode.part.Jupyter.sh)

configure_jupyterhub $JUPYTER_PORT $USER_USERNAME




# Install basic R packages

if [ $BAREBONES = "no" ]
then

	# Must-haves
	install_Rpkg Rcpp 
	install_Rpkg boot glmnet pwr
	install_Rpkg data.table parallel curl jsonlite httr devtools testthat roxygen2 magrittr cronR
	install_Rpkg addinslist
	# Database connectors
	install_Rpkg RMySQL RSQLite
	# Foreign sources
	install_Rpkg rio datapasta xlsx XLConnect foreign validate
	# Data munging
	install_Rpkg plyr dplyr tidyr sqldf stringr lubridate iterator purrr reshape2 
	# Visualization
	install_Rpkg ggplot2 ggvis rgl leaflet dygraphs NetworkD3 gridExtra corrplot fmsb wordcloud RColorBrewer
	# Modeling
	install_Rpkg glmnet survival MASS metrics e1071 qdap sentimentr tidytext
	# Reporting tools
	install_Rpkg shiny 
	install_Rpkg xtable rmarkdown knitr 
	# Spatial data
	install_Rpkg sp maptools maps ggmap tmap tmaptools mapsapi tidycensus
	# Time series
	install_Rpkg zoo xts quantmod 
	# Progtools
	install_Rpkg compiler foreach doParallel

fi

# RStudio install

source <(curl https://raw.githubusercontent.com/chrisvoncsefalvay/stackscripts/master/ResearchNode.part.RStudio.sh)

install_RStudio ${RSTUDIO_VERSION}

configure_RStudio ${RSTUDIO_PORT} ${USERGROUPNAME}


# Shiny install

source <(curl https://raw.githubusercontent.com/chrisvoncsefalvay/stackscripts/master/ResearchNode.part.Shiny.sh)

install_Shiny ${SHINYSERVER_VERSION}


## Create first (Admin) user

create_admin_user ${USER_USERNAME} ${USER_PASSWORD} ${USERGROUPNAME}


echo "--------------------------------"
echo "Generating Github SSH/RSA key..."
echo "--------------------------------"

create_ssh_key


echo "-------------------------------------------"
echo "Starting Jupyterhub service on port $JUPYTER_PORT..."
echo "-------------------------------------------"


sudo systemctl restart jupyterhub


echo "All done. Enjoy your Jupyterhub & RStudio installation!"
echo ""
echo ""
echo "You can now use your server:"
echo "----------------------------"
echo ""

echo "RStudio (${RSTUDIO_VERSION}): http://${IPADDR}:${RSTUDIO_PORT}"
echo "Shiny (${SHINYSERVER_VERSION}): http://${IPADDR}:3838"

echo "Jupyterhub (Python ${PYTHON_VERSION}): http://${IPADDR}:${JUPYTER_PORT}"
echo "Postgresql: pgsql://${IPADDR}:5432"

echo ""

echo "Randoms:"
echo $TESTING

if [ $KEY_UPLOAD_RESULT = 200 ]
then
	echo "Your key has been automatically uploaded to your GitHub account (username: ${GIT_USERNAME}). You have nothing more to do. Your keypair is located at ${KEY_LOCATION}."
else
	echo "The automatic key upload process has failed (the server returned an error code ${KEY_UPLOAD_RESULTS}). To upload your GitHub key, follow the steps below:"
	echo ""
	echo "1) Go to https://github.com/settings/ssh/new and log in."
	echo "2) Copy your public key, displayed below, in the big textbox:"
	echo ""
	echo "${PUBLIC_KEY}"
	echo ""
	echo "3) Click on 'Add SSH key'."
fi	
