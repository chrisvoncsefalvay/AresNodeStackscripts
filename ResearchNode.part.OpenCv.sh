echo "--------------------"
echo "Installing OpenCV..."
echo "--------------------"
sudo apt-get install -y libpng12-dev libjpeg8-dev libtiff5-dev libjasper-dev
sudo apt-get install -y qtbase5-dev libavcodec-dev libavformat-dev libswscale-dev 
sudo apt-get install -y libgtk2.0-dev libv4l-dev libatlas-base-dev gfortran
sudo apt-get install -y libhdf5-serial-dev
pip3 install opencv-contrib-python