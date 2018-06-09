#!/bin/bash

DOCKER_DIR=./docker-download
WORK_DIR=/data/docker


mkdir -p /usr/lib/systemd/system/
systemctl stop docker.service >/dev/null 2>&1
cp ${DOCKER_DIR}/* /usr/bin/
rm -r ${WORK_DIR}
mkdir -p ${WORK_DIR}




cat <<EOF >/usr/lib/systemd/system/docker.service
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network.target docker.socket firewalld.service
Requires=docker.socket

[Service]
Type=notify
# the default is not to use systemd for cgroups because the delegate issues still
# exists and systemd currently does not support the cgroup feature set required
# for containers run by docker
ExecStart=/usr/bin/dockerd -H fd://
ExecReload=/bin/kill -s HUP $MAINPID
LimitNOFILE=1048576
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNPROC=infinity
LimitCORE=infinity
# Uncomment TasksMax if your systemd version supports it.
# Only systemd 226 and above support this version.
#TasksMax=infinity
TimeoutStartSec=0
# set delegate yes so that systemd does not reset the cgroups of docker containers
Delegate=yes
# kill only the docker process, not all processes in the cgroup
KillMode=process

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable docker
systemctl restart docker

echo "## docker version"
docker version