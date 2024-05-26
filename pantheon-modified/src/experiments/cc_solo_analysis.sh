if [ $# -ne 14 ]
then
    echo "usage:"
    echo "\t$0 scheme [vegas bbr reno cubic ...] [log comment] [num of flows] [num of runs] [interval bw flows] [one-way delay] [qs] [loss] [down link: e.g., "48" for wired48 link] [duration] [BW (Mbps)] [BW2 (Mbps)] [setup_time] [log_dir]"
    exit
fi
scheme=$1
comment=$2
num_of_flows=$3
num_times=$4
interval=$5
lat=$6
qs=$7
loss="$8"
dl=$9
duration=${10}
bw=${11}
bw2=${12}
setup_time=${13}
log_dir=${14}
trace_period=7

basetimestamp_fld=`pwd -P`
basetimestamp_fld="$basetimestamp_fld\/data"

downl="wired${dl}"
upl=$downl
time=$duration
down=$downl
log=${comment}-$scheme-$num_of_flows-$down-$lat-$qs-$loss

echo "************************Analyzing $log*********************************"
#Overall Analysis ...
../analysis/analyze.py --data-dir $log_dir/$log/
