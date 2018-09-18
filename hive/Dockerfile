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

# Hive-specific configuration
ARG hive_version=3.1.0
ARG postgresql_jdbc_version=42.2.4
ENV HIVE_VERSION=${hive_version} \
    HIVE_HOME=${INSTALL_ROOT}/hive \
    HIVE_CONF_DIR=${INSTALL_ROOT}/hive/conf \
    POSTGRESQL_JDBC_DRIVER_VERSION=${postgresql_jdbc_version}
COPY scripts/install-hive.sh /tmp/
RUN chmod +x /tmp/install-hive.sh && /tmp/install-hive.sh

# Role-specific configuration
ARG hive_role=metastore
ENV HIVE_ROLE=${hive_role}
COPY --chown=hadoop:hadoop conf/hadoop/*.xml ${HADOOP_CONF_DIR}/
COPY --chown=hadoop:hadoop conf/${HIVE_ROLE}/ ${HIVE_CONF_DIR}/

COPY scripts/docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

USER hadoop

ENTRYPOINT ["/docker-entrypoint.sh"]
