FROM openjdk:8-jdk-slim-stretch

LABEL maintainer="Dimitris Stafylarakis 'dimitris.stafylarakis@linkit.nl'"

# Common configuration
ENV INSTALL_ROOT=/opt/kafka \
  JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

RUN apt update && \
    apt install -y --no-install-recommends sudo curl rsync ssh pdsh jq vim net-tools && \    
    apt clean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p ${INSTALL_ROOT}/data && \
    groupadd kafka && \
    useradd -d ${INSTALL_ROOT} -g kafka kafka && \
    chown -R kafka:kafka ${INSTALL_ROOT}
COPY scripts/common.sh bin/* /tmp/

# Kafka-specific configuration
ARG kafka_version=2.0.0
ARG scala_version=2.12
ENV KAFKA_VERSION=${kafka_version} \
    SCALA_VERSION=${scala_version} \
    KAFKA_HOME=${INSTALL_ROOT}/kafka
COPY scripts/install-kafka.sh /tmp/
RUN chmod +x /tmp/install-kafka.sh && /tmp/install-kafka.sh

COPY scripts/docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

VOLUME ["${INSTALL_ROOT}/data"]

USER kafka

ENTRYPOINT ["/docker-entrypoint.sh"]
