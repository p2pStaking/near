#!/bin/bash 

MaxExpectedPathBDP=8388608
sudo sysctl -w net.core.rmem_max=$MaxExpectedPathBDP
sudo sysctl -w net.core.wmem_max=$MaxExpectedPathBDP
sudo sysctl -w net.ipv4.tcp_rmem="4096 87380 $MaxExpectedPathBDP"
sudo sysctl -w net.ipv4.tcp_wmem="4096 16384 $MaxExpectedPathBDP"
sudo sysctl -w net.ipv4.tcp_slow_start_after_idle=0
