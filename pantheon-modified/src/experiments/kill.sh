#!/bin/bash
# 查找 CMD 列中包含 "solo_runall" 的进程并终止
solo_pids=$(ps aux | grep 'test_fairness' | grep -v 'grep' | awk '{print $2}')

for pid in $solo_pids; do
    echo "Terminating process $pid (solo_runall)"
    kill -15 $pid
done

solo_pids=$(ps aux | grep 'analyze' | grep -v 'grep' | awk '{print $2}')

for pid in $solo_pids; do
    echo "Terminating process $pid (solo_runall)"
    kill -15 $pid
done

solo_pids=$(ps aux | grep 'pantheon' | grep -v 'grep' | awk '{print $2}')

for pid in $solo_pids; do
    echo "Terminating process $pid (solo_runall)"
    kill -15 $pid
done

solo_pids=$(ps aux | grep 'analysis/plot.py' | grep -v 'grep' | awk '{print $2}')

for pid in $solo_pids; do
    echo "Terminating process $pid (solo_runall)"
    kill -15 $pid
done

# 查找 CMD 列中包含 "tunnel_manager" 的进程并发送 SIGTERM
tunnel_pids=$(ps aux | grep 'tunnel_manager' | grep -v 'grep' | awk '{print $2}')

for pid in $tunnel_pids; do
    echo "Sending SIGTERM to process $pid (tunnel_manager)"
    kill -15 $pid
done

# 查找所有 CMD 列含有 "test.py local --schemes" 的进程并终止
test_pids=$(ps aux | grep 'test.py local --schemes' | grep -v 'grep' | awk '{print $2}')

for pid in $test_pids; do
    echo "Terminating process $pid (test.py local --schemes)"
    kill -15 $pid
done

# 查找所有 CMD 列含有 "cc_solo" 的进程并终止
cc_solo_pids=$(ps aux | grep 'cc_solo' | grep -v 'grep' | awk '{print $2}')

for pid in $cc_solo_pids; do
    echo "Terminating process $pid (cc_solo)"
    kill -15 $pid
done
