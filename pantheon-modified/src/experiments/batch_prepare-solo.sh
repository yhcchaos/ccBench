#!/bin/bash
schemes="cubic htcp vegas yeah"
for cc in $schemes
do
    ./prepare-solo_league.sh $cc
done
