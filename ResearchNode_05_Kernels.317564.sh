#!/bin/bash


# ResearchNode installer
#
# PART 05
# JUPYTER KERNELS
#
# Linode embedding ID:    317564
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

echo "Loaded subsidiary resource RN05.KERNELS.317564"


# rn05_selective_kernel_installer
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
# - Ruby
# - JavaScript
# - R
# - OCaml
# - Octave
# - Bash
# - Clojure
# - AIML
# - ARMv6THUMB
# - MIT_Scheme

rn05_selective_kernel_installer () {


	echo "---------------------------------------------"
	echo "Installing selected Jupyter kernels..."
	echo "---------------------------------------------"

	IFS=',' read -ra KERNELS <<< "$1"
	for i in "${KERNELS[@]}"; do	
		
		echo "***** Installing ${i} kernel..."
		rn05_install_kernel_${i}
		
	done
}

# rn05_selective_kernel_installer %end%



# rn05_install_kernel_Ruby
# ------------------------
# Installs a Ruby kernel.

rn05_install_kernel_Ruby () {
	sudo apt-get install -y ruby ruby-dev
	gem install cztop iruby
	jupyter kernelspec install /root/.ipython/kernels/ruby
}

# rn05_install_kernel_Ruby %end%



# rn05_install_kernel_JavaScript
# ------------------------------
# Installs a JavaScript kernel based on node.

rn05_install_kernel_JavaScript () {
    sudo apt install -y ijavascript
}

# rn05_install_kernel_JavaScript %end%


# rn05_install_kernel_Julia
# -------------------------
# Installs a Julia kernel.


rn05_install_kernel_Julia () {
    sudo apt install -y ijulia
}

# rn05_install_kernel_JavaScript %end%



# rn05_install_kernel_R
# -------------------------
# Installs an R kernel. This assumes a recent R is installed!

rn05_install_kernel_R () {
    sudo apt-get -y install irkernel
}

# rn05_install_kernel_R %end%


# rn05_install_kernel_Octave
# --------------------------
# Installs Octave and an Octave kernel to Jupyterhub

rn05_install_kernel_Octave () {
	sudo apt-get install -y octave
	sudo pip3 install octave_kernel
}

# rn05_install_kernel_Octave %end%



# rn05_install_kernel_Bash
# ------------------------
# Installs a Bash kernel to Jupyterhub

rn05_install_kernel_Bash () {
	pip3 install bash_kernel
	python3 -m bash_kernel.install
}

# rn05_install_kernel_Bash %end%



# rn05_install_kernel_Clojure
# ---------------------------
# Installs a Clojure kernel to Jupyterhub

rn05_install_kernel_Clojure () {
	cd /tmp
	wget https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein
	sudo chmod a+x lein
	sudo mv lein /usr/bin/lein
	lein
	git clone https://github.com/clojupyter/clojupyter
	cd clojupyter
	make
	sudo make install
}

# rn05_install_kernel_Clojure %end%



# rn05_install_kernel_AIML
# ------------------------
# Installs AIML chatbot kernel

rn05_install_kernel_AIML () {
	sudo pip3 install python-aiml aimlbotkernel
	sudo jupyter aimlbotkernel install
}

# rn05_install_kernel_AIML %end%



# rn05_install_kernel_ARMv6THUMB
# ------------------------------
# Installs a Jupyter kernel for the ARMv6 THUMB instruction set as 
# implemented by the ARM0 Cortex M0+ CPU

rn05_install_kernel_ARMv6THUMB () {
	sudo pip3 install iarm
	sudo python3 -m iarm_kernel.install
}

# rn05_install_kernel_ARMv6THUMB %end%



# rn05_install_kernel_Haskell
# ---------------------------
# Installs ghc and Haskell kernel

rn05_install_kernel_Haskell () {
    sudo apt-get install -y haskell-ipython-kernel
}



# rn05_install_kernel_MIT_Scheme
# ------------------------------
# Installs MIT Scheme 9.2, ZeroMQ 4.2.1 and the MIT Scheme kernel

rn05_install_kernel_MIT_Scheme () {
	sudo apt-get install -y libtool pkg-config build-essential autoconf automake uuid-dev m4
	sudo apt-get install -y checkinstall

	cd /tmp
	
	git clone https://github.com/joeltg/mit-scheme-kernel
	wget http://ftp.gnu.org/gnu/mit-scheme/stable.pkg/9.2/mit-scheme-9.2-x86-64.tar.gz
	tar -xzvf mit-scheme-9.2-x86-64.tar.gz
	
	# Install MIT Scheme 9.2
	cd /tmp/mit-scheme-9.2/src/
	./configure
	
	make compile-microcode
	sudo make install
	
	# Install the kernel
	cd /tmp/mit-scheme-kernel
	export LD_LIBRARY_PATH=/usr/local/lib
	make
	sudo make install
}

# rn05_install_kernel_MIT_Scheme %end%