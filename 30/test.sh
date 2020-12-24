#!/bin/bash

# copy jdk，node_export,filebeat 


#修改時間  
sudo rm -rf /etc/localtime
sudo ln -s /usr/share/zoninfo/Asia/Shanghai /etc/localtime
date
#修改ssh 端口號
sudo sed -i 's/^#Port 22/Port 22822/g' /etc/ssh/sshd_config

#磁盤格式化
sudo parted -s -a optimal /dev/nvme1n1 mklabel gpt -- mkpart primary xfs 1 -1
sudo mkfs.xfs /dev/nvme1n1p1
sudo sh -c "echo '/dev/nvme1n1p1   /data   xfs defaults    0 0' "
sudo mkdir -p /data/{local/app,logs,backup}
sudo chown -R ec2-user.ec2-user /data
sudo mount -a 

sudo yum install telnet tree  -y 

sudo systemctl restart sshd 


