#get name of external drive
echo "Enter the name of the external drive"
read drive
#mount external drive
sudo mount /dev/$drive /media/$drive

#check if dev/sdb is already formatted
if [ -e /dev/sda ]; then
    echo "sdb already formatted"
else
    echo "formatting sdb"
    mkfs.ext4 /dev/sda
fi

#create /data mount point if it doesn't exist
if [ -d /data ]; then
    echo "/data already exists"
else
    echo "creating /data"
    mkdir /data
fi

#check if dev/sdb is already mounted
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