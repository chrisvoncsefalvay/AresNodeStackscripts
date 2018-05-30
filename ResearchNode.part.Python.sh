#!/bin/bash

# ResearchNode installer
#
# Python packages subroutine
#
#
# Sourcing script:
#
#		curl https://github.com | sudo bash -
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