#!/bin/bash
ls -trlh /data/pantheon/tmp | awk '{print $7" "$8" "$9}' | sed "s/:/ /g" | awk '{a=($1*24+$2)*60+$3; print a" "$4}' > files
now=$(date | awk '{print $3" "$5}' | sed 's/\<0\+//;s/日//;s/:/ /g' | awk '{print ($1*24+$2)*60+$3}');
cat files | awk -v now="$now" '{if($1<(now-10))print $2}' > remove-them
for i in $(cat remove-them); do rm ../../tmp/$i;done
rm files remove-them

for i in /data/pantheon/data/dataset-gen-*/tcpdatagen_mm_*.log;
do
    rm $i
done

for i in /data/pantheon/data/dataset-gen-*/*_mm_*.log;
do
    rm $i
done
for i in /data/pantheon/data/dataset-gen-*/*_acklink_*.log;
do
    rm $i
done
