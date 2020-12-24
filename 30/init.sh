#!/bin/bash
key=~
host=$1
# copy jdk，node_export,filebeat 
scp -i ${key} /data/packages/jdk.tar.gz  $host:~/
scp -i ${key} /data/packages/filebeat-5.6.0.tar.gz  $host:~/
scp -i ${key} -r /data/local/node_exporter  $host:~/
 

#修改時間  
ssh -i ${key} ${host} "sudo rm -rf /etc/localtime"
ssh -i ${key} ${host}  "sudo ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime"

ssh -i ${key} ${host} date
#修改ssh 端口號
ssh -i ${key} ${host} "sudo sed -i 's/^#Port 22/Port 22822/g' /etc/ssh/sshd_config"

#磁盤格式化
ssh -i ${key} ${host} sudo parted -s -a optimal /dev/nvme1n1 mklabel gpt -- mkpart primary xfs 1 -1
ssh -i ${key} ${host} sudo mkfs.xfs /dev/nvme1n1p1
ssh -i ${key} ${host} "sudo sed -i  '$ a/dev/nvme1n1p1   /data   xfs defaults    0 0' /etc/fstab" 

ssh -i ${key} ${host} "sudo mkdir /data" 
ssh -i ${key} ${host} sudo chown -R ec2-user.ec2-user /data
ssh -i ${key} ${host} "sudo mount -a" 


ssh -i ${key} ${host} sudo mkdir -p /data/{local/app,logs,backup}
ssh -i ${key} ${host} "sudo mv ~/* /data/local/"
ssh -i ${key} ${host} "cd /data/local/ && sudo tar xf /data/local/jdk.tar.gz"


ssh -i ${key} ${host} "sed -i '/# User specific environment and startup programs/a JAVA_HOME=/data/local/jdk1.8.0_211/bin\nPATH=$PATH:$HOME/.local/bin:$HOME/bin:$JAVA_HOME\n' ~/.bash_profile"

ssh -i ${key} ${host} "source ~/.bash_profile"
ssh -i ${key} ${host} "cd /data/local/node_exporter && sudo ./node_exporter &"

ssh -i ${key} ${host} sudo yum install telnet tree  -y 
ssh -i ${key} ${host} sudo systemctl restart sshd 

