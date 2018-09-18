#!/usr/bin/env bash
set -e

function configure_broker() {
  # Dirty hack: schema registry does not support named endpoints
  # see https://github.com/confluentinc/schema-registry/issues/648
  echo "Configuring Kafka broker"
  cat << EOF > "${KAFKA_HOME}/config/server.properties"
  broker.id=${BROKER_ID}
  log.dir=${INSTALL_ROOT}/data
  zookeeper.connect=${ZOOKEEPER_CONNECT}
  advertised.listeners=PLAINTEXT://:9095,EXTERNAL://kafka${BROKER_ID}.localhost:${PORT}
  listeners=PLAINTEXT://:9095,EXTERNAL://:${PORT}
  listener.security.protocol.map=PLAINTEXT:PLAINTEXT,EXTERNAL:PLAINTEXT
  inter.broker.listener.name=PLAINTEXT
EOF
}

configure_broker
"${KAFKA_HOME}/bin/kafka-server-start.sh" "${KAFKA_HOME}/config/server.properties"
