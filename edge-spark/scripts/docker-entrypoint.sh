#!/usr/bin/env bash
set -e

function setup_spark_hdfs() {
  local spark_hdfs_home=/user/spark
  if ! "${HADOOP_HOME}/bin/hdfs" dfs -test -d $spark_hdfs_home/jars ; then
    blue "Creating Spark HDFS home directory"
    "${HADOOP_HOME}/bin/hdfs" dfs -mkdir -p "${spark_hdfs_home}/jars"
    "${HADOOP_HOME}/bin/hdfs" dfs -chown -R spark:hadoop "${spark_hdfs_home}"
    jar cvf /tmp/spark-libs.jar -C $SPARK_HOME/jars/ .
    "${HADOOP_HOME}/bin/hdfs" dfs -put /tmp/spark-libs.jar "${spark_hdfs_home}/jars/spark-libs.jar"
  fi
  
}

function finish() {
    blue "Shutting down edge container"
}
trap finish EXIT

source /tmp/common.sh

setup_spark_hdfs
blue "Starting up Spark edge container"
sleep infinity

