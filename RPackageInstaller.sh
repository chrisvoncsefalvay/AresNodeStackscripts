#!/usr/bin/env bash
#
# R Package Installer library
#
# (c) Chris von Csefalvay <chris@chrisvoncsefalvay.com>
#

install_Rpkg () {
  REXEC=$(which R)
  
  if [ -z ${REXEC} ]
  then
    echo "Can't access R. Please check if R is available, in the PATH and try again."
    echo "For reference, your PATH is:"
    echo $PATH
    exit 1
  fi
  
  for pkg in "$@"
  do
    echo "Installing R package $pkg..."
    echo "install.packages(\"${pkg}\", repos=\"https://cran.rstudio.com\")" | R --no-save
  done
}
