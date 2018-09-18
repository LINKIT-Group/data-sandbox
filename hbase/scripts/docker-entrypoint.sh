#!/usr/bin/env bash
set -e

export HBASE_CLASSPATH="${HBASE_HOME}/lib/client-facing-thirdparty/htrace-core-3.1.0-incubating.jar"

case "${HBASE_ROLE}" in
    master)         
        echo 'Starting HBase master'
        "${HBASE_HOME}/bin/hbase" --config "${HBASE_CONF_DIR}" master start
        ;;
    regionserver)
        echo 'Starting HBase regionserver'
        "${HBASE_HOME}/bin/hbase" --config "${HBASE_CONF_DIR}" regionserver start
        ;;
    *) "Unsupported role ${HBASE_ROLE}"; exit 1 ;;
esac
