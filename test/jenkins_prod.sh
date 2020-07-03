#!/bin/bash
build_dir_web=/data/local/jenkins/workspace/blcok-signature/sig-web/target
build_dir_client=/data/local/jenkins/workspace/blcok-signature/sig-client/target
build_dir_server=/data/local/jenkins/workspace/blcok-signature/sig-server/target
deploy_dir=/data/local/app
app_web=sig-web-0.0.1-SNAPSHOT.jar
app_client=sig-client-0.0.1-SNAPSHOT.jar
app_server=sig-server-0.0.1-SNAPSHOT.jar
host_web=10.10.2.93
host_client=10.20.2.45
host_server=10.20.2.180
key=/home/ec2-user/bittok_super.pem
service=$1


app_web(){
    echo "当前选择服务： >>>>>> app_web >>>>>>"
    #停掉原有的服务
    ssh -i ${key} ec2-user@${host_web} "ps -ef | grep sig-web-0.0.1-SNAPSHOT.jar | grep -v grep | awk '{print \$2}' |xargs kill -9"
    #jar 包进行备份
    ssh -i ${key} ec2-user@${host_web} "sudo mv ${deploy_dir}/${app_web} /data/backup/${app_web}`date +%Y%m%d%H%M%S`"
    #jar copy
    scp -i ${key} ${build_dir_web}/${app_web} ec2-user@${host_web}:${deploy_dir}/
    #服务启动
    ssh -i ${key} ec2-user@${host_web} "source ~/.bash_profile;nohup java -server -Xms256m -Xmx512m -jar ${deploy_dir}/${app_web} --spring.profiles.active=test >>/dev/null 2>&1 &"
    echo ">>>>>>app_web 执行完成>>>>>>"
}

app_client(){
    echo "--------${app_client}--------"
    #ssh -i ${key} ec2-user@${host_client} "ps -ef | grep sig-client-0.0.1-SNAPSHOT.jar | grep -v grep | awk '{print \$2}' |xargs kill -9"
    #jar 包进行备份
    ssh -i ${key} ec2-user@${host_client} "cp ${deploy_dir}/${app_client} /data/backup/${app_client}`date +%Y%m%d%H%M%S`"

    #jar copy
    scp -i ${key} ${build_dir_client}/${app_client} ec2-user@${host_client}:${deploy_dir}/test_client.jar

    echo "--------${app_client}执行完成--------"
}

app_server(){
    echo "************${app_server}**********"
    #ssh -i ${key} ec2-user@${host_server} "ps -ef | grep sig-server-0.0.1-SNAPSHOT.jar | grep -v grep | awk '{print \$2}' |xargs kill -9"
    ssh -i ${key} ec2-user@${host_server} "cp ${deploy_dir}/${app_server} /data/backup/${app_server}`date +%Y%m%d%H%M%S`"
    #jar copy
    scp -i ${key} ${build_dir_server}/${app_server} ec2-user@${host_server}:${deploy_dir}/test_server.jar

    echo "************${app_server}执行完成**********"
}


case "${service}" in

    "sig-web")
        app_web
        ;;

    "sig-client")
        app_client
        ;;

    "sig-server")
        app_server
        ;;

    "all")
        echo ""
        app_web
        app_server
        app_client
        ;;
    *)
        echo "未找到服务"
        ;;

esac
