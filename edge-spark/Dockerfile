FROM openjdk:8-jdk-slim-stretch

LABEL maintainer="Dimitris Stafylarakis 'dimitris.stafylarakis@linkit.nl'"

# Common configuration
ENV INSTALL_ROOT=/opt/hadoop \
    JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

RUN apt update && \
    apt install -y --no-install-recommends sudo curl rsync ssh pdsh jq vim net-tools && \    
    apt clean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p ${INSTALL_ROOT} && \
    groupadd hadoop && \
    useradd -d ${INSTALL_ROOT} -g hadoop hadoop && \
    useradd -d ${INSTALL_ROOT} -g hadoop hdfs && \
    useradd -d ${INSTALL_ROOT} -g hadoop yarn && \
    chown -R hadoop:hadoop ${INSTALL_ROOT} && \
    chmod 775 ${INSTALL_ROOT}
COPY scripts/common.sh bin/* /tmp/

# Hadoop-specific configuration
ARG hadoop_version=3.1.1
ENV HADOOP_VERSION=${hadoop_version} \
    HADOOP_HOME=${INSTALL_ROOT}/hadoop \
    HADOOP_CONF_DIR=${INSTALL_ROOT}/hadoop-${hadoop_version}/etc/hadoop
COPY scripts/install-hadoop.sh /tmp/
RUN chmod +x /tmp/install-hadoop.sh && /tmp/install-hadoop.sh

# Spark-specific configuration
ARG spark_version=2.3.1
ARG scala_version=2.11
ENV SPARK_VERSION=${spark_version} \
    SCALA_VERSION=${scala_version} \ 
    SPARK_HOME=${INSTALL_ROOT}/spark \
    SPARK_CONF_DIR=${INSTALL_ROOT}/spark/conf \
    SPARK_USER=spark
COPY scripts/install-spark.sh /tmp/
RUN useradd -M -d ${SPARK_HOME} -g hadoop spark && \
    chmod +x /tmp/install-spark.sh && \
    /tmp/install-spark.sh

# Role-specific configuration
COPY conf/hadoop/*.xml ${HADOOP_CONF_DIR}/
COPY conf/spark/* ${SPARK_CONF_DIR}/

COPY scripts/docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

USER hadoop

ENTRYPOINT ["/docker-entrypoint.sh"]
