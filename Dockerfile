# from frolvlad/alpine-glibc:alpine-3.9
FROM frolvlad/alpine-glibc:alpine-3.9

# maintainer
MAINTAINER "rancococ" <rancococ@qq.com>

# set arg info
ARG ALPINE_VER=v3.9
ARG APP_HOME=/data/app
ARG JRE_HOME=/data/jre
ARG GOSU_URL=https://github.com/tianon/gosu/releases/download/1.11/gosu-amd64
ARG JRE_URL=https://github.com/rancococ/serverjre/releases/download/server-jre-8/server-jre-8u192-linux-x64.tar.gz

# copy script
COPY docker-entrypoint.sh /

# install repositories and packages : curl bash openssh wget net-tools gettext zip unzip tar tzdata ncurses procps ttf-dejavu
RUN echo -e "https://mirrors.huaweicloud.com/alpine/${ALPINE_VER}/main\nhttps://mirrors.huaweicloud.com/alpine/${ALPINE_VER}/community" > /etc/apk/repositories && \
    apk update && apk add curl bash openssh wget net-tools gettext zip unzip tar tzdata ncurses procps ttf-dejavu && \
    \rm -rf /var/cache/apk/* && \
    ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N '' && \
    ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key  -N '' && \
    ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N '' && \
    ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key  -N '' && \
    sed -i 's/#UseDNS.*/UseDNS no/g' /etc/ssh/sshd_config && \
    sed -i "s/#PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config && \
    sed -i "s/#AuthorizedKeysFile/AuthorizedKeysFile/g" /etc/ssh/sshd_config && \
    echo "Asia/Shanghai" > /etc/timezone && \ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    mkdir -p /root/.ssh && chown root.root /root && chmod 700 /root/.ssh && \
    sed -i 's/root:x:0:0:root:\/root:\/bin\/ash/root:x:0:0:root:\/root:\/bin\/bash/g' /etc/passwd && \
    mkdir -p ${APP_HOME} && mkdir -p ${JRE_HOME} && \
    addgroup -S app && adduser -S -G app -h ${APP_HOME} -s /bin/bash app && \
    tempuuid=$(cat /proc/sys/kernel/random/uuid) && mkdir -p /tmp/${tempuuid} && \
    wget -c -O /usr/local/bin/gosu --no-cookies --no-check-certificate "${GOSU_URL}" && chmod +x /usr/local/bin/gosu && \
    wget -c -O /tmp/${tempuuid}/myjre.tar.gz --no-cookies --no-check-certificate ${JRE_URL} && \
    myjrename=$(tar -tzf /tmp/${tempuuid}/myjre.tar.gz | awk -F "/" '{print $1}' | sed -n '1p') && \
    tar -xzf /tmp/${tempuuid}/myjre.tar.gz --directory=${JRE_HOME} --strip-components=2 ${myjrename}/jre && \
    \rm -rf /tmp/${tempuuid} && \
    sed -i 's@securerandom.source=file:/dev/random@securerandom.source=file:/dev/urandom@g' "${JRE_HOME}/lib/security/java.security" && \
    sed -i 's@#crypto.policy=unlimited@crypto.policy=unlimited@g' "${JRE_HOME}/lib/security/java.security" && \
    chmod -Rf u+x ${JRE_HOME}/bin/* && \
    chown -R app:app /data && \
    chown -R app:app /docker-entrypoint.sh && \
    chmod +x /docker-entrypoint.sh

# set environment
ENV LANG C.UTF-8
ENV TZ "Asia/Shanghai"
ENV TERM xterm
ENV JAVA_HOME ${JRE_HOME}
ENV JRE_HOME ${JRE_HOME}
ENV CLASSPATH .:${JRE_HOME}/lib
ENV PATH .:${PATH}:${JRE_HOME}/bin

# set work home
WORKDIR /data

# expose port 22
EXPOSE 22

# stop signal
STOPSIGNAL SIGTERM

# entry point
ENTRYPOINT ["/docker-entrypoint.sh"]

# default command
CMD ["java", "-version"]
