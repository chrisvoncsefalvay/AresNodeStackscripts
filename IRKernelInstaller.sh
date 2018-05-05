#!/usr/bin/env bash
#
# IRKernel installer
#
# (c) Chris von Csefalvay <chris@chrisvoncsefalvay.com>
#

install_IRKernel () {
  REXEC=$(which R)
  
  if [ -z ${REXEC} ]
  then
    echo "Can't access R. Please check if R is available, in the PATH and try again."
    echo "For reference, your PATH is:"
    echo $PATH
    exit 1
  fi
  
  R --no-save << EOF
    install.packages(c('repr', 'IRdisplay', 'evaluate', 'crayon', 'pbdZMQ', 'devtools', 'uuid', 'digest'))
    devtools::install_github('IRkernel/IRkernel')
  EOF
  
  R --no-save << EOF
    IRkernel::installspec()
  EOF
}

