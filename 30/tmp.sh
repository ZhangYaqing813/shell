#!/bin/bash
job_name=$(echo ${JOB_NAME} | cut -f2- -d'_' )

build_dir=/data/jenkins/jenkins/workspace/${JOB_NAME}/${job_name}/
deploy_dir=/data/local/app
app_name=$(ls ${build_dir} | grep "jar$")
host=$1
port=$2    

key=/home/ec2-user/.cmes-prod.pem
active=prod

ip_arr=(172.17.11.20 172.17.12.31 172.17.13.9)

JVM_OPT_01='-server -Xmx4G -Xms4G -XX:MetaspaceSize=512m -XX:MaxMetaspaceSize=512m  -XX:+UnlockExperimentalVMOptions -XX:+UseZGC'
JVM_OPT_exchange='-Xmx21824M -Xms21824M -XX:MaxMetaspaceSize=512M -XX:MetaspaceSize=512M -XX:MaxGCPauseMillis=100 -XX:+ParallelRefProcEnabled -XX:+UnlockExperimentalVMOptions -XX:+UseZGC'

JVM_OPT_market='Xmx5440M -Xms5440M -XX:MaxMetaspaceSize=512M -XX:MetaspaceSize=512M  -XX:MaxGCPauseMillis=100 -XX:+ParallelRefProcEnabled -XX:+UnlockExperimentalVMOptions -XX:+UseZGC'
JVM_OPT_account='-Xmx8192M -Xms8192M -XX:MetaspaceSize=512m -XX:MaxMetaspaceSize=512m  -XX:+UnlockExperimentalVMOptions -XX:+UseZGC'


Backup(){
	ssh -i ${key} ec2-user@${host} "mv ${deploy_dir}/${app_name} /data/backup/${app_name}`date +%Y%m%d%H%M%S`"

}


# 检查服务是否运行
CheckP(){
	if [[ ${pid} < '1' ]];then
		echo " 当前服务启动失败 "

	else 
		echo "服务启动成功"
	fi
}


Deploy(){
	pid=$(ssh -i ${key} ec2-user@${host} ps -ef | grep ${app_name} | grep -v grep | awk '{print $2}' )
	ssh -i ${key}  ec2-user@${host} "kill -9 ${pid}"
	scp -i ${key} ${source_file}/${app_name} ec2-user@${host}:${deploy_dir}/
	
#	ssh -i ${key} ec2-user@${host} "source ~/.bash_profile;nohup java ${JVM_OPT_exchange} -jar ${deploy_dir}/${app_name} --spring.profiles.active=${active} >>/dev/null 2>&1 &"
	
#	ssh -i ${key} ec2-user@${host} "source ~/.bash_profile;nohup java ${JVM_OPT_market} -jar ${deploy_dir}/${app_name} --spring.profiles.active=${active} >>/dev/null 2>&1 &"
	
#	ssh -i ${key} ec2-user@${host} "source ~/.bash_profile;nohup java ${JVM_OPT_account} -jar ${deploy_dir}/${app_name} --spring.profiles.active=${active} >>/dev/null 2>&1 &"

	ssh -i ${key} ec2-user@${host} "source ~/.bash_profile;nohup java ${JVM_OPT_01} -jar ${deploy_dir}/${app_name} --spring.profiles.active=${active} >>/dev/null 2>&1 &"

}


if [[ ${host} == "all" ]];then
    for host in "${ip_arr[@]}"
	do
        Backup
        echo "备份中======>"
        sleep 2

        Deploy
        echo "检查服务启动*******"
        sleep 3
        CheckP
	done	
else 
    Backup
    echo "备份中======>"
    sleep 2

    Deploy
    echo "检查服务启动*******"
    sleep 3
    CheckP
fi