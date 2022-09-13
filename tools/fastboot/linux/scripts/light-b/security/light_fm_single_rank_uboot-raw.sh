#! /bin/sh
# Script to flash imagess via fastboot
#

# This script can only be run in LINUX OS! 
# NOT SUPPORT to flash imagess by fastboot IN MAC OS!!!

sudo ../../../fastboot flash ram ../../../../../../images/light-fm-b/light_fastboot_image_single_rank_sec/u-boot-imagewriter.bin
sudo ../../../fastboot reboot
sleep 10
sudo ../../../fastboot flash uboot ../../../../../../images/light-fm-b/light_fastboot_image_single_rank_sec/u-boot-with-spl.bin
