/*
    Copyright (C) 2024 The LineageOS Project

    SPDX-License-Identifier: Apache-2.0
*/

#include <ctype.h>
#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <sys/stat.h>

#include <log/log.h>

#define LOG_TAG "macloader"

// Actually, this is supposed to be in /efs, but we want to avoid
// BOARD_ROOT_EXTRA_SYMLINKS
#define EFS_MAC_INFO_FILE "/mnt/vendor/sec_efs/wifi/.mac.info"
// This one is in the expected place, though
#define DEFAULT_EFS_MAC_INFO_FILE "/mnt/vendor/efs/wifi/.mac.info"

#define WCNSS_CTRL "/dev/wcnss_ctrl"
#define WCNSS_CMD_SET_MAC_ADDRESS 0x3

void WCNSS_SetMacAddress(uint8_t * macAddr)
{
	uint8_t wcnssCommand[128] = {};
	int fd;

    if (!macAddr) {
        ALOGE("macAddr is NULL");
        return;
    }

	fd = open(WCNSS_CTRL, O_WRONLY);
	if (fd < 0) {
		ALOGE("Failed to open %s : %s", WCNSS_CTRL, strerror(errno));
		return;
	}

    /*
        Command format :
        - Byte 0-1: command. This is a 16-bit number in big-endian
        - Remaining bytes: Parameters for given command, for a maximum of 126 bytes
    */
    wcnssCommand[0] = 0; // just set this to 0, our command doesn't exceed uint8_t
    wcnssCommand[1] = WCNSS_CMD_SET_MAC_ADDRESS;
    wcnssCommand[2] = macAddr[0];
    wcnssCommand[3] = macAddr[1];
    wcnssCommand[4] = macAddr[2];
    wcnssCommand[5] = macAddr[3];
    wcnssCommand[6] = macAddr[4];
    wcnssCommand[7] = macAddr[5];

    if (write(fd, wcnssCommand, 8) < 0) {
        ALOGE("Failed to write to %s : %s", WCNSS_CTRL,
                    strerror(errno));
    }

	close(fd);
	return;
}

int main(void) {
    FILE * efsMacInfoFile = NULL;
    char macAddr[18] = {};
    uint8_t formattedMacAddr[6] = {};

    if (efsMacInfoFile = fopen(EFS_MAC_INFO_FILE, "rb"), efsMacInfoFile == NULL) {
        // Fallback to normal EFS path
        ALOGE("Failed to open %s, trying default path", EFS_MAC_INFO_FILE);
        if (efsMacInfoFile = fopen(DEFAULT_EFS_MAC_INFO_FILE, "rb"), efsMacInfoFile == NULL) {
            ALOGE("Failed to open %s", DEFAULT_EFS_MAC_INFO_FILE);
            return -ENOENT;
        }
    }

    // Get the address
    fread(macAddr, 17, 1, efsMacInfoFile);
    fclose(efsMacInfoFile);

    // Sanity check all of the input
    // Observing the given files in EFS, the input appears to be one of the following:
    // - integer
    // - capital alphabet
    // - colon `:`
    for (int i = 0; i < sizeof(macAddr); i++) {
        if ((!isdigit(macAddr[i])) &&
           (macAddr[i] != ':') &&
           ((macAddr[i] > 'A') || (macAddr[i] < 'Z'))
           ) {
            ALOGE("Invalid MAC address!!!");
            return -EINVAL;
        }
    }

    // Change the provided string to a uint8_t array
    sscanf(macAddr, "%hhx:%hhx:%hhx:%hhx:%hhx:%hhx", &formattedMacAddr[0], &formattedMacAddr[1],
                                                     &formattedMacAddr[2], &formattedMacAddr[3],
                                                     &formattedMacAddr[4], &formattedMacAddr[5]);

    // Fire in the hole
    WCNSS_SetMacAddress(formattedMacAddr);

    return 0;
}
