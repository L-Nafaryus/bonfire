# astora

## Specs

| Type | Description |
|---|---|
| Case | MSI MPG Sekira 100R |
| Motherboard | MSI MEG X570 Unify |
| CPU | AMD Ryzen 9 3900X, 12-core, 24-thread |
| Cooler | MSI MAG Coreliquid 240R V2 |
| RAM | Kingston Fury Renegade, 2x16GB |
| Power supply | DeepCool PQ1000M, 1000W |
| GPU | MSI GeForce RTX 3060 Ventus 2X, 12GB |
| NVMe M.2 | Samsung 980, 250GB |
| SSD | Samsung 860 EVO, 500GB |
| HDD | Seagate SkyHawk, 8TB |

## Disk management

* Samsung 980

```bash
parted /dev/nvme0n1 -- mktable gpt
parted /dev/nvme0n1 -- mkpart primary fat32 0% 4GB
parted /dev/nvme0n1 -- set 1 boot on
parted /dev/nvme0n1 -- set 1 no_automount on
parted /dev/nvme0n1 -- mkpart primary btrfs 4GB 100%

mkfs.fat -F 32 /dev/nvme0n1p1
fatlabel /dev/nvme0n1p1 boot 
mkfs.btrfs /dev/nvme0n1p2 
btrfs filesystem label /dev/nvme0n1p2 nixos

mkdir -p /mnt 
mount /dev/nvme0n1p2 /mnt 
btrfs subvolume create /mnt/root
btrfs subvolume create /mnt/nix 
btrfs subvolume create /mnt/home
btrfs subvolume create /mnt/swap
umount /mnt 

mount -o compress=zstd,subvol=root /dev/nvme0n1p2 /mnt 
mkdir /mnt/{boot,nix,home,swap}
mount /dev/nvme0n1p1 /mnt/boot
mount -o compress=zstd,noatime,subvol=nix /dev/nvme0n1p2 /mnt/nix 
mount -o compress=zstd,subvol=home /dev/nvme0n1p2 /mnt/home
mount -o noatime,subvol=swap /dev/nvme0n1p2 /mnt/swap
btrfs filesystem mkswapfile --size 16g --uuid clear /mnt/swap/swapfile
# umount /mnt
```

* Samsung 860

```bash
parted /dev/sda -- mktable gpt
parted /dev/sda -- mkpart primary btrfs 0% 100%

mkfs.btrfs /dev/sda1 
btrfs filesystem label /dev/sda1 nixos

mkdir -p /mnt 
mount /dev/sda1 /mnt 
btrfs subvolume create /mnt/steam-library
btrfs subvolume create /mnt/lutris
umount /mnt 

mount -o compress=zstd,subvol=root /dev/sda1 /media 
mkdir /media/{steam-library,lutris}
mount -o compress=zstd,subvol=steam-library /dev/sda1 /media/steam-library
mount -o compress=zstd,subvol=lutris /dev/sda1 /media/lutris
# umount /media
```
