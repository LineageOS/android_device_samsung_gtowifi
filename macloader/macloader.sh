#!/vendor/bin/sh
#
# Copyright (C) 2024 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

if [ -f "/efs/wifi/.mac.info" ]; then
    mac_address=`cat /efs/wifi/.mac.info`
elif [ -f "/mnt/vendor/efs/wifi/.mac.info" ]; then
    mac_address=`cat /mnt/vendor/efs/wifi/.mac.info`
else
    exit 1
fi

sysfs_macaddr_path="/sys/devices/platform/soc/a000000.qcom,wcnss-wlan/wcnss_mac_addr"

echo $mac_address > $sysfs_macaddr_path
