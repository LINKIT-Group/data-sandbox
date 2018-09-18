FROM openjdk:8-jdk-slim-stretch

LABEL maintainer="Dimitris Stafylarakis 'dimitris.stafylarakis@linkit.nl'"

# Common configuration
ENV INSTALL_ROOT=/opt/hadoop \
    JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

RUN apt update && \
    apt install -y --no-install-recommends sudo curl rsync ssh pdsh jq vim net-tools && \    
    apt clean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p ${INSTALL_ROOT}/data && \
    groupadd hadoop && \ 
    useradd -d ${INSTALL_ROOT} -g hadoop hadoop && \
    useradd -d ${INSTALL_ROOT} -g hadoop hdfs && \
    useradd -d ${INSTALL_ROOT} -g hadoop yarn && \
    useradd -g hadoop spark && \
    chown -R hadoop:hadoop ${INSTALL_ROOT}
COPY scripts/common.sh bin/* /tmp/

# Hadoop-specific configuration
ARG hadoop_version=3.1.1
ENV HADOOP_VERSION=${hadoop_version} \
    HADOOP_HOME=${INSTALL_ROOT}/hadoop \
    HADOOP_CONF_DIR=${INSTALL_ROOT}/hadoop-${hadoop_version}/etc/hadoop
COPY scripts/install-hadoop.sh /tmp/
RUN chmod +x /tmp/install-hadoop.sh && /tmp/install-hadoop.sh

# HBase-specific configuration
ARG hbase_version=2.1.0
ENV HBASE_VERSION=${hbase_version} \
    HBASE_HOME=${INSTALL_ROOT}/hbase \
    HBASE_CONF_DIR=${INSTALL_ROOT}/hbase/conf
COPY scripts/install-hbase.sh /tmp/
RUN chmod +x /tmp/install-hbase.sh && /tmp/install-hbase.sh

# Role-specific configuration
ARG hbase_role=master
ENV HBASE_ROLE=${hbase_role}
COPY --chown=hadoop:hadoop conf/hadoop/*.xml ${HADOOP_CONF_DIR}/
COPY --chown=hadoop:hadoop conf/${HBASE_ROLE}/ ${HBASE_CONF_DIR}/

COPY scripts/docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

USER hadoop

ENTRYPOINT ["/docker-entrypoint.sh"]
