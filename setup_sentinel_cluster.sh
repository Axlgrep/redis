#!/bin/bash

CUR_DIR=$(pwd)
REDIS_CLI=$CUR_DIR/src/redis-cli
REDIS_SENTINEL=$CUR_DIR/src/redis-sentinel

# clean dirty file
cd $CUR_DIR/sentinel_cluster/5000 && rm 5000.log && cd -
cd $CUR_DIR/sentinel_cluster/5001 && rm 5001.log && cd -
cd $CUR_DIR/sentinel_cluster/5002 && rm 5002.log && cd -

# start server
cd $CUR_DIR/sentinel_cluster/5000 && $REDIS_SENTINEL ./5000-sentinel.conf && cd -
cd $CUR_DIR/sentinel_cluster/5001 && $REDIS_SENTINEL ./5001-sentinel.conf && cd -
cd $CUR_DIR/sentinel_cluster/5002 && $REDIS_SENTINEL ./5002-sentinel.conf && cd -
