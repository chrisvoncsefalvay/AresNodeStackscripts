#!/bin/bash


# ResearchNode installer
#
# PART 03
# JUPYTER KERNELS
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

echo "Loaded subsidiary resource RN03.KERNELS.000000"


# rn03_selective_domain_installer
# -------------------------------
# Installs languages and kernels dependent on a domain selection string.
#
# WARNING: 
# ******** INSTALL KERNELS ONLY AFTER INSTALLING JUPYTERHUB
# ******** AND MOST OTHER LANGUAGES. R, ESPECIALLY, IS NOT 
# ******** INSTALLED BY THE INCLUDED INSTALLER FUNCTIONS.
# ******** THIS IS THEREFORE BEST DONE TOWARDS THE END OF THE
# ******** INSTALLATION PROCESS.
#		
# @param $1: domain selection string, comma separated
#
# The currently registered kernels are:
# - Haskell

rn03_selective_kernel_installer () {
	echo "---------------------------------------------"
	echo "Installing selected Jupyter kernels..."
	echo "---------------------------------------------"

	sudo add-apt-repository ppa:chronitis/jupyter
	sudo apt-get update

	IFS=',' read -ra KERNEL <<< "$1"
	for i in "${KERNELS[@]}"; do	
		echo "***** Installing ${i} kernel..."
		rn02_install_kernel_${i}
	done
}

# rn03_selective_kernel_installer %end%



# rn03_install_kernel_Ruby
# ------------------------
# Installs a Ruby kernel.

rn03_install_kernel_Ruby () {
	sudo apt-get install -y ruby ruby-dev
	gem install cztop iruby
	iruby register --force
	
}

# rn03_install_kernel_Ruby %end%



# rn03_install_kernel_JavaScript
# ------------------------------
# Installs a JavaScript kernel based on node.

rn03_install_kernel_JavaScript () {
	sudo apt-get install -y nodejs npm
	sudo npm install -g ijavascript
	ijsinstall
}

# rn03_install_kernel_Ocaml %end%



# rn03_install_kernel_R
# -------------------------
# Installs an R kernel. This assumes a recent R is installed!

rn03_install_kernel_R () {
R --slave <<EOF
	install.packages(c('repr', 'IRdisplay', 'evaluate', 'crayon', 'pbdZMQ', 'devtools', 'uuid', 'digest')
	devtools::install_github('IRkernel/IRkernel')	library(IRkernel)
	IRkernel::installspec(user = FALSE)	
EOF	
}

# rn03_install_kernel_R %end%



# rn03_install_kernel_OCaml
# -------------------------
# Installs OCaml and an OCaml kernel to Jupyterhub

# rn03_install_kernel_Ocaml () {
	sudo apt-get install -y ocaml-nox opam
	opam init
	opam install jupyter
	opam install jupyter-archimedes
	sudo jupyter kernelspec install --name ocaml-jupyter "$(opam config var share)/ocaml-jupyter"
}

# rn03_install_kernel_Ocaml %end%



# rn03_install_kernel_Octave
# --------------------------
# Installs Octave and an Octave kernel to Jupyterhub

# rn03_install_kernel_Octave () {
	sudo apt-get install -y octave
	sudo pip3 install octave_kernel
}

# rn03_install_kernel_Octave %end%



# rn03_install_kernel_Bash
# ------------------------
# Installs a Bash kernel to Jupyterhub

# rn03_install_kernel_Bash () {
	pip3 install bash_kernel
	python -m bash_kernel.install
}

# rn03_install_kernel_Bash %end%



# rn03_install_kernel_Clojure
# ---------------------------
# Installs a Clojure kernel to Jupyterhub

# rn03_install_kernel_Clojure () {
	cd /tmp
	git clone https://github.com/clojupyter/clojupyter
	make
	sudo make install
}

# rn03_install_kernel_Clojure %end%



# rn03_install_kernel_AIML
# ------------------------
# Installs AIML chatbot kernel

rn03_install_kernel_AIML () {
	sudo pip3 install python-aiml aimlbotkernel
	sudo jupyter aimlbotkernel install
}

# rn03_install_kernel_Clojure %end%



# rn03_install_kernel_ARMv6THUMB
# ------------------------------
# Installs a Jupyter kernel for the ARMv6 THUMB instruction set as 
# implemented by the ARM0 Cortex M0+ CPU

rn02_install_kernel_ARMv6THUMB () {
	sudo pip3 install iarm
	sudo python3 -m iarm_kernel.install
}

# rn03_install_kernel_ARMv6THUMB %end%



# rn03_install_kernel_Haskell
# ---------------------------
# Installs ghc and Haskell kernel

rn03_install_kernel_Haskell () {
	sudo apt-get install haskell-platform
	cd /tmp
	git clone https://github.com/gibiansky/IHaskell
	cd IHaskell
	pip3 install -r requirements.txt
	stack install gtk2hs-buildtools
	stack install --fast
	ihaskell install --stack
}

# rn03_install_kernel_Haskell %end%



# rn03_install_kernel_MIT_Scheme
# ------------------------------
# Installs MIT Scheme 9.2, ZeroMQ 4.2.1 and the MIT Scheme kernel

rn03_install_kernel_MIT_Scheme () {
	sudo apt-get install -y libtool pkg-config build-essential autoconf automake uuid-dev m4
	sudo apt-get install -y checkinstall

	cd /tmp
	
	git clone https://github.com/joeltg/mit-scheme-kernel
	wget http://ftp.gnu.org/gnu/mit-scheme/stable.pkg/9.2/mit-scheme-9.2-x86-64.tar.gz
	tar -xzvf mit-scheme-9.2-x86-64.tar.gz
	wget https://github.com/zeromq/libzmq/releases/download/v4.2.5/zeromq-4.2.5.tar.gz
	tar -xvzf zeromq-4.2.1.tar.gz
	
	
	# Install MIT Scheme 9.2
	cd /tmp/mit-scheme-9.2/src/
	./configure
	make compile-microcode
	sudo make install
	
	# Install ZeroMQ 4.2.5
	cd /tmp/zeromq-4.2.1/
	./configure
	make
	sudo make install
	
	# Install the kernel
	cd /tmp/mit-scheme-kernel
	export LD_LIBRARY_PATh=/usr/local/lib
	make
	sudo make install
}

# rn03_install_kernel_MIT_Scheme %end%




