PREFIX=${CONDA_PREFIX:-"/usr/local"}
# setup mahimahi
cd mahimahi/
./autogen.sh && ./configure && make
sudo make install
sudo sysctl -w net.ipv4.ip_forward=1
sudo cp /usr/local/bin/mm-* "$PREFIX"/bin/
sudo chown root:root "$PREFIX"/bin/mm-*
sudo chmod 4755 "$PREFIX"/bin/mm-*

cd ../pantheon-modified/tools/
./install_deps.sh
