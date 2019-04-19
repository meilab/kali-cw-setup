#!/usr/bin/env bash

# 宗旨：没有版本特殊要求的，能用apt-get安装最好，不需要编译，不会出一堆问题。

export LANGUAGE="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"
echo 'LANGUAGE="en_US.UTF-8"' >> /etc/default/locale
echo 'LC_ALL="en_US.UTF-8"' >> /etc/default/locale
echo 'LANG="en_US.UTF-8"' >> /etc/default/locale

# normal apt installs
# apt-get update
# apt-get upgrade -y


# use apt to install below libs other than pip3 install from requirement.txt in chipwhisperer, because pip install need to build wheels may need big swap and also some times fail with other reason
apt-get install -y python3-scipy
apt-get install -y python3-matplotlib
apt-get install -y python3-pandas
apt-get install -y python3-numba
apt-get install -y python3-zmq
apt-get install -y python3-pycryptodome
apt-get install -y python3-h5py
apt-get install -y python3-keras
apt-get install -y python3-sklearn

# normal install
# apt-get install -y python3
# apt-get install -y python3-pip
apt-get install -y python3-tk #for matplotlib/lascar
apt-get install -y git
apt-get install -y gcc-avr
apt-get install -y avr-libc
apt-get install -y gcc-arm-none-eabi
apt-get install -y make

# to fix some issue
apt-get install -y zlib1g-dev libjpeg-dev libpng-dev
apt-get install -y libfreetype6-dev
apt-get install -y pkg-config
apt-get install -y libblas-dev liblapack-dev
apt-get install -y gfortran
apt-get install -y libzmq3-dev
apt-get install -y libhdf5-dev
# solve the pgen not found issue
apt-get install -y cython3
apt-get install -y jupyter-notebook

# pip installs
python3 -m pip install --upgrade pip
pip3 install pgen
# we use apt-get to install cython3 not pip
# pip3 install cython==0.28.6

cd /root
mkdir software
cd software

# get lascar and install
git clone https://github.com/Ledger-Donjon/lascar
# chown -R vagrant:vagrant lascar
cd lascar
pip3 install --upgrade colorama

# below command my fail because of "Unable to find pgen, not compiling formal grammar."
python3 setup.py install
cd ..

# get chipwhisperer and install
git clone https://github.com/newaetech/chipwhisperer
# chown -R vagrant:vagrant chipwhisperer
cd chipwhisperer/software
git checkout cw5dev
git pull
# sudo -Hu vagrant git config --global user.name "Vagrant"
# sudo -Hu vagrant git config --global user.email "Vagrant@none.com"
pip3 install -r requirements.txt
python3 setup.py develop

# USB permissions
cd ../hardware
cp 99-newae.rules /etc/udev/rules.d/
usermod -a -G plugdev root
udevadm control --reload-rules

# copy cron script from vagrant folder
# cp /vagrant/run_jupyter.sh /home/vagrant/
# chown -R vagrant:vagrant /home/vagrant/run_jupyter.sh
# chmod +x /home/vagrant/run_jupyter.sh

cp /root/kali-cw-setup/run_jupyter.sh /root/run_jupyter.sh
chmod +x /root/run_jupyter.sh

# jupyter stuff
jupyter contrib nbextension install --system

# copy jupyter config
mkdir -p /root/.jupyter
cp /root/kali-cw-setup/jupyter_notebook_config.py /root/.jupyter/

# make sure jupyter is under the vagrant user
# maybe just make /home/vagrant all vagrant?
# chown vagrant:vagrant -R /home/vagrant/

# Enable jupyter extensions
# sudo -Hu vagrant jupyter nbextension enable toc2/main
# sudo -Hu vagrant jupyter nbextension enable collapsible_headings/main
jupyter nbextension enable toc2/main
jupyter nbextension enable collapsible_headings/main

jupyter nbextensions_configurator enable --system

# check if cron job already inserted, and if not insert it
if !(crontab -u root -l | grep "run_jupyter\.sh"); then
    (crontab -u root -l 2>/dev/null; echo "@reboot /root/run_jupyter.sh") | crontab -u root -
fi

#done now reboot
reboot
