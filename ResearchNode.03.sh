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
# @param $@	packages to install
#
_install_Rpkg() {
	if [ $(find /tmp --name install.r | wc -l) -eq 0 ]; then
		cat << EOM > /tmp/install.r
#!/usr/bin/env r
if (is.null(argv) | length(argv)<1) {
  cat("Usage: install.r pkg1 [pkg2 pkg3 ...]\n")
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

# _install_Rpkgit
# ---------------
# Installs a single package from github. Specify package as username and repo. For example,
#
#		_install_Rpkgit chrisvoncsefalvay testrepo
#
# will install from github.com/chrisvoncsefalvay/testrepo.git
#
# To install a particular subdirectory, reference or pull, add these to the repo. For example,
#
#	_install_Rpkgit chrisvoncsefalvay testrepo/src#4
#
# installs pull request #4 of the folder /src in the repo, and
#
#	_install_Rpkgit chrisvoncsefalvay testrepo@f3ab23f
#
# installs commit ref f3ab23f of the repo. Note that you *cannot* combine # and @, i.e. you cannot specify both a reference AND a PR.
#
# To get a particular branch, add a third argument:
#
#	_install_Rpkgit chrisvoncsefalvay testrepo devel
#
# gets you the `devel` branch of `testrepo`.
#
# @param $1	Github username
# @param $2	repository name and params
# @param $3 (optional) token if installing from private repo

_install_Rpkgit () {

	if [ $(find /tmp --name github.r | wc -l) -eq 0 ]; then
		cat << EOM > /tmp/github.r
#!/usr/bin/env r

library(devtools)

devtools::install_github(paste(argv[1], argv[2], sep="/"))

EOM

	r /tmp/github.r $1/$2
}

# _install_Rpkgit %end%


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
	_install_Rpkg docopt remotes devtools
}

# rn03_install_R %end%


# rn03_selective_domain_installer
# -------------------------------
# Installs R packages dependent on a domain selection string.
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

rn03_selective_domain_installer () {
	echo "----------------------------------------"
	echo "Installing domain specific R packages..."
	echo "----------------------------------------"

	IFS=',' read -ra DOMAINS <<< "$1"
	for i in "${DOMAINS[@]}"; do	
		echo "***** Installing domain ${i}"
		rn03_install_domain_${i}
	done
}

# rn03_selective_domain_installer %end%



# rn03_install_domain_general
# ---------------------------

rn03_install_domain_general(){

}
# rn03_install_domain_general %end%



# rn03_install_domain_General
# ---------------------------

rn03_install_domain_General(){
	# Essential deps
	_install_Rpkg Rcpp magrittr devtools 
	# Tools for programming and testing
	_install_Rpkg testthat
	# Basic data wrangling and transforms
	_install_Rpkg data.table dplyr plyr reshape lubridate stringr forecast nlme sqldf purrr tidyr validate
	# Basic HTTP
	_install_Rpkg digest curl httpr 
}

# rn03_install_domain_General %end%



# rn03_install_domain_Reporting
# -----------------------------

rn03_install_domain_Reporting(){
	sudo apt-get install -y texlive-full texlive-xetex ttf-mscorefonts-installer 
	_install_Rpkg rmarkdown knitr xtable 
}
# rn03_install_domain_Reporting %end%



# rn03_install_domain_Biomedical
# ------------------------------

rn03_install_domain_Biomedical(){

}
# rn03_install_domain_Biomedical %end%



# rn03_install_domain_Plotting
# ----------------------------

rn03_install_domain_Plotting(){
	_install_Rpkg RColorBrewer ggplot2 ggthemes ggpubr scales colorspace corrplot 
	_install_Rpkgit thomasp85 patchwork
}
# rn03_install_domain_Plotting %end%



# rn03_install_domain_Cartography
# -------------------------------

rn03_install_domain_Cartography(){

}
# rn03_install_domain_Cartography %end%




# rn03_install_domain_ExportImport
# --------------------------------

rn03_install_domain_ExportImport(){
	_install_Rpkg foreign readr readxl RODBC googlesheets rio datapasta jsonlite XML rvest officeR
	_install_Rpkgit timelyportfolio listviewer
	_install_Rpkgit rstudio DT
}
# rn03_install_domain_ExportImport %end%




# rn03_install_domain_StatisticsAndRegression
# -------------------------------------------

rn03_install_domain_StatisticsAndRegression(){
	_install_Rpkg class RWeka PerformanceAnalytics Hmisc car caret mlbench Boruta DAAG xgboost
}
# rn03_install_domain_StatisticsAndRegression %end%



# rn03_install_domain_TextMining
# ------------------------------

rn03_install_domain_TextMining(){
	_install_Rpkg tm
}
# rn03_install_domain_TextMining %end%


# rn03_install_domain_MachineLearning
# -----------------------------------

rn03_install_domain_MachineLearning(){

}
# rn03_install_domain_MachineLearning %end%



# rn03_install_domain_TimeSeries
# ------------------------------

rn03_install_domain_TimeSeries(){
	_install_Rpkg xts zoo
}
# rn03_install_domain_TimeSeries %end%
