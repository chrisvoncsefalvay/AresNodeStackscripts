#!/bin/bash


# ResearchNode installer
#
# PART 06
# DATABASES
#
# Linode embedding ID:    317565
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

echo "Loaded subsidiary resource RN06.COREAPPS.317565"



# rn06_selective_db_installer
# ---------------------------
# Installs databases and their supporting clients dependent on a domain selection string.
#
# WARNING: 
# ******** INSTALL DBs ONLY AFTER INSTALLING JUPYTERHUB
# ******** AND MOST OTHER LANGUAGES. R, ESPECIALLY, IS NOT 
# ******** INSTALLED BY THE INCLUDED INSTALLER FUNCTIONS.
# ******** THIS IS THEREFORE BEST DONE TOWARDS THE END OF THE
# ******** INSTALLATION PROCESS.
#		
# @param $1: domain selection string, comma separated
#
# The currently registered databases are:
# - Neo4j
# - MongoDB
# - PostgreSQL

rn06_selective_db_installer () {
	echo "---------------------------------------------------------------"
	echo "Installing selected databases and their R and Python support..."
	echo "---------------------------------------------------------------"

	IFS=',' read -ra KERNEL <<< "$1"
	for i in "${KERNELS[@]}"; do	
		echo "***** Installing ${i}..."
		rn06_install_db_${i}
	done
}

# rn06_selective_db_installer %end%



# rn06_install_db_MongoDB
# -----------------------

rn06_install_db_MongoDB () {
	sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
	echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse"
	sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list
	sudo apt-get update
	sudo apt-get install -y mongodb-org
	sudo pip3 install pymongo
	_install_Rpkg mongolite
	sudo systemctl start mongod
}

# rn06_install_db_MongoDB %end%



# rn06_install_db_Neo4j
# ---------------------

rn06_install_db_Neo4j () {
	sudo apt-get install -y default-jre default-jre-headless
	sudo update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/bin/java
	sudo update-alternatives --set javac /usr/lib/jvm/java-8-openjdk-amd64/bin/javac

	wget --no-check-certificate https://debian.neo4j.org/neotechnology.gpg.key -O /tmp/neotechnology.key | sudo apt-key add /tmp/neotechnology.key
	echo 'deb http://debian.neo4j.org/repo stable/' | sudo tee /etc/apt/sources.list.d/neo4j.list

	sudo apt-get update -y
	sudo apt-get -y install neo4j

	sudo pip3 uninstall scikit-learn
	sudo pip3 install scikit-learn>=0.18.1
	sudo pip3 install neo4j-driver==1.5.2 py2neo neomodel
	sudo pip3 install neo4jupyter
	_install_Rpkg rstudioapi RNeo4j
	
	ln -s $(which neo4j) /etc/init.d/neo4j
	
	cat << EOM > /lib/systemd/system/neo4j.services
[Unit] 
Description=Neo4j Management Service

[Service] 
Type=forking
User=neo4j
ExecStart=/etc/init.d/neo4j start
ExecStop=/etc/init.d/neo4j stop
ExecReload=/etc/init.d/neo4j restart
RemainAfterExit=no
Restart=on-failure
PIDFile=/opt/neo4j/data/neo4j-service.pid
LimitNOFILE=60000
TimeoutSec=600

[Install]
WantedBy=multi-user.target

EOM

	sudo systemctl enable neo4j.service
	sudo systemctl daemon-reload
}

# rn06_install_db_Neo4j %end%


# rn06_install_db_Postgresql
# --------------------------

rn06_install_db_Postgresql () {
	sudo apt-get install -y postgresql postgresql-contrib
	sudo pip3 install psycopg2
	_install_Rpkg RPostgreSQL
	
	sudo systemctl enable postgresql
	sudo systemctl daemon-reload
}

# rn06_install_db_Postgresql %end%