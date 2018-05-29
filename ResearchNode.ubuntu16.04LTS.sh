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
# <UDF name="INSTALL_RSTUDIO" label="Install RStudio?" oneOf="yes,no" default="yes" />
# <UDF name="JUPYTER_PORT" label="JupyterHub port" default="8888" />
# <UDF name="RSTUDIO_PORT" label="RStudio port" default="9999" />
# <UDF name="RSTUDIO_VERSION" label="RStudio version" default="1.1.447" />
# <UDF name="PYTHON_VERSION" label="Python version" oneOf="3.5" default="3.5" />
# <UDF name="BAREBONES" label="Barebones install (only instals basic Python packages)" oneOf="yes,no" default="no" />
# <UDF name="CARTOTOOLS" label="Python: Do you want to install cartography and GIS tools?" oneOf="yes,no" default="no" />
# <UDF name="OPENCV" label="Python: Do you want to install OpenCV and deep learning tools?" oneOf="yes,no" default="no" />
# <UDF name="BIOINFORMATICS" label="Python: Do you want to install bioinformatics tools?" oneOf="yes,no" default="no" />
# <UDF name="USER_USERNAME" label="First user username" />
# <UDF name="USER_PASSWORD" label="First user password" />
# <UDF name="USERGROUPNAME" label="Usergroup name for Jupyterhub users" default="jupyter" />


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
echo "OpenCV: $OPENCV"
echo "Cartography tools: $CARTOTOOLS"
echo "Deep learning tools: $DEEPLEARNING"
echo ""
echo "R & RStudio"
echo "-----------"
echo "RStudio install: $INSTALL_RSTUDIO"
echo ""
echo "Ports"
echo "*---> RStudio: $RSTUDIO_PORT"
echo "*---> Jupyter: $JUPYTER_PORT"


if [ $BAREBONES = "yes" ] 
then
	echo "This is a barebones install, so it'll be pretty quick."
fi

echo ""
echo "OK, let's go! ..."
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
sudo apt-get install -y libdb5.3-dev libexpat1-dev liblzma-dev


# --- INSTALLING LIBSSL -------------------------------------------------------
echo "------------------------------------"
echo "Configuring libssl and linking it..."
echo "------------------------------------"

sudo apt-get install -y software-properties-common build-essential
sudo apt-get install -y python-software-properties 
sudo apt-get install -y libssl-dev libssl-doc



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

sudo apt-get install -y python python-pip python3 python3-pip python3* libpython3*

cd /tmp
sudo wget https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py


# --- INSTALLING R -----------------------------------------------------------
echo "------------------"
echo "Adding apt repo..."
echo "------------------"

sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
sudo add-apt-repository 'deb [arch=amd64,i386] https://cran.rstudio.com/bin/linux/ubuntu xenial/'


echo "---------------"
echo "Installing R..."
echo "---------------"
sudo apt-get install -y r-base r-*


# --- INSTALLING OPENCV -------------------------------------------------------
if [ $OPENCV = "yes" ]
then
  echo "--------------------"
  echo "Installing OpenCV..."
  echo "--------------------"
  sudo apt-get install -y libpng12-dev libjpeg8-dev libtiff5-dev libjasper-dev
  sudo apt-get install -y qtbase5-dev libavcodec-dev libavformat-dev libswscale-dev 
  sudo apt-get install -y libgtk2.0-dev libv4l-dev libatlas-base-dev gfortran
  sudo apt-get install -y libhdf5-serial-dev
fi


# --- INSTALLING PYTHON PACKAGES ----------------------------------------------
echo "-------------------------------------------"
echo "Installing barebones scientific packages..."
echo "-------------------------------------------"
sudo pip3 install Cython
sudo pip3 install scipy numpy pandas matplotlib

if [ $BAREBONES = "no" ]
then
  echo "------------------------------------------------------------"
  echo "Installing extended scientific and visualization packages..."
  echo "------------------------------------------------------------"
  sudo pip3 install graphviz ggplot deap NetworkX scikit-learn Pillow
  sudo pip3 install simpy seaborn epipy mesa requests BeautifulSoup4
  sudo pip3 install bokeh scikit-image gensim nltk statsmodels scrapy
  sudo pip3 install biopython cubes 
fi


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
echo "c.JupyterHub.ip = '0.0.0.0'" >> $CONFIG_FILE
echo "c.JupyterHub.port = $JUPYTER_PORT" >> $CONFIG_FILE
echo "c.JupyterHub.pid_file = '/var/run/$NAME.pid'" >> $CONFIG_FILE
echo "c.Authenticator.admin_users = {'$USER_USERNAME'}" >> $CONFIG_FILE
echo "c.JupyterHub.db_url = 'sqlite:////usr/local/jupyterhub/jupyterhub.sqlite'" >> $CONFIG_FILE
echo "c.JupyterHub.extra_log_file = '/var/log/jupyterhub.log'" >> $CONFIG_FILE
echo "c.JupyterHub.spawner_class = 'sudospawner.SudoSpawner'" >> $CONFIG_FILE
echo "c.Spawner.cmd = '/usr/local/bin/sudospawner'" >> $CONFIG_FILE
echo "c.SudoSpawner.sudospawner_path = '/usr/local/bin/sudospawner'" >> $CONFIG_FILE 
sudo jupyterhub upgrade-db



if [ $CARTOTOOLS = "yes" ]
then
  echo "--------------------------------"
  echo "Installing cartographic tools..."
  echo "--------------------------------"
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

if [ $BIOINFORMATICS = "yes" ]
then
  echo "------------------------------------"
  echo "Installing bioinformatics toolkit..."
  echo "------------------------------------"



fi

# Install OpenCV

if [ $OPENCV = "yes" ]
then
  echo "--------------------"
  echo "Installing OpenCV..."
  echo "--------------------"
  sudo apt-get install -y libopencv-dev python-opencv
  sudo pip3 install opencv-contrib-python
fi


# Install basic R packages

if [ $BAREBONES = "no" ]
then
  # Must-haves
  install_Rpkg Rcpp 
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
  install_Rpkg shiny xtable rmarkdown knitr 
  # Spatial data
  install_Rpkg sp maptools maps ggmap tmap tmaptools mapsapi tidycensus
  # Time series
  install_Rpkg zoo xts quantmod 
  # Progtools
  install_Rpkg compiler foreach doParallel
fi

# RStudio install
if [ $INSTALL_RSTUDIO = "yes" ]
then
	echo "---------------------"
	echo "Installing RStudio..."
	echo "---------------------"
	
	sudo apt-get install -y gdebi-core
	wget https://download2.rstudio.org/rstudio-server-$RSTUDIO_VERSION-amd64.deb
	sudo gdebi -n rstudio-server-$RSTUDIO_VERSION-amd64.deb
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

echo "-------------------------------------------"
echo "Starting Jupyterhub service on port $JUPYTER_PORT..."
echo "-------------------------------------------"

sudo systemctl restart jupyterhub


echo "All done. Enjoy your Jupyterhub installation!"
