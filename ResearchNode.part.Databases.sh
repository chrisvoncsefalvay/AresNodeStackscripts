#!/bin/bash

# ResearchNode installer
#
# Databases and support packages subroutine
#
#
# Sourcing script:
#
#		curl https://raw.githubusercontent.com/chrisvoncsefalvay/stackscripts/master/ResearchNode.part.Databases.sh | sudo bash -
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

install_db_mongodb () {
  echo "---------------------"
  echo "Installing MongoDB..."
  echo "---------------------"

  sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
  echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list
  sudo apt-get update
  sudo apt-get install -y mongodb-org
  sudo pip3 install pymongo
}

install_db_neo4j () {
  echo "-------------------"
  echo "Installing Neo4j..."
  echo "-------------------"

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
}

install_db_postgresql () {
  echo "------------------------"
  echo "Installing Postgresql..."
  echo "-------------------------"

  sudo apt-get install -y postgresql postgresql-contrib
  sudo pip3 install psycopg2
}

install_db_all() {
  install_db_mongodb
  install_db_neo4j
  install_db_postgresql
}
