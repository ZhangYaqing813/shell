#!/bin/bash
source_file=/data/rsync_test
target_file=/data/test_rsync
source_host=172.16.151.11
data_backup=/tmp/test_rsync
checksum=/data/checksum

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
    #备份前生成检验文件

    flag=`rsync -a  --backup --backup-dir=${data_backup}/ --suffix=~ ${target_file}/ ${data_backup}/`
    
    #备份完后再次生成校验文件


    echo "flag = ${flag}"
    

    if [[ "${flag}" == "" ]];then
        echo "backup sucess"
    
    fi

}
#执行同步
brsync(){
    echo "开始同步--------"
    ssh root@${source_host} "md5sum ${source_file} >${checksum}/check.md5"
    rsync -a -e "ssh -p 22" root@${source_host}:${source_file}/ $target_file/
    
}


#文件校验，如果校验失败退出，并还原

list_file
sleep 5

backup
sleep 5

brsync




