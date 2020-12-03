shardNum=32
oldShard=32
portBegin=20000
redisserver=/root/redis/src/redis-server

for((i=1; i<=$oldShard; i++))
do
	sh -c "redis-cli -p `expr $portBegin + $i` shutdown"
	rm -rf master$i
done

for ((i=1; i<=$shardNum; i++))
do
	mkdir master$i
	cd master$i
	rm -rf redis.conf
	sh -c "cp $redisserver ./ -rf"
	echo  "port "`expr $i + $portBegin`>>redis.conf
	echo "cluster-enabled yes">>redis.conf
	echo "cluster-config-file nodes.conf">>redis.conf
	echo "cluster-node-timeout 15000">>redis.conf
	./redis-server ./redis.conf &
	cd ..
done

#join cluster
for ((i=2; i<=$shardNum; i++))
do
	redis-cli -p `expr $portBegin + $i` cluster meet 127.0.0.1 `expr $portBegin + 1`
done

slotNum=`expr 16384 / $shardNum`
beginSlot=0
for ((i=1; i<=$shardNum; i++))
do
	for ((j=0; j<slotNum;j++))
	do
		redis-cli -p `expr $portBegin + $i` cluster addslots $beginSlot > /dev/null
		beginSlot=`expr $beginSlot + 1`
	done
	echo "finished addslots $beginSlot"
done

for ((i=$beginSlot; i<16384; i++))
do
	redis-cli -p `expr $portBegin + $shardNum` cluster addslots $i > /dev/null
done
echo "finished 16384"
