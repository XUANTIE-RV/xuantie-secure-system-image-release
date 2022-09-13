#! /bin/sh
# Script to flash imagess via fastboot
#

# This script can only be run in LINUX OS! 
# NOT SUPPORT to flash imagess by fastboot IN MAC OS!!!

sudo ../../../fastboot flash ram ../../../../../../images/light-fm-b/light_fastboot_image_single_rank_sec/u-boot-imagewriter.bin
sudo ../../../fastboot reboot
sleep 10
sudo ../../../fastboot flash uboot ../../../../../../images/light-fm-b/light_fastboot_image_single_rank_sec/u-boot-with-spl.bin
sudo ../../../fastboot flash tf ../../../../../../images/light-fm-b/tf.ext4
sudo ../../../fastboot flash tee ../../../../../../images/light-fm-b/tee.ext4
sudo ../../../fastboot flash boot ../../../../../../images/light-fm-b/boot.ext4
sudo ../../../fastboot flash root ../../../../../../images/light_fm-b/rootfs.yocto.ext4
