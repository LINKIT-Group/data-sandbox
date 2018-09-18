#!/bin/bash

set -e

install_spark() {
  if [ ! -f "/tmp/spark-${SPARK_VERSION}-bin-hadoop2.7.tgz" ]; then
    # download files from Apache
    download_file_from_mirror "/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop2.7.tgz"
    download_signature_file "/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop2.7.tgz.sha512"

    # verify downloaded binary
    expected=$(sed -e 's/^.*://' "/tmp/spark-${SPARK_VERSION}-bin-hadoop2.7.tgz.sha512")
    actual=$(get_digest_from_file sha512 "/tmp/spark-${SPARK_VERSION}-bin-hadoop2.7.tgz")
    assert_signature "${expected}" "${actual}"
  else
    yellow "Custom-built artifact found, skipping download.."
  fi

  # deploy Spark
  blue "Deploying Spark ${SPARK_VERSION}"
  sudo -u "${SPARK_USER}" tar -xzf "/tmp/spark-${SPARK_VERSION}-bin-hadoop2.7.tgz" -C "${INSTALL_ROOT}" --no-same-owner
  sudo -u "${SPARK_USER}" ln -sf "${INSTALL_ROOT}/spark-${SPARK_VERSION}-bin-hadoop2.7" "${SPARK_HOME}"
  echo "export HADOOP_CONF_DIR=${HADOOP_CONF_DIR}" >> "${SPARK_HOME}/spark-env.sh"
  {
    # shellcheck disable=SC2016
    echo 'PATH=$PATH:${HADOOP_HOME}/bin:${SPARK_HOME}/bin'
    echo "export LD_LIBRARY_PATH=${HADOOP_HOME}/lib/native"
  } >> "${SPARK_HOME}/.bashrc"
  
  # Clean up
  blue "Cleaning up artifacts"
  rm -rf "/tmp/spark-${SPARK_VERSION}-bin-hadoop2.7.tgz" 
  if test -f "/tmp/spark-${SPARK_VERSION}-bin-hadoop2.7.tgz.sha512"; then rm -rf "/tmp/spark-${SPARK_VERSION}-bin-hadoop2.7.tgz.sha512"; fi

}

source "$(dirname "$0")/common.sh"
install_spark


