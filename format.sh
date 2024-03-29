#check if dev/sdb is already formatted and if not formats it
#blkid --match-token TYPE=ext4 /dev/sdb || mkfs.ext4 /dev/sdb


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

#make sure that sdb is mounted automatically
if grep -qs '/dev/sdb' /etc/fstab; then
    echo "sdb already in fstab"
else
    echo "adding sdb to fstab"
    echo "/dev/sdb /data ext4 defaults 0 0" >> /etc/fstab
fi

#create container directory if it doesn't exist
if [ -d /data/containers ]; then
    echo "/data/containers already exists"
else
    echo "creating /data/containers"
    mkdir /data/containers
fi