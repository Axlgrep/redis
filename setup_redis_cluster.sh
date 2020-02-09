#!/bin/bash

CUR_DIR=$(pwd)
REDIS_CLI=$CUR_DIR/src/redis-cli
REDIS_SERVER=$CUR_DIR/src/redis-server

# clean dirty file
cd $CUR_DIR/redis_cluster/7000 && rm 7000.log dump.rdb nodes.conf && cd -
cd $CUR_DIR/redis_cluster/7001 && rm 7001.log dump.rdb nodes.conf && cd -
cd $CUR_DIR/redis_cluster/7002 && rm 7002.log dump.rdb nodes.conf && cd -
cd $CUR_DIR/redis_cluster/7003 && rm 7003.log dump.rdb nodes.conf && cd -
cd $CUR_DIR/redis_cluster/7004 && rm 7004.log dump.rdb nodes.conf && cd -
cd $CUR_DIR/redis_cluster/7005 && rm 7005.log dump.rdb nodes.conf && cd -

# start server
cd $CUR_DIR/redis_cluster/7000 && $REDIS_SERVER ./7000-redis.conf && cd -
cd $CUR_DIR/redis_cluster/7001 && $REDIS_SERVER ./7001-redis.conf && cd -
cd $CUR_DIR/redis_cluster/7002 && $REDIS_SERVER ./7002-redis.conf && cd -
cd $CUR_DIR/redis_cluster/7003 && $REDIS_SERVER ./7003-redis.conf && cd -
cd $CUR_DIR/redis_cluster/7004 && $REDIS_SERVER ./7004-redis.conf && cd -
cd $CUR_DIR/redis_cluster/7005 && $REDIS_SERVER ./7005-redis.conf && cd -
sleep 2

# cluster meet
$REDIS_CLI -h 127.0.0.1 -p 7000 cluster meet 127.0.0.1 7001
$REDIS_CLI -h 127.0.0.1 -p 7000 cluster meet 127.0.0.1 7002
$REDIS_CLI -h 127.0.0.1 -p 7000 cluster meet 127.0.0.1 7003
$REDIS_CLI -h 127.0.0.1 -p 7000 cluster meet 127.0.0.1 7004
$REDIS_CLI -h 127.0.0.1 -p 7000 cluster meet 127.0.0.1 7005
sleep 2

# alloc slot
$REDIS_CLI -h 127.0.0.1 -p 7000 cluster addslots `seq 0     5461 `
$REDIS_CLI -h 127.0.0.1 -p 7001 cluster addslots `seq 5462  11282`
$REDIS_CLI -h 127.0.0.1 -p 7002 cluster addslots `seq 11283 16383`

# add replicate
node7000=`$REDIS_CLI -h 127.0.0.1 -p 7000 cluster nodes | grep 7000 | awk '{print $1}'`
node7001=`$REDIS_CLI -h 127.0.0.1 -p 7000 cluster nodes | grep 7001 | awk '{print $1}'`
node7002=`$REDIS_CLI -h 127.0.0.1 -p 7000 cluster nodes | grep 7001 | awk '{print $1}'`

$REDIS_CLI -h 127.0.0.1 -p 7003 cluster replicate $node7000
$REDIS_CLI -h 127.0.0.1 -p 7004 cluster replicate $node7001
$REDIS_CLI -h 127.0.0.1 -p 7005 cluster replicate $node7002


