#!/bin/bash
# 作轮询记录数据的
bmc=127.0.0.1
# 获取所有传感器的数据

# 定义一个阈值
THRESHOLD=100  # 限制表中总共能存储的数据数量
COUNTNUM=30    # 当数据达到总量时候删除数据的数量
time=$(date "+%m-%d %T")
dbfile=/data/openbmc.db
tokenFile=$(cat /data/token)

# 拿到token
if [ -n "$tokenFile" ]; then
    TOKEN=$tokenFile
else
    TOKEN=$(curl -k -H "Content-Type: application/json" -X POST https://${bmc}:443/login -d '{"username" :"wtty", "password" :"5ujsGrh"}' | grep token | awk '{print $2;}' | tr -d '"')
    echo $TOKEN > /data/token
fi

# 对于的sqlite数据库的操作
# 并且按照数量条件删除数据库内容
sqlite3 $dbfile "CREATE TABLE IF NOT EXISTS sensorData (id INTEGER PRIMARY KEY, time DATETIME, rawData TEXT);"
sensorData=$(curl -k -H "X-Auth-Token: $TOKEN"  https://$bmc:443/xyz/openbmc_project/sensors/enumerate)

count=$(sqlite3 /data/openbmc.db "SELECT COUNT(*) FROM sensorData;")
if [ $count -gt $THRESHOLD ]; then
    sqlite3  $dbfile "delete from sensorData where id in (select id from sensorData order by id limit $COUNTNUM);"
else
    # 刨除不符合规则的检查数据
    if [[ $sensorData == *data* ]]; then
        sqlite3 $dbfile "INSERT INTO sensorData (time, rawData) VALUES ('$time', '$sensorData');"
    fi
fi
sqlite3 $dbfile  ".quit"


# 查看当前的 sqlite3 /data/openbmc.db "SELECT * FROM sensorData;"
