# docker-oraclejre

#### 项目介绍
docker-oraclejre

support os:
1. alpine:curl bash openssh wget net-tools gettext zip unzip tzdata ncurses ttf-dejavu
2. centos:passwd openssl openssh-server wget net-tools gettext zip unzip ncurses

support tool
1. sshd, jre
2. apphome: /data/app
3  jrehome: /data/jre
4. user: root/admin; app/123456
5. usage:
docker run -it --rm --name oraclejre-1.8.0_192-alpine registry.cn-hangzhou.aliyuncs.com/rancococ/oraclejre:1.8.0_192-alpine "bash"
docker run -it --rm --name oraclejre-1.8.0_192-centos registry.cn-hangzhou.aliyuncs.com/rancococ/oraclejre:1.8.0_192-centos "bash"
