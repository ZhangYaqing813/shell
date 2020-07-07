#!/bin/bash
source_file=/data/rsync_test
target_file=/data/test_rsync
source_host=172.16.151.11
data_backup=/tmp/test_rsync
checksum=/data/checksum
check_res=md5sum.md5
#显示目标目录文件

checkfile() {
    #备份文件是否完整
    #$1 为校验结果存放的目录
    #$2 校验结果文件
    a=0
    echo "checkfile 执行中======="
    cd $1

    echo "$1/$2 -----"
    while read sum file
    do
        echo "while 执行"
        flag=`sha256sum $file |awk '{print $1}'`
        if [[ ${flag} == ${sum} ]]; then
            echo " sucess"
        else
            echo " faild"
        fi
    done <$1/$2

}

list_file() {
    echo "###显示目标目录文件"
    rsync root@${source_host}:${source_file}/
    echo "<----------------------------->"
    echo "###显示源目录文件"
    rsync ${target_file}/

}
#同步前备份
backup() {
    echo "执行备份----------"
    
    if [[ "$(ls -A ${data_backup})"="" ]]; then
        
        echo ">>>>>>>>>>>>>>>>>>"
        rm -rf ${data_backup}/*
        sudo sha256sum ${target_file}/* >${data_backup}/${check_res}
        flag=$(rsync -a --backup --backup-dir=${data_backup}/ ${target_file}/ ${data_backup}/)
        checkfile ${data_backup} ${check_res}
    else
        echo "<<<<<<<<<<<<<<<<<<<<<<<<"
        flag=$(rsync -a --backup --backup-dir=${data_backup}/ ${target_file}/ ${data_backup}/)
        #备份完后再次校验备份文件
        checkfile ${data_backup} ${check_res}
    fi
}
#执行同步

brsync() {
    echo "开始同步--------"
    ssh root@${source_host} "md5sum ${source_file}/* >${source_file}/${check_res}"
    rsync -a -e "ssh -p 22" root@${source_host}:${source_file}/ $target_file/
    checkfile ${target_file} ${check_res}

}

#文件校验，如果校验失败退出，并还原

#list_file
#sleep 5


backup
sleep 5
brsync
#brsync
