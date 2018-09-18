#!/bin/bash

set -e

install_kafka() {
  if [ ! -f "/tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz" ]; then
    # download files from Apache
    download_file_from_mirror "/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz"
    download_signature_file "/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz.sha512"

    # verify downloaded binary
    expected=$(sed -e 's/^.*://' "/tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz.sha512")
    actual=$(get_digest_from_file sha512 "/tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz")
    assert_signature "${expected}" "${actual}"
  else
    yellow "Custom-build artifact found, skipping download"
  fi

  # deploy Kafka
  sudo -u kafka tar -xzf "/tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz" -C "${INSTALL_ROOT}" --no-same-owner
  sudo -u kafka ln -sf "${INSTALL_ROOT}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}" "${KAFKA_HOME}"
  echo "PATH=${PATH}:${KAFKA_HOME}/bin" | sudo -u kafka tee -a "${INSTALL_ROOT}/.bashrc"

  # Clean up
  blue "Cleaning up artifacts"
  rm -rf "/tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz" 
  if test -f "/tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz.sha512"; then rm -rf "/tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz.sha512"; fi

}

source "$(dirname "$0")/common.sh"
install_kafka


