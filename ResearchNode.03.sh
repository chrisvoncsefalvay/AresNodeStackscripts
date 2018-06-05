#!/bin/bash

# ResearchNode installer
#
# PART 03
# R AND RELATED ITEMS
#
# Linode embedding ID:    317343
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

echo "Loaded subsidiary resource RN03.RPACKAGES.317343"

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
	fi
	
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
	
	sudo apt-get install -y r-base r-base-dev r-cran-littler
	_install_Rpkg docopt remotes devtools 
	
	if [ ${SHINY_VER} != "None" ]; then
		echo "---------------------------------"
		echo "Installing Shiny Server ${SHINY_VER}..."
		echo "---------------------------------"

		_install_Rpkg shiny

		sudo wget https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-${SHINY_VER}-amd64.deb -O /tmp/shiny-${SHINY_VER}-amd64.deb
		
		sudo gdebi -n /tmp/shiny-${SHINY_VER}-amd64.deb
		sudo rm /tmp/shiny-${SHINY_VER}-amd64.deb
	fi
}

rn03_install_R

# rn03_install_R %end%


# rn03_install_core_r_packages
# ----------------------------
# Installs core R packages.

rn03_install_core_r_packages () {
	_install_Rpkg magrittr data.table dplyr reshape stringr curl Rcpp packrat
	_install_Rpkg testthat foreach purrr digest httpr
	sudo apt-get install -y texlive-full texlive-xetex 
	_install_Rpkg rmarkdown knitr
	_install_Rpkg Hmisc MASS nnet RNetLogo EpiModel
	_install_Rpkg RColorBrewer ggplot2 ggthemes ggExtra gganimate scales 
	_install_Rpkg xts zoo forecast
}

# rn03_install_core_r_packages %end%

