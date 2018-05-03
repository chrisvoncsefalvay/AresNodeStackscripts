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
echo "****************************************************"
echo "This will take you through the installation of Jupyterhub."
echo ""
echo "Your component settings are:"
echo "OpenCV: $OPENCV"
echo "Cartography tools: $CARTOTOOLS"
echo "Deep learning tools: $DEEPLEARNING"


if [ $BAREBONES = "yes" ] 
then
	echo "This is a barebones install, so it'll be pretty quick."
fi

echo ""

echo "----------------------"
echo "Installing Anaconda..."
echo "----------------------"

# Install Anaconda
sudo apt-get install -y wget 
wget https://repo.anaconda.com/archive/Anaconda3-5.1.0-Linux-x86_64.sh
bash Anaconda3-5.1.0-Linux-x86_64.sh -b -p $HOME/conda
export PATH="$HOME/conda/bin:$PATH"
echo 'source $HOME/conda/bin/activate' > ~/.bashrc
source .bashrc

echo "-----------------------------"
echo "Installing Python and deps..."
echo "-----------------------------"

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
sudo pip3 install jupyterhub
sudo pip3 install --upgrade notebook

# Generate jupyter config
echo "------------------------------------"
echo "Generating JupyterHub config file..."
echo "------------------------------------"
sudo mkdir /etc/jupyterhub
sudo cd /etc/jupyterhub
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

PATH=/sbin:/usr/sbin:/bin:/usr/bin:/usr/local/bin
DESC="Multi-user server for Jupyter notebooks"
DAEMON=/usr/local/bin/jupyterhub
DAEMON_ARGS="--config=/etc/jupyterhub/jupyterhub_config.py"
PIDFILE=/var/run/$NAME.pid
SCRIPTNAME=/etc/init.d/$NAME

# Exit if the package is not installed
[ -x "$DAEMON" ] || exit 0

# Read configuration variable file if it is present
[ -r /etc/default/$NAME ] && . /etc/default/$NAME

# Load the VERBOSE setting and other rcS variables
. /lib/init/vars.sh

# Define LSB log_* functions.
# Depend on lsb-base (>= 3.2-14) to ensure that this file is present
# and status_of_proc is working.
. /lib/lsb/init-functions

#
# Function that starts the daemon/service
#
do_start()
{
	# Return
	#   0 if daemon has been started
	#   1 if daemon was already running
	#   2 if daemon could not be started
	start-stop-daemon --start --quiet --pidfile $PIDFILE --exec $DAEMON --test > /dev/null \
		|| return 1
	start-stop-daemon --start --background --make-pidfile --quiet --pidfile $PIDFILE --exec $DAEMON -- \
		$DAEMON_ARGS \
		|| return 2
	# Add code here, if necessary, that waits for the process to be ready
	# to handle requests from services started subsequently which depend
	# on this one.  As a last resort, sleep for some time.
}

#
# Function that stops the daemon/service
#
do_stop()
{
	# Return
	#   0 if daemon has been stopped
	#   1 if daemon was already stopped
	#   2 if daemon could not be stopped
	#   other if a failure occurred
	start-stop-daemon --stop --quiet --retry=TERM/30/KILL/5 --pidfile $PIDFILE --name $NAME
	RETVAL="$?"
	[ "$RETVAL" = 2 ] && return 2
	# Wait for children to finish too if this is a daemon that forks
	# and if the daemon is only ever run from this initscript.
	# If the above conditions are not satisfied then add some other code
	# that waits for the process to drop all resources that could be
	# needed by services started subsequently.  A last resort is to
	# sleep for some time.
	start-stop-daemon --stop --quiet --oknodo --retry=0/30/KILL/5 --exec $DAEMON
	[ "$?" = 2 ] && return 2
	# Many daemons don't delete their pidfiles when they exit.
	rm -f $PIDFILE
	return "$RETVAL"
}

#
# Function that sends a SIGHUP to the daemon/service
#
do_reload() {
	#
	# If the daemon can reload its configuration without
	# restarting (for example, when it is sent a SIGHUP),
	# then implement that here.
	#
	start-stop-daemon --stop --signal 1 --quiet --pidfile $PIDFILE --name $NAME
	return 0
}

case "$1" in
  start)
	[ "$VERBOSE" != no ] && log_daemon_msg "Starting $DESC" "$NAME"
	do_start
	case "$?" in
		0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
		2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
	esac
	;;
  stop)
	[ "$VERBOSE" != no ] && log_daemon_msg "Stopping $DESC" "$NAME"
	do_stop
	case "$?" in
		0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
		2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
	esac
	;;
  status)
	status_of_proc "$DAEMON" "$NAME" && exit 0 || exit $?
	;;
  #reload|force-reload)
	#
	# If do_reload() is not implemented then leave this commented out
	# and leave 'force-reload' as an alias for 'restart'.
	#
	#log_daemon_msg "Reloading $DESC" "$NAME"
	#do_reload
	#log_end_msg $?
	#;;
  restart|force-reload)
	#
	# If the "reload" option is implemented then remove the
	# 'force-reload' alias
	#
	log_daemon_msg "Restarting $DESC" "$NAME"
	do_stop
	case "$?" in
	  0|1)
		do_start
		case "$?" in
			0) log_end_msg 0 ;;
			1) log_end_msg 1 ;; # Old process is still running
			*) log_end_msg 1 ;; # Failed to start
		esac
		;;
	  *)
		# Failed to stop
		log_end_msg 1
		;;
	esac
	;;
  *)
	#echo "Usage: $SCRIPTNAME {start|stop|restart|reload|force-reload}" >&2
	echo "Usage: $SCRIPTNAME {start|stop|status|restart|force-reload}" >&2
	exit 3
	;;
esac
:
EOF

echo "-----------------"
echo "Placing daemon..."
echo "-----------------"

sudo mv jupyterhubdaemon /etc/init.d/jupyterhub
sudo chmod +x /etc/init.d/jupyterhub

echo "--------------------------"
echo "Setting up for start-up..."
echo "--------------------------"

# Set jupyterhub to start at startup
sudo update-rc.d jupyterhub defaults

echo "-------------------------------------------"
echo "Starting Jupyterhub service on port $JUPYTER_PORT..."
echo "-------------------------------------------"

sudo service jupyterhub start

echo "\nAll done. Enjoy your Jupyterhub installation!"
