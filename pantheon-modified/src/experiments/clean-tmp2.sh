#!/bin/bash
log_dir=${1}

for i in ${log_dir}/*_mm_*.log;
do
    rm $i
done
for i in ${log_dir}/*_mm_*.log
do
    rm $i
done
