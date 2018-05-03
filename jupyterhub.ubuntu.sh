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

CONFIG_FILE=/etc/jupyterhub/jupyterhub_config.py
USER=root

echo "Welcome to Chris's awesome Jupyterhub stackscript ;)"
echo "****************************************************\n\n"
echo "This will take you through the installation of Jupyterhub.\n\n"
echo "Your component settings are:"
echo "OpenCV: $OPENCV"
echo "Cartography tools: $CARTOTOOLS"
echo "Deep learning tools: $DEEPLEARNING"


if [ $BAREBONES = "yes" ] 
then
	echo "This is a barebones install, so it'll be pretty quick."
fi

echo "\n\n"

echo "----------------------"
echo "Installing Anaconda..."
echo "----------------------\n\n"

# Install Anaconda
sudo apt-get install -y wget 
wget https://repo.anaconda.com/archive/Anaconda3-5.1.0-Linux-x86_64.sh
bash Anaconda3-5.1.0-Linux-x86_64.sh -b -p $HOME/conda
export PATH="$HOME/conda/bin:$PATH"
echo 'source $HOME/conda/bin/activate' > ~/.bashrc
source .bashrc

echo "-----------------------------"
echo "Installing Python and deps..."
echo "-----------------------------\n\n"

# Install dependencies
sudo apt-get install -y python3-pip
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
sudo apt-get install -y nodejs build-essential cmake g++ gfortran libopenblas-dev
sudo apt-get install -y pkg-config python-dev software-properties-common 
sudo apt-get install -y wget autoremove virtualenv swig python-wheel
sudo apt-get install -y libcurl3-dev python3-dev python-dev libfreetype6-dev

if [ $OPENCV = "yes" ]
then
  echo "--------------------"
  echo "Installing OpenCV..."
  echo "--------------------\n\n"
  sudo apt-get install -y libpng12-dev libjpeg8-dev libtiff5-dev libjasper-dev
  sudo apt-get install -y qtbase5-dev libavcodec-dev libavformat-dev libswscale-dev 
  sudo apt-get install -y libgtk2.0-dev libv4l-dev libatlas-base-dev gfortran
  sudo apt-get install -y libhdf5-serial-dev
fi

echo "------------------------"
echo "Installing JupyterHub..."
echo "------------------------\n\n"

npm install -g configurable-http-proxy
sudo pip3 install jupyterhub
sudo pip3 install --upgrade notebook

# Generate jupyter config
echo "------------------------------------"
echo "Generating JupyterHub config file..."
echo "------------------------------------\n\n"
sudo mkdir /etc/jupyterhub
sudo cd /etc/jupyterhub
sudo jupyterhub --generate-config -f $CONFIG_FILE

# Configure config file
echo "-------------------------------------"
echo "Configuring JupyterHub config file..."
echo "-------------------------------------\n\n"
echo "c.JupyterHub.ip = '0.0.0.0'" >> $CONFIG_FILE
echo "c.JupyterHub.port = $JUPYTER_PORT" >> $CONFIG_FILE
echo "c.JupyterHub.pid_file = '/var/run/$NAME.pid'" >> $CONFIG_FILE
echo "c.Authenticator.admin_users = {'$USER_USERNAME'}" >> $CONFIG_FILE
echo "c.JupyterHub.db_url = 'sqlite:////usr/local/jupyterhub/jupyterhub.sqlite'" >> $CONFIG_FILE
echo "c.JupyterHub.extra_log_file = '/var/log/jupyterhub.log'" >> $CONFIG_FILE

# Install the usual pythonic stuff
echo "-------------------------------------------"
echo "Installing barebones scientific packages..."
echo "-------------------------------------------\n\n"
sudo pip3 install scipy numpy pandas matplotlib

if [ $BAREBONES = "no" ]
then
  echo "------------------------------------------------------------"
  echo "Installing extended scientific and visualization packages..."
  echo "------------------------------------------------------------\n\n"
  sudo pip3 install graphviz ggplot deap NetworkX scikit-learn Pillow
  sudo pip3 install simpy seaborn epipy mesa requests BeautifulSoup4
  sudo pip3 install bokeh scikit-image gensim nltk statsmodels scrapy
  sudo pip3 install biopython cubes 
fi

if [ $CARTOTOOLS = "yes" ]
then
  echo "--------------------------------"
  echo "Installing cartographic tools..."
  echo "--------------------------------\n\n"
  sudo apt-get install -y proj-bin libgeos-dev
  sudo pip3 install GEOS GDAL geojson
fi

if [ $DEEPLEARNING = "yes" ]
then
  echo "---------------------------------"
  echo "Installing deep learning tools..."
  echo "---------------------------------\n\n"
  sudo pip3 install tensorflow keras
fi

# Install OpenCV

if [ $OPENCV = "yes" ]
then
  echo "--------------------"
  echo "Installing OpenCV..."
  echo "--------------------\n\n"
  sudo apt-get install libopencv-dev python-opencv
fi

# Create first user
echo "----------------------------------"
echo "Creating admin user $USER_USERNAME"
echo "----------------------------------\n\n"
sudo groupadd $USERGROUPNAME
sudo su -c "useradd $USER_USERNAME -s /bin/bash -m -g $USERGROUPNAME"
sudo echo "$USER_USERNAME:$USER_PASSWORD" | chpasswd

# Create daemon

echo "------------------"
echo "Creating daemon..."
echo "------------------\n\n"

cat << EOF > jupyterhubdaemon
#! /bin/sh
### BEGIN INIT INFO
# Provides:          jupyterhub
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start jupyterhub
# Description:       This file should be used to construct scripts to be
#                    placed in /etc/init.d.
### END INIT INFO

# Author: Chris von Csefalvay <chris@chrisvoncsefalvay.com>
# Part of Chris's Rad Jupyterhub Stackscript
# For details, please see: http://github.com/chrisvoncsefalvay/stackscripts

# Do NOT "set -e"

# PATH should only include /usr/* if it runs after the mountnfs.sh script
PATH=/sbin:/usr/sbin:/bin:/usr/bin:/usr/local/bin
DESC="Multi-user server for Jupyter notebooks"
DAEMON=/usr/local/bin/jupyterhub
DAEMON_ARGS="--config=$CONFIG_FILE"
NAME=`basename $0`
DIR=/srv/jupyterhub
PIDFILE=/var/run/$NAME.pid
SCRIPTNAME=/etc/init.d/$NAME
STDOUT_LOG="/var/log/$name.log"
STDERR_LOG="/var/log/$name.err"
CMD="/usr/local/bin/jupyterhub -f $CONFIG_FILE"

get_pid() {
    cat "$PID_FILE"
}

is_running() {
    [ -f "$PID_FILE" ] && ps `get_pid` > /dev/null 2>&1
}

case "$1" in
    start)
    if is_running; then
        echo "Already started"
    else
        echo "Starting $NAME"
        cd "$DIR"
        if [ -z "$USER" ]; then
            sudo $CMD >> "$STDOUT_LOG" 2>> "$STDERR_LOG" &
        else
            sudo -u "$USER" $CMD >> "$STDOUT_LOG" 2>> "$STDERR_LOG" &
        fi
        echo $! > "$PID_FILE"
        if ! is_running; then
            echo "Unable to start, see $stdout_log and $stderr_log"
            exit 1
        fi
    fi
    ;;
    stop)
    if is_running; then
        echo -n "Stopping $NAME.."
        kill `get_pid`
        for i in {1..10}
        do
            if ! is_running; then
                break
            fi

            echo -n "."
            sleep 1
        done
        echo

        if is_running; then
            echo "Not stopped; may still be shutting down or shutdown may have failed"
            exit 1
        else
            echo "Stopped"
            if [ -f "$PID_FILE" ]; then
                rm "$PID_FILE"
            fi
        fi
    else
        echo "Not running"
    fi
    ;;
    restart)
    $0 stop
    if is_running; then
        echo "Unable to stop, will not attempt to start"
        exit 1
    fi
    $0 start
    ;;
    status)
    if is_running; then
        echo "Running"
    else
        echo "Stopped"
        exit 1
    fi
    ;;
    *)
    echo "Usage: $0 {start|stop|restart|status}"
    exit 1
    ;;
esac

exit 0

EOF

echo "-----------------"
echo "Placing daemon..."
echo "-----------------\n\n"

sudo chmod a+x jupyterhubdaemon
sudo mv jupyterhubdaemon /etc/init.d/jupyterhub

echo "--------------------------"
echo "Setting up for start-up..."
echo "--------------------------\n\n"

# Set jupyterhub to start at startup
sudo update-rc.d jupyterhub defaults

echo "-------------------------------------------"
echo "Starting Jupyterhub service on port $JUPYTER_PORT..."
echo "-------------------------------------------\n\n"

sudo service jupyterhub start

echo "\nAll done. Enjoy your Jupyterhub installation!\n"
