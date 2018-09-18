#!/bin/bash

set -e

install_hive() {
  if [ ! -f "/tmp/apache-hive-${HIVE_VERSION}-bin.tar.gz" ]; then
    # download files from Apache
    download_file_from_mirror "/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz"
    # download PostgreSQL JDBC driver
    download_file "https://jdbc.postgresql.org/download/postgresql-${POSTGRESQL_JDBC_DRIVER_VERSION}.jar" /usr/share/java/postgresql-jdbc.jar
    
    yellow "Skipping verification, no digests published online!"
  else
    yellow "Custom-built artifact found, skipping download.."
  fi

  # deploy Hive
  blue "Deploying Hive ${HIVE_VERSION}"
  sudo -u hadoop tar -xzf "/tmp/apache-hive-${HIVE_VERSION}-bin.tar.gz" -C "${INSTALL_ROOT}" --no-same-owner
  sudo -u hadoop ln -sf "${INSTALL_ROOT}/apache-hive-${HIVE_VERSION}-bin" "${HIVE_HOME}"
  sudo -u hadoop ln -sf /usr/share/java/postgresql-jdbc.jar "${HIVE_HOME}/lib"
  {
    echo "HIVE_HOME=${HIVE_HOME}"
    echo "HIVE_CONF_DIR=${HIVE_CONF_DIR}"
    echo "HADOOP_HOME=${HADOOP_HOME}"
    echo "HADOOP_CONF_DIR=${HADOOP_CONF_DIR}"
  } >> "${INSTALL_ROOT}/hive/hive-env.sh"
    # shellcheck disable=SC2016
  echo 'PATH=$PATH:${HIVE_HOME}/bin' >> "${INSTALL_ROOT}/.bashrc"

  # Clean up
  rm -f "/tmp/apache-hive-${HIVE_VERSION}-bin.tar.gz" 
}

source "$(dirname "$0")/common.sh"
sudo -u hadoop touch "${INSTALL_ROOT}/.bashrc"
install_hive


