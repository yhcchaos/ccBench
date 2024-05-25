sudo modprobe -a tcp_vegas
sudo modprobe -a tcp_bbr
sudo modprobe -a tcp_cdg
sudo modprobe -a tcp_hybla
sudo modprobe -a tcp_highspeed
sudo modprobe -a tcp_illinois
sudo modprobe -a tcp_westwood
sudo modprobe -a tcp_yeah
sudo modprobe -a tcp_htcp
sudo modprobe -a tcp_bic
sudo modprobe -a tcp_veno
sudo modprobe -a tcp_cubic
sudo sysctl -w net.ipv4.tcp_allowed_congestion_control="vegas bbr reno cdg hybla highspeed illinois westwood yeah htcp bic veno cubic"