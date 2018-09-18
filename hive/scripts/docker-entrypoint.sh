#!/usr/bin/env bash
set -e

function initialize_hive() {
  if ! "${HADOOP_HOME}/bin/hdfs" dfs -test -e /user/hive/warehouse; then
    echo 'Initializing Hive'
    "${HIVE_HOME}/bin/schematool" -dbType postgres -initSchema
    "${HADOOP_HOME}/bin/hdfs" dfs -mkdir -p /tmp
    "${HADOOP_HOME}/bin/hdfs" dfs -mkdir -p /user/hive/warehouse
    "${HADOOP_HOME}/bin/hdfs" dfs -chown -R hive:hadoop /user/hive
    "${HADOOP_HOME}/bin/hdfs" dfs -chmod g+w /tmp
    "${HADOOP_HOME}/bin/hdfs" dfs -chmod g+w /user/hive/warehouse
  fi
}

case "${HIVE_ROLE}" in
    metastore) 
        initialize_hive
        echo 'Starting Hive metastore'
        exec "${HIVE_HOME}/bin/hive" --service metastore
        ;;
    server)
        echo 'Starting hiveserver2'
        exec "${HIVE_HOME}/bin/hive" --service hiveserver2
        ;;
    *) "Unsupported role ${HIVE_ROLE}"; exit 1 ;;
esac
