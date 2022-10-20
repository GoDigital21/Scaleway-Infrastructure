#check if dev/sdb is already formatted
if [ -e /dev/sdb ]; then
    echo "sdb already formatted"
else
    echo "formatting sdb"
    mkfs.ext4 /dev/sdb
fi

#create /data mount point if it doesn't exist
if [ -d /data ]; then
    echo "/data already exists"
else
    echo "creating /data"
    mkdir /data
fi

#check if dev/sdb is already mounted
if grep -qs '/dev/sdb' /proc/mounts; then
    echo "sdb already mounted"
else
    echo "mounting sdb"
    mount /dev/sdb /data
fi