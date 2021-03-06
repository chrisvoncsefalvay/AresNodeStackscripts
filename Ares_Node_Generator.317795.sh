#!/bin/bash

set +e
set +u

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

# <UDF name="BOX_UID" label="Box unique identifier" default="AresAlpha" />
# <UDF name="USER_USERNAME" label="User name" default="chris" />
# <UDF name="USER_PASSWORD" label="User password" />
# <UDF name="USER_USERGROUP" label="Authorisation usergroup" default="ares"/>
# <UDF name="PYTHON_VER" label="Python version (NB.: OpenCV is not available for Python 3.7.0)" oneOf="3.5.3,3.5.4,3.6.5,3.6.6rc1,3.7.0" default="3.7.0" />
# <UDF name="RSTUDIO_PORT" label="RStudio port" default="9999" />
# <UDF name="RSTUDIO_VER" label="RStudio version" oneOf="1.2.679,1.1.453," default="1.2.679" />
# <UDF name="JUPYTERHUB_PORT" label="Jupyterhub port" default="8888" />
# <UDF name="JUPYTERHUB_VER" label="Jupyterhub version" oneOf="0.9.0b3,0.9.0b2,0.9.0b1,0.8.1,0.8.0,0.7.2" default="0.9.0b3" />
# <UDF name="JUPYTERHUB_KERNELS" label="Additional kernels for JupyterHub" manyOf="Ruby,JavaScript,R,Octave,Bash,JavaScript,Haskell,Julia,Clojure,AIML,ARMv6THUMB,MIT_Scheme" default="R,Bash,Octave,AIML" />
# <UDF name="JUPYTERHUB_THEME" label="JupyterHub theme" oneOf="default,chesterish,grade3,gruvboxd,gruvboxl,monokai,oceans16,onedork,solarizedd,solarizedl" default="default" />
# <UDF name="GIT_FULLNAME" label="Full name (for Git) (leave empty to skip Git configuration)" default="Chris von Csefalvay" />
# <UDF name="GIT_EMAIL" label="Git e-mail (leave empty to skip Git configuration)" default="chris@chrisvoncsefalvay.com" />
# <UDF name="GIT_USERNAME" label="Github user name (leave empty to skip GitHub configuration)" default="chrisvoncsefalvay" />
# <UDF name="GIT_TOKEN_PASSWORD" label="Github personal access token (leave empty to skip GitHub configuration)" default="" />
# <UDF name="GIT_EDITOR" label="Preferred editor for Git operations" oneOf="vim,nano" default="vim" />

# Ascertain IP address for future use
IPADDR=$(/sbin/ifconfig eth0 | awk '/inet / { print $2 }' | sed 's/addr://')


#=============================================================
# PREFLIGHT AND CONFIGURATION
#=============================================================


# SOURCE RN01                     V
source <ssinclude StackScriptID=316999>
# SOURCE RN01                     A



#=============================================================
# INSTALL R AND PYTHON
#=============================================================

# SOURCE RN02                     V
source <ssinclude StackScriptID=317342>
# SOURCE RN02                     A

# SOURCE RN03                     V
source <ssinclude StackScriptID=317343>
# SOURCE RN03                     A

# Install R packages
rn03_install_core_R_packages


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


# RN01._create_user_and_usergroup
# Creates a user with a given password, and assigns it to a newly created usergroup.
rn01_create_user_and_usergroup



#=============================================================
# INSTALL ADDITIONAL KERNELS
#=============================================================

# SOURCE RN05
source <ssinclude StackScriptID=317564>
# SOURCE RN05

if [[ -n ${JUPYTERHUB_KERNELS} ]]; then
    rn05_selective_kernel_installer ${JUPYTERHUB_KERNELS}
fi


#=============================================================
# START SERVICES
#=============================================================

sudo rstudio-server start
sudo service jupyterhub restart

#=============================================================
# CONFIGURE GIT
#=============================================================

# RN01._configure_git
# Configures git and uploads keys.
rn01_configure_git

if [[ -n ${GIT_TOKEN_PASSWORD} ]]; then
    rn01_create_rsakey
    rn01_upload_rsakey
fi

clear

#=============================================================
# Print installation summary
#=============================================================

# RN01._print_install_summary
rn01_print_install_summary