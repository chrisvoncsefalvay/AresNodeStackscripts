#!/bin/bash

# ResearchNode installer
#
# Python packages subroutine
#
#
# Sourcing script:
#
#		curl https://raw.githubusercontent.com/chrisvoncsefalvay/stackscripts/master/ResearchNode.part.Python.sh | sudo bash -
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

install_python3 () {
	echo "----------------------------"
	echo "Installing Python and pip..."
	echo "----------------------------"

	sudo apt-get install -y python python-pip python3 python3-pip python3 libpython3-all-dev
	sudo apt-get install -y g++

	sudo wget https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py
	sudo python3 /tmp/get-pip.py

	sudo pip3 install --upgrade pip setuptools
	sudo pip3 install virtualenv virtualenvwrapper
}

install_barebones () {
	echo "-----------------------------------"
	echo "Installing basic Python packages..."
	echo "-----------------------------------"

	sudo pip3 install Cython requests BeautifulSoup4 scrapy
}

install_general () {
	echo "------------------------------------------------"
	echo "Installing general scientific Python packages..."
	echo "------------------------------------------------"

	sudo pip3 install scipy numpy pandas matplotlib
	sudo pip3 install deap NetworkX simpy epipy mesa 
	sudo pip3 install gensim statsmodels cubes PyMC PyMix BayesPy 
	sudo pip3 install scikit-learn scikit-dataaccess scikit-datasets 
	sudo pip3 install scikit-metrics scikit-neuralnetwork
}

install_dataviz () {
	echo "--------------------------------------"
	echo "Installing Python graphing packages..."
	echo "--------------------------------------"

	sudo pip3 install graphviz ggplot seaborn bokeh scikit-image scikit-plot Pillow
}


install_nlp () {
	echo "--------------------------------------------------"
	echo "Installing natural language processing packages..."
	echo "--------------------------------------------------"

	sudo pip3 install nltk textblob nalaf spacy
}

install_corpora () {
	echo "-------------------------"
	echo "Installing NLP corpora..."
	echo "-------------------------"

	sudo python3 -m nalaf.download_data
	sudo python3 -m nltk.downloader -d /usr/local/share/nltk_data all 
	sudo python3 -m spacy download en_core_web_sm
}

install_ML () {
	echo "----------------------------"
	echo "Installing ML/DL packages..."
	echo "----------------------------"

	sudo pip3 install scikit-learn scikit-neuralnetwork yellowbrick
	sudo pip3 install tensorflow
	sudo pip3 install http://download.pytorch.org/whl/cpu/torch-0.4.0-cp35-cp35m-linux_x86_64.whl 
	sudo pip3 install torchvision
	sudo pip3 install keras	
}

install_cartotools () {
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
}

install_bioinformatics () {
  echo "------------------------------------"
  echo "Installing bioinformatics toolkit..."
  echo "------------------------------------"

  sudo pip3 install biopython 
  sudo pip3 install scikit-bio
}