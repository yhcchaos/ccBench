#!/bin/bash
period=7
#schemes="veno cdg highspeed hybla illinois westwood yeah htcp bic cubic bbr2 vegas reno"
#schemes="$schemes indigo vivace aurora orca dbbr"
#schemes="$schemes pure"
#schemes="$schemes $1 $2"

#A sample:
#schemes="veno cdg highspeed hybla illinois westwood yeah htcp bic cubic bbr vegas reno mvfst_rl"
schemes="bbr cubic htcp vegas illinois mvfst_rl orca sage"
#schemes=""
#schemes="sage orca aurora mvfst_rl"
#schemes="bbr vegas copa ledbat mvfst_rl sprout"
#schemes="aurora bbr copa cubic ledbat mvfst_rl orca sage vivace"

setup_time=5
data="/data/4.5-lr0.01/test_all"
win_margin=10 # % -> 10: 10% ==> everyone in the range of [0.9*best,best] is a winner.

end_of_ss_comp_segment=3

for j in $data/dataset-gen-league-*
do
    rm -r $j/log
done

#for start in 0 10 30
for start in 0 10 30
do
    if [ $start -eq 0 ]
        then
            end=$((start+10))
        elif [ $start -eq 10 ]
        then
            end=$((start+20))
        else
            end=$((start+30))
        fi
    python ../analysis/league-piecewise.py --datadir $data/ --win-start=$((start+setup_time)) --win-end=$((end+setup_time)) --win-margin=$win_margin --schemes="$schemes"
    for j in $data/dataset-gen-league-*;
    do
        for flow_num in 1 2 3;
        do  
            rm $j/flow${flow_num}_chart $j/flow${flow_num}_charts
            num_env=$(cat $j/flow${flow_num}_num_env | grep total | awk '{print $2}')
            for i in $schemes;
            do  
                # NR: number of records，print: cubic   winners以cubic为开头的行的数量  数量/总的环境数量
                # cat $j/flow${flow_num}_winners
                cat $j/flow${flow_num}_winners | grep -e "^${i}-" | awk -v s="$i"  -v n_env="$num_env" 'END{print s"\t "NR"\t "NR/n_env}' >>$j/flow${flow_num}_chart
            done
            sort -k2 -rh $j/flow${flow_num}_chart > $j/flow${flow_num}_charts
            echo $j;cat $j/flow${flow_num}_charts
        done
    done
    echo " ---------------- Done with date/dataset-gen-league-${start}_${end}/winners-dataset/ ------------------"
done

for flow_num in 1 2 3;
do
    declare -A sum
    declare -A norm
    for i in $schemes
    do
        sum[$i]=0;
    done
    for cc in $schemes
    do
        for i in $data/dataset-gen-league-*;
        do
            
            # 在处理每一行时，检查第一个字段是否等于 sch（即 $cc 的值），如果相等，则打印该行的第二个字段。
            d=$(cat $i/flow${flow_num}_charts | awk -v sch="$cc" '{if($1==sch)print $2}');    sum[$cc]=$((sum[$cc]+d));
        done
    done
    for key in "${!sum[@]}"; do
        echo "sum[$key] = ${sum[$key]}"
    done
    total=0
    for cc in $schemes
    do
        total=$((sum[$cc]+total));
    done
    rm $data/flow${flow_num}_num_env $data/flow${flow_num}_total

    for i in $data/dataset-gen-league-*;
    do
        cat $i/flow${flow_num}_num_env
        echo "`cat $i/flow${flow_num}_num_env | grep total | awk '{print $2}'`" >> $data/flow${flow_num}_total
    done
    # BEGIN{s=0}'：在处理文件之前执行的代码块，在这里初始化变量 s 为 0。
    # '{s=s+$1}'：对文件中的每一行执行的代码块，将该行的第一个字段（由 $1 表示）的值加到变量 s 中。
    # 'END{print s}'：在处理文件之后执行的代码块，在这里打印变量 s 的最终值。
    total=`cat $data/flow${flow_num}_total | awk 'BEGIN{s=0}{s=s+$1}END{print s}'`

    for cc in $schemes
    do
        norm[$cc]=`printf %.2f "$((1000000000  *  100*sum[$cc]/total))e-9"`
    done
    for key in "${!norm[@]}"; do
        echo "norm[$key] = ${norm[$key]}"
    done
    rm flow${flow_num}_tmp flow${flow_num}_tmp2 flow${flow_num}_tmp_l flow${flow_num}_tmp_l2 flow${flow_num}_tmp_nl flow${flow_num}_tmp_nl2
    for cc in $schemes
    do
        echo flow${flow_num}_tmp
        echo "$cc ${sum[$cc]} ${norm[$cc]} $total" >> flow${flow_num}_tmp
    done
    sort -k2 -hr flow${flow_num}_tmp > flow${flow_num}_tmp2;
    column -t flow${flow_num}_tmp2 > flow${flow_num}_tmp;
    output="charts-overall-ranking-${flow_num}-flows"
    rm $data/${output}-$win_margin

    echo -e "scheme wins % num_games" >> $data/${output}-$win_margin

    cat flow${flow_num}_tmp >> $data/${output}-$win_margin
    cat $data/${output}-$win_margin
    rm flow${flow_num}_tmp*
done
