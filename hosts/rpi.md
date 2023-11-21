

# get pi to boot from usb-source
echo program_usb_boot_mode=1 | sudo tee -a /boot/config.txt
https://www.elektronik-kompendium.de/sites/raspberry-pi/2404241.htm

# setup
## set static ip (192.168.1.2)
used /etc/network/interfaces (seems to be debian only)


## enable ssh (touch ssh file in the boot partition)

## set root pwd (copy hash from local /etc/shadow)

CMD: apt update
CMD: apt install nodejs npm
CMD: npm i -g @bitwarden/cli

## set hostname

## setup bcache
- if "sudo make-bcache -C /dev/sda3 -B /dev/md0" then no need for registering (i think)
PKG: bcache-tools git build-essential uuid-dev mdadm
CMD: sudo make-bcache -C /dev/sda3
CMD: sudo mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/sdb /dev/sdc
CMD: sudo make-bcache -B /dev/md0

## other bcache things 
- you can echo 1 > /sys/fs/bcache/<UUID>/unregister
- but there also is: echo 1 > /sys/block/bcache0/bcache/stop
	- if seccond is not done, volumes used by this bcache device will show as "<dev> is apparently in use by the system; will not make a filesystem here!", when mkfs.ext5 <dev>

## mdadm things 
- do a check: https://www.thomas-krenn.com/de/wiki/Mdadm_checkarray

## add swap file maybe
CMD: sudo vim /etc/dphys-swapfile
CMD: sudo dphys-swapfile setup
CMD: sudo dphys-swapfile swapon

# things
- mdadm
- bcache
- mount /home/files/storage
    - so that other users can't read it

- podman containers

- me-net (wireguard)

- rclone mount onedrive backups
- borgmatic

## things done
- smb shares
- swap
- users
    admin - sudo without password and access to bitwarden
    files - for managing files (old: dateimanager)
    server - for deployed servers (podman)
    mamafiles - for the mamafiles share
- ssh acces
    - ssh config: PermitRootAccess and PasswordAuthentication
- dyndns
- wstunnel for wireguard




