#!/bin/bash

set -e

install_hadoop() {
  if [ ! -f "/tmp/hadoop-${HADOOP_VERSION}.tar.gz" ]; then
    # download files from Apache
    download_file_from_mirror "/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz"
    download_signature_file "/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz.mds"

    # verify downloaded binary
    expected=$(sed -ne '/SHA512/,$ {s/.*SHA512 = //I; p; }' "/tmp/hadoop-${HADOOP_VERSION}.tar.gz.mds")
    actual=$(get_digest_from_file sha512 "/tmp/hadoop-${HADOOP_VERSION}.tar.gz")
    assert_signature "${expected}" "${actual}"
  else
    yellow "Custom-built artifact found, skipping download.."
  fi

  # deploy Hadoop
  blue "Deploying Hadoop ${HADOOP_VERSION}"
  sudo -u hadoop tar -xzf "/tmp/hadoop-${HADOOP_VERSION}.tar.gz" -C "${INSTALL_ROOT}" --no-same-owner --exclude="hadoop-${HADOOP_VERSION}/share/doc"
  sudo -u hadoop ln -sf "${INSTALL_ROOT}/hadoop-${HADOOP_VERSION}" "${HADOOP_HOME}"
  echo "export JAVA_HOME=${JAVA_HOME}" >> "${HADOOP_CONF_DIR}/hadoop-env.sh"
  # shellcheck disable=SC2016
  echo 'PATH=$PATH:${HADOOP_HOME}/bin' >> "${INSTALL_ROOT}/.bashrc"

  # Clean up
  blue "Cleaning up Hadoop artifacts"
  rm -f "/tmp/hadoop-${HADOOP_VERSION}.tar.gz" 
  if test -f "/tmp/hadoop-${HADOOP_VERSION}.tar.gz.mds"; then rm -f "/tmp/hadoop-${HADOOP_VERSION}.tar.gz.mds"; fi
}

source "$(dirname "$0")/common.sh"
sudo -u hadoop touch "${INSTALL_ROOT}/.bashrc"
install_hadoop


