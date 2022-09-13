#! /bin/sh
# Script to flash imagess via fastboot
#

# This script can only be run in LINUX OS! 
# NOT SUPPORT to flash imagess by fastboot IN MAC OS!!!

sudo ../../../fastboot flash uboot ../../../../../../images/light-fm-a/light_fastboot_image_single_rank_sec/u-boot-with-spl.bin
sudo ../../../fastboot flash tf ../../../../../../images/light-fm-a/tf.ext4
sudo ../../../fastboot flash tee ../../../../../../images/light-fm-a/tee.ext4
sudo ../../../fastboot flash boot ../../../../../../images/light-fm-a/boot.ext4
sudo ../../../fastboot flash root ../../../../../../images/light_fm-a/rootfs.yocto.ext4
