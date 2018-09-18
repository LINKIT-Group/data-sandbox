#!/usr/bin/env bash
set -e

source /tmp/common.sh

function format_namenode() {
  if [ "$(ls -A /opt/hadoop/data)" == "" ]; then
      yellow "Formatting name directory"
      "${HADOOP_HOME}/bin/hdfs" --config "${HADOOP_HOME}/etc/hadoop" namenode -format "${CLUSTER_NAME}"
  fi
}

function cleanup_pid_file() {
  local role="${1:-$HADOOP_ROLE}"
  local pid_file="${1:-/tmp/hadoop-hadoop-$role.pid}"
  if [ -f "$pid_file" ]; then
    yellow "Removing old PID file"
    rm "$pid_file"
  fi
}

case "${HADOOP_ROLE}" in
    namenode) 
        format_namenode
        cleanup_pid_file
        blue 'Starting NameNode'
        exec "${HADOOP_HOME}/bin/hdfs" --config "${HADOOP_HOME}/etc/hadoop" namenode
        ;;
    resourcemanager) 
        cleanup_pid_file
        blue 'Starting Hadoop ResourceManager'
        exec "${HADOOP_HOME}/bin/yarn" --config "${HADOOP_HOME}/etc/hadoop" resourcemanager
        ;;
    datanode) 
        cleanup_pid_file
        blue 'Starting Hadoop data node'
        "${HADOOP_HOME}/bin/hdfs" --config "${HADOOP_HOME}/etc/hadoop" --daemon start datanode

        cleanup_pid_file nodemanager
        blue 'Starting Hadoop node manager'
        exec "${HADOOP_HOME}/bin/yarn" --config "${HADOOP_HOME}/etc/hadoop" nodemanager
        ;;
    *) "Unsupported role ${HIVE_ROLE}"; exit 1 ;;
esac
