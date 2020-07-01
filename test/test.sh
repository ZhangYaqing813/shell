#!/bin/bash
source_file=/data/rsync_test
target_file=/data/test_rsync
source_host=172.16.151.11
data_backup=/tmp/test_rsync


#显示目标目录文件

list_file(){
    echo "###显示目标目录文件"
    rsync root@${source_host}:${source_file}/
    echo "<----------------------------->"
    echo "###显示源目录文件"
    rsync ${target_file}/

}
#同步前备份
backup(){
    echo "执行备份----------"
    flag=`rsync -a -v  --backup --backup-dir=${data_backup}/ --suffix=~ ${target_file}/ ${data_backup}/`
    echo "flag = ${flag}"
    if [[ "${flag}" == "" ]];then
        echo "backup sucess"
    
    fi

}
#执行同步
brsync(){
    echo "开始备份--------"
    rsync -a -e "ssh -p 22" root@${source_host}:${source_file}/ $target_file/

}
list_file
sleep 5

backup
sleep 5s

brsync
