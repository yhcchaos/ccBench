#!/bin/bash
for trace in cellular-traces/*
do
    name=$(basename $trace)
    echo $name >> cellular-traces-name.txt
done
