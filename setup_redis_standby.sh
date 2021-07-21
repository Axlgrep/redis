#!/bin/bash

CUR_DIR=$(pwd)
REDIS_CLI=$CUR_DIR/src/redis-cli
REDIS_SERVER=$CUR_DIR/src/redis-server

# clean dirty file
cd $CUR_DIR/redis_standby/8000 && rm 8000.log dump.rdb nodes.conf && cd -
cd $CUR_DIR/redis_standby/8001 && rm 8001.log dump.rdb nodes.conf && cd -
cd $CUR_DIR/redis_standby/8002 && rm 8002.log dump.rdb nodes.conf && cd -
cd $CUR_DIR/redis_standby/8003 && rm 8002.log dump.rdb nodes.conf && cd -

# start server
cd $CUR_DIR/redis_standby/8000 && $REDIS_SERVER ./8000-redis.conf && cd -
cd $CUR_DIR/redis_standby/8001 && $REDIS_SERVER ./8001-redis.conf && cd -
cd $CUR_DIR/redis_standby/8002 && $REDIS_SERVER ./8002-redis.conf && cd -
cd $CUR_DIR/redis_standby/8003 && $REDIS_SERVER ./8003-redis.conf && cd -
sleep 2

# cluster meet
$REDIS_CLI -h 127.0.0.1 -p 8000 -a abc cluster meet 127.0.0.1 8001
$REDIS_CLI -h 127.0.0.1 -p 8000 -a abc cluster meet 127.0.0.1 8002
$REDIS_CLI -h 127.0.0.1 -p 8000 -a abc cluster meet 127.0.0.1 8003
sleep 2

# alloc slot
$REDIS_CLI -h 127.0.0.1 -p 8000 -a abc cluster addslots `seq 0     16383 `

# add replicate
node8000=`$REDIS_CLI -h 127.0.0.1 -p 8000 -a abc cluster nodes | grep 8000 | awk '{print $1}'`

$REDIS_CLI -h 127.0.0.1 -p 8003 -a abc cluster replicate $node8000
