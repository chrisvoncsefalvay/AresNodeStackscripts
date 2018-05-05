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
# <UDF name="BAREBONES" label="Barebones install (only instals basic Python packages)" oneOf="yes,no" default="no" />
# <UDF name="CARTOTOOLS" label="Python: Do you want to install cartography and GIS tools?" oneOf="yes,no" default="no" />
# <UDF name="OPENCV" label="Python: Do you want to install OpenCV and deep learning tools?" oneOf="yes,no" default="no" />
# <UDF name="DEEPLEARNING" label="Python: Do you want to install deep learning support?" oneOf="yes,no" default="no" />
# <UDF name="USER_USERNAME" label="First user username" />
# <UDF name="USER_PASSWORD" label="First user password" />
# <UDF name="USERGROUPNAME" label="Usergroup name for Jupyterhub users" default="jupyter" />


# IMPORTING STACK SCRIPTS
source <ssinclude StackScriptID=1>	# Linode stock functions - https://www.linode.com/stackscripts/view/1
source <ssinclude StackScriptID=312380> # install_Rpkg() function - https://manager.linode.com/stackscripts/edit/312380

CONFIG_FILE=/etc/jupyterhub/jupyterhub_config.py
USER=root

echo "Welcome to Chris's awesome Jupyterhub stackscript ;)"
echo "****************************************************"
echo "This will take you through the installation of Jupyterhub."
echo ""
echo "Your component settings"
echo "======================="
echo ""
echo "Python"
echo "------"
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


echo "------------------"
echo "Adding apt repo..."
echo "------------------"

sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
sudo add-apt-repository 'deb [arch=amd64,i386] https://cran.rstudio.com/bin/linux/ubuntu xenial/'


echo "------------------------------------------------"
echo "Updating system and installing the good stuff..."
echo "------------------------------------------------"

sudo apt-get update
sudo apt-get upgrade -y
goodstuff()


echo "---------------"
echo "Installing R..."
echo "---------------"

sudo apt-get install r-base 


if [ $INSTALL_RSTUDIO = "yes" ]
then
	echo "---------------------"
	echo "Installing RStudio..."
	echo "---------------------"
	
	sudo apt-get install gdebi-core
	wget https://download2.rstudio.org/rstudio-server-$RSTUDIO_VERSION-amd64.deb
	sudo gdebi rstudio-server-$RSTUDIO_VERSION-amd64.deb
fi

echo "----------------------"
echo "Installing IRKernel..."
echo "----------------------"



echo "-----------------------------"
echo "Installing Python and deps..."
echo "-----------------------------"

# Install dependencies
sudo apt-get install -y python3-pip
sudo pip3 install --upgrade pip
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
sudo apt-get install -y nodejs build-essential cmake g++ gfortran libopenblas-dev
sudo apt-get install -y pkg-config python-dev software-properties-common 
sudo apt-get install -y wget autoremove virtualenv swig python-wheel
sudo apt-get install -y libcurl3-dev python3-dev python-dev libfreetype6-dev

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

# Install the usual pythonic stuff
echo "-------------------------------------------"
echo "Installing barebones scientific packages..."
echo "-------------------------------------------"
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

if [ $CARTOTOOLS = "yes" ]
then
  echo "--------------------------------"
  echo "Installing cartographic tools..."
  echo "--------------------------------"
  sudo apt-get install -y proj-bin libgeos-dev
  sudo pip3 install GEOS GDAL geojson
fi

if [ $DEEPLEARNING = "yes" ]
then
  echo "---------------------------------"
  echo "Installing deep learning tools..."
  echo "---------------------------------"
  sudo pip3 install tensorflow keras
fi

# Install OpenCV

if [ $OPENCV = "yes" ]
then
  echo "--------------------"
  echo "Installing OpenCV..."
  echo "--------------------"
  sudo apt-get install libopencv-dev python-opencv
fi

# Create first user
echo "----------------------------------"
echo "Creating admin user $USER_USERNAME"
echo "----------------------------------"
sudo groupadd $USERGROUPNAME
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
