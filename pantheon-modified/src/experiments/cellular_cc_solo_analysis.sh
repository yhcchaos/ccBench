if [ $# -ne 13 ]
then
    echo "usage:"
    echo "\t$0 scheme [vegas bbr reno cubic ...] [log comment] [num of flows] [num of runs] [interval bw flows] [one-way delay] [qs] [loss] [down link: e.g., "48" for wired48 link] [duration] [BW (Mbps)] [BW2 (Mbps)] [setup_time]"
    exit
fi
scheme=$1
comment=$2
num_of_flows=$3
lat=$6
qs=$7
loss="$8"
trace=$9
trace_name=$(basename $trace)
basetimestamp_fld=`pwd -P`
basetimestamp_fld="$basetimestamp_fld\/data"


log=${comment}-$scheme-$num_of_flows-$trace_name-$lat-$qs-$loss

echo "************************Analyzing $log*********************************"

#Overall Analysis ...
../analysis/analyze.py --data-dir /data/4.7-cellular/test_all/$log/
