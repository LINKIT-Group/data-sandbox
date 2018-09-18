# BigData sandbox

## Overview

This repository contains a data engineering stack managed by docker-compose. It comprises the following components:

* Hadoop cluster (name node, resource manager and data nodes)
* Kafka cluster (brokers)
* Confluent schema registry
* ZooKeeper cluster
* Hive metastore (PostgreSQL backed)/hive server2
* HBase master/region-server
* Edge node with Spark installed

## Design

### Component structure

Each component has its own folder, this will allow for independent generation from templates in the future.

The conventional folder structure is as follows:

```Text
<component name>
 /bin: place binaries to use instead of downloading
 /conf: configuration files, grouped per role
   /<role1>
   /<role2>
 /input: used as a mounted volume to easily transfer files to/from containers
 /scripts: installation scripts and entrypoint script
 Dockerfile
```

* reuse image layers wherever possible
* use docker-entrypoint.sh to start up the required process
* Use roles to configure image at build/run time (e.g. HIVE_ROLE=metastore)
