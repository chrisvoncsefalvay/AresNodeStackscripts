#!/bin/bash


# ResearchNode installer
#
# PART 03
# R AND RELATED ITEMS
#
# Linode embedding ID:    000000
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

echo "Loaded subsidiary resource RN03.PYTHON.000000"

# _retry
# ------
# Retries a certain command. Designed to deal with flaky PPAs.
#
_retry() {
    if "$@"; then
        return 0
    fi
    for wait_time in 5 20 30 60; do
        echo "Command failed, retrying in ${wait_time} ..."
        sleep ${wait_time}
        if "$@"; then
            return 0
        fi
    done
    echo "Failed all retries!"
    exit 1
}

# _retry %end%


# _install_Rpkg
# -------------
# Installs packages using littler. Depends on the `install.r` script, which it loads.
#
_install_Rpkg() {
	if [ $(find /tmp --name install.r | wc -l) -eq 0 ]; then
		cat << EOM > /tmp/install.r
#!/usr/bin/env r
if (is.null(argv) | length(argv)<1) {
  cat("Usage: installr.r pkg1 [pkg2 pkg3 ...]\n")
  q()
}
repos <- "http://cran.rstudio.com"
lib.loc <- "/usr/local/lib/R/site-library"
install.packages(argv, lib.loc, repos)
EOM
	fi
	
	r /tmp/install.r $@
}

# _install_Rpkg %end%


# rn03_install_R
# --------------
# Installs R and dependencies.

rn03_install_R () {
	echo "---------------"
	echo "Installing R..."
	echo "---------------"
	
	sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9

	sudo add-apt-repository -y 'deb http://cran.rstudio.com/bin/linux/ubuntu xenial/'
	sudo add-apt-repository -y "ppa:marutter/rrutter"
    sudo add-apt-repository -y "ppa:marutter/c2d4u"
	sudo apt-get update
	sudo apt-get install -y r-base r-base-dev r-cran-littler
}

# rn03_install_R %end%


# rn02_install_barebones
# ----------------------
# Installs the most essential python packages.

rn02_install_barebones () {
	echo "-----------------------------------"
	echo "Installing basic Python packages..."
	echo "-----------------------------------"

	sudo pip3 install Cython requests BeautifulSoup4 scrapy
	sudo pip3 install scipy numpy pandas matplotlib
}

# rn02_install_barebones %end%


# rn02_selective_domain_installer
# -------------------------------
# Installs python packages dependent on a domain selection string.
#		
# @param $1: domain selection string, comma separated
#
# The currently registered domains are:
# - MachineLearning
# - GeneralScience
# - NLP
# - NLPCorpora
# - Bioinformatics
# - GIS
# - DataVisualisation

rn02_selective_domain_installer () {
	echo "---------------------------------------------"
	echo "Installing domain specific python packages..."
	echo "---------------------------------------------"

	IFS=',' read -ra DOMAINS <<< "$1"
	for i in "${DOMAINS[@]}"; do	
		echo "***** Installing domain ${i}"
		rn02_install_domain_${i}
	done
}

# rn02_selective_domain_installer %end%


# rn02_install_domain_GeneralScience
# ----------------------------------
# Installs general scientific packages

rn02_install_domain_GeneralScience () {
	sudo pip3 install deap NetworkX simpy mesa BayesPy
	sudo pip3 install statsmodels cubes PyMC PyMix 
	sudo pip3 install scikit-learn scikit-dataaccess scikit-datasets 
	sudo pip3 install scikit-metrics scikit-neuralnetwork
}

# rn02_install_domain_GeneralScience %end%


# rn02_install_domain_MachineLearning
# -----------------------------------
# Installs ML and deep learning packages

rn02_install_domain_MachineLearning () {
	sudo pip3 install scikit-learn scikit-neuralnetwork
	sudo pip3 install tensorflow
	sudo pip3 install http://download.pytorch.org/whl/cpu/torch-0.4.0-cp35-cp35m-linux_x86_64.whl 
	sudo pip3 install torchvision
	sudo pip3 install keras	
	sudo pip3 install yellowbrick livelossplot
}

# rn02_install_domain_MachineLearning %end%


# rn02_install_domain_NLP
# -----------------------
# Installs natural language programming packages

rn02_install_domain_NLP () {
	sudo pip3 install nltk textblob nalaf spacy gensim
	sudo pip3 install markovify 
}

# rn02_install_domain_NLP %end%


# rn02_install_domain_NLPCorpora
# ------------------------------
# Installs NLP corpora

rn02_install_domain_NLPCorpora () {
	sudo python3 -m nalaf.download_data
	sudo python3 -m nltk.downloader -d /usr/local/share/nltk_data all 
	sudo python3 -m spacy download en_core_web_sm
}

# rn02_install_domain_NLPCorpora %end%


# rn02_install_domain_Bioinformatics
# ----------------------------------
# Installs bioinformatics packages

rn02_install_domain_Bioinformatics () {
  sudo pip3 install biopython 
  sudo pip3 install scikit-bio
  sudo pip3 install boyle clintrials dicom-numpy dicompyler dinopy epipylib 
  sudo pip3 install fhir hl7 hl7parser PyMedTermino metapub pubmed bioscraping pubmed-lookup pubMunch3 pubmedasync
  sudo pip3 install medgen-prime pygrowup 
  sudo pip3 install ncbi-acc-download ncbi-genome-download genomepy ncbi Geeneus multifastadb 
}

# rn02_install_domain_Bioinformatics %end%


# rn02_install_domain_GIS
# -----------------------
# Installs GIS packages

rn02_install_domain_GIS () {
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

# rn02_install_domain_GIS %end%


# rn02_install_domain_DataVisualisation
# -------------------------------------
# Installs data visualisation packages

rn02_install_domain_DataVisualisation () {
	sudo pip3 install graphviz ggplot seaborn bokeh scikit-image scikit-plot Pillow
	sudo pip3 install matplotlib-venn SeqFindr features iplotter colouringmap jupyterd3 ipython-d3-sankey
}

# rn02_install_domain_DataVisualisation %end%
