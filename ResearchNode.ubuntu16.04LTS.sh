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
# <UDF name="INSTALL_RSTUDIO" label="RSTUDIO: Install RStudio?" oneOf="yes,no" default="yes" />
# <UDF name="RSTUDIO_PORT" label="RSTUDIO: RStudio port" default="9999" />
# <UDF name="RSTUDIO_VERSION" label="RSTUDIO: RStudio version (stable: 1.1.453)" default="1.1.453" />
# <UDF name="INSTALL_SHINYSERVER" label="RSTUDIO: Install Shiny server?" oneOf="yes,no" default="yes" />
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

# IMPORTING STACK SCRIPTS
source <ssinclude StackScriptID=1>	# Linode stock functions - https://www.linode.com/stackscripts/view/1


# Getting the IP address of the current box

IPADDR=$(/sbin/ifconfig eth0 | awk '/inet / { print $2 }' | sed 's/addr://')


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

	if [ -z $1 ]
	then	
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

CONFIG_FILE=/etc/jupyterhub/jupyterhub_config.py
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

if [ $INSTALL_RSTUDIO = "yes" ]
then
  echo "R & RStudio"
  echo "-----------"
  echo "R version: "
  echo "RStudio version: $RSTUDIO_VERSION"
  echo ""
fi

echo "Components"
echo "----------"
echo "OpenCV:               $OPENCV"
echo "GIS tools:            $CARTOTOOLS"
echo "Deep learning tools:  $DEEPLEARNING"
echo "Bioinformatics tools: $BIOINFORMATICS"
echo ""

echo "Databases"
echo "---------"
echo "* PostgreSQL"
echo "* SQLite"

if [ $INSTALL_MONGO = "yes" ]
then
  echo "* MongoDB"
fi

if [ $INSTALL_NEO4J = "yes" ]
then
  echo "* Neo4j"
fi

echo ""
echo "Ports"
echo "-----"
echo ""
echo "         SERVICE       |  PORT  "
echo "-----------------------|--------"
echo "*-------->     RStudio | $RSTUDIO_PORT"
echo "*-------->     Jupyter | $JUPYTER_PORT"

if [ $DEEPLEARNING = "yes" ]
then
	echo "*--------> TensorBoard | 1234"
fi

if [ $INSTALL_NEO4J = "yes" ]
then
	echo "*-------->       Neo4j | 1234"
fi

if [ $INSTALL_MONGO = "yes" ]
then
	echo "*-------->       Mongo | 1234"
fi

echo "*-------->  PostgreSQL | 1234"
echo "-----------------------|-------"

if [ $BAREBONES = "yes" ] 
then
	echo "This is a barebones install, so it will be pretty quick."
fi

echo ""
echo "OK, ready to roll!"
echo ""

# --- INSTALLING UPDATES ------------------------------------------------------
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


# --- INSTALLING LIBSSL -------------------------------------------------------
echo "------------------------------------"
echo "Configuring libssl and linking it..."
echo "------------------------------------"

sudo apt-get install -y software-properties-common build-essential
sudo apt-get install -y python-software-properties python3-software-properties
sudo apt-get install -y libssl-dev libssl-doc
sudo apt-get install -y libcurl4-openssl-dev


# --- INSTALLING NODEJS -------------------------------------------------------
echo "--------------------"
echo "Installing NodeJS..."
echo "--------------------"

curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
sudo apt-get install -y nodejs


# --- INSTALLING PYTHON -------------------------------------------------------
echo "--------------------------------"
echo "Installing Python $PYTHON_VERSION and pip..."
echo "--------------------------------"

sudo apt-get install -y python python-pip python3 python3-pip python3 libpython3-all-dev
sudo apt-get install -y g++

sudo wget https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py
sudo python3 /tmp/get-pip.py

sudo pip3 install --upgrade pip setuptools
sudo pip3 install virtualenv virtualenvwrapper


# --- INSTALLING R -----------------------------------------------------------
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


# --- INSTALLING DATABASES ----------------------------------------------------

if [ $INSTALL_NEO4J = "yes" ]
then
  echo "-------------------"
  echo "Installing Neo4j..."
  echo "-------------------"

  sudo apt-get install -y default-jre default-jre-headless
  sudo update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/bin/java
  sudo update-alternatives --set javac /usr/lib/jvm/java-8-openjdk-amd64/bin/javac

  wget --no-check-certificate https://debian.neo4j.org/neotechnology.gpg.key -O /tmp/neotechnology.key | sudo apt-key add /tmp/neotechnology.key
  echo 'deb http://debian.neo4j.org/repo stable/' | sudo tee /etc/apt/sources.list.d/neo4j.list
  	
  sudo apt-get update -y
  sudo apt-get -y install neo4j
  
  sudo pip3 uninstall scikit-learn
  sudo pip3 install scikit-learn>=0.18.1
  sudo pip3 install neo4j-driver==1.5.2 py2neo neomodel
fi

if [ $INSTALL_MONGO = "yes" ]
then
  echo "---------------------"
  echo "Installing MongoDB..."
  echo "---------------------"

  sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
  echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list
  sudo apt-get update
  sudo apt-get install -y mongodb-org
  sudo pip3 install pymongo
fi

echo "------------------------"
echo "Installing Postgresql..."
echo "-------------------------"

sudo apt-get install -y postgresql postgresql-contrib
sudo pip3 install psycopg2


# --- INSTALLING OPENCV -------------------------------------------------------

if [ $OPENCV = "yes" ]
then
  echo "--------------------"
  echo "Installing OpenCV..."
  echo "--------------------"
  # DOWNLOAD AND LAUNCH OPENCV INSTALLER
  
fi


# --- INSTALLING PYTHON PACKAGES ----------------------------------------------

# INSTALLER GOES HERE

# --- INSTALLING JUPYTERHUB ---------------------------------------------------

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
sudo jupyterhub --generate-config -f $CONFIG_FILE


# Configure config file
echo "-------------------------------------"
echo "Configuring JupyterHub config file..."
echo "-------------------------------------"

cat << EOF >> $CONFIG_FILE
c.JupyterHub.ip = '0.0.0.0'
c.JupyterHub.port = $JUPYTER_PORT
c.JupyterHub.pid_file = '/var/run/$NAME.pid'
c.Authenticator.admin_users = {'$USER_USERNAME'}
c.JupyterHub.db_url = 'sqlite:////usr/local/jupyterhub/jupyterhub.sqlite'
c.JupyterHub.extra_log_file = '/var/log/jupyterhub.log'
c.Spawner.cmd = '/usr/local/bin/sudospawner'
c.SudoSpawner.sudospawner_path = '/usr/local/bin/sudospawner'
EOF

# Upgrading the jupyterhub DB

sudo jupyterhub upgrade-db



# --- INSTALLING GIS TOOLS ----------------------------------------------------

if [ $CARTOTOOLS = "yes" ]
then

  echo "-----------------------"
  echo "Installing GIS tools..."
  echo "-----------------------"

  sudo apt-get install -y proj-bin libproj-dev libgeos-dev
  sudo add-apt-repository -y ppa:ubuntugis/ppa
  sudo apt-get update
  sudo apt-get install -y pyproj 
  sudo apt-get install -y gdal-bin python-gdal python3-gdal
  sudo pip3 install GEOS 
  sudo pip3 install GDAL pygdal
  sudo pip3 install geopandas geojson geopy geoviews elevation OSMnx giddy
  sudo pip3 install spint landsatxplore telluric 
  sudo pip3 install mapbox mapboxgl

fi



# --- INSTALLING BIOINFORMATICS TOOLS -----------------------------------------

if [ $BIOINFORMATICS = "yes" ]
then

  echo "------------------------------------"
  echo "Installing bioinformatics toolkit..."
  echo "------------------------------------"

  sudo pip3 install biopython 
  sudo pip3 install scikit-bio
  install_Rpkg purrr 

fi


# --- INSTALLING OPENCV -----------------------------------------------------

if [ $OPENCV = "yes" ]
then

  echo "--------------------"
  echo "Installing OpenCV..."
  echo "--------------------"
  sudo apt-get install -y libopencv-dev python-opencv
  sudo pip3 install opencv-contrib-python imtools

fi


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
sudo apt-get install -y gdebi-core

echo "---------------------------"
echo "Installing RStudio $RSTUDIO_VERSION..."
echo "---------------------------"

if [[ $RSTUDIO_VERSION =~ "1\.1\.\d*" ]]
then
	echo "Stable version $RSTUDIO_VERSION requested"
	sudo wget https://download2.rstudio.org/rstudio-server/$RSTUDIO_VERSION-amd64.deb -O /tmp/rstudio-$RSTUDIO_VERSION-amd64.deb
else
	echo "Nightly version $RSTUDIO_VERSION requested"
	sudo wget https://s3.amazonaws.com/rstudio-ide-build/server/trusty/amd64/rstudio-server-$RSTUDIO_VERSION-amd64.deb -O /tmp/rstudio-$RSTUDIO_VERSION-amd64.deb
fi

sudo gdebi -n /tmp/rstudio-$RSTUDIO_VERSION-amd64.deb
sudo rm /tmp/rstudio-$RSTUDIO_VERSION-amd64.deb


if [ $INSTALL_SHINYSERVER = "yes" ]
then
	
	echo "---------------------------------"
	echo "Installing Shiny Server $SHINYSERVER_VERSION..."
	echo "---------------------------------"

	if [[ $SHINYSERVER_VERSION=~"1.5.7.[0-9]{1,3}" ]]
	then

		sudo wget https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-$SHINYSERVER_VERSION-amd64.deb -O /tmp/shiny-$SHINYSERVER_VERSION-amd64.deb
	
	else
		
		sudo wget https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-14.04/x86_64/shiny-server-$SHINYSERVER_VERSION-amd64.deb -O /tmp/shiny-$SHINYSERVER_VERSION-amd64.deb
	
	fi
	
	sudo gdebi -n /tmp/shiny-$SHINYSERVER_VERSION-amd64.deb
	sudo rm /tmp/shiny-$SHINYSERVER_VERSION-amd64.deb
	
fi

# Configure RStudio config file
echo "----------------------------------"
echo "Configuring RStudio config file..."
echo "----------------------------------"

sudo groupadd $USERGROUPNAME

cat << EOF > /etc/rstudio/rserver.conf
  www-port=$RSTUDIO_PORT
  www-address=0.0.0.0
  rsession-which-r=$(which R)
  auth-required-user-group=$USERGROUPNAME
EOF

sudo rstudio-server restart


# Create first user
echo "----------------------------------"
echo "Creating admin user $USER_USERNAME"
echo "----------------------------------"
sudo su -c "useradd $USER_USERNAME -s /bin/bash -m -g $USERGROUPNAME"
sudo echo "$USER_USERNAME:$USER_PASSWORD" | chpasswd

# Create daemon

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

echo "------------------"
echo "Configuring git..."
echo "------------------"

cat << EOF > /tmp/template.gitconfig
[user]
		name = $GIT_FULLNAME
		email = $GIT_EMAIL
		username = $USER_USERNAME
[core]
		editor = $PREFERRED_EDITOR
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

if [ -n "$GIT_USERNAME" ]
then
	cat << EOF >> /tmp/template.gitconfig
		[github]
			user = $GIT_USERNAME
EOF

fi


echo "--------------------------------"
echo "Generating Github SSH/RSA key..."
echo "--------------------------------"

create_ssh_key()


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

if [ $INSTALL_SHINYSERVER = "yes" ]
then
	echo "Shiny (${SHINYSERVER_VERSION}): http://${IPADDR}:3838"
fi

echo "Jupyterhub (Python ${PYTHON_VERSION}): http://${IPADDR}:${JUPYTER_PORT}"
echo "Postgresql: pgsql://${IPADDR}:5432"
echo ""


if [ $KEY_UPLOAD_RESULT = 200 ]
then
	echo "Your key has been automatically uploaded to your GitHub account (username: ${GIT_USERNAME}). You have nothing more to do. Your keypair is located at ${KEY_LOCATION}."
else
	echo "The automatic key upload process has failed (the server returned an error code ${KEY_UPLOAD_RESULTS}). To upload your GitHub key, follow the steps below:"
	echo ""
	echo "1) Go to https://github.com/settings/ssh/new and log in."
	echo "2) Copy your public key, displayed below, in the big textbox:
	echo ""
	echo "${PUBLIC_KEY}"
	echo ""
	echo "3) Click on 'Add SSH key'."
fi	
