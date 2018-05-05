  echo "--------------------"
  sudo apt-get install libopencv-dev python-opencv
fi

# Create first user
echo "----------------------------------"
echo "Creating admin user $USER_USERNAME"
echo "----------------------------------"
sudo groupadd $USERGROUPNAME
sudo su -c "useradd $USER_USERNAME -s /bin/bash -m -g $USERGROUPNAME"
sudo echo "$USER_USERNAME:$USER_PASSWORD" | chpasswd

# Create daemon

echo "------------------"
echo "Creating daemon..."
echo "------------------"

cat << EOF > jupyterhub.service
[Unit]
Description=Jupyterhub
After=syslog.target network.target

[Service]
User=root
ExecStart=/usr/local/bin/jupyterhub -f /etc/jupyterhub/jupyterhub_config.py JupyterHub.spawner_class=sudospawner.SudoSpawner 
WorkingDirectory=/etc/jupyterhub
Restart=always

[Install]
WantedBy=multi-user.target
EOF


echo "-----------------"
echo "Placing daemon..."
echo "-----------------"

sudo mkdir /usr/lib/systemd/system
sudo mv jupyterhub.service /usr/lib/systemd/system/jupyterhub.service
sudo chmod a+x /usr/lib/systemd/system/jupyterhub.service
sudo systemctl enable jupyterhub
sudo systemctl daemon-reload

echo "-------------------------------------------"
echo "Starting Jupyterhub service on port $JUPYTER_PORT..."
echo "-------------------------------------------"

sudo systemctl restart jupyterhub


echo "All done. Enjoy your Jupyterhub installation!"
