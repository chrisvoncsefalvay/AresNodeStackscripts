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

# <UDF name="COUNTRY" label="RSA key attribute: Country" default="US" />
# <UDF name="STATE" label="RSA key attribute: State" default="IL" />
# <UDF name="LOCALITY" label="RSA key attribute: Locality" default="Chicago" />
# <UDF name="ORG" label="RSA key attribute: Organisation name" default="Your organisation name" />
# <UDF name="COMMONNAME" label="RSA key attribute: Key common name" default="Jupyterhub key" />
# <UDF name="JUPYTER_PORT" label"JupyterHub port" default=8888 />

# Install Anaconda
wget https://repo.anaconda.com/archive/Anaconda3-5.1.0-Linux-x86_64.sh
bash Anaconda3-5.1.0-Linux-x86_64.sh -b -p $HOME/conda
export PATH="$HOME/conda/bin:$PATH"
echo 'source $HOME/conda/bin/activate' > ~/.bashrc
source .bashrc

# Install dependencies
sudo apt-get install -y python3-pip
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo apt-get install -y nodejs-legacy
sudo apt-get install -y npm nodejs-legacy
npm install -g configurable-http-proxy
pip3 install jupyterhub
pip3 install --upgrade notebook

# Generate SSL key
openssl req -x509 -nodes -days 365 -newkey rsa:1024 -keyout server.key -out server.pem -passin pass:$JUPYTERPASS -subj "/C=$COUNTRY/ST=$STATE/O=$ORG/L=$LOCALITY/CN=$COMMONNAME"
chmod 400 server.key
chmod 400 server.pem
sudo mkdir /srv/jupyterhub
cp server.* /srv/jupyterhub/

# Generate jupyter config
sudo mkdir /etc/jupyterhub
cd /etc/jupyterhub
jupyterhub --generate-config

# Install the usual pythonic stuff
pip3 install scipy numpy pandas matplotlib
pip3 install simpy seaborn epipy mesa requests
pip3 install bokeh scikit-image gensim nltk statsmodels scrapy
pip3 install biopython cubes deap NetworkX scikit-learn Pillow
pip3 install BeautifulSoup4 cartopy GDAL geojson ggplot graphviz 

# Run jupyterhub
sudo jupyterhub --ip 0.0.0.0 --port $JUPYTER_PORT 
