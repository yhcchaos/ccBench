#!/bin/bash
timeout=300
#./system_setup.sh
cpu_num=1
#schemes="c2tcp copa vivace ledbat sprout"
#schemes="sage orca indigo dbbr"
#schemes="vegas bbr reno cdg hybla highspeed illinois westwood yeah htcp bic veno cubic"
# 350+
pids=""
schemes="sage"
#bbr-vegas-reno-highspeed-illinois-westwood-yeah-htcp cubic
#schemes="cdg hybla veno bic"
# schemes="vegas bbr"
setup_time=5
#loss_list="0 0.0001 0.001 0.01 0.05" #5
#loss_list="0 0.001"
loss_list="0"
flow_num_list="1 2 3" #3
trace_dir=cellular-traces
del_list="10 20" #5
#total_envs=41600
total_envs=690
time=120
run_times=3
flow_interval=0
cnt=0
## Pantheon and Mahimahi have problem with links higher than 350Mbps!
## For now, avoid using any link BW>350Mbps. But, stay tuned! A new patch is on the way! ;)
# flow 1: [f1 l2 q6 d5 c13 b13] = 10140 5070
# flow 2: [f1 l2 q5 d5 c13 b5] = 3250 1625
# flow 3: [f1 l2 q5 d5 c13 b5] = 3250 1625

# flow 1: [f1 l5 q6 d5 c13 b13] = 25350
# flow 2: [f1 l5 q5 d5 c13 b5] = 8125 1625
# flow 3: [f1 l5 q5 d5 c13 b5] = 8125 1625
# all:16640
# 1264 - 975 = 289 f=2 l=0 q=3 d=5 c=2 b=3 [2 0 4 80 bbr 20 ]
# 289-260=29->13*2=24->3
bw=1
bw2=1
:<<CMT
for flow_num in $flow_num_list # 1 1 1  
do
    for loss in $loss_list # 2 2 2
    do
        for del  in $del_list # 5 5 5
        do
            for cc in $schemes # 13 13 13
            do 
                for trace in $trace_dir/*
                do
                    qs=128
                    if [ $cnt -gt -1 ]; then
                        echo "./cc_solo.sh $cc dataset-gen $flow_num $run_times $flow_interval $del $qs "$loss" $trace $time $bw $bw2 $setup_time &"
                        ./cellular_cc_solo.sh $cc dataset-gen $flow_num $run_times $flow_interval $del $qs "$loss" $trace $time $bw $bw2 $setup_time &
                        cnt=$((cnt+1))
                        echo "------------cnt=$cnt-----------------"
                        echo "------------f=$flow_num, l=$loss, q=$qs, del=$del, cc=$cc, b=$bw---------------"
                        pids="$pids $!"
                        sleep 1
                        if [ $((cnt % cpu_num)) -eq 0 ] || [ $cnt -eq $total_envs ];
                        then
                            for pid in $pids
                            do
                                wait $pid
                            done
                            pids=""
                            ./clean-tmp.sh
                        fi
                    else
                        cnt=$((cnt+1))
                        echo "------------cnt=$cnt-----------------"
                    fi
                done
            done    
        done
    done
done
sleep 35
CMT
schemes="all"
cnt=0
sys_cpu_cnt=`lscpu | grep "^CPU(s):" | awk '{print $2}'`
cpu_num=$sys_cpu_cnt
for flow_num in $flow_num_list
do
    for loss in $loss_list
    do
        for del in $del_list
        do 
            for cc in $schemes
            do
                for trace in $trace_dir/*
                do
                    qs=128
                    echo "./cellular_cc_solo_analysis.sh $cc dataset-gen $flow_num $run_times $flow_interval $del $qs "$loss" $trace $time $bw $bw2 $setup_time"
                    ./cellular_cc_solo_analysis.sh $cc dataset-gen $flow_num $run_times $flow_interval $del $qs "$loss" $trace $time $bw $bw2 $setup_time &
                    cnt=$((cnt+1))
                    pids="$pids $!"
                    if [ $((cnt % cpu_num)) -eq 0 ] || [ $cnt -eq $total_envs ];
                    then
                        for pid in $pids
                        do
                            wait $pid
                        done
                        pids=""
                        ./clean-tmp.sh
                    fi
                done
            done
        done
    done
done
./clean-tmp.sh
:<<CMT
for cc in $schemes
do
    ./prepare-solo_league.sh $cc
done
./clean-tmp2.sh
CMT