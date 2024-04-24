# catarina

## Disk management

```sh 
mkfs.fat -F 32 /dev/sda1
fatlabel /dev/sda1 boot

mkfs.btrfs /dev/sda2 
btrfs filesystem label /dev/sda2 nixos

mkdir -p /mnt 
mount /dev/sda2 /mnt 
btrfs subvolume create /mnt/root
btrfs subvolume create /mnt/nix 
btrfs subvolume create /mnt/home
btrfs subvolume create /mnt/persist
btrfs subvolume create /mnt/swap
umount /mnt 

mount -o compress=zstd,subvol=root /dev/sda2 /mnt 
mkdir /mnt/{boot,nix,home,persist,swap}
mount /dev/sda1 /mnt/boot
mount -o compress=zstd,noatime,subvol=nix /dev/sda2 /mnt/nix 
mount -o compress=zstd,subvol=home /dev/sda2 /mnt/home
mount -o compress=zstd,subvol=persist /dev/sda2 /mnt/persist
mount -o noatime,subvol=swap /dev/sda2 /mnt/swap

btrfs filesystem mkswapfile --size 16g --uuid clear /mnt/swap/swapfile

mkdir -p /media/{storage,btrbk-backups,btrbk-snapshots}
```
