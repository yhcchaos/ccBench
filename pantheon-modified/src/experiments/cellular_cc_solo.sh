if [ $# -ne 13 ]
then
    echo "usage:"
    echo "\t$0 scheme [vegas bbr reno cubic ...] [log comment] [num of flows] [num of runs] [interval bw flows] [one-way delay] [qs] [loss] [down link: e.g., "48" for wired48 link] [duration] [BW (Mbps)] [BW2 (Mbps)] [setup_time]"
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
trace=$9
duration=${10}
bw=${11}
bw2=${12}
setup_time=${13}
trace_period=7
trace_name=$(basename $trace)
basetimestamp_fld=`pwd -P`
basetimestamp_fld="$basetimestamp_fld\/data"

time=$duration
log=${comment}-$scheme-$num_of_flows-$trace_name-$lat-$qs-$loss
echo "************************ Running $log *********************************"

./test.py local --schemes $scheme --uplink-trace $trace --downlink-trace traces/wired48-x1-35 -t $time \
    --extra-mm-link-args "--uplink-queue=droptail --uplink-queue-args=\"packets=$qs\" --downlink-queue=droptail --downlink-queue-args=\"packets=$qs" \
    --prepend-mm-cmds " mm-loss uplink $loss mm-loss downlink $loss mm-delay $lat " \
    --setup_time $setup_time --orcalearn 4 --random-order -f $num_of_flows --interval $interval --run-times $num_times --data-dir /data/4.7-cellular/heu/$log  \
    --save 1 --rm 0 --comment \"${down}_${lat}_${qs}_${loss}\" --tcpgen_cc $scheme --bw $bw \
    --basetime_fld "$basetimestamp_fld\/$log\/${scheme}_mm_acklink_run1.log_init_timestamp" --bw2 $bw2 --trace_period $trace_period
