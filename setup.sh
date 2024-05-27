#!/bin/bash
PREFIX=${CONDA_PREFIX:-"/usr/local"}
sys_cpu_cnt=$(lscpu | grep "^CPU(s):" | awk '{print $2}')
cpu_num=$sys_cpu_cnt
# setup mahimahi
cd mahimahi/
./autogen.sh && ./configure && make -j $cpu_num
sudo make install
sudo sysctl -w net.ipv4.ip_forward=1
sudo cp /usr/local/bin/mm-* "$PREFIX"/bin/
sudo chown root:root "$PREFIX"/bin/mm-*
sudo chmod 4755 "$PREFIX"/bin/mm-*

cd ../pantheon-modified/tools/
./install_deps.sh
