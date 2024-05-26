#!/bin/bash
#./system_setup.sh
cpu_num=5
#schemes="c2tcp copa vivace ledbat sprout"
#schemes="sage orca indigo dbbr"
log_dir=$1
mkdir -p $log_dir
schemes="vivace"
# 350+
pids=""
# schemes="sage mvfst_rl"
#bbr-vegas-reno-highspeed-illinois-westwood-yeah-htcp cubic
#schemes="cdg hybla veno bic"
# schemes="vegas bbr"
setup_time=5
#loss_list="0 0.0001 0.001 0.01 0.05" #5
#loss_list="0 0.001"
#loss_list="0"
#flow_num_list="1 2 3" #3
#bw_list="12 24 48 96 192" #5
#del_list="5 10 20 40 80" #5

loss_list="0"
flow_num_list="1 2 3" #3
bw_list="24" #5
del_list="10" #5
#total_envs=41600
total_envs=3
time=60
run_times=1
flow_interval=0
cnt=0
## Pantheon and Mahimahi have problem with links higher than 350Mbps!
## For now, avoid using any link BW>350Mbps. But, stay tuned! A new patch is on the way! ;)

for flow_num in $flow_num_list # 1 1 1  
do
    if [ "$flow_num" -eq 1 ]; then
        qs_bdp_multiplier_list="2"
    else
        qs_bdp_multiplier_list="2"
    fi
    for loss in $loss_list # 2 2 2
    do
        for qs_bdp_multiplier in $qs_bdp_multiplier_list # 6 5 5
        do
            for del  in $del_list # 5 5 5
            do
                for cc in $schemes # 13 13 13
                do 
                    for bw in $bw_list # 13 5 5
                    do  
                        scales=1
                        bdp=$((del*bw/6))
                        qs=$(echo "$qs_bdp_multiplier * $bdp" | bc -l)  #浮点运算
                        qs=$(echo "scale=0; $qs/1" | bc)    #小数点后保留0位
                        for scale in $scales
                        do
                            if [ $cnt -gt -1 ]; then
                                
                                dl_post="-x${scale}-35"
                                bw2=$(echo "$bw * $scale" | bc -l)
                                bw2=$(echo "scale=0; $bw2/1" | bc)
                                link="$bw$dl_post"
                                echo "./cc_solo.sh $cc dataset-gen $flow_num $run_times $flow_interval $del $qs "$loss" $link $time $bw $bw2 $setup_time $log_dir&"
                                ./cc_solo.sh $cc dataset-gen $flow_num $run_times $flow_interval $del $qs "$loss" $link $time $bw $bw2 $setup_time $log_dir&
                                cnt=$((cnt+1))
                                echo "------------cnt=$cnt-----------------"
                                echo "------------cc=$cc, f=$flow_num, b=$bw, del=$del, , q=$qs_bdp_multiplier, l=$loss---------------"
                                pids="$pids $!"
                                sleep 2
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
    done
done
sleep 30

cnt=0
for flow_num in $flow_num_list
do
    if [ "$flow_num" -eq 1 ]; then
        qs_bdp_multiplier_list="2"
    else
        qs_bdp_multiplier_list="2"
    fi
    for loss in $loss_list
    do
        for qs_bdp_multiplier in $qs_bdp_multiplier_list
        do
            for del in $del_list
            do 
                for cc in $schemes
                do
                    for bw in $bw_list
                    do
                        scales=1
                        bdp=$((del*bw/6))
                        qs=$(echo "$qs_bdp_multiplier * $bdp" | bc -l)
                        qs=$(echo "scale=0; $qs/1" | bc)
                        for scale in $scales
                        do
                            dl_post="-x${scale}-35"
:<<CMT
                            if [ $bw -eq 12 ]; then
                                scales="1 2"
                            elif [ $bw -eq 24 ]; then 
                                scales="0.5 1 2"
                            elif [ $bw -eq 48 ]; then
                                scales="0.5 1 2"
                            elif [ $bw -eq 96 ]; then
                                scales="0.5 1 2"
                            else
                                scales="0.5 1"
                            fi
CMT
                            bw2=$(echo "$bw * $scale" | bc -l)
                            bw2=$(echo "scale=0; $bw2/1" | bc)
                            link="$bw$dl_post"
                            echo "./cc_solo_analysis.sh $cc dataset-gen $flow_num $run_times $flow_interval $del $qs "$loss" $link $time $bw $bw2 $setup_time $log_dir"
                            ./cc_solo_analysis.sh $cc dataset-gen $flow_num $run_times $flow_interval $del $qs "$loss" $link $time $bw $bw2 $setup_time $log_dir&
                            cnt=$((cnt+1))
                            pids="$pids $!"
                        done
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
done
./clean-tmp.sh
for cc in $schemes
do
    ./prepare-solo_league.sh $cc $log_dir
done
./clean-tmp2.sh
