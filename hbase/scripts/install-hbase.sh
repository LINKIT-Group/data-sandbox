#!/bin/bash

set -e

install_hbase() {
  if [ ! -f "/tmp/hbase-${HBASE_VERSION}-bin.tar.gz" ]; then
    # download files from Apache
    download_file_from_mirror "/hbase/${HBASE_VERSION}/hbase-${HBASE_VERSION}-bin.tar.gz"
    download_signature_file "/hbase/${HBASE_VERSION}/hbase-${HBASE_VERSION}-bin.tar.gz.sha512"  

    # verify downloaded binary
    expected=$(sed -e 's/^.*://' "/tmp/hbase-${HBASE_VERSION}-bin.tar.gz.sha512")
    actual=$(get_digest_from_file sha512 "/tmp/hbase-${HBASE_VERSION}-bin.tar.gz")
    assert_signature "${expected}" "${actual}"
  else
    yellow "Custom-built artifact found, skipping download.."
  fi

  # deploy HBase
  blue "Deploying HBase ${HBASE_VERSION}"
  sudo -u hadoop tar -xzf "/tmp/hbase-${HBASE_VERSION}-bin.tar.gz" -C "${INSTALL_ROOT}" --no-same-owner
  sudo -u hadoop ln -sf "${INSTALL_ROOT}/hbase-${HBASE_VERSION}" "${HBASE_HOME}"
  {
    echo "HBASE_MANAGES_ZK=false"
    echo "JAVA_HOME=${JAVA_HOME}"
    echo "HBASE_ROOT_LOGGER=INFO,console"
    echo "HBASE_CONF_DIR=${HBASE_CONF_DIR}"
    echo "HADOOP_HOME=${HADOOP_HOME}"
    echo "HADOOP_CONF_DIR=${HADOOP_CONF_DIR}"
  } >> "${HBASE_CONF_DIR}/hbase-env.sh"
  # shellcheck disable=SC2016
  echo 'PATH=$PATH:${HBASE_HOME}/bin' >> "${INSTALL_ROOT}/.bashrc"

  # Clean up
  blue "Cleaning up HBase Artifacts"
  rm -f "/tmp/hbase-${HBASE_VERSION}-bin.tar.gz" 
  if test -f "/tmp/hbase-${HBASE_VERSION}-bin.tar.gz.sha512"; then rm -f "/tmp/hbase-${HBASE_VERSION}-bin.tar.gz.sha512"; fi 
}

source "$(dirname "$0")/common.sh"
sudo -u hadoop touch "${INSTALL_ROOT}/.bashrc"
install_hbase


