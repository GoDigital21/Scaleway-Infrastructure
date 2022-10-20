#check if dev/sdb is already formatted and if not formats it
blkid --match-token TYPE=ext4 /dev/sda || mkfs.ext4 /dev/sda

#create /data mount point if it doesn't exist
if [ -d /data ]; then
    echo "/data already exists"
else
    echo "creating /data"
    mkdir /data
fi

#check if dev/sda is already mounted
if grep -qs '/dev/sda' /proc/mounts; then
    echo "sdb already mounted"
else
    echo "mounting sda"
    mount /dev/sda /data
fi

#make sure that sda is mounted automatically
if grep -qs '/dev/sda' /etc/fstab; then
    echo "sda already in fstab"
else
    echo "adding sda to fstab"
    echo "/dev/sda /data ext4 defaults 0 0" >> /etc/fstab
fi

#create container directory if it doesn't exist
if [ -d /data/containers ]; then
    echo "/data/containers already exists"
else
    echo "creating /data/containers"
    mkdir /data/containers
fi