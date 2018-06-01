#!/bin/bash

# ResearchNode installer
#
# PART 00*
# MASTER INSTALL SCRIPT
# ---------------------
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

#=============================================================
# UDFs and user configuration
#=============================================================

# <UDF name="USER_USERNAME" label="User name" />
# <UDF name="USER_PASSWORD" label="User password" />
# <UDF name="USER_USERGROUP" label="Authorisation usergroup" default="ares"/>
# <UDF name="PY_PACKAGES" label="Python packages to install" manyOf="GeneralScience,MachineLearning,NLP,NLPCorpora,Bioinformatics,GIS,DataVisualisation" default="GeneralScience,DataVisualisation" />
# <UDF name="R_PACKAGES" label="R packages to install" manyOf="General,ReproducibleResearch,StatisticalMethods,SocialNetworkAnalysis,Epidemiology,ClinicalTrials,Plotting,Spatial,ExportImport,TextMining,BayesianInference,MachineLearning,TimeSeries" default="General,ReproducibleResearch,StatisticalMethods,Plotting" />
# <UDF name="RSTUDIO_PORT" label="RStudio port" default="9999" />
# <UDF name="RSTUDIO_VER" label="RStudio version" oneOf="1.2.679,1.1.453," default="1.1.453" />
# <UDF name="JUPYTERHUB_PORT" label="Jupyterhub port" default="8888" />
# <UDF name="JUPYTERHUB_VER" label="Jupyterhub version" oneOf="0.9.0b3,0.9.0b2,0.9.0b1,0.8.1,0.8.0,0.7.2" default="0.8.1" />


#=============================================================
# PREFLIGHT AND CONFIGURATION
#=============================================================

set -x

# SOURCE RN01                     V
source <ssinclude StackScriptID=316999>
# SOURCE RN01                     A

# RN01._create_user_and_usergroup
# Creates a user with a given password, and assigns it to a newly created usergroup.
# rn01_create_user_and_usergroup ${USER_USERNAME} ${USER_PASSWORD} ${USER_USERGROUP}



#=============================================================
# INSTALL R AND PYTHON
#=============================================================

# SOURCE RN02                     V
source <ssinclude StackScriptID=317342>
# SOURCE RN02                     A

# SOURCE RN03                     V
source <ssinclude StackScriptID=317343>
# SOURCE RN03                     A

# Install Python packages
if [ -n ${PY_PACKAGES} ]; then
    rn02_selective_domain_installer ${PY_PACKAGES}
fi

# Install R packages
if [ -n ${R_PACKAGES} ]; then
    rn03_selective_domain_installer ${R_PACKAGES}
fi



#=============================================================
# INSTALL JUPYTERHUB AND RSTUDIO
#=============================================================

# SOURCE RN04                     V
source <ssinclude StackScriptID=317448>
# SOURCE RN04                     A

rn04_install_RStudio

rn04_create_RStudio_config

rn04_install_Jupyterhub

rn04_configure_Jupyterhub