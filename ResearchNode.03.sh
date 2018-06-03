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



# rn03_selective_domain_installer
# -------------------------------
# Installs R packages dependent on a domain selection string.
#		
# @param $1: domain selection string, comma separated
#
# The currently registered domains are:
# - Core
# - General
# - ReproducibleResearch
# - StatisticalMethods
# - SocialNetworkAnalysis
# -	Epidemiology
# - ClinicalTrials
# - Plotting
# - Spatial
# - ExportImport
# - TextMining
# - BayesianInference
# - MachineLearning
# - TimeSeries

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


# rn03_install_domain_Core
# ------------------------

rn03_install_domain_Core () {
	# Essential deps
	_install_Rpkg magrittr data.table dplyr reshape stringr curl
}

# rn03_install_domain_Core



# rn03_install_domain_General
# ---------------------------

rn03_install_domain_General () {
	# Essential deps
	_install_Rpkg Rcpp magrittr
	# Tools for programming and testing
	_install_Rpkg testthat foreach doMC 
	# Basic data wrangling and transforms
	_install_Rpkg data.table dplyr plyr reshape lubridate stringr forecast nlme sqldf purrr tidyr validate
	# Basic HTTP
	_install_Rpkg digest curl httpr 
}

# rn03_install_domain_General %end%



# rn03_install_domain_ReproducibleResearch
# ----------------------------------------

rn03_install_domain_ReproducibleResearch () {
	sudo apt-get install -y texlive-full texlive-xetex 
	_install_Rpkg rmarkdown knitr xtable brew ztable knitLatex bibtex RefManageR formattable rapport pander
}

# rn03_install_domain_ReproducibleResearch %end%


# rn03_install_domain_StatisticalMethods
# --------------------------------------

rn03_install_domain_StatisticalMethods () {
	# ABM
	_install_Rpkg RNetLogo EpiModel
	# Missing data
	_install_Rpkg Amelia
	# Model selections
	_install_Rpkg MASS 
	# Matching and demographics
	_install_Rpkg demography
	# Misc functions and models
	_install_Rpkg spatial nnet Zelig 
	# Regression models
	_install_Rpkg nlme lme4 lmeSplines MCMCglmm gmcv class Hmisc car caret mlbench xgboost glmnet gbm arules tree mboost ROCR
}

# rn03_install_domain_StatisticalMethods %end%


# rn03_install_domain_SocialNetworkAnalysis
# -----------------------------------------

rn03_install_domain_SocialNetworkAnalysis () {
	_install_Rpkg sna network
	_install_Rpkg instaR Rfacebook twitteR streamR graphTweets
}

# rn03_install_domain_SocialNetworkAnalysis %end%



# rn03_install_domain_Epidemiology
# --------------------------------

rn03_install_domain_Epidemiology () {
	# Basic epi
	_install_Rpkg Epi epitools epiR pubh prevalence EpiModel IDSpatialStats 
	# Meta-analyses 
	_install_Rpkg metasens meta metafor rmeta psychmeta ratesci netmeta 
	# Meta-analysis plots
	_install_Rpkg forestplot metaplotr MetaAnalyser metaviz
	# Survival
	_install_Rpkg survival rms condSURV interval vitality rankhazard
	# Drug side effects 
	_install_Rpkg MHTrajectoryR openEBGM vaersvax vaersNDvax PhViD 
}

# rn03_install_domain_Epidemiology %end%



# rn03_install_domain_ClinicalTrials
# ----------------------------------

rn03_install_domain_ClinicalTrials () {
	# Trial analysis
	_install_Rpkg clinfun CRM clinsig speff2trial ThreeGroups epibasix
	# Experimental design
	_install_Rpkg OptimalDesign FrF2 ThreeArmedTrials DoseFinding TrialSize blockrand CRTSize experiment sensoMineR
}

# rn03_install_domain_ClinicalTrials %end%


# rn03_install_domain_Plotting
# ----------------------------

rn03_install_domain_Plotting () {
	_install_Rpkg RColorBrewer scales colorspace corrplot animation lattice
	# GGverse
	_install_Rpkg ggplot2 ggthemes ggpubr ggQC ggedit ggforce ggalt ggrepel ggraph geomnet ggExtra ggfortify gganimate ggspectra ggseas ggsci ggmosaic survminer ggridges qqplotr  ggalluvial ggdag 
	_install_Rpkgit sachsmc plotROC
	_install_Rpkgit ricardio-bion ggradar
	_install_Rpkgit Ather-Energy ggTimeSeries
	# non-GGverse
	_install_Rpkg plotrix hexbin vcd scatterplot3d misc3d biclust seriation gclus onion RCircos
	_install_Rpkgit thomasp85 patchwork
	# Devices, colours, interactivity
	_install_Rpkg RSvgDevice cairoDevice
}

# rn03_install_domain_Plotting %end%



# rn03_install_domain_Spatial
# ---------------------------

rn03_install_domain_Spatial () {
	_install_Rpkg raster rasterVis spatial.tools micromap statebins spacetime UScensus2000cdp UScensus2000tract rworldmap rworldxtra cshapes gdalUtils rgdal rgeos maps mapdata mapproj shapefiles spatstat geonames OpenStreetMap osmar rpostgis RgoogleMaps ggmap plotKML leafletR spatial spatgraphs spatialsegregation
	# Geostatistics
	_install_Rpkg gstat automap geoR geoRglm intamap vardiag SpatialExtremes spTimer gear
	# Geoepidemiology
	_install_Rpkg DCluster SpatialEpi diseasemapping OasisR CARBayes spaMM geospacom spatsurv spselect
	# Spatiotemporal
	_install_Rpkg googleVis plm spacetime surveillance stppResid SpatioTemporal adehabitatLT splancs stam pastecs nlme lme4 spBayes tripEstimation crawl move 
	# Geolocation
	_install_Rpkg rgeolocate geoparser
}

# rn03_install_domain_Spatial %end%




# rn03_install_domain_ExportImport
# --------------------------------

rn03_install_domain_ExportImport () {
	_install_Rpkg foreign readr readxl RODBC googlesheets rio datapasta jsonlite XML rvest officeR
	_install_Rpkgit timelyportfolio listviewer
	_install_Rpkgit rstudio DT
}

# rn03_install_domain_ExportImport %end%



# rn03_install_domain_TextMining
# ------------------------------

rn03_install_domain_TextMining () {
	_install_Rpkg tm tau tm.plugin.mail tm.plugin.factiva tm.plugin.europresse tidytext wordnet Rstem stringi stringdist languageR zipfR maxent wordcloud hunspell phonics tesseract tokenizers lsa topicmodels lda stm kernlab skmeans RTextTools textrank text2vec qdap gutenbergr
}

# rn03_install_domain_TextMining %end%


# rn03_install_domain_BayesianInference
# -------------------------------------

rn03_install_domain_BayesianInference () {
	_install_Rpkg arm BACCO bayesm bayesSurv DPpackage MCMCpack nimble openEBGM bayesImageS BayesTree BAYSTAR bbemkr bclust deal catnet eigenmodel ggmcmc simpleTable LearnBayes
}

# rn03_install_domain_BayesianInference %end%



# rn03_install_domain_MachineLearning
# -----------------------------------

rn03_install_domain_MachineLearning () {
	_install_Rpkg mice rpart caret nnet e1071
	# Neural nets & Deep Learning
	_install_Rpkg rnn deepnet RcppDL tensorflow RSNNS
	# Random forests
	_install_Rpkg randomForest quantregForest
	# Bayesianism & association rules
	_install_Rpkg openEBGM tgp BayesTree BART bartMachine
	# GenAlgs
	_install_Rpkg rgenoud
	# ESLR companion package
	_install_Rpkg ElemStatLearn
	# ML visualisation
	_install_Rpkg effects pdp plotmo ggRandomForest
	
}

# rn03_install_domain_MachineLearning %end%



# rn03_install_domain_TimeSeries
# ------------------------------

rn03_install_domain_TimeSeries () {
	_install_Rmpkg xts zoo forecast ggseas fanplot
	# Date and time classes
	_install_Rpkg chron tsibble tibbletime TimeProjection 
	# Basic models
	_install_Rpkg prophet forecTheta fitARMA tseries pear fracdiff TSA tsoutliers strucchange trend changepoint funtimes scoringRules sweep timsac 
	# Spectral density estimation
	_install_Rpkg bspec quantspec lomb spectral multitaper kza 
	# Wavelets and Fourier harmonics
	_install_Rpkg wavelets WaveletComp waveslim
	# Filtering, decomposition and SSA
	_install_Rpkg robfilter sleekts ArDec tsdecomp spectral.methods Rlibeemd mFilter
	# Seasonality
	_install_Rpkg seasonal season bfast seas deseasonalize
	# Stationarity, Engle-Granger etc.
	_install_Rpkg CommonTrend tsDyn urca LSTS wavethresh locits
	# Nonlinear, dynamic and mvar models
	_install_Rpkg tseriesChaos tsDyn nnfor fractal ntls dse dlm dyn dlnm tpr orderedLasso sparsevar MTS ecm dlmodeler freqdom Tides tiger
	# Time series cohorts
	_install_Rpkg TSdist TSrepr jmotif rucrdtw TSclust thief
}

# rn03_install_domain_TimeSeries %end%
