#!/bin/bash

service=$1
shift
until [ $# -eq 0 ]
do 
    echo $service
    host=$1

    echo "当前主机：${host}"
    pid=`ssh -i ~/.cmes-prod.pem ${host} ps -ef| grep ${service} | awk '{print $2}'`
    echo "当前APP服务进程号：${pid}"
    sleep 2s
    ssh -i ~/.cmes-prod.pem ${host} kill -9 ${pid}
    ssh -i ~/.cmes-prod.pem ${host} ps -ef| grep ${service}
    shift

done 









