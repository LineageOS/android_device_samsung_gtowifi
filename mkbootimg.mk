#
# SPDX-FileCopyrightText: 2025 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

LOCAL_PATH := $(call my-dir)

## Boot Image Generation
$(INSTALLED_BOOTIMAGE_TARGET): $(MKBOOTIMG) $(AVBTOOL) $(INTERNAL_BOOTIMAGE_FILES) $(BOARD_AVB_BOOT_KEY_PATH) $(BOOTIMAGE_EXTRA_DEPS)
	$(call pretty,"Target boot image: $@")
	$(eval kernel := $(call bootimage-to-kernel,$@))
	$(MKBOOTIMG) --kernel $(kernel) $(INTERNAL_BOOTIMAGE_ARGS) $(INTERNAL_MKBOOTIMG_VERSION_ARGS) $(BOARD_MKBOOTIMG_ARGS) --output $@
# SAMSUNG GTO CHANGES START
# Add SEAndroid Enforcing to avoid bootloader warnings
	$(hide) echo -n "SEANDROIDENFORCE" >> $@
# Add fake SignerVer02 struct. Struct of 512 bytes with only the magic numbers added
	$(hide) echo -ne "SignerVer02\x00\x00\x00\x00\x00" >> $@
	$(hide) truncate -s +496 $@
# SAMSUNG GTO CHANGES END
	$(call assert-max-image-size,$@,$(call get-hash-image-max-size,$(call get-bootimage-partition-size,$@,boot)))
	$(AVBTOOL) add_hash_footer \
			--image $@ \
			$(call get-partition-size-argument,$(call get-bootimage-partition-size,$@,boot)) \
			--salt `sha256sum "$(kernel)" | cut -d " " -f 1` \
			--partition_name boot $(INTERNAL_AVB_BOOT_SIGNING_ARGS) \
			$(BOARD_AVB_BOOT_ADD_HASH_FOOTER_ARGS)

## Recovery image generation
$(INSTALLED_RECOVERYIMAGE_TARGET): $(recoveryimage-deps) $(RECOVERYIMAGE_EXTRA_DEPS)
	$(MKBOOTIMG) --kernel $(strip $(recovery_kernel)) $(INTERNAL_RECOVERYIMAGE_ARGS) \
                 $(INTERNAL_MKBOOTIMG_VERSION_ARGS) \
                 $(BOARD_RECOVERY_MKBOOTIMG_ARGS) --output $@
# SAMSUNG GTO CHANGES START
# Add SEAndroid Enforcing to avoid bootloader warnings
	$(hide) echo -n "SEANDROIDENFORCE" >> $@
# Add fake SignerVer02 struct. Struct of 512 bytes with only the magic numbers added
	$(hide) echo -ne "SignerVer02\x00\x00\x00\x00\x00" >> $@
	$(hide) truncate -s +496 $@
# SAMSUNG GTO CHANGES END
	$(call assert-max-image-size,$@,$(call get-hash-image-max-size,$(BOARD_RECOVERYIMAGE_PARTITION_SIZE)))
	$(AVBTOOL) add_hash_footer --image $@ $(call get-partition-size-argument,$(BOARD_RECOVERYIMAGE_PARTITION_SIZE)) --partition_name recovery $(INTERNAL_AVB_RECOVERY_SIGNING_ARGS) $(BOARD_AVB_RECOVERY_ADD_HASH_FOOTER_ARGS)
