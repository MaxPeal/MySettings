# MySettings


## Support

Only for Debian10(buster)

## for Debian
  1. add shortcut for open terminal. For this open settings->keyboard and
     add 'x-terminal-emulator' with shortcut `ctrl-alt-t`
  2. uncomment string in .bashrc 'force_color_prompt=yes'
  3. add /usr/sbin and /usr/local/sbin to you PATH (in .bashrc)
  4. set caps_lock as additional ctrl. For this add string
     'XKBOPTIONS="ctrl:nocaps"' in /etc/default/keyboard and run command
      - `udevadm trigger --subsystem-match=input --action=change`
  5. add current user to sudo group
      - `su root`
      - `adduser levkovitch sudo`
  6. install bash-completion (optional)
  7. add `xfce4-panel` to autoload (optional)


### Boot problems

If you have problem with load debian on you computer, then you need push `e`
while in grub and change `quet` to `nomodeset`. After it you need install 
needed firmware. For this you need add `contrib` and `non-free`, after you
need run `sudo dmesg` for check which firmware is missing.
Usually enough only:
  - `apt-get install firmware-linux-nonfree`


Also you have to check firmware by:
  - `sudo dmesg`


If after installation all needed packages you get "passible missing firmware",
then you can install it manually from linux-frimware repo:
  - `git://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git`


### Release
If you have testing buster, then you need manually change repositories. In
security you have to set `testing-security` insted `buster/security`, and change
buster to stable.


### Time

For reconfigure time you need:
  - dpkg-reconfigure tzdata


## Virtualbox Notes

For virtualbox you can install extension and guest addition:
	- download extension and guest addition on `download.virtualbox.org/virtualbox/`
  - execute `sudo adduser $USER vboxusers`


On guest machine:
  - install `build-essential` and `linux-headers-...`
	- install guest addition
	- execute `sudo usermod -aG vboxsf $USER`


Your shared folders will be in media folder

### Network

If you choise two network adapters in you guest mashine, you have to manually
configure second network interface. For example, if you set second adapter as
bridge, then you must add next lines in your `/etc/network/interfaces` file:

  - `allow-hotplug enp0s8`
  - `iface enp0s8 inet dhcp`


And start command: `sudo ifup enp0s8`.

## Raspberry Pi3

1. for connect lcd ttf display:
  - `git clone https://github.com/goodtft/LCD-show.git`
  - `chmod -R 755 LCD-show`
  - `cd LCD-show/`
  - `sudo ./LCD35-show`
  - (optional) add in /boot/config.txt at end:
    - `fbcon=map:1`


2. for connect to hdmi back:
  - `sudo ./LCD-hdmi`

## Create bootable usb stick

as root:
```sh
umount /dev/sdb1
cat image.iso > /dev/sdb; sync
```


## Add gpu to kvm (Intel, Nvidia)

NOTE: you can not use the `GPU` on you host, so switch to `internal GPU` and
remove all drivers for `GPU`. Also you have to switch on `VT-d`

  - Install `kvm` (see `install_virt.sh`)
  - Add nouveau to blacklist (`/etc/modprobe.d/blacklist-nouveau.conf`):
      ```bash
      blacklist nouveau
      options nouveau modeset=0
      ```

  - Edit grub (`/etc/default/grub`):
      ```bash
      GRUB_CMDLINE_LINUX_DEFAULT="quiet splash intel_iommu=on"
      ```

  - Update grup:
      ```bash
      sudo update-grub
      ```

  - Get GPU PCI ID's:
      ```bash
      lspci -nn | grep -i nvidia
      ```

  - Write it to `/etc/modprobe.d/vfio.conf` like:
      ```bash
      options vfio-pci ids=$1,$2,...
      ```

  - Update initramfs:
      ```bash
      sudo update-initramfs -u
      ```

  - Reboot

  - For check you can use commands:
      ```bash
      dmesg | grep -E "DMAR|IOMMU"
      dmesg | grep -i vfio
      ```

NOTE: before installing image you have to add pci devices of the `GPU`
