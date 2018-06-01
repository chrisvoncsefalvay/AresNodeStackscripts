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

echo "Loaded subsidiary resource RN03.RPACKAGES.000000"

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



# rn03_install_domain_General
# ---------------------------

rn03_install_domain_General () {
	# Essential deps
	_install_Rpkg Rcpp magrittr
	# Tools for programming and testing
	_install_Rpkg testthat foreach doMC SOAR Matrix 
	# Basic data wrangling and transforms
	_install_Rpkg data.table dplyr plyr reshape lubridate stringr forecast nlme sqldf purrr tidyr validate
	# Basic HTTP
	_install_Rpkg digest curl httpr 
}

# rn03_install_domain_General %end%



# rn03_install_domain_ReproducibleResearch
# ----------------------------------------

rn03_install_domain_ReproducibleResearch () {
	sudo apt-get install -y texlive-full texlive-xetex ttf-mscorefonts-installer 
	_install_Rpkg rmarkdown knitr xtable lazyWeave brew papeR ztable knitLatex tikzDevice animation texreg bibtex RefManageR latex2exp formattable rapport pander tufterhandout sparktex reporttools humanformat prettyunits
}

# rn03_install_domain_ReproducibleResearch %end%


# rn03_install_domain_StatisticalMethods
# --------------------------------------

rn03_install_domain_StatisticalMethods () {
	# ABM
	_install_Rpkg RNetLogo SpaDES EpiModel spartan
	# Missing data
	_install_Rpkg mi Amelia mitools VIM
	# Model selections
	_install_Rpkg MASS leaps 
	# Matching and demographics
	_install_Rpkg PSAgraphics arm optmatch demography
	# Misc functions and models
	_install_Rpkg spatial nnet Zelig rms Hmisc
	# Regression models
	_install_Rpkg brglm logistf exactLoglinTest vcd gnm catspec betareg nlstools nlme lme4 lmeSplines MCMCglmm gee gmcv locfit np sm acepack quantreg biglm lmtest perturb effects visreg class RWeka PerformanceAnalytics Hmisc car caret mlbench Boruta DAAG xgboost glmnet ORCR gbm arules tree mboost ROCR lars earth CORElearn
}

# rn03_install_domain_StatisticalMethods %end%


# rn03_install_domain_SocialNetworkAnalysis
# -----------------------------------------

rn03_install_domain_SocialNetworkAnalysis () 
	_install_Rpkg sna network latentnet ergm statnet RSiena multiplex tsna NetData2
	_install_Rpkg instaR Rfacebook twitteR streamR graphTweets
}

# rn03_install_domain_SocialNetworkAnalysis %end%



# rn03_install_domain_Epidemiology
# --------------------------------

rn03_install_domain_Epidemiology () {
	# Basic epi
	_install_Rpkg Epi epitools epiR pubh prevalence landsepi episensr epibasix cmprsk EpiModel IDSpatialStats 
	# Meta-analyses 
	_install_Rpkg metasens meta metafor rmeta psychmeta metagear revtools metavcov epiR ratesci ipdmeta ecoreg surrosurv netmeta 
	# Meta-analysis plots
	_install_Rpkg forestmodel forestplot metaplotr MetaAnalyser metaviz
	# Pop genetics
	_install_Rpkg genetics rmetasim LDheatmap HardyWeinberg Biodem
	# Survival
	_install_Rpkg survival rms prodlim eha NADA NestedCohort survPresmooth landest tranSurv condSURV MLEcens dblcens interval fitdistrplus vitality muhaz ICE bshazard maxstat Survgini controlTest clinfuntimereg dynamichazard smcure pch isoph dynsurv gof CPE smoothHR rankhazard
	# Drug side effects 
	_install_Rpkg MHTrajectoryR WCE discreteMTP openEBGM adepro vaersvax vaersNDvax PhViD 
}

# rn03_install_domain_Epidemiology %end%



# rn03_install_domain_ClinicalTrials
# ----------------------------------

rn03_install_domain_ClinicalTrials () {
	# Trial analysis
	_install_Rpkg seqmon PIPS PowerTOST clinfun CRM dfpk dfped clinsig speff2trial ThreeGroups epibasix multcomp survival
	# Experimental design
	_install_Rpkg AlgDesign skpr OptimalDesign LDOD planor FrF2 BHH2 ThreeArmedTrials gsDesign DoseFinding TrialSize blockrand CRTSize experiment samplesize binseqtest BOIN designmatch toxtestD sensoMineR bioOED
}

# rn03_install_domain_ClinicalTrials %end%


# rn03_install_domain_Plotting
# ----------------------------

rn03_install_domain_Plotting () {
	_install_Rpkg RColorBrewer scales colorspace corrplot animation lattice
	# GGverse
	_install_Rpkg ggplot2 ggthemes ggpubr ggQC ggedit ggforce ggalt ggrepel ggraph geomnet ggExtra ggfortify gganimate ggspectra ggseas ggsci ggmosaic survminer GGally ggridges qqplotr  ggalluvial ggdag 
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
	_install_Rpkg sf stplanr raster rasterVis spatial.tools micromap recmap statebins spacetime geosphere trip gdistance magclass UScensus2000cdp UScensus2000tract marmap rworldmap rworldxtra cshapes landsat gdalUtils rgdal rgeos wkb maps mapdata mapproj shapefiles spatstat geonames OpenStreetMap osmar rpostgis tmap mapview RgoogleMaps ggmap ggsn plotKML leafletR spatial spatgraphs smacpod ecespa aspace spatialsegregation GriegSmith latticeDensity
	# Geostatistics
	_install_Rpkg gstat automap geoR geoRglm intamap vardiag spsann FRK RandomFields SpatialExtremes spTimer gear
	# Geoepidemiology
	_install_Rpkg DCluster SpatialEpi diseasemapping AMOEBA OasisR spgwr sparr CARBayes spaMM geospacom spatsurv spselect
	# Spatiotemporal
	_install_Rpkg googleVis plm spacetime surveillance stppResid SpatioTemporal adehabitatLT splancs stam pastecs nlme lme4 spBayes tripEstimation crawl move 
	# Geolocation
	_install_Rpkg rgeolocate threewords nominatim geoparser
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
	_install_Rpkg arm BACCO bayesm bayesSurv DPpackage MCMCpack mcmc nimble openEBGM bayesGARCH bayesImageS bayesQR BayesTree BAYSTAR bbemkr bclust deal catnet eigenmodel ggmcmc simpleTable spikeslab LearnBayes
}

# rn03_install_domain_BayesianInference %end%



# rn03_install_domain_MachineLearning
# -----------------------------------

rn03_install_domain_MachineLearning () {
	_install_Rpkg mice rpart party caret nnet e1071 kernLab tree arules RWeka ipred lars ROCR CORElearn 
	# Neural nets & Deep Learning
	_install_Rpkg rnn deepnet RcppDL tensorflow RSNNS
	# Random forests
	_install_Rpkg randomForest quantregForest LogicForest Boruta trtf
	# Bayesianism & association rules
	_install_Rpkg openEBGM tgp BayesTree BART bartMachine 
	# GenAlgs
	_install_Rpkg rgenoud Rmalschains
	# ESLR companion package
	_install_Rpkg ElemStatLearn
	# ML visualisation
	_install_Rpkg effects pdp plotmo ICEbox ggRandomForests
	
}

# rn03_install_domain_MachineLearning %end%



# rn03_install_domain_TimeSeries
# ------------------------------

rn03_install_domain_TimeSeries () {
	_install_Rmpkg xts zoo forecast ggseas ZRA fanplot
	# Date and time classes
	_install_Rpkg chron tsibble tibbletime timetk tsbox TimeProjection 
	# Basic models
	_install_Rpkg prophet forecTheta fitARMA tseries pear fracdiff TSA tsoutliers strucchange trend changepoint funtimes scoringRules sweep timsac 
	# Spectral density estimation
	_install_Rpkg bspec quantspec lomb spectral multitaper kza 
	# Wavelets and Fourier harmonics
	_install_Rpkg wavelets WavbeletComp brainwaver waveslim HarmonicRegression
	# Filtering, decomposition and SSA
	_install_Rpkg robfilter sleekts ArDec tsdecomp rmaf Rssa spectral.methods Rlibeemd mFilter
	# Seasonality
	_install_Rpkg seasonal season bfast seas deseasonalize
	# Stationarity, Engle-Granger etc.
	_install_Rpkg CommonTrend tsDyn urca LSTS wavethresh locits costat CADFtest MultipleBubbles uroot
	# Nonlinear, dynamic and mvar models
	_install_Rpkg tseriesChaos tsDyn nnfor fractal ntls dse dlm dyn dlnm tpr orderedLasso sparsevar MTS ecm dlmodeler dlm freqdom pomp ptw pastecs ptw rts sae2 spTimer Tides tiger
	# Time series cohorts
	_install_Rpkg TSdist TSrepr jmotif rucrdtw TSclust dtwclust BNPTSclust pdc thief gtop
}

# rn03_install_domain_TimeSeries %end%
