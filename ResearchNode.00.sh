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
#
#



#=============================================================
# PREFLIGHT AND CONFIGURATION
#=============================================================

# SOURCE RN01                     V
source <ssinclude StackScriptID=316999>
# SOURCE RN01                     A

# RN01._update_system
# Runs a basic system update
rn01_update_system



